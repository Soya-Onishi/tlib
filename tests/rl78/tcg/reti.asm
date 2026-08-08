$INCLUDE    "../harness/prelude.asm"

PUSH_PC .MACRO  symbol
    MOVW    AX, #LOWW(symbol)
    MOVW    [SP+0], AX
    MOVW    AX, #HIGHW(symbol)
    MOVW    [SP+2], AX
.ENDM

TEST_HEADER
TEST    1
    ARRANGE
    ACT
        MOVW    SP, #0xFE00
        PUSH_PC test1_jumpdst
        MOV     [SP+3], #0xD7
        RETI
        MOV     !LOWW(invalid_jump_data), #1
test1_jumpdst:
        MOV     !LOWW(expect_jump_data), #1
    ASSERT
        ASSERT_REG  REG_PSW, 0xD7
        ASSERT_MEM  invalid_jump_data, 0, 0
        ASSERT_MEM  expect_jump_data, 0, 1
        ASSERT_SP   0xFE04
END 1

TEST    2
    ARRANGE
    ACT
        MOVW    SP, #0xFDC0
        PUSH_PC test2_jumpdst
        MOV     [SP+3], #0x57
        RETI
        MOV     !LOWW(invalid_jump_data), #2
test2_goback:
    ASSERT
        ASSERT_REG  REG_PSW, 0x57
        ASSERT_MEM  invalid_jump_data, 0, 0
        ASSERT_MEM  expect_jump_data, 0, 2
END 2
TEST_FOOTER

.text   .CSEG   AT  0x11234
        MOV     !LOWW(invalid_jump_data), #2
test2_jumpdst:
        MOV     !LOWW(expect_jump_data), #2
        PUSH_PC test2_goback
        RET

.bss    .DSEG   BSS
invalid_jump_data:
    .DS 1
expect_jump_data:
    .DS 1