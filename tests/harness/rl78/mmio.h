/*
 *  RL78 test MMIO register map (guest physical).
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

/* IO page base (256-byte page). Near addressing !addr16 maps here. */
#define TEST_MMIO_BASE 0x000F0000u

#define TEST_MMIO_OFF_STATUS    0x00u
#define TEST_MMIO_OFF_TEST_ID   0x02u
#define TEST_MMIO_OFF_ASSERT_ID 0x04u
#define TEST_MMIO_OFF_EXPECT    0x06u
#define TEST_MMIO_OFF_ACTUAL    0x08u
#define TEST_MMIO_OFF_IGNORED   0x0Au

#define TEST_MMIO_SIZE 0x100u

static inline int test_mmio_contains(uint64_t address)
{
    return address >= TEST_MMIO_BASE && address < (TEST_MMIO_BASE + TEST_MMIO_SIZE);
}
