$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN 2
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBW    AX, #0xDEAD
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_X, 0
        ASSERT_REG  REG_PSW, 0x40
END 1

TEST    2
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_Z)
    ACT
        SUBW    AX, #0xDEAE
    ASSERT
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_PSW, 0x01
END 2

TEST    3
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    BC, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBW    AX, BC
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_B, 0xDE
        ASSERT_REG  REG_C, 0xAD
        ASSERT_REG  REG_PSW, 0x40
END 3

TEST    4
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    DE, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBW    AX, DE
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_D, 0xDE
        ASSERT_REG  REG_E, 0xAD
        ASSERT_REG  REG_PSW, 0x40
END 4

TEST    5
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    HL, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBW    AX, HL
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_H, 0xDE
        ASSERT_REG  REG_L, 0xAD
        ASSERT_REG  REG_PSW, 0x40
END 5

TEST    6
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     !LOWW(testdata+1), #0xDE
        MOV     !LOWW(testdata+0), #0xAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBW    AX, !LOWW(testdata+0)
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_MEM  testdata, 1, 0xDE
        ASSERT_MEM  testdata, 0, 0xAD
        ASSERT_REG  REG_PSW, 0x40
END 6

TEST    7
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+3), #0xDE
        MOV     !LOWW(testdata+2), #0xAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBW    AX, [HL+2]
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_MEM  testdata, 3, 0xDE
        ASSERT_MEM  testdata, 2, 0xAD
        ASSERT_REG  REG_PSW, 0x40
END 7

TEST    8
    ARRANGE
        MOVW    SP, #0x0000
    ACT
        SUBW    SP, #2
    ASSERT
        ASSERT_SP   0xFFFE
END 11

TEST    9
    ARRANGE
        MOVW    SP, #0xFFF0
    ACT
        SUBW    SP, #0x3
    ASSERT
        ASSERT_SP   0xFFEC
END 9


TEST_FOOTER