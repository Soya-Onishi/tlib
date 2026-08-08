/*
 *  RL78 tlib instruction-test harness entrypoint.
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 */
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

static uint16_t mmio_load16(const Rl78TestMmio *m, uint64_t offset)
{
    switch(offset) {
        case TEST_MMIO_OFF_STATUS:
            return m->status;
        case TEST_MMIO_OFF_TEST_ID:
            return m->test_id;
        case TEST_MMIO_OFF_ASSERT_ID:
            return m->assert_id;
        case TEST_MMIO_OFF_EXPECT:
            return m->expect;
        case TEST_MMIO_OFF_ACTUAL:
            return m->actual;
        case TEST_MMIO_OFF_IGNORED:
            return m->ignored;
        default:
            return 0;
    }
}

static void mmio_store16(Rl78TestMmio *m, uint64_t offset, uint16_t value)
{
    switch(offset) {
        case TEST_MMIO_OFF_STATUS:
            m->status = value;
            m->status_written = 1;
            break;
        case TEST_MMIO_OFF_TEST_ID:
            m->test_id = value;
            break;
        case TEST_MMIO_OFF_ASSERT_ID:
            m->assert_id = value;
            break;
        case TEST_MMIO_OFF_EXPECT:
            m->expect = value;
            break;
        case TEST_MMIO_OFF_ACTUAL:
            m->actual = value;
            break;
        case TEST_MMIO_OFF_IGNORED:
            m->ignored = value;
            break;
        default:
            break;
    }
}

static void mmio_store_bytes(Rl78TestMmio *m, uint64_t offset, uint64_t value, unsigned width)
{
    for(unsigned i = 0; i < width; i++) {
        uint64_t off = offset + i;
        uint64_t aligned = off & ~UINT64_C(1);
        uint16_t cur = mmio_load16(m, aligned);
        unsigned shift = (unsigned)((off & 1u) * 8u);
        uint16_t mask = (uint16_t)(0xffu << shift);
        uint16_t updated = (uint16_t)((cur & ~mask) | (((value >> (8u * i)) & 0xffu) << shift));
        mmio_store16(m, aligned, updated);
    }
}

static uint64_t mmio_load_bytes(const Rl78TestMmio *m, uint64_t offset, unsigned width)
{
    uint64_t value = 0;
    for(unsigned i = 0; i < width; i++) {
        uint64_t off = offset + i;
        uint16_t reg = mmio_load16(m, off & ~UINT64_C(1));
        uint8_t b = (uint8_t)((reg >> ((off & 1u) * 8u)) & 0xffu);
        value |= ((uint64_t)b) << (8u * i);
    }
    return value;
}

static int rl78_on_io_read(uint64_t address, uint64_t *value_out, unsigned width, void *user)
{
    Rl78TestMmio *m = user;
    if(test_mmio_contains(address)) {
        *value_out = mmio_load_bytes(m, address - TEST_MMIO_BASE, width);
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
        mmio_store_bytes(m, address - TEST_MMIO_BASE, value, width);
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

static void usage(const char *argv0)
{
    fprintf(stderr, "usage: %s <guest.abs> [--max-insns N]\n", argv0);
}

int main(int argc, char **argv)
{
    const char *guest_path = NULL;
    uint64_t max_insns = 1000000;

    for(int i = 1; i < argc; i++) {
        if(strcmp(argv[i], "--max-insns") == 0) {
            if(i + 1 >= argc) {
                usage(argv[0]);
                return HARNESS_EXIT_ERROR;
            }
            max_insns = strtoull(argv[++i], NULL, 0);
        } else if(argv[i][0] == '-') {
            usage(argv[0]);
            return HARNESS_EXIT_ERROR;
        } else if(!guest_path) {
            guest_path = argv[i];
        } else {
            usage(argv[0]);
            return HARNESS_EXIT_ERROR;
        }
    }

    if(!guest_path) {
        usage(argv[0]);
        return HARNESS_EXIT_ERROR;
    }

    HarnessMemoryRegion regions[] = {
        { .guest_base = RL78_ROM_BASE, .size = RL78_ROM_SIZE, .host = g_rom },
        { .guest_base = RL78_RAM_BASE, .size = RL78_RAM_SIZE, .host = g_ram },
    };
    uint64_t io_pages[] = { TEST_MMIO_BASE };

    HarnessConfig config = {
        .cpu_name = "rl78",
        .max_insns = max_insns,
        .regions = regions,
        .region_count = sizeof(regions) / sizeof(regions[0]),
        .io_pages = io_pages,
        .io_page_count = sizeof(io_pages) / sizeof(io_pages[0]),
        .on_io_read = rl78_on_io_read,
        .on_io_write = rl78_on_io_write,
        .io_user = &g_mmio,
    };

    if(harness_init(&config) != 0) {
        return HARNESS_EXIT_ERROR;
    }

    if(harness_load_elf(guest_path) != 0) {
        harness_dispose();
        return HARNESS_EXIT_ERROR;
    }

    int rc = harness_run();
    harness_dispose();
    return rc;
}
