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
#pragma once

#include "harness.h"

/* Fill config with RL78 memory map, test MMIO hooks, and backing buffers. */
void harness_rl78_setup(HarnessConfig *config, uint64_t max_insns);
