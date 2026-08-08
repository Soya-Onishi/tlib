/*
 *  RL78 virtual CPU header
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
#pragma once

#include "bit_helper.h"
#include "cpu-defs.h"
#include "host-utils.h"

/*
 * RL78 has a flat 20-bit (1 MiB) address space and no MMU.
 * Memory map granularity is 256 bytes, hence TARGET_PAGE_BITS = 8.
 * The maximum guest memory access width is 2 bytes.
 */
#define TARGET_PAGE_BITS            8
#define TARGET_PHYS_ADDR_SPACE_BITS 20
#define TARGET_VIRT_ADDR_SPACE_BITS 20

#define NB_MMU_MODES 1

#define REGISTER_BANK_NUM 4

typedef enum {
    RL78_BYTE_REG_X = 0,
    RL78_BYTE_REG_A,
    RL78_BYTE_REG_C,
    RL78_BYTE_REG_B,
    RL78_BYTE_REG_E,
    RL78_BYTE_REG_D,
    RL78_BYTE_REG_L,
    RL78_BYTE_REG_H,
    RL78_BYTE_REG_NUM,
} RL78ByteRegister;

typedef enum {
    RL78_WORD_REG_AX = 0,
    RL78_WORD_REG_BC,
    RL78_WORD_REG_DE,
    RL78_WORD_REG_HL,
    RL78_WORD_REG_NUM,
} RL78WordRegister;

/* Program Status Word, kept as individual 32-bit fields so that each one
 * can be exposed to TCG through a dedicated global (see translate.c). */
typedef struct RL78PSW {
    uint32_t cy;
    uint32_t isp;
    uint32_t rbs;
    uint32_t ac;
    uint32_t z;
    uint32_t ie;
} RL78PSW;

/* TB flags carried across translation-block boundaries. */
enum RL78TBFlags {
    TB_FLAG_SKIP = 1 << 0,
};

/* Exception indices used internally (interrupt vectors reuse env->irq_index). */
#define EXCP_RL78_ILLEGAL 0x100

#include "cpu_registers.h"

typedef struct DisasContext {
    struct DisasContextBase base;

    uint32_t pc;
    uint32_t tb_flags;

    /* translate-time: previous instruction was a skip -> wrap next one */
    bool skip_flag;
    /* translate-time: current instruction is prefixed with ES: */
    bool use_es;
} DisasContext;

typedef struct CPUState CPUState;

#include "cpu-common.h"

struct CPUState {
    RL78PSW psw;

    /* General purpose registers, indexed by [bank][byte-register]. */
    uint32_t regs[REGISTER_BANK_NUM][RL78_BYTE_REG_NUM];

    /* Control registers */
    uint32_t sp;
    uint32_t pc;
    uint32_t pmc;
    uint32_t mem;

    /* Segment registers */
    uint32_t es;
    uint32_t cs;

    /* Multiply-accumulate result register */
    uint32_t macr;

    /* Skip instruction control */
    uint32_t skip_en;
    uint32_t skip_req;

    /* Latched interrupt candidate (updated from outside via arch_exports). */
    int32_t irq_index;
    uint8_t irq_priority;

    CPU_COMMON
};

static inline uint8_t rl78_cpu_pack_psw(RL78PSW p)
{
    return (uint8_t)((p.cy & 1) | ((p.isp & 3) << 1) | ((p.rbs & 1) << 3) | ((p.ac & 1) << 4) | (((p.rbs >> 1) & 1) << 5) |
                     ((p.z & 1) << 6) | ((p.ie & 1) << 7));
}

static inline RL78PSW rl78_cpu_unpack_psw(uint8_t v)
{
    RL78PSW p;
    p.cy  = v & 1;
    p.isp = (v >> 1) & 3;
    p.rbs = ((v >> 3) & 1) | (((v >> 5) & 1) << 1);
    p.ac  = (v >> 4) & 1;
    p.z   = (v >> 6) & 1;
    p.ie  = (v >> 7) & 1;
    return p;
}

void cpu_reset(CPUState *env);
int cpu_init(const char *cpu_model);
void do_interrupt(CPUState *env);
int process_interrupt(int interrupt_request, CPUState *env);

static inline int cpu_mmu_index(CPUState *env)
{
    return 0;
}

#include "cpu-all.h"
#include "exec-all.h"

static inline void cpu_get_tb_cpu_state(CPUState *env, target_ulong *pc, target_ulong *cs_base, int *flags)
{
    *pc      = env->pc;
    *cs_base = 0;
    *flags   = env->skip_en ? TB_FLAG_SKIP : 0;
}

static inline bool cpu_has_work(CPUState *env)
{
    /*
     * In tlib, cpu_exec() gates TB execution on this predicate:
     *   if (!cpu_has_work(env)) return EXCP_WFI;
     * So true means "run TBs now", false means "parked".
     *
     * That is not the same as QEMU's cpu_has_work / has_work, which mainly
     * answers "is there a wake-up reason while halted?" (typically pending
     * IRQs). QEMU still runs a non-halted vCPU even when has_work is false
     * (idle check is roughly: halted && !cpu_has_work).
     *
     * Returning only (interrupt_request & CPU_INTERRUPT_HARD) therefore
     * matches QEMU-ish wake semantics but breaks tlib: with no IRQ the
     * core never reaches translation. Follow the other tlib targets
     * (riscv/i386/ppc/...): clear WFI on a wake IRQ, then return !wfi.
     * env->wfi itself remains "nonzero if suspended" (see cpu-defs.h).
     */
    if(env->interrupt_request & CPU_INTERRUPT_HARD) {
        env->wfi = 0;
    }
    return !env->wfi;
}

static inline void cpu_pc_from_tb(CPUState *env, TranslationBlock *tb)
{
    env->pc = tb->pc;
}
