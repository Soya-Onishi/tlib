$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN 2
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #0xFFFF
        MOV     PSW, #(PSW_AC)
    ACT
        ADDW    AX, #1
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_PSW, 0x41
END 1

TEST    2
    ARRANGE
        MOVW    AX, #0xFF00
        MOV     PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        ADDW    AX, #0x00FE
    ASSERT
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_X, 0xFE
        ASSERT_REG  REG_PSW, 0x00
END 2

TEST    3
    ARRANGE
        MOVW    AX, #0x00FF
        MOV     PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        ADDW    AX, #0x0001
    ASSERT
        ASSERT_REG  REG_A, 0x01
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_PSW, 0x00
END 3

TEST    4
    ARRANGE
        MOVW    AX, #0x0000
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, #0x0000
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_PSW, 0x40
END 4

TEST    5
    ARRANGE
        MOVW    AX, #0x0000
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, #0x0000
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_PSW, 0x40
END 5

TEST    6
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    BC, #0xBEEF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, BC
    ASSERT
        ASSERT_REG  REG_A, 0x9D
        ASSERT_REG  REG_X, 0x9C
        ASSERT_REG  REG_B, 0xBE
        ASSERT_REG  REG_C, 0xEF
        ASSERT_REG  REG_PSW, 0x01
END 6

TEST    7
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    DE, #0xBEEF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, DE
    ASSERT
        ASSERT_REG  REG_A, 0x9D
        ASSERT_REG  REG_X, 0x9C
        ASSERT_REG  REG_D, 0xBE
        ASSERT_REG  REG_E, 0xEF
        ASSERT_REG  REG_PSW, 0x01
END 7

TEST    8
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    HL, #0xBEEF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, HL
    ASSERT
        ASSERT_REG  REG_A, 0x9D
        ASSERT_REG  REG_X, 0x9C
        ASSERT_REG  REG_H, 0xBE
        ASSERT_REG  REG_L, 0xEF
        ASSERT_REG  REG_PSW, 0x01
END 8

TEST    9
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     !LOWW(testdata+1), #0xBE
        MOV     !LOWW(testdata+0), #0xEF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, !(testdata+0)
    ASSERT
        ASSERT_REG  REG_A, 0x9D
        ASSERT_REG  REG_X, 0x9C
        ASSERT_MEM  testdata, 1, 0xBE
        ASSERT_MEM  testdata, 0, 0xEF
        ASSERT_REG  REG_PSW, 0x01
END 9

TEST    10
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+3), #0xBE
        MOV     !LOWW(testdata+2), #0xEF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        ADDW    AX, [HL+2]
    ASSERT
        ASSERT_REG  REG_A, 0x9D
        ASSERT_REG  REG_X, 0x9C
        ASSERT_MEM  testdata, 3, 0xBE
        ASSERT_MEM  testdata, 2, 0xEF
        ASSERT_REG  REG_PSW, 0x01
END 10

TEST    11
    ARRANGE
        MOVW    SP, #0xFFFE
    ACT
        ADDW    SP, #2
    ASSERT
        ASSERT_SP   0x0000
END 11

TEST    12
    ARRANGE
        MOVW    SP, #0xFFF0
    ACT
        ADDW    SP, #0x3
    ASSERT
        ASSERT_SP   0xFFF2
END 12
TEST_FOOTER