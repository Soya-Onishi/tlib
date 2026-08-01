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
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 */
#include "cpu.h"
#include "tcg-op.h"

/*
 * DISAS_NEXT/DISAS_JUMP/DISAS_UPDATE/DISAS_TB_JUMP are defined in exec-all.h.
 * Additional block-exit reason:
 */
#define DISAS_BRANCH 4 /* branch generated its own exit sequence */

/* General purpose registers, indexed by [bank][byte-register]. */
static TCGv_i32 cpu_regs[REGISTER_BANK_NUM][RL78_BYTE_REG_NUM];

/* PSW fields (each mapped to a dedicated env field). */
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

    cpu_psw_cy  = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.cy), "psw.cy");
    cpu_psw_isp = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.isp), "psw.isp");
    cpu_psw_rbs = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.rbs), "psw.rbs");
    cpu_psw_ac  = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.ac), "psw.ac");
    cpu_psw_z   = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.z), "psw.z");
    cpu_psw_ie  = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, psw.ie), "psw.ie");

    cpu_pc = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, pc), "pc");
    cpu_sp = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, sp), "sp");
    cpu_es = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, es), "es");
    cpu_cs = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, cs), "cs");

    cpu_skip_en  = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, skip_en), "skip_en");
    cpu_skip_req = tcg_global_mem_new_i32(TCG_AREG0, offsetof(CPUState, skip_req), "skip_req");
}

void gen_sync_pc(DisasContext *dc)
{
    tcg_gen_movi_i32(cpu_pc, dc->base.pc);
}

static inline bool use_goto_tb(DisasContext *dc, target_ulong dest)
{
    return (dc->base.tb->pc & TARGET_PAGE_MASK) == (dest & TARGET_PAGE_MASK);
}

static inline void gen_goto_tb(DisasContext *dc, int n, target_ulong dest)
{
    if(use_goto_tb(dc, dest)) {
        /* chaining is only allowed when the jump stays on the same page */
        tcg_gen_goto_tb(n);
        tcg_gen_movi_i32(cpu_pc, dest);
        gen_exit_tb(dc->base.tb, n);
    } else {
        tcg_gen_movi_i32(cpu_pc, dest);
        gen_exit_tb_no_chaining(dc->base.tb);
    }
}

void setup_disas_context(DisasContextBase *base, CPUState *env)
{
    DisasContext *dc = (DisasContext *)base;

    base->mem_idx = cpu_mmu_index(env);
    dc->tb_flags  = base->tb->flags;
    /* The skip-pending state is carried across TB boundaries via TB_FLAG_SKIP
     * (folded into tb->flags by cpu_get_tb_cpu_state). */
    dc->skip_flag = (base->tb->flags & TB_FLAG_SKIP) != 0;
    dc->use_es    = false;
}

int gen_intermediate_code(CPUState *env, DisasContextBase *base)
{
    DisasContext *dc = (DisasContext *)base;
    int skip_label   = 0;

    tcg_gen_insn_start(base->pc);

    /*
     * If the previous instruction was a skip, wrap this instruction in a
     * runtime-conditional branch that skips it when skip_req is set.
     * (Ported structure from qemu/target/rl78 translate.c.)
     */
    const bool use_skip = dc->skip_flag;
    dc->skip_flag       = false;
    if(use_skip) {
        TCGv_i32 required_tmp = tcg_temp_new_i32();

        tcg_gen_movi_i32(cpu_skip_en, 0);
        tcg_gen_mov_i32(required_tmp, cpu_skip_req);
        tcg_gen_movi_i32(cpu_skip_req, 0);

        skip_label = gen_new_label();
        tcg_gen_brcondi_i32(TCG_COND_NE, required_tmp, 0, skip_label);
        tcg_temp_free_i32(required_tmp);
    }

    /*
     * TODO(rl78): port decode.c and the per-instruction translation from
     * qemu/target/rl78. Until the decoder is in place, translating any RL78
     * code aborts so the missing coverage is obvious.
     */
    tlib_abortf("RL78 instruction translation is not yet implemented (PC=0x%06x)", (unsigned)base->pc);

    if(use_skip) {
        gen_set_label(skip_label);
    }

    return 0;
}

uint32_t gen_intermediate_code_epilogue(CPUState *env, DisasContextBase *base)
{
    DisasContext *dc = (DisasContext *)base;

    switch(dc->base.is_jmp) {
        case DISAS_NEXT:
            gen_goto_tb(dc, 0, dc->base.pc);
            break;
        case DISAS_UPDATE:
            gen_sync_pc(dc);
            gen_exit_tb_no_chaining(dc->base.tb);
            break;
        case DISAS_BRANCH:
            /* the instruction generated its own exit sequence */
            break;
        default:
            break;
    }

    return 0;
}

int gen_breakpoint(DisasContextBase *base, CPUBreakpoint *bp)
{
    DisasContext *dc = (DisasContext *)base;

    gen_sync_pc(dc);
    gen_exit_tb_no_chaining(dc->base.tb);
    return 1;
}

void restore_state_to_opc(CPUState *env, TranslationBlock *tb, target_ulong *data)
{
    env->pc = data[0];
}

//  TODO: These empty implementations are required due to problems with weak attribute.
void cpu_exec_prologue(CPUState *env) { }

void cpu_exec_epilogue(CPUState *env) { }
