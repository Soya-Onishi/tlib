#include "def-helper.h"

DEF_HELPER_FLAGS_5(rl78_btclr, 0, i32, env, i32, i32, i32, i32)
DEF_HELPER_FLAGS_3(rl78_btclr_paddr, 0, i32, env, i32, i32)
DEF_HELPER_FLAGS_3(rl78_stb, 0, void, env, i32, i32)
/* Write to SFR 0xFB / phys 0xFFFFB — multiply/divide/MAC unit command. */
DEF_HELPER_FLAGS_2(rl78_mdu_cmd, 0, void, env, i32)

#include "def-helper.h"
