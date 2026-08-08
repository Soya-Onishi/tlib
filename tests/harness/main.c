/*
 *  tlib instruction-test harness entrypoint.
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 */
#include <stdlib.h>
#include <string.h>

#include "harness.h"
#include "rl78/target.h"

int main(int argc, char **argv)
{
    const char *guest_path = NULL;
    uint64_t max_insns = 1000000;

    for(int i = 1; i < argc; i++) {
        if(strcmp(argv[i], "--max-insns") == 0) {
            if(i + 1 >= argc) {
                return HARNESS_EXIT_ERROR;
            }
            max_insns = strtoull(argv[++i], NULL, 0);
        } else if(argv[i][0] == '-') {
            return HARNESS_EXIT_ERROR;
        } else if(!guest_path) {
            guest_path = argv[i];
        } else {
            return HARNESS_EXIT_ERROR;
        }
    }

    if(!guest_path) {
        return HARNESS_EXIT_ERROR;
    }

    HarnessConfig config;
    harness_rl78_setup(&config, max_insns);

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
