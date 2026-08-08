/*
 *  Minimal ELF32 little-endian PT_LOAD loader for CCRL .abs images.
 *
 *  Copyright (c) 2026 Soya Ohnishi
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 */
#pragma once

#include <stddef.h>
#include <stdint.h>

typedef int (*HarnessElfWriteFn)(uint64_t guest_addr, const void *data, size_t len, void *user);

int harness_elf_load_file(const char *path, HarnessElfWriteFn write_fn, void *user);
