/*
 *  RL78 instruction helpers.
 *
 *  Copyright (c) 2026 Soya Ohnishi
 */
#include "cpu.h"
#include "decode.h"
#include "helper.h"
#include "softmmu_exec.h"

void *tlib_guest_offset_to_host_ptr(uint64_t offset);

static uint32_t rl78_reg_hl(CPUState *env)
{
    const uint32_t bank = env->psw.rbs & 3;
    const uint32_t l = env->regs[bank][RL78_BYTE_REG_L] & 0xFF;
    const uint32_t h = env->regs[bank][RL78_BYTE_REG_H] & 0xFF;

    return l | (h << 8);
}

static uint32_t rl78_read_byte(CPUState *env, uint32_t paddr)
{
    switch(paddr) {
        case 0xFFFF8:
            return env->sp & 0xFF;
        case 0xFFFF9:
            return (env->sp >> 8) & 0xFF;
        case 0xFFFFA:
            return rl78_cpu_pack_psw(env->psw);
        case 0xFFFFC:
            return env->cs & 0x0F;
        case 0xFFFFD:
            return env->es & 0x0F;
        default: {
            void *host = tlib_guest_offset_to_host_ptr(paddr);
            if(host) {
                return *(const uint8_t *)host;
            }
            return ldub_phys(paddr);
        }
    }
}

static void rl78_write_byte(CPUState *env, uint32_t paddr, uint32_t data)
{
    data &= 0xFF;
    switch(paddr) {
        case 0xFFFF8:
            env->sp = (env->sp & 0xFF00) | data;
            env->sp &= 0xFFFE;
            break;
        case 0xFFFF9:
            env->sp = (env->sp & 0x00FF) | (data << 8);
            env->sp &= 0xFFFE;
            break;
        case 0xFFFFA:
            env->psw = rl78_cpu_unpack_psw((uint8_t)data);
            break;
        case 0xFFFFC:
            env->cs = data & 0x0F;
            break;
        case 0xFFFFD:
            env->es = data & 0x0F;
            break;
        default: {
            void *host = tlib_guest_offset_to_host_ptr(paddr);
            if(host) {
                *(uint8_t *)host = (uint8_t)data;
            } else {
                stb_phys(paddr, data);
            }
            break;
        }
    }
}

uint32_t helper_rl78_btclr_paddr(CPUState *env, uint32_t paddr, uint32_t bit)
{
    const uint32_t mask = 1u << (bit & 7);
    uint32_t byte = rl78_read_byte(env, paddr);

    if(!(byte & mask)) {
        return 0;
    }
    rl78_write_byte(env, paddr, byte & ~mask);
    return 1;
}

uint32_t helper_rl78_btclr(CPUState *env, uint32_t kind, uint32_t addr, uint32_t bit, uint32_t use_es)
{
    uint32_t paddr;

    switch((RL78BitOpKind)kind) {
        case RL78_BITOP_CY:
            if(!(env->psw.cy & 1)) {
                return 0;
            }
            env->psw.cy = 0;
            return 1;

        case RL78_BITOP_REG_A: {
            const uint32_t mask = 1u << (bit & 7);
            uint32_t *areg = &env->regs[env->psw.rbs & 3][RL78_BYTE_REG_A];
            uint32_t byte = *areg & 0xFF;

            if(!(byte & mask)) {
                return 0;
            }
            *areg = byte & ~mask;
            return 1;
        }

        case RL78_BITOP_SADDR:
            paddr = (addr < 0x20 ? 0xFFF00u : 0xFFE00u) + (addr & 0xFF);
            return helper_rl78_btclr_paddr(env, paddr, bit);

        case RL78_BITOP_SFR:
            paddr = 0xFFF00u + (addr & 0xFF);
            return helper_rl78_btclr_paddr(env, paddr, bit);

        case RL78_BITOP_ABS16:
            paddr = use_es ? (((env->es & 0x0F) << 16) | (addr & 0xFFFF))
                           : ((addr & 0xFFFF) | 0xF0000u);
            return helper_rl78_btclr_paddr(env, paddr, bit);

        case RL78_BITOP_IND_HL: {
            const uint32_t hl = rl78_reg_hl(env);

            paddr = use_es ? (((env->es & 0x0F) << 16) | hl) : (hl | 0xF0000u);
            return helper_rl78_btclr_paddr(env, paddr, bit);
        }

        default:
            return 0;
    }
}

void helper_rl78_stb(CPUState *env, uint32_t paddr, uint32_t data)
{
    (void)env;
    void *host = tlib_guest_offset_to_host_ptr(paddr);
    if(host) {
        *(uint8_t *)host = (uint8_t)(data & 0xFF);
    } else {
        stb_phys(paddr, data);
    }
}

/* Multiply / divide / MAC unit — commanded by writes to 0xFFFFB. */
#define RL78_MDU_MULHU 0x01
#define RL78_MDU_MULH  0x02
#define RL78_MDU_DIVHU 0x03
#define RL78_MDU_MACHU 0x05
#define RL78_MDU_MACH  0x06
#define RL78_MDU_DIVWU 0x0B

#define RL78_MACRL_PADDR 0xFFFF0u
#define RL78_MACRH_PADDR 0xFFFF2u

static uint32_t rl78_get_rp(CPUState *env, RL78WordRegister rp)
{
    const uint32_t bank = env->psw.rbs & 3;
    const uint32_t lo = env->regs[bank][rp * 2] & 0xFF;
    const uint32_t hi = env->regs[bank][rp * 2 + 1] & 0xFF;

    return lo | (hi << 8);
}

static void rl78_set_rp(CPUState *env, RL78WordRegister rp, uint32_t value)
{
    const uint32_t bank = env->psw.rbs & 3;

    env->regs[bank][rp * 2] = value & 0xFF;
    env->regs[bank][rp * 2 + 1] = (value >> 8) & 0xFF;
}

static uint32_t rl78_read_u16(CPUState *env, uint32_t paddr)
{
    return rl78_read_byte(env, paddr) | (rl78_read_byte(env, paddr + 1) << 8);
}

static void rl78_write_u16(CPUState *env, uint32_t paddr, uint32_t value)
{
    rl78_write_byte(env, paddr, value & 0xFF);
    rl78_write_byte(env, paddr + 1, (value >> 8) & 0xFF);
}

static uint32_t rl78_load_macr(CPUState *env)
{
    const uint32_t lo = rl78_read_u16(env, RL78_MACRL_PADDR);
    const uint32_t hi = rl78_read_u16(env, RL78_MACRH_PADDR);

    return lo | (hi << 16);
}

static void rl78_store_macr(CPUState *env, uint32_t macr)
{
    rl78_write_u16(env, RL78_MACRL_PADDR, macr & 0xFFFF);
    rl78_write_u16(env, RL78_MACRH_PADDR, (macr >> 16) & 0xFFFF);
}

void helper_rl78_mdu_cmd(CPUState *env, uint32_t cmd)
{
    switch(cmd & 0xFF) {
        case RL78_MDU_MULHU: {
            const uint32_t ax = rl78_get_rp(env, RL78_WORD_REG_AX);
            const uint32_t bc = rl78_get_rp(env, RL78_WORD_REG_BC);
            const uint32_t product = ax * bc;

            rl78_set_rp(env, RL78_WORD_REG_AX, product & 0xFFFF);
            rl78_set_rp(env, RL78_WORD_REG_BC, (product >> 16) & 0xFFFF);
            break;
        }
        case RL78_MDU_MULH: {
            const int32_t ax = (int16_t)rl78_get_rp(env, RL78_WORD_REG_AX);
            const int32_t bc = (int16_t)rl78_get_rp(env, RL78_WORD_REG_BC);
            const uint32_t product = (uint32_t)(ax * bc);

            rl78_set_rp(env, RL78_WORD_REG_AX, product & 0xFFFF);
            rl78_set_rp(env, RL78_WORD_REG_BC, (product >> 16) & 0xFFFF);
            break;
        }
        case RL78_MDU_DIVHU: {
            const uint32_t ax = rl78_get_rp(env, RL78_WORD_REG_AX);
            const uint32_t de = rl78_get_rp(env, RL78_WORD_REG_DE);

            if(de == 0) {
                rl78_set_rp(env, RL78_WORD_REG_AX, 0xFFFF);
                rl78_set_rp(env, RL78_WORD_REG_DE, ax);
            } else {
                rl78_set_rp(env, RL78_WORD_REG_AX, ax / de);
                rl78_set_rp(env, RL78_WORD_REG_DE, ax % de);
            }
            break;
        }
        case RL78_MDU_DIVWU: {
            const uint32_t ax = rl78_get_rp(env, RL78_WORD_REG_AX);
            const uint32_t bc = rl78_get_rp(env, RL78_WORD_REG_BC);
            const uint32_t de = rl78_get_rp(env, RL78_WORD_REG_DE);
            const uint32_t hl = rl78_get_rp(env, RL78_WORD_REG_HL);
            const uint32_t dividend = ax | (bc << 16);
            const uint32_t divisor = de | (hl << 16);

            if(divisor == 0) {
                rl78_set_rp(env, RL78_WORD_REG_AX, 0xFFFF);
                rl78_set_rp(env, RL78_WORD_REG_BC, 0xFFFF);
                rl78_set_rp(env, RL78_WORD_REG_DE, ax);
                rl78_set_rp(env, RL78_WORD_REG_HL, bc);
            } else {
                const uint32_t quot = dividend / divisor;
                const uint32_t rem = dividend % divisor;

                rl78_set_rp(env, RL78_WORD_REG_AX, quot & 0xFFFF);
                rl78_set_rp(env, RL78_WORD_REG_BC, (quot >> 16) & 0xFFFF);
                rl78_set_rp(env, RL78_WORD_REG_DE, rem & 0xFFFF);
                rl78_set_rp(env, RL78_WORD_REG_HL, (rem >> 16) & 0xFFFF);
            }
            break;
        }
        case RL78_MDU_MACHU: {
            const uint32_t ax = rl78_get_rp(env, RL78_WORD_REG_AX);
            const uint32_t bc = rl78_get_rp(env, RL78_WORD_REG_BC);
            const uint32_t macr = rl78_load_macr(env);
            const uint64_t product = (uint64_t)ax * (uint64_t)bc;
            const uint64_t sum = (uint64_t)macr + product;

            rl78_store_macr(env, (uint32_t)sum);
            env->psw.cy = (sum > 0xFFFFFFFFull) ? 1 : 0;
            env->psw.ac = 0;
            env->psw.z = 0;
            break;
        }
        case RL78_MDU_MACH: {
            const int32_t ax = (int16_t)rl78_get_rp(env, RL78_WORD_REG_AX);
            const int32_t bc = (int16_t)rl78_get_rp(env, RL78_WORD_REG_BC);
            const int32_t macr = (int32_t)rl78_load_macr(env);
            const int32_t product = ax * bc;
            const int32_t result = macr + product;
            const uint32_t ov =
                (((uint32_t)macr ^ (uint32_t)result) & ((uint32_t)product ^ (uint32_t)result)) >> 31;

            rl78_store_macr(env, (uint32_t)result);
            env->psw.cy = ov & 1;
            env->psw.ac = ((uint32_t)result >> 31) & 1;
            env->psw.z = 0;
            break;
        }
        default:
            break;
    }
}
