/*
 *  Per-target harness setup.
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

/*
 * Implemented by tests/harness/<arch>/target.c (selected via TARGET_ARCH
 * in CMake). Fills config with that arch's memory map and IO hooks.
 */
void harness_setup(HarnessConfig *config, uint64_t max_insns);
