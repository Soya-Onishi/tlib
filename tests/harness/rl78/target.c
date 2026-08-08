/*
 *  RL78 target glue for the instruction-test harness.
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 */
#include "target.h"

#include <inttypes.h>
#include <stdio.h>

#include "harness.h"
#include "memory_map.h"
#include "mmio.h"

typedef struct {
    uint16_t status;
    uint16_t test_id;
    uint16_t assert_id;
    uint16_t expect;
    uint16_t actual;
    uint16_t ignored;
    int status_written;
} Rl78TestMmio;

static uint8_t g_rom[RL78_ROM_SIZE];
static uint8_t g_ram[RL78_RAM_SIZE];
static Rl78TestMmio g_mmio;
static HarnessMemoryRegion g_regions[2];
static uint64_t g_io_pages[1];

static uint16_t *mmio_reg(Rl78TestMmio *m, uint64_t offset)
{
    switch(offset) {
        case TEST_MMIO_OFF_STATUS:
            return &m->status;
        case TEST_MMIO_OFF_TEST_ID:
            return &m->test_id;
        case TEST_MMIO_OFF_ASSERT_ID:
            return &m->assert_id;
        case TEST_MMIO_OFF_EXPECT:
            return &m->expect;
        case TEST_MMIO_OFF_ACTUAL:
            return &m->actual;
        case TEST_MMIO_OFF_IGNORED:
            return &m->ignored;
        default:
            return NULL;
    }
}

static int mmio_write(Rl78TestMmio *m, uint64_t offset, uint64_t value, unsigned width)
{
    if(width == 2 && (offset & 1u) == 0) {
        uint16_t *reg = mmio_reg(m, offset);
        if(!reg) {
            return -1;
        }
        *reg = (uint16_t)value;
        if(offset == TEST_MMIO_OFF_STATUS) {
            m->status_written = 1;
        }
        return 0;
    }

    if(width == 1) {
        uint64_t aligned = offset & ~UINT64_C(1);
        uint16_t *reg = mmio_reg(m, aligned);
        if(!reg) {
            return -1;
        }
        if(offset & 1u) {
            *reg = (uint16_t)((*reg & 0x00ffu) | ((value & 0xffu) << 8));
        } else {
            *reg = (uint16_t)((*reg & 0xff00u) | (value & 0xffu));
        }
        if(aligned == TEST_MMIO_OFF_STATUS) {
            m->status_written = 1;
        }
        return 0;
    }

    return -1;
}

static int mmio_read(Rl78TestMmio *m, uint64_t offset, uint64_t *value_out, unsigned width)
{
    if(width == 2 && (offset & 1u) == 0) {
        uint16_t *reg = mmio_reg(m, offset);
        if(!reg) {
            return -1;
        }
        *value_out = *reg;
        return 0;
    }

    if(width == 1) {
        uint64_t aligned = offset & ~UINT64_C(1);
        uint16_t *reg = mmio_reg(m, aligned);
        if(!reg) {
            return -1;
        }
        *value_out = (offset & 1u) ? ((*reg >> 8) & 0xffu) : (*reg & 0xffu);
        return 0;
    }

    return -1;
}

static int rl78_on_io_read(uint64_t address, uint64_t *value_out, unsigned width, void *user)
{
    Rl78TestMmio *m = user;
    if(test_mmio_contains(address)) {
        if(mmio_read(m, address - TEST_MMIO_BASE, value_out, width) != 0) {
            fprintf(stderr, "harness: unsupported test MMIO read addr=0x%" PRIx64 " width=%u\n", address, width);
            harness_request_exit(HARNESS_EXIT_ERROR);
            return -1;
        }
        return 0;
    }

    fprintf(stderr, "harness: unassigned read addr=0x%" PRIx64 " width=%u\n", address, width);
    harness_request_exit(HARNESS_EXIT_ERROR);
    return -1;
}

static int rl78_on_io_write(uint64_t address, uint64_t value, unsigned width, void *user)
{
    Rl78TestMmio *m = user;
    if(test_mmio_contains(address)) {
        if(mmio_write(m, address - TEST_MMIO_BASE, value, width) != 0) {
            fprintf(stderr, "harness: unsupported test MMIO write addr=0x%" PRIx64 " width=%u\n", address, width);
            harness_request_exit(HARNESS_EXIT_ERROR);
            return -1;
        }
        if(m->status_written) {
            harness_print_report(m->status, m->test_id, m->assert_id, m->expect, m->actual, m->ignored);
            harness_request_exit(m->status == 0 ? HARNESS_EXIT_PASS : HARNESS_EXIT_FAIL);
        }
        return 0;
    }

    fprintf(stderr, "harness: unassigned write addr=0x%" PRIx64 " value=0x%" PRIx64 " width=%u\n", address, value,
            width);
    harness_request_exit(HARNESS_EXIT_ERROR);
    return -1;
}

void harness_setup(HarnessConfig *config, uint64_t max_insns)
{
    g_regions[0] = (HarnessMemoryRegion) { .guest_base = RL78_ROM_BASE, .size = RL78_ROM_SIZE, .host = g_rom };
    g_regions[1] = (HarnessMemoryRegion) { .guest_base = RL78_RAM_BASE, .size = RL78_RAM_SIZE, .host = g_ram };
    g_io_pages[0] = TEST_MMIO_BASE;

    *config = (HarnessConfig) {
        .cpu_name = "rl78",
        .max_insns = max_insns,
        .regions = g_regions,
        .region_count = sizeof(g_regions) / sizeof(g_regions[0]),
        .io_pages = g_io_pages,
        .io_page_count = sizeof(g_io_pages) / sizeof(g_io_pages[0]),
        .on_io_read = rl78_on_io_read,
        .on_io_write = rl78_on_io_write,
        .io_user = &g_mmio,
    };
}
