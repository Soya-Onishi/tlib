/*
 *  Common tlib instruction-test harness API.
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
#include <stddef.h>

enum {
    HARNESS_EXIT_PASS = 0,
    HARNESS_EXIT_FAIL = 1,
    HARNESS_EXIT_ERROR = 2,
};

typedef struct HarnessMemoryRegion {
    uint64_t guest_base;
    uint64_t size;
    uint8_t *host;
} HarnessMemoryRegion;

typedef struct HarnessConfig {
    const char *cpu_name;
    uint64_t max_insns;

    /* Flat RAM/ROM regions registered with tlib_map_range. */
    const HarnessMemoryRegion *regions;
    size_t region_count;

    /* Pages that must always take the IO callback path (test MMIO). */
    const uint64_t *io_pages;
    size_t io_page_count;

    /* Required: guest IO / unassigned accesses. Return non-zero to stop. */
    int (*on_io_read)(uint64_t address, uint64_t *value_out, unsigned width, void *user);
    int (*on_io_write)(uint64_t address, uint64_t value, unsigned width, void *user);
    void *io_user;
} HarnessConfig;

typedef struct HarnessState {
    HarnessConfig config;
    int finished;
    int exit_code;
    uint64_t executed_insns;
    /*
     * False until harness_run() starts. tlib_init()->cpu_reset() reads the
     * reset vector before map_range, so unassigned access must be ignored
     * during init; once running, unassigned access is fatal.
     */
    int running;
    char abort_message[256];
} HarnessState;

extern HarnessState g_harness;

int harness_init(const HarnessConfig *config);
void harness_dispose(void);
int harness_load_elf(const char *path);
int harness_run(void);
void harness_request_exit(int exit_code);
void harness_print_report(uint16_t status, uint16_t test_id, uint16_t assert_id, uint16_t expect,
                          uint16_t actual, uint16_t ignored);
