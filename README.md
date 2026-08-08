# tlib

Translation library (TCG-based) used by Renode and embeddable host harnesses.

## Build

Requires CMake ≥ 3.12 and a C11 compiler. The build produces a static archive (`libtlib.a`).

```bash
cmake -S . -B build \
  -DTARGET_ARCH=rl78 \
  -DTARGET_WORD_SIZE=32
cmake --build build
```

`TARGET_ARCH` must be set (for example `rl78`, `riscv`, `arm`). See `CMakeLists.txt` for the full list.

## Embedding with a static link

Instruction-test hosts can link `libtlib.a` and supply strong definitions for weak callbacks:

```bash
cc -o harness harness.c -L/path/to/build -ltlib -lpthread
```

Typical entry points: `tlib_init`, `tlib_map_range`, `tlib_execute` (see `exports.c`).

Override weak callbacks in the host (strong symbols win at final link):

```c
void *tlib_guest_offset_to_host_ptr(uint64_t offset)
{
    /* host-specific mapping */
    return ...;
}
```

Weak symbols from `libtlib.a` remain overridable by the executable.

## RL78 instruction-test harness

When `TARGET_ARCH=rl78`, the build also produces `tlib-harness`:

```bash
cmake -S . -B build -DTARGET_ARCH=rl78 -DTARGET_WORD_SIZE=32
cmake --build build
./build/tlib-harness guest.abs [--max-insns N]
```

Guest images are CCRL ELF32 `.abs` files published under
[`Soya-Onishi/rl78-qemu-tests` `out/tests/`](https://github.com/Soya-Onishi/rl78-qemu-tests/tree/main/out/tests).
Fetch the branch zip archive, then run:

```bash
python3 tests/rl78/fetch.py
python3 tests/rl78/run.py --harness ./build/tlib-harness
```

`tlib-harness` exit codes: `0` guest PASS, `1` guest FAIL (MMIO STATUS),
`2` host/setup error (CLI, init, ELF load), `3` guest run abort (translate,
unassigned access, max-insns, …).
