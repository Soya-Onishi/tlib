#include "def-helper.h"

DEF_HELPER_FLAGS_5(rl78_btclr, 0, i32, env, i32, i32, i32, i32)
DEF_HELPER_FLAGS_3(rl78_btclr_paddr, 0, i32, env, i32, i32)
DEF_HELPER_FLAGS_3(rl78_stb, 0, void, env, i32, i32)

#include "def-helper.h"
