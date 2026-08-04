/*
 *  RL78 emulation helpers
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
#include <string.h>

#include "cpu.h"
#include "cpu-common.h"
#include "arch_callbacks.h"

void cpu_reset(CPUState *env)
{
    RL78PSW psw = {
        .cy  = 0,
        .isp = 3,
        .rbs = 0,
        .ac  = 0,
        .z   = 0,
        .ie  = 0,
    };

    memset(env->regs, 0, sizeof(env->regs));

    env->psw = psw;
    env->sp  = 0;
    env->pmc = 0;
    env->mem = 0;
    env->es  = 0x0F;
    env->cs  = 0x00;
    env->macr = 0;

    env->skip_en  = 0;
    env->skip_req = 0;

    env->irq_index    = -1;
    env->irq_priority = 0;

    /* RL78 fetches the reset vector from address 0x00000 (2 bytes, little endian).
     * When memory is not yet mapped this reads back 0 through the external bus. */
    env->pc = lduw_phys(0x00000);
}

int cpu_init(const char *cpu_model)
{
    cpu_reset(cpu);
    return 0;
}

void tlib_arch_dispose(void) { }

/*
 * Interrupt acceptance. Ported from qemu target/rl78 helper.c
 * (rl78_cpu_do_interrupt). RL78 has no MMU so virtual == physical and the
 * stack/vector accesses go straight through the *_phys helpers.
 */
void do_interrupt(CPUState *env)
{
    const uint32_t irq_index = env->irq_index;
    const uint8_t psw = rl78_cpu_pack_psw(env->psw);

    const uint8_t pc_l = (env->pc >> 0) & 0xFF;
    const uint8_t pc_h = (env->pc >> 8) & 0xFF;
    const uint8_t pc_s = (env->pc >> 16) & 0xFF;

    env->sp -= 4;
    const uint32_t stack_addr = 0xF0000 | env->sp;
    stb_phys(stack_addr + 0, pc_l);
    stb_phys(stack_addr + 1, pc_h);
    stb_phys(stack_addr + 2, pc_s);
    stb_phys(stack_addr + 3, psw);

    const uint32_t vectbl_addr = env->exception_index * 2 + 4;
    env->psw.ie  = 0;
    env->psw.isp = env->irq_priority;
    env->pc      = lduw_phys(vectbl_addr);

    env->irq_index       = -1;
    env->exception_index = -1;

    tlib_on_rl78_irq_ack(irq_index);
}

/*
 * Interrupt candidate evaluation. Ported from rl78_cpu_exec_interrupt.
 * Returns 1 when an interrupt has been accepted (do_interrupt called).
 */
int process_interrupt(int interrupt_request, CPUState *env)
{
    if(interrupt_request & CPU_INTERRUPT_HARD) {
        //  interrupt disabled or a skip is pending -> do not accept
        if(!env->psw.ie || env->skip_en) {
            return 0;
        }

        if(env->irq_index < 0) {
            env->exception_index = -1;
            cpu_reset_interrupt(env, CPU_INTERRUPT_HARD);
            return 0;
        }

        int priority = env->psw.isp + 1;
        if(env->irq_priority < priority) {
            env->exception_index = env->irq_index;
            do_interrupt(env);
            return 1;
        }
    }

    return 0;
}

/* RL78 has no MMU: identity map every access on a 256-byte page basis. */
int arch_tlb_fill(CPUState *env, target_ulong addr, int access_type, int mmu_idx, void *retaddr, int no_page_fault,
                  int access_width, target_phys_addr_t *paddr)
{
    const target_ulong vaddr = addr & TARGET_PAGE_MASK;

    *paddr = addr;
    tlb_set_page(env, vaddr, vaddr, PAGE_READ | PAGE_WRITE | PAGE_EXEC, mmu_idx, TARGET_PAGE_SIZE);

    return TRANSLATE_SUCCESS;
}

/* Identity map: virt == phys (same as QEMU rl78_cpu_get_phys_page_debug). */
target_phys_addr_t cpu_get_phys_page_debug(CPUState *env, target_ulong addr)
{
    return addr;
}

void arch_raise_mmu_fault_exception(CPUState *env, int errcode, int access_type, target_ulong address, void *retaddr)
{
    /* Identity mapping never faults; nothing to do. */
}

/* Transaction filtering by CPU state is not used for RL78. */
uint64_t cpu_get_state_for_memory_transaction(CPUState *env, target_ulong addr, int access_type)
{
    return 0;
}
