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
