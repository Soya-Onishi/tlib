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
#pragma once

#include "cpu-defs.h"

//  REMARK: we use #ifdef/#endif notation (no #else) due to the limitation of `RegisterEnumParser.cs`.
typedef enum {
    //  Byte registers of the currently selected register bank (X, A, C, B, E, D, L, H).
    R_0_32 = 0,
    R_1_32 = 1,
    R_2_32 = 2,
    R_3_32 = 3,
    R_4_32 = 4,
    R_5_32 = 5,
    R_6_32 = 6,
    R_7_32 = 7,

    PC_32 = 8,
    SP_32 = 9,
    ES_32 = 10,
    CS_32 = 11,

    PSW_CY_32  = 12,
    PSW_ISP_32 = 13,
    PSW_RBS_32 = 14,
    PSW_AC_32  = 15,
    PSW_Z_32   = 16,
    PSW_IE_32  = 17,
} Registers32;

uint32_t *get_reg_pointer_32(int reg);
