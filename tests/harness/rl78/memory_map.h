/*
 *  RL78 guest memory map for the instruction-test harness (R7F100GxN-ish).
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 */
#pragma once

#include <stdint.h>

#define RL78_ROM_BASE 0x00000000u
#define RL78_ROM_SIZE 0x000C0000u /* 768 KiB: 0x00000–0xBFFFF */

#define RL78_RAM_BASE 0x000F3F00u
#define RL78_RAM_SIZE 0x0000C000u /* 48 KiB: 0xF3F00–0xFFEFF */

#define RL78_SFR_BASE 0x000FFF00u
#define RL78_SFR_END  0x00100000u

static inline int rl78_rom_contains(uint64_t address)
{
    return address < (RL78_ROM_BASE + RL78_ROM_SIZE);
}

static inline int rl78_ram_contains(uint64_t address)
{
    return address >= RL78_RAM_BASE && address < (RL78_RAM_BASE + RL78_RAM_SIZE);
}
