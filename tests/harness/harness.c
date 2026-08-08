/*
 *  Common tlib instruction-test harness.
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 */
#include "harness.h"
#include "elf.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "callbacks.h"
#include "cpu-defs.h"
#include "exports.h"
#include "infrastructure.h"

HarnessState g_harness;

static HarnessMemoryRegion *find_region(uint64_t address, uint64_t *offset_out)
{
    for(size_t i = 0; i < g_harness.config.region_count; i++) {
        const HarnessMemoryRegion *r = &g_harness.config.regions[i];
        if(address >= r->guest_base && address < r->guest_base + r->size) {
            if(offset_out) {
                *offset_out = address - r->guest_base;
            }
            return (HarnessMemoryRegion *)r;
        }
    }
    return NULL;
}

static int guest_write_bytes(uint64_t guest_addr, const void *data, size_t len)
{
    const uint8_t *src = data;
    while(len > 0) {
        uint64_t offset = 0;
        HarnessMemoryRegion *region = find_region(guest_addr, &offset);
        if(!region) {
            fprintf(stderr, "harness: ELF load hits unmapped address 0x%" PRIx64 "\n", guest_addr);
            return -1;
        }
        size_t chunk = (size_t)(region->size - offset);
        if(chunk > len) {
            chunk = len;
        }
        memcpy(region->host + offset, src, chunk);
        guest_addr += chunk;
        src += chunk;
        len -= chunk;
    }
    return 0;
}

static int elf_write(uint64_t guest_addr, const void *data, size_t len, void *user)
{
    (void)user;
    return guest_write_bytes(guest_addr, data, len);
}

void *tlib_guest_offset_to_host_ptr(uint64_t offset)
{
    uint64_t local = 0;
    HarnessMemoryRegion *region = find_region(offset, &local);
    if(!region) {
        return NULL;
    }
    return region->host + local;
}

void tlib_abort(char *message)
{
    if(message) {
        snprintf(g_harness.abort_message, sizeof(g_harness.abort_message), "%s", message);
        fprintf(stderr, "harness: abort: %s\n", message);
    } else {
        g_harness.abort_message[0] = '\0';
        fprintf(stderr, "harness: abort\n");
    }
    harness_request_exit(HARNESS_EXIT_ABORT);
    exit(HARNESS_EXIT_ABORT);
}

void tlib_log(int32_t level, char *message)
{
    (void)level;
    if(message) {
        fprintf(stderr, "tlib: %s\n", message);
    }
}

static int dispatch_io_read(uint64_t address, uint64_t *value_out, unsigned width)
{
    if(!g_harness.running) {
        *value_out = 0;
        return 0;
    }
    tlib_assert(g_harness.config.on_io_read != NULL);
    return g_harness.config.on_io_read(address, value_out, width, g_harness.config.io_user);
}

static int dispatch_io_write(uint64_t address, uint64_t value, unsigned width)
{
    if(!g_harness.running) {
        return 0;
    }
    tlib_assert(g_harness.config.on_io_write != NULL);
    return g_harness.config.on_io_write(address, value, width, g_harness.config.io_user);
}

uint64_t tlib_read_byte(uint64_t address, uint64_t cpustate)
{
    (void)cpustate;
    uint64_t value = 0;
    if(dispatch_io_read(address, &value, 1) != 0) {
        tlib_set_return_request();
    }
    return value & 0xffu;
}

uint64_t tlib_read_word(uint64_t address, uint64_t cpustate)
{
    (void)cpustate;
    uint64_t value = 0;
    if(dispatch_io_read(address, &value, 2) != 0) {
        tlib_set_return_request();
    }
    return value & 0xffffu;
}

uint64_t tlib_read_double_word(uint64_t address, uint64_t cpustate)
{
    (void)cpustate;
    uint64_t value = 0;
    if(dispatch_io_read(address, &value, 4) != 0) {
        tlib_set_return_request();
    }
    return value & 0xffffffffu;
}

uint64_t tlib_read_quad_word(uint64_t address, uint64_t cpustate)
{
    (void)cpustate;
    uint64_t value = 0;
    if(dispatch_io_read(address, &value, 8) != 0) {
        tlib_set_return_request();
    }
    return value;
}

void tlib_write_byte(uint64_t address, uint64_t value, uint64_t cpustate)
{
    (void)cpustate;
    if(dispatch_io_write(address, value & 0xffu, 1) != 0) {
        tlib_set_return_request();
    }
}

void tlib_write_word(uint64_t address, uint64_t value, uint64_t cpustate)
{
    (void)cpustate;
    if(dispatch_io_write(address, value & 0xffffu, 2) != 0) {
        tlib_set_return_request();
    }
}

void tlib_write_double_word(uint64_t address, uint64_t value, uint64_t cpustate)
{
    (void)cpustate;
    if(dispatch_io_write(address, value & 0xffffffffu, 4) != 0) {
        tlib_set_return_request();
    }
}

void tlib_write_quad_word(uint64_t address, uint64_t value, uint64_t cpustate)
{
    (void)cpustate;
    if(dispatch_io_write(address, value, 8) != 0) {
        tlib_set_return_request();
    }
}

void harness_request_exit(int exit_code)
{
    g_harness.finished = 1;
    g_harness.exit_code = exit_code;
    if(g_harness.running) {
        tlib_set_return_request();
    }
}

void harness_print_report(uint16_t status, uint16_t test_id, uint16_t assert_id, uint16_t expect, uint16_t actual,
                          uint16_t ignored)
{
    fprintf(stderr, "status=%u test_id=%u assert_id=%u expect=0x%04x actual=0x%04x ignored=%u\n", status, test_id,
            assert_id, expect, actual, ignored);
}

int harness_init(const HarnessConfig *config)
{
    memset(&g_harness, 0, sizeof(g_harness));
    g_harness.config = *config;
    g_harness.exit_code = HARNESS_EXIT_ERROR;
    g_harness.running = 0;

    if(tlib_init((char *)config->cpu_name) != 0) {
        fprintf(stderr, "harness: tlib_init failed\n");
        return -1;
    }

    for(size_t i = 0; i < config->region_count; i++) {
        const HarnessMemoryRegion *r = &config->regions[i];
        if(!r->host || r->size == 0) {
            fprintf(stderr, "harness: invalid memory region %zu\n", i);
            return -1;
        }
        memset(r->host, 0, (size_t)r->size);
        tlib_map_range(r->guest_base, r->size);
    }

    for(size_t i = 0; i < config->io_page_count; i++) {
        tlib_set_page_io_accessed(config->io_pages[i]);
    }

    return 0;
}

void harness_dispose(void)
{
    tlib_dispose();
}

int harness_load_elf(const char *path)
{
    return harness_elf_load_file(path, elf_write, NULL);
}

int harness_run(void)
{
    const uint64_t max_insns = g_harness.config.max_insns ? g_harness.config.max_insns : UINT64_C(1000000);
    const uint32_t chunk = 64 * 1024;

    g_harness.finished = 0;
    g_harness.exit_code = HARNESS_EXIT_ABORT;
    g_harness.executed_insns = 0;
    g_harness.running = 1;

    tlib_reset();

    while(!g_harness.finished) {
        if(g_harness.executed_insns >= max_insns) {
            fprintf(stderr, "harness: max instruction count exceeded (%" PRIu64 ")\n", max_insns);
            g_harness.exit_code = HARNESS_EXIT_ABORT;
            break;
        }

        uint64_t remaining = max_insns - g_harness.executed_insns;
        uint32_t step = chunk;
        if(remaining < step) {
            step = (uint32_t)remaining;
        }

        int32_t result = tlib_execute(step);
        uint64_t ran = tlib_get_executed_instructions();
        g_harness.executed_insns += ran;

        if(g_harness.finished) {
            break;
        }

        if(result == EXCP_WFI) {
            fprintf(stderr, "harness: CPU entered WFI unexpectedly\n");
            g_harness.exit_code = HARNESS_EXIT_ABORT;
            break;
        }

        /* TODO: support debugger stops (EXCP_DEBUG / breakpoints) without
         * treating them as harness errors. */
        if(ran == 0 && result != EXCP_INTERRUPT && result != EXCP_RETURN_REQUEST) {
            fprintf(stderr, "harness: execute stalled (result=%d)\n", result);
            g_harness.exit_code = HARNESS_EXIT_ABORT;
            break;
        }
    }

    return g_harness.exit_code;
}
