/*
 *  RL78 translation
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * Ported from qemu/target/rl78/translate.c (Soya-Onishi/qemu develop/rl78).
 */
#include "cpu.h"
#include "decode.h"
#include "tcg-op.h"
#include "tcg-memop.h"

typedef TCGMemOp MemOp;

/* General purpose registers, indexed by [bank][byte-register]. */
static TCGv_i32 cpu_regs[REGISTER_BANK_NUM][RL78_BYTE_REG_NUM];

static TCGv_i32 cpu_psw_cy;
static TCGv_i32 cpu_psw_isp;
static TCGv_i32 cpu_psw_rbs;
static TCGv_i32 cpu_psw_ac;
static TCGv_i32 cpu_psw_z;
static TCGv_i32 cpu_psw_ie;

static TCGv_i32 cpu_pc;
static TCGv_i32 cpu_sp;
static TCGv_i32 cpu_es;
static TCGv_i32 cpu_cs;

static TCGv_i32 cpu_skip_en;
static TCGv_i32 cpu_skip_req;

#include "tb-helper.h"

void translate_init(void)
{
    static const char *const regnames[RL78_BYTE_REG_NUM] = { "X", "A", "C", "B", "E", "D", "L", "H" };

    for(int bank = 0; bank < REGISTER_BANK_NUM; bank++) {
        for(int r = 0; r < RL78_BYTE_REG_NUM; r++) {
            cpu_regs[bank][r] = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, regs[bank][r]), regnames[r]);
        }
    }

    cpu_psw_cy = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.cy), "psw.cy");
    cpu_psw_isp = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.isp), "psw.isp");
    cpu_psw_rbs = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.rbs), "psw.rbs");
    cpu_psw_ac = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.ac), "psw.ac");
    cpu_psw_z = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.z), "psw.z");
    cpu_psw_ie = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.ie), "psw.ie");

    cpu_pc = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, pc), "pc");
    cpu_sp = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, sp), "sp");
    cpu_es = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, es), "es");
    cpu_cs = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, cs), "cs");

    cpu_skip_en = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, skip_en), "skip_en");
    cpu_skip_req = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, skip_req), "skip_req");
}

void gen_sync_pc(DisasContext *dc)
{
    tcg_gen_movi_i32(cpu_pc, dc->base.pc);
}

static TCGv_i32 rl78_gen_addr(DisasContext *ctx, TCGv_i32 addr)
{
    TCGv_i32 ret = tcg_temp_new_i32();
    TCGv_i32 es  = tcg_temp_new_i32();

    if (ctx->use_es) {
        tcg_gen_shli_i32(es, cpu_es, 16);
    } else {
        tcg_gen_movi_i32(es, 0xF0000);
    }

    tcg_gen_mov_i32(ret, addr);
    tcg_gen_or_i32(ret, ret, es);

    return ret;
}

static TCGv_i32 rl78_gen_load(DisasContext *ctx, TCGv_i32 addr, TCGMemOp memop)
{
    TCGv_i32 actual_addr = tcg_temp_new_i32();
    TCGv_i32 ret = tcg_temp_new_i32();

    tcg_gen_mov_i32(actual_addr, addr);
    if(memop == MO_16) {
        tcg_gen_andi_i32(actual_addr, actual_addr, ~0x01);
    }

    tcg_gen_qemu_ld_i32(ret, actual_addr, 0, memop);

    return ret;
}

static void rl78_gen_store(DisasContext *ctx, TCGv_i32 addr, TCGv_i32 data,
                           TCGMemOp memop)
{
    TCGv_i32 actual_addr = tcg_temp_new_i32();

    tcg_gen_mov_i32(actual_addr, addr);
    if(memop == MO_16) {
        tcg_gen_andi_i32(actual_addr, actual_addr, ~0x01);
    }

    tcg_gen_qemu_st_i32(data, actual_addr, 0, memop);
}

static TCGv_i32 rl78_gen_lb(DisasContext *ctx, TCGv_i32 addr)
{
    return rl78_gen_load(ctx, addr, MO_8);
}

static TCGv_i32 rl78_gen_lw(DisasContext *ctx, TCGv_i32 addr)
{
    TCGv_i32 access_addr = tcg_temp_new_i32();

    tcg_gen_andi_i32(access_addr, addr, ~0x01);

    return rl78_gen_load(ctx, access_addr, MO_16);
}

static void rl78_gen_sb(DisasContext *ctx, TCGv_i32 addr, TCGv_i32 data)
{
    rl78_gen_store(ctx, addr, data, MO_8);
}

static void rl78_gen_sw(DisasContext *ctx, TCGv_i32 addr, TCGv_i32 data)
{
    TCGv_i32 access_addr = tcg_temp_new_i32();

    tcg_gen_andi_i32(access_addr, addr, ~0x01);

    rl78_gen_store(ctx, access_addr, data, MO_16);
}

static TCGv_ptr reg_ptr(const uint reg) 
{
    const uint regoffset = (uint)reg * sizeof(uint32_t);

    TCGv_ptr reg_ptr_base = tcg_temp_new_ptr();
    TCGv_ptr reg_ptr_offset = tcg_temp_new_ptr();
    TCGv_i32 reg_offset = tcg_temp_new_i32();

    tcg_gen_shli_i32(reg_offset, cpu_psw_rbs, 5);
    tcg_gen_addi_i32(reg_offset, reg_offset, regoffset);
    tcg_gen_ext_i32_ptr(reg_ptr_offset, reg_offset);

    tcg_gen_mov_i32(TCGV_PTR_TO_NAT(reg_ptr_base), TCGV_PTR_TO_NAT(cpu_env));
    tcg_gen_addi_ptr(reg_ptr_base, reg_ptr_base, offsetof(CPUState, regs));
    tcg_gen_add_ptr(reg_ptr_base, reg_ptr_base, reg_ptr_offset);

    return reg_ptr_base;
}

static TCGv_i32 load_byte_reg(const RL78ByteRegister reg)
{
    TCGv_ptr regptr = reg_ptr((uint)reg);
    TCGv_i32 ret = tcg_temp_new_i32();

    tcg_gen_ld_i32(ret, regptr, 0);
    tcg_gen_andi_i32(ret, ret, 0xFF);

    return ret;
}

static TCGv_i32 load_word_reg(const RL78WordRegister reg)
{
    TCGv_ptr regptr = reg_ptr((uint)reg*2);
    TCGv_i32 ret_lo = tcg_temp_new_i32();
    TCGv_i32 ret_hi = tcg_temp_new_i32();

    tcg_gen_ld_i32(ret_lo, regptr, 0);
    tcg_gen_ld_i32(ret_hi, regptr, 4);

    tcg_gen_shli_i32(ret_hi, ret_hi, 8);
    tcg_gen_andi_i32(ret_lo, ret_lo, 0xFF);
    tcg_gen_or_i32(ret_lo, ret_lo, ret_hi);

    return ret_lo;
}

static void store_byte_reg(const RL78ByteRegister reg, TCGv_i32 data)
{
    TCGv_ptr regptr = reg_ptr((uint)reg);
    TCGv_i32 store_data = tcg_temp_new_i32();

    tcg_gen_andi_i32(store_data, data, 0xFF);
    tcg_gen_st_i32(store_data, regptr, 0);
}

static void store_word_reg(const RL78WordRegister reg, TCGv_i32 data)
{
    TCGv_ptr regptr = reg_ptr((uint)reg*2);
    TCGv_i32 store_data = tcg_temp_new_i32();

    tcg_gen_andi_i32(store_data, data, 0xFF);
    tcg_gen_st_i32(store_data, regptr, 0);

    tcg_gen_shri_i32(store_data, data, 8);
    tcg_gen_andi_i32(store_data, store_data, 0xFF);
    tcg_gen_st_i32(store_data, regptr, 4);
}

static TCGv_i32 load_psw(void)
{
    TCGv_i32 ret  = tcg_temp_new_i32();
    TCGv_i32 rbs0 = tcg_temp_new_i32();
    TCGv_i32 rbs1 = tcg_temp_new_i32();

    tcg_gen_extract_i32(rbs0, cpu_psw_rbs, 0, 1);
    tcg_gen_extract_i32(rbs1, cpu_psw_rbs, 1, 1);

    tcg_gen_mov_i32(ret, cpu_psw_cy);
    tcg_gen_deposit_i32(ret, ret, cpu_psw_isp, 1, 2);
    tcg_gen_deposit_i32(ret, ret, rbs0, 3, 1);
    tcg_gen_deposit_i32(ret, ret, cpu_psw_ac, 4, 1);
    tcg_gen_deposit_i32(ret, ret, rbs1, 5, 1);
    tcg_gen_deposit_i32(ret, ret, cpu_psw_z, 6, 1);
    tcg_gen_deposit_i32(ret, ret, cpu_psw_ie, 7, 1);

    return ret;
}

static void store_psw(DisasContext *ctx, TCGv_i32 psw)
{
    TCGv_i32 rbs0 = tcg_temp_new_i32();
    TCGv_i32 rbs1 = tcg_temp_new_i32();

    tcg_gen_extract_i32(cpu_psw_cy, psw, 0, 1);
    tcg_gen_extract_i32(cpu_psw_isp, psw, 1, 2);
    tcg_gen_extract_i32(cpu_psw_ac, psw, 4, 1);
    tcg_gen_extract_i32(cpu_psw_z, psw, 6, 1);
    tcg_gen_extract_i32(cpu_psw_ie, psw, 7, 1);

    tcg_gen_movi_i32(cpu_psw_rbs, 0);
    tcg_gen_extract_i32(rbs0, psw, 3, 1);
    tcg_gen_extract_i32(rbs1, psw, 5, 1);
    tcg_gen_deposit_i32(cpu_psw_rbs, cpu_psw_rbs, rbs0, 0, 1);
    tcg_gen_deposit_i32(cpu_psw_rbs, cpu_psw_rbs, rbs1, 1, 1);

    ctx->base.is_jmp = DISAS_UPDATE;
}

static TCGv_i32 load_sp(void)
{
    TCGv_i32 ret = tcg_temp_new_i32();

    tcg_gen_mov_i32(ret, cpu_sp);
    tcg_gen_andi_i32(ret, ret, 0xFFFE);

    return ret;
}

static void store_sp(TCGv_i32 sp)
{
    TCGv_i32 tmp = tcg_temp_new_i32();

    tcg_gen_andi_i32(tmp, sp, 0xFFFE);
    tcg_gen_mov_i32(cpu_sp, tmp);
}

static TCGv_i32 load_byte_paddr(DisasContext *ctx, const uint32_t paddr, const TCGMemOp memop)
{
    switch(paddr) {
        case 0xFFFF8: {
            TCGv_i32 ret = tcg_temp_new_i32();
            tcg_gen_extract_i32(ret, load_sp(), 0, 8);
            return ret;
        }
        case 0xFFFF9: {
            TCGv_i32 ret = tcg_temp_new_i32();
            tcg_gen_extract_i32(ret, load_sp(), 8, 8);
            return ret;
        }
        case 0xFFFFA:
            return load_psw();
        case 0xFFFFC: {
            TCGv_i32 ret = tcg_temp_new_i32();
            tcg_gen_mov_i32(ret, cpu_cs);
            return ret;
        }
        case 0xFFFFD: {
            TCGv_i32 ret = tcg_temp_new_i32();
            tcg_gen_mov_i32(ret, cpu_es);
            return ret;
        }            
        default:
            return rl78_gen_load(ctx, tcg_const_i32(paddr), memop);
    }
}

static TCGv_i32 load_word_paddr(DisasContext *ctx, const uint32_t paddr, const TCGMemOp memop)
{
    // TODO: check actual MCU implementation
    switch(paddr) {
        case 0xFFFF8:
            return load_sp();
        default:
            return rl78_gen_load(ctx, tcg_const_i32(paddr), memop);
    }
}

static TCGv_i32 load_paddr(DisasContext *ctx, const uint32_t paddr, const TCGMemOp memop)
{
    switch((memop & MO_SIZE)) {
        case MO_8:
            return load_byte_paddr(ctx, paddr, memop);
        case MO_16:
            return load_word_paddr(ctx, paddr, memop);
        default:
            g_assert_not_reached();
    } 
}

static TCGv_i32 load_abs16(DisasContext *ctx, const uint32_t addr,
                           const TCGMemOp memop)
{
    if(ctx->use_es) {
        TCGv_i32 a = rl78_gen_addr(ctx, tcg_const_i32(addr));
        return rl78_gen_load(ctx, a, memop);
    } else {
        const uint32_t paddr = addr | 0xF0000;
        return load_paddr(ctx, paddr, memop);
    }
}

static void store_byte_paddr(DisasContext *ctx, const uint32_t paddr, TCGv_i32 data, const TCGMemOp memop) 
{
    switch(paddr) {
        case 0xFFFF8: {
            TCGv_i32 spl = tcg_temp_new_i32();
            TCGv_i32 sp = tcg_temp_new_i32();

            tcg_gen_extract_i32(spl, data, 0, 8);
            tcg_gen_deposit_i32(sp, cpu_sp, spl, 0, 8);
            store_sp(sp);

            break;
        }
        case 0xFFFF9: {
            TCGv_i32 sph = tcg_temp_new_i32();
            TCGv_i32 sp = tcg_temp_new_i32();

            tcg_gen_extract_i32(sph, data, 0, 8);
            tcg_gen_deposit_i32(sp, cpu_sp, data, 8, 8);
            store_sp(sp);

            break;
        }
        case 0xFFFFA:
            store_psw(ctx, data);
            break;
        case 0xFFFFC:
            tcg_gen_deposit_i32(cpu_cs, cpu_cs, data, 0, 4);
            break;
        case 0xFFFFD:
            tcg_gen_deposit_i32(cpu_es, cpu_es, data, 0, 4);
            break;
        default:
            rl78_gen_store(ctx, tcg_const_i32(paddr), data, memop);
            break;
    }
}


static void store_word_paddr(DisasContext *ctx, const uint32_t paddr, TCGv_i32 data, const TCGMemOp memop) 
{
    // TODO: check actual MCU implementation
    switch(paddr) {
        case 0xFFFF8:
            store_sp(data);
            break; 
        default:
            rl78_gen_store(ctx, tcg_const_i32(paddr), data, memop);
            break;
    }
}

static void store_paddr(DisasContext *ctx, const uint32_t paddr, TCGv_i32 data, const TCGMemOp memop)
{
    switch((memop & MO_SIZE)) {
        case MO_8:
            store_byte_paddr(ctx, paddr, data, memop);
            break;
        case MO_16:
            store_word_paddr(ctx, paddr, data, memop);
            break;
        default:
            g_assert_not_reached();
    }
}

static void store_abs16(DisasContext *ctx, const uint32_t addr, TCGv_i32 data,
                        const TCGMemOp memop)
{

    if(ctx->use_es) {
        TCGv_i32 a = rl78_gen_addr(ctx, tcg_const_i32(addr));
        rl78_gen_store(ctx, a, data, memop);
    } else {
        const uint32_t paddr = addr | 0xF0000; 
        store_paddr(ctx, paddr, data, memop);
    }
}

static TCGv_i32 load_saddr(DisasContext *ctx, const uint32_t saddr,
                           const TCGMemOp memop)
{
    const target_ulong base        = saddr < 0x20 ? 0xFFF00 : 0xFFE00;
    const target_ulong access_addr = base + saddr;

    return load_paddr(ctx, access_addr, memop);
}

static void store_saddr(DisasContext *ctx, const uint32_t saddr, TCGv_i32 data,
                        const TCGMemOp memop)
{
    const target_ulong base        = saddr < 0x20 ? 0xFFF00 : 0xFFE00;
    const target_ulong access_addr = base + saddr;

    store_paddr(ctx, access_addr, data, memop);
}

static TCGv_i32 load_sfr(DisasContext *ctx, const uint32_t sfr,
                         const TCGMemOp memop)
{
    const target_ulong access_addr = 0xFFF00 + sfr;
    return load_paddr(ctx, access_addr, memop);
}

static void store_sfr(DisasContext *ctx, const uint32_t sfr, TCGv_i32 data,
                      const TCGMemOp memop)
{
    const target_ulong access_addr = 0xFFF00 + sfr;
    store_paddr(ctx, access_addr, data, memop);
}

static TCGv_i32 ind_reg(DisasContext *ctx, const RL78WordRegister base)
{
    TCGv_i32 tcg_base = load_word_reg(base);
    return rl78_gen_addr(ctx, tcg_base);
}

static TCGv_i32 load_ind_reg(DisasContext *ctx, const RL78OperandIndReg op, const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_reg(ctx, op.base);
    return rl78_gen_load(ctx, addr, memop);
}

static void store_ind_reg(DisasContext *ctx, const RL78OperandIndReg op,
                          TCGv_i32 data, const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_reg(ctx, op.base);
    rl78_gen_store(ctx, addr, data, memop);
}

static TCGv_i32 ind_reg_reg(DisasContext *ctx, const RL78WordRegister base,
                            const RL78ByteRegister idx)
{
    TCGv_i32 tcg_base = load_word_reg(base);
    TCGv_i32 tcg_idx  = load_byte_reg(idx);
    tcg_gen_add_i32(tcg_base, tcg_base, tcg_idx);

    return rl78_gen_addr(ctx, tcg_base);
}

static TCGv_i32 load_ind_reg_reg(DisasContext *ctx,
                                 const RL78OperandIndRegReg op,
                                 const TCGMemOp memop)
{
    TCGv_i32 addr = ind_reg_reg(ctx, op.base, op.idx);

    return rl78_gen_load(ctx, addr, memop);
}

static void store_ind_reg_reg(DisasContext *ctx, const RL78OperandIndRegReg op,
                              TCGv_i32 data, const TCGMemOp memop)
{
    TCGv_i32 addr = ind_reg_reg(ctx, op.base, op.idx);

    rl78_gen_store(ctx, addr, data, memop);
}

static TCGv_i32 ind_reg_imm(DisasContext *ctx, const RL78WordRegister base,
                            const uint32_t imm)
{
    TCGv_i32 tcg_base = load_word_reg(base);
    tcg_gen_addi_i32(tcg_base, tcg_base, imm);

    return rl78_gen_addr(ctx, tcg_base);
}

static TCGv_i32 load_ind_reg_imm(DisasContext *ctx,
                                 const RL78OperandIndRegImm op,
                                 const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_reg_imm(ctx, op.base, op.imm);
    return rl78_gen_load(ctx, addr, memop);
}

static void store_ind_reg_imm(DisasContext *ctx, const RL78OperandIndRegImm op,
                              TCGv_i32 data, const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_reg_imm(ctx, op.base, op.imm);
    rl78_gen_store(ctx, addr, data, memop);
}

static TCGv_i32 ind_sp_imm(DisasContext *ctx, const uint32_t imm)
{
    TCGv_i32 sp = load_sp();
    tcg_gen_addi_i32(sp, sp, imm);

    return rl78_gen_addr(ctx, sp);
}

static TCGv_i32 load_ind_sp_imm(DisasContext *ctx, const RL78OperandIndSPImm op,
                                const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_sp_imm(ctx, op.imm);
    return rl78_gen_load(ctx, addr, memop);
}

static void store_ind_sp_imm(DisasContext *ctx, const RL78OperandIndSPImm op,
                              TCGv_i32 data, const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_sp_imm(ctx, op.imm);
    rl78_gen_store(ctx, addr, data, memop);
}

static TCGv_i32 ind_base_byte(DisasContext *ctx, const uint32_t base,
                              const RL78ByteRegister idx)
{
    TCGv_i32 tcg_base = tcg_const_i32(base);
    TCGv_i32 tcg_addr  = load_byte_reg(idx);
    tcg_gen_add_i32(tcg_addr, tcg_addr, tcg_base);

    return rl78_gen_addr(ctx, tcg_addr);
}

static TCGv_i32 load_ind_base_byte(DisasContext *ctx,
                                   const RL78OperandIndBaseByte op,
                                   const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_base_byte(ctx, op.base, op.idx);
    return rl78_gen_load(ctx, addr, memop);
}

static void store_ind_base_byte(DisasContext *ctx,
                                const RL78OperandIndBaseByte op, TCGv_i32 data,
                                const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_base_byte(ctx, op.base, op.idx);
    rl78_gen_store(ctx, addr, data, memop);
}

static TCGv_i32 ind_base_word(DisasContext *ctx, const uint32_t base,
                              const RL78WordRegister idx)
{
    TCGv_i32 tcg_base = tcg_const_i32(base);
    TCGv_i32 tcg_addr  = load_word_reg(idx);
    tcg_gen_add_i32(tcg_addr, tcg_addr, tcg_base);

    return rl78_gen_addr(ctx, tcg_addr);
}

static TCGv_i32 load_ind_base_word(DisasContext *ctx,
                                   const RL78OperandIndBaseWord op,
                                   const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_base_word(ctx, op.base, op.idx);
    return rl78_gen_load(ctx, addr, memop);
}

static void store_ind_base_word(DisasContext *ctx,
                                const RL78OperandIndBaseWord op, TCGv_i32 data,
                                const TCGMemOp memop)
{
    const TCGv_i32 addr = ind_base_word(ctx, op.base, op.idx);
    rl78_gen_store(ctx, addr, data, memop);
}

#define control_reg(reg)                        \
    static TCGv_i32 load_##reg(void) {          \
        TCGv_i32 ret = tcg_temp_new_i32();      \
        tcg_gen_mov_i32(ret, cpu_##reg);        \
        return ret;                             \
    }                                           \
                                                \
    static void store_##reg(TCGv_i32 data) {    \
        tcg_gen_mov_i32(cpu_##reg, data);       \
    }

control_reg(es);
control_reg(psw_cy);

static TCGv_i32 rl78_gen_load_operand(DisasContext *ctx, const RL78Operand op, const TCGMemOp memop)
{
    switch (op.kind) {
    case RL78_OP_BYTE_REG:
        return load_byte_reg(op.byte_reg);
    case RL78_OP_WORD_REG:
        return load_word_reg(op.word_reg);
    case RL78_OP_PSW:
        return load_psw();
    case RL78_OP_SP:
        return load_sp();
    case RL78_OP_ES:
        return load_es();
    case RL78_OP_CY:
        return load_psw_cy();
    case RL78_OP_IMM8:
        return tcg_const_i32(op.const_op & 0xFF);
    case RL78_OP_IMM16:
        return tcg_const_i32(op.const_op & 0xFFFF);
    case RL78_OP_ABS16:
        return load_abs16(ctx, op.const_op, memop);
    case RL78_OP_SADDR:
        return load_saddr(ctx, op.const_op, memop);
    case RL78_OP_SFR:
        return load_sfr(ctx, op.const_op, memop);
    case RL78_OP_IND_REG:
        return load_ind_reg(ctx, op.ind_reg, memop);
    case RL78_OP_IND_REG_REG:
        return load_ind_reg_reg(ctx, op.ind_reg_reg, memop);
    case RL78_OP_IND_REG_IMM:
        return load_ind_reg_imm(ctx, op.ind_reg_imm, memop);
    case RL78_OP_IND_SP_IMM:
        return load_ind_sp_imm(ctx, op.ind_sp_imm, memop);
    case RL78_OP_IND_BASE_BYTE:
        return load_ind_base_byte(ctx, op.ind_base_byte, memop);
    case RL78_OP_IND_BASE_WORD:
        return load_ind_base_word(ctx, op.ind_base_word, memop);
    case RL78_OP_SHAMT:
        return tcg_const_i32(op.const_op & 0x1F);
    case RL78_OP_SEL_RB:
        return tcg_const_i32(op.const_op & 0x03);
    case RL78_OP_BIT:
    case RL78_OP_ABS20:
    case RL78_OP_REL8:
    case RL78_OP_REL16:
    case RL78_OP_CALLT:
    case RL78_OP_NONE:
    default:
        tlib_abortf("Unexpected load addressing type: %d", op.kind);
        break;
    }

    return tcg_const_i32(0);
}

static void rl78_gen_store_operand(DisasContext *ctx, const RL78Operand op,
                                   TCGv_i32 data, const TCGMemOp memop)
{
    switch (op.kind) {
    case RL78_OP_BYTE_REG:
        store_byte_reg(op.byte_reg, data);
        break;
    case RL78_OP_WORD_REG:
        store_word_reg(op.word_reg, data);
        break;
    case RL78_OP_PSW:
        store_psw(ctx, data);
        break;
    case RL78_OP_SP:
        store_sp(data);
        break;
    case RL78_OP_ES:
        store_es(data);
        break;
    case RL78_OP_CY:
        store_psw_cy(data);
        break;
    case RL78_OP_ABS16:
        store_abs16(ctx, op.const_op, data, memop);
        break;
    case RL78_OP_SADDR:
        store_saddr(ctx, op.const_op, data, memop);
        break;
    case RL78_OP_SFR:
        store_sfr(ctx, op.const_op, data, memop);
        break;
    case RL78_OP_IND_REG:
        store_ind_reg(ctx, op.ind_reg, data, memop);
        break;
    case RL78_OP_IND_REG_REG:
        store_ind_reg_reg(ctx, op.ind_reg_reg, data, memop);
        break;
    case RL78_OP_IND_REG_IMM:
        store_ind_reg_imm(ctx, op.ind_reg_imm, data, memop);
        break;
    case RL78_OP_IND_SP_IMM:
        store_ind_sp_imm(ctx, op.ind_sp_imm, data, memop);
        break;
    case RL78_OP_IND_BASE_BYTE:
        store_ind_base_byte(ctx, op.ind_base_byte, data, memop);
        break;
    case RL78_OP_IND_BASE_WORD:
        store_ind_base_word(ctx, op.ind_base_word, data, memop);
        break;
    case RL78_OP_SHAMT:
    case RL78_OP_SEL_RB:
    case RL78_OP_IMM8:
    case RL78_OP_IMM16:
    case RL78_OP_BIT:
    case RL78_OP_ABS20:
    case RL78_OP_REL8:
    case RL78_OP_REL16:
    case RL78_OP_CALLT:
    case RL78_OP_NONE:
    default:
        tlib_abortf("Unexpected store addressing type: %d", op.kind);
        break;
    }
}

static inline bool use_goto_tb(DisasContext *dc, target_ulong dest)
{
    return (dc->base.tb->pc & TARGET_PAGE_MASK) == (dest & TARGET_PAGE_MASK);
}

static inline void gen_goto_tb(DisasContext *dc, int n, target_ulong dest)
{
    if(use_goto_tb(dc, dest)) {
        tcg_gen_goto_tb(n);
        tcg_gen_movi_i32(cpu_pc, dest);
        gen_exit_tb(dc->base.tb, n);
    } else {
        tcg_gen_movi_i32(cpu_pc, dest);
        gen_exit_tb_no_chaining(dc->base.tb);
    }
}

static void rl78_gen_goto_tb(DisasContext *dc, unsigned tb_slot_idx, target_ulong dest)
{
    gen_goto_tb(dc, (int)tb_slot_idx, dest);
    dc->base.is_jmp = DISAS_TB_JUMP;
}

static bool trans_unimplemented(DisasContext *ctx, RL78Instruction *insn)
{
    tlib_abortf("RL78 instruction not yet implemented (mnemonic=%d PC=0x%06x)",
                (int)insn->mnemonic, (unsigned)ctx->base.pc);
    return false;
}
static TCGv_i32 borrow_byte(TCGv_i32 result)
{
    TCGv_i32 cy = tcg_temp_new_i32();

    tcg_gen_shri_i32(cy, result, 8);
    tcg_gen_andi_i32(cy, cy, 0x01);

    return cy;
}

static TCGv_i32 carry_byte(TCGv_i32 result)
{
    TCGv_i32 cy = tcg_temp_new_i32();

    tcg_gen_shri_i32(cy, result, 8);
    tcg_gen_andi_i32(cy, cy, 0x01);

    return cy;
}

static TCGv_i32 zero_byte(TCGv_i32 result)
{
    TCGv_i32 z = tcg_temp_new_i32();

    tcg_gen_andi_i32(z, result, 0xFF);
    tcg_gen_movcond_i32(TCG_COND_EQ, z, z, tcg_const_i32(0),
                        tcg_const_i32(1), tcg_const_i32(0));

    return z;
}

static TCGv_i32 half_carry(TCGv_i32 op0, TCGv_i32 op1, TCGv_i32 result)
{
    TCGv_i32 tmp = tcg_temp_new_i32();
    TCGv_i32 ac  = tcg_temp_new_i32();

    tcg_gen_mov_i32(tmp, op0);
    tcg_gen_xor_i32(tmp, tmp, op1);
    tcg_gen_xor_i32(tmp, tmp, result);

    tcg_gen_shri_i32(ac, tmp, 4);
    tcg_gen_andi_i32(ac, ac, 0x01);

    return ac;
}

static TCGv_i32 half_borrow(TCGv_i32 op0, TCGv_i32 op1, TCGv_i32 result)
{
    TCGv_i32 tmp = tcg_temp_new_i32();
    TCGv_i32 ac  = tcg_temp_new_i32();

    tcg_gen_xor_i32(tmp, op0, op1);
    tcg_gen_xor_i32(tmp, tmp, result);

    tcg_gen_shri_i32(ac, tmp, 4);
    tcg_gen_andi_i32(ac, ac, 0x01);

    return ac;
}

static void rl78_gen_ind_jump(DisasContext *ctx, RL78WordRegister reg)
{
    TCGv_i32 target = load_word_reg(reg);
    TCGv_i32 pc_s   = tcg_temp_new_i32();

    tcg_gen_mov_i32(pc_s, cpu_cs);
    tcg_gen_shli_i32(pc_s, pc_s, 16);
    tcg_gen_add_i32(pc_s, pc_s, target);

    tcg_gen_mov_i32(cpu_pc, pc_s);
    gen_exit_tb_no_chaining(ctx->base.tb);
    ctx->base.is_jmp = DISAS_UPDATE;
}

static void rl78_gen_abs_jump(DisasContext *ctx, target_ulong target)
{
    rl78_gen_goto_tb(ctx, 1, target);
}

static void rl78_gen_rel_jump(DisasContext *ctx, int32_t rel)
{
    const target_ulong target = ctx->base.pc + rel;
    rl78_gen_goto_tb(ctx, 1, target);
}

static void rl78_gen_skip(DisasContext *ctx, TCGCond cond, TCGv_i32 operand)
{
    /*
     * Same-TB: skip_flag makes the next gen_intermediate_code wrap the
     * following insn. Cross-TB: skip_en folds into TB_FLAG_SKIP via
     * cpu_get_tb_cpu_state when this TB ends for other reasons.
     */
    ctx->skip_flag = true;
    tcg_gen_movi_i32(cpu_skip_en, 1);
    tcg_gen_movcond_i32(cond, cpu_skip_req, operand, tcg_const_i32(1),
                        tcg_const_i32(1), tcg_const_i32(0));
}

static bool trans_MOV(DisasContext *ctx, RL78Instruction *insn)
{
    TCGv_i32 src = rl78_gen_load_operand(ctx, insn->operand[1], MO_8);
    rl78_gen_store_operand(ctx, insn->operand[0], src, MO_8);
    return true;
}

static bool trans_MOVW(DisasContext *ctx, RL78Instruction *insn)
{
    TCGv_i32 src = rl78_gen_load_operand(ctx, insn->operand[1], MO_16);
    rl78_gen_store_operand(ctx, insn->operand[0], src, MO_16);
    return true;
}

static bool trans_ONEW(DisasContext *ctx, RL78Instruction *insn)
{
    TCGv_i32 op = tcg_const_i32(1);
    rl78_gen_store_operand(ctx, insn->operand[0], op, MO_16);
    return true;
}

static bool trans_CMP(DisasContext *ctx, RL78Instruction *insn)
{
    TCGv_i32 op0    = rl78_gen_load_operand(ctx, insn->operand[0], MO_8);
    TCGv_i32 op1    = rl78_gen_load_operand(ctx, insn->operand[1], MO_8);
    TCGv_i32 result = tcg_temp_new_i32();

    tcg_gen_sub_i32(result, op0, op1);

    tcg_gen_mov_i32(cpu_psw_cy, borrow_byte(result));
    tcg_gen_mov_i32(cpu_psw_ac, half_borrow(op0, op1, result));
    tcg_gen_mov_i32(cpu_psw_z, zero_byte(result));

    return true;
}

static bool trans_INC(DisasContext *ctx, RL78Instruction *insn)
{
    TCGv_i32 src    = rl78_gen_load_operand(ctx, insn->operand[0], MO_8);
    TCGv_i32 result = tcg_temp_new_i32();

    tcg_gen_add_i32(result, src, tcg_const_i32(1));

    rl78_gen_store_operand(ctx, insn->operand[0], result, MO_8);

    tcg_gen_mov_i32(cpu_psw_ac, half_carry(src, tcg_const_i32(1), result));
    tcg_gen_mov_i32(cpu_psw_z, zero_byte(result));

    return true;
}

static bool trans_BR(DisasContext *ctx, RL78Instruction *insn)
{
    RL78Operand op = insn->operand[0];

    switch (op.kind) {
    case RL78_OP_WORD_REG:
        rl78_gen_ind_jump(ctx, op.word_reg);
        break;
    case RL78_OP_ABS16:
        rl78_gen_abs_jump(ctx, op.const_op & 0xFFFF);
        break;
    case RL78_OP_ABS20:
        rl78_gen_abs_jump(ctx, op.const_op & 0xFFFFF);
        break;
    case RL78_OP_REL8:
        rl78_gen_rel_jump(ctx, (int8_t)(op.const_op & 0xFF));
        break;
    case RL78_OP_REL16:
        rl78_gen_rel_jump(ctx, (int16_t)(op.const_op & 0xFFFF));
    default:
        // TODO: raise implementation error assert
        break;
    }

    return true;
}

static bool trans_SKZ(DisasContext *ctx, RL78Instruction *insn)
{
    rl78_gen_skip(ctx, TCG_COND_EQ, cpu_psw_z);
    return true;
}

static bool trans_NOP(DisasContext *ctx, RL78Instruction *insn) { return true; }


static uint32_t rl78_get_pc(DisasContext *ctx)
{
    return ctx->base.pc;
}

static void rl78_set_pc(DisasContext *ctx, uint32_t pc)
{
    ctx->base.pc = pc;
}

static void rl78_set_es(DisasContext *ctx, bool es)
{
    ctx->use_es = es;
}

static uint8_t rl78_load_byte(DisasContext *ctx, uint32_t pc)
{
    (void)ctx;
    return ldub_code(pc);
}

static TranslateHandler translator_table[RL78_INSN_UNKNOWN] = {
    [RL78_INSN_MOV] = trans_MOV,
    [RL78_INSN_XCH] = trans_unimplemented,
    [RL78_INSN_ONEB] = trans_unimplemented,
    [RL78_INSN_CLRB] = trans_unimplemented,
    [RL78_INSN_MOVW] = trans_MOVW,
    [RL78_INSN_XCHW] = trans_unimplemented,
    [RL78_INSN_ONEW] = trans_ONEW,
    [RL78_INSN_CLRW] = trans_unimplemented,
    [RL78_INSN_ADD] = trans_unimplemented,
    [RL78_INSN_ADDC] = trans_unimplemented,
    [RL78_INSN_SUB] = trans_unimplemented,
    [RL78_INSN_SUBC] = trans_unimplemented,
    [RL78_INSN_AND] = trans_unimplemented,
    [RL78_INSN_OR] = trans_unimplemented,
    [RL78_INSN_XOR] = trans_unimplemented,
    [RL78_INSN_CMP] = trans_CMP,
    [RL78_INSN_CMP0] = trans_unimplemented,
    [RL78_INSN_CMPS] = trans_unimplemented,
    [RL78_INSN_MOVS] = trans_unimplemented,
    [RL78_INSN_ADDW] = trans_unimplemented,
    [RL78_INSN_SUBW] = trans_unimplemented,
    [RL78_INSN_CMPW] = trans_unimplemented,
    [RL78_INSN_MULU] = trans_unimplemented,
    [RL78_INSN_INC] = trans_INC,
    [RL78_INSN_DEC] = trans_unimplemented,
    [RL78_INSN_INCW] = trans_unimplemented,
    [RL78_INSN_DECW] = trans_unimplemented,
    [RL78_INSN_SHR] = trans_unimplemented,
    [RL78_INSN_SHRW] = trans_unimplemented,
    [RL78_INSN_SHL] = trans_unimplemented,
    [RL78_INSN_SHLW] = trans_unimplemented,
    [RL78_INSN_SAR] = trans_unimplemented,
    [RL78_INSN_SARW] = trans_unimplemented,
    [RL78_INSN_ROR] = trans_unimplemented,
    [RL78_INSN_ROL] = trans_unimplemented,
    [RL78_INSN_RORC] = trans_unimplemented,
    [RL78_INSN_ROLC] = trans_unimplemented,
    [RL78_INSN_ROLWC] = trans_unimplemented,
    [RL78_INSN_MOV1] = trans_unimplemented,
    [RL78_INSN_AND1] = trans_unimplemented,
    [RL78_INSN_OR1] = trans_unimplemented,
    [RL78_INSN_XOR1] = trans_unimplemented,
    [RL78_INSN_SET1] = trans_unimplemented,
    [RL78_INSN_CLR1] = trans_unimplemented,
    [RL78_INSN_NOT1] = trans_unimplemented,
    [RL78_INSN_CALL] = trans_unimplemented,
    [RL78_INSN_CALLT] = trans_unimplemented,
    [RL78_INSN_BRK] = trans_unimplemented,
    [RL78_INSN_RET] = trans_unimplemented,
    [RL78_INSN_RETI] = trans_unimplemented,
    [RL78_INSN_RETB] = trans_unimplemented,
    [RL78_INSN_PUSH] = trans_unimplemented,
    [RL78_INSN_POP] = trans_unimplemented,
    [RL78_INSN_BR] = trans_BR,
    [RL78_INSN_BC] = trans_unimplemented,
    [RL78_INSN_BNC] = trans_unimplemented,
    [RL78_INSN_BZ] = trans_unimplemented,
    [RL78_INSN_BNZ] = trans_unimplemented,
    [RL78_INSN_BH] = trans_unimplemented,
    [RL78_INSN_BNH] = trans_unimplemented,
    [RL78_INSN_BT] = trans_unimplemented,
    [RL78_INSN_BF] = trans_unimplemented,
    [RL78_INSN_BTCLR] = trans_unimplemented,
    [RL78_INSN_SKC] = trans_unimplemented,
    [RL78_INSN_SKNC] = trans_unimplemented,
    [RL78_INSN_SKZ] = trans_SKZ,
    [RL78_INSN_SKNZ] = trans_unimplemented,
    [RL78_INSN_SKH] = trans_unimplemented,
    [RL78_INSN_SKNH] = trans_unimplemented,
    [RL78_INSN_SEL] = trans_unimplemented,
    [RL78_INSN_NOP] = trans_NOP,
    [RL78_INSN_HALT] = trans_unimplemented,
    [RL78_INSN_STOP] = trans_unimplemented,
};

void setup_disas_context(DisasContextBase *base, CPUState *env)
{
    DisasContext *dc = (DisasContext *)base;

    base->mem_idx = cpu_mmu_index(env);
    dc->tb_flags = base->tb->flags;
    dc->skip_flag = (base->tb->flags & TB_FLAG_SKIP) != 0;
    dc->use_es = false;
}

int gen_intermediate_code(CPUState *env, DisasContextBase *base)
{
    DisasContext *dc = (DisasContext *)base;
    int skip_label = 0;
    const DecodeHandler handler = {
        .get_pc = rl78_get_pc,
        .set_pc = rl78_set_pc,
        .set_es = rl78_set_es,
        .load_byte = rl78_load_byte,
        .translator_table = translator_table,
    };

    (void)env;
    tcg_gen_insn_start(base->pc);

    const bool use_skip = dc->skip_flag;
    dc->skip_flag = false;
    if(use_skip) {
        TCGv_i32 required_tmp = tcg_temp_new_i32();

        tcg_gen_movi_i32(cpu_skip_en, 0);
        tcg_gen_mov_i32(required_tmp, cpu_skip_req);
        tcg_gen_movi_i32(cpu_skip_req, 0);

        skip_label = gen_new_label();
        tcg_gen_brcondi_i32(TCG_COND_NE, required_tmp, 0, skip_label);
        tcg_temp_free_i32(required_tmp);
    }

    dc->pc = dc->base.pc;
    dc->use_es = false;

    target_ulong head_pc = dc->base.pc;
    if(!decode(dc, &handler)) {
        tlib_abortf("RL78 decode/translate failed (PC=0x%06x)", (unsigned)head_pc);
    }
    /* Full insn length (opcode + operands + prefixes), matching other tlib targets. */
    dc->base.tb->size += (int)(dc->base.pc - head_pc);

    if(use_skip) {
        gen_set_label(skip_label);
        /*
         * If the wrapped insn ends the TB (e.g. BR), the execute path already
         * emitted an exit. The skip path lands here and must continue at the
         * following PC; otherwise SKZ; BR sequences never skip the branch.
         */
        if(dc->base.is_jmp != DISAS_NEXT) {
            gen_goto_tb(dc, 0, dc->base.pc);
        }
    }

    return 0;
}

uint32_t gen_intermediate_code_epilogue(CPUState *env, DisasContextBase *base)
{
    DisasContext *dc = (DisasContext *)base;

    (void)env;
    switch(dc->base.is_jmp) {
        case DISAS_NEXT:
            gen_goto_tb(dc, 0, dc->base.pc);
            break;
        case DISAS_UPDATE:
            gen_sync_pc(dc);
            gen_exit_tb_no_chaining(dc->base.tb);
            break;
        case DISAS_TB_JUMP:
        case DISAS_JUMP:
            break;
        default:
            break;
    }

    return 0;
}

int gen_breakpoint(DisasContextBase *base, CPUBreakpoint *bp)
{
    DisasContext *dc = (DisasContext *)base;

    (void)bp;
    gen_sync_pc(dc);
    gen_exit_tb_no_chaining(dc->base.tb);
    return 1;
}

void restore_state_to_opc(CPUState *env, TranslationBlock *tb, target_ulong *data)
{
    (void)tb;
    env->pc = data[0];
}

void cpu_exec_prologue(CPUState *env) { (void)env; }

void cpu_exec_epilogue(CPUState *env) { (void)env; }
