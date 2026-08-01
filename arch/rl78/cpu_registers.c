/*
 *  RL78 registers interface
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
#include "cpu_registers.h"

uint32_t *get_reg_pointer_32(int reg)
{
    switch(reg) {
        case R_0_32 ... R_7_32:
            return &(cpu->regs[cpu->psw.rbs][reg - R_0_32]);
        case PC_32:
            return &(cpu->pc);
        case SP_32:
            return &(cpu->sp);
        case ES_32:
            return &(cpu->es);
        case CS_32:
            return &(cpu->cs);
        case PSW_CY_32:
            return &(cpu->psw.cy);
        case PSW_ISP_32:
            return &(cpu->psw.isp);
        case PSW_RBS_32:
            return &(cpu->psw.rbs);
        case PSW_AC_32:
            return &(cpu->psw.ac);
        case PSW_Z_32:
            return &(cpu->psw.z);
        case PSW_IE_32:
            return &(cpu->psw.ie);
        default:
            break;
    }
    return NULL;
}

CPU_REGISTER_ACCESSOR(32)
