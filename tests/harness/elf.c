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
#include "elf.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma pack(push, 1)
typedef struct {
    uint8_t e_ident[16];
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint32_t e_entry;
    uint32_t e_phoff;
    uint32_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_phnum;
    uint16_t e_shentsize;
    uint16_t e_shnum;
    uint16_t e_shstrndx;
} Elf32_Ehdr;

typedef struct {
    uint32_t p_type;
    uint32_t p_offset;
    uint32_t p_vaddr;
    uint32_t p_paddr;
    uint32_t p_filesz;
    uint32_t p_memsz;
    uint32_t p_flags;
    uint32_t p_align;
} Elf32_Phdr;
#pragma pack(pop)

#define EI_MAG0 0
#define EI_MAG1 1
#define EI_MAG2 2
#define EI_MAG3 3
#define EI_CLASS 4
#define EI_DATA 5
#define ELFCLASS32 1
#define ELFDATA2LSB 1
#define PT_LOAD 1

static int read_fully(FILE *fp, void *buf, size_t len)
{
    return fread(buf, 1, len, fp) == len ? 0 : -1;
}

int harness_elf_load_file(const char *path, HarnessElfWriteFn write_fn, void *user)
{
    FILE *fp = fopen(path, "rb");
    if(!fp) {
        fprintf(stderr, "harness: failed to open '%s': %s\n", path, strerror(errno));
        return -1;
    }

    Elf32_Ehdr eh;
    if(read_fully(fp, &eh, sizeof(eh)) != 0) {
        fprintf(stderr, "harness: short ELF header in '%s'\n", path);
        fclose(fp);
        return -1;
    }

    if(eh.e_ident[EI_MAG0] != 0x7f || eh.e_ident[EI_MAG1] != 'E' || eh.e_ident[EI_MAG2] != 'L' ||
       eh.e_ident[EI_MAG3] != 'F') {
        fprintf(stderr, "harness: '%s' is not an ELF file\n", path);
        fclose(fp);
        return -1;
    }
    if(eh.e_ident[EI_CLASS] != ELFCLASS32 || eh.e_ident[EI_DATA] != ELFDATA2LSB) {
        fprintf(stderr, "harness: '%s' is not ELF32 little-endian\n", path);
        fclose(fp);
        return -1;
    }
    if(eh.e_phoff == 0 || eh.e_phnum == 0) {
        fprintf(stderr, "harness: '%s' has no program headers\n", path);
        fclose(fp);
        return -1;
    }
    if(eh.e_phentsize < sizeof(Elf32_Phdr)) {
        fprintf(stderr, "harness: unexpected program header size in '%s'\n", path);
        fclose(fp);
        return -1;
    }

    for(uint16_t i = 0; i < eh.e_phnum; i++) {
        if(fseek(fp, (long)(eh.e_phoff + (uint32_t)i * eh.e_phentsize), SEEK_SET) != 0) {
            fprintf(stderr, "harness: failed to seek program header %u\n", i);
            fclose(fp);
            return -1;
        }

        Elf32_Phdr ph;
        if(read_fully(fp, &ph, sizeof(ph)) != 0) {
            fprintf(stderr, "harness: short program header %u\n", i);
            fclose(fp);
            return -1;
        }

        if(ph.p_type != PT_LOAD || ph.p_memsz == 0) {
            continue;
        }

        /* Prefer physical address for bare-metal CCRL images. */
        uint64_t guest_addr = ph.p_paddr != 0 ? ph.p_paddr : ph.p_vaddr;
        uint8_t *buf = calloc(1, ph.p_memsz);
        if(!buf) {
            fprintf(stderr, "harness: out of memory loading segment %u\n", i);
            fclose(fp);
            return -1;
        }

        if(ph.p_filesz > 0) {
            if(fseek(fp, (long)ph.p_offset, SEEK_SET) != 0 || read_fully(fp, buf, ph.p_filesz) != 0) {
                fprintf(stderr, "harness: failed to read PT_LOAD segment %u\n", i);
                free(buf);
                fclose(fp);
                return -1;
            }
        }

        if(write_fn(guest_addr, buf, ph.p_memsz, user) != 0) {
            fprintf(stderr, "harness: failed to place PT_LOAD segment %u at 0x%lx\n", i,
                    (unsigned long)guest_addr);
            free(buf);
            fclose(fp);
            return -1;
        }
        free(buf);
    }

    fclose(fp);
    return 0;
}
