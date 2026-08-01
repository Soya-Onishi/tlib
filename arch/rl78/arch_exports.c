/*
 *  RL78 arch-specific exports (external -> tlib).
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
#include <stdint.h>

#include "cpu.h"
#include "unwind.h"
#include "arch_exports.h"

void tlib_set_rl78_irq(int32_t index, int32_t priority, int32_t enable)
{
    if(enable) {
        cpu->irq_index    = index;
        cpu->irq_priority = (uint8_t)priority;
        cpu_interrupt(cpu, CPU_INTERRUPT_HARD);
    } else {
        cpu->exception_index = -1;
        cpu->irq_index       = -1;
        cpu->irq_priority    = 0;
        cpu_reset_interrupt(cpu, CPU_INTERRUPT_HARD);
    }
}

EXC_VOID_3(tlib_set_rl78_irq, int32_t, index, int32_t, priority, int32_t, enable)
