$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN 2
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_Z | PSW_AC)
    ACT
        CMPW    AX, #0xDEAE
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_PSW, 0x01
END 1

TEST    2
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY | PSW_AC)
    ACT 
        CMPW    AX, #0xDEAD
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_PSW, 0x40
END 2

TEST    3
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        CMPW    AX, #0xDEAC
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_PSW, 0x00
END 3

TEST    4
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_Z | PSW_AC)
    ACT
        CMPW    AX, #0xDFAD
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_PSW, 0x01
END 4

TEST    5
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV     PSW, #(PSW_Z | PSW_CY | PSW_CY)
    ACT
        CMPW    AX, #0xDDAE
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG REG_PSW, 0x00
END 5

TEST    6
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    BC, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        CMPW    AX, BC
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_B, 0xDE
        ASSERT_REG  REG_C, 0xAD
        ASSERT_REG  REG_PSW, 0x40 
END 6

TEST    7
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    DE, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        CMPW    AX, DE
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_D, 0xDE
        ASSERT_REG  REG_E, 0xAD
        ASSERT_REG  REG_PSW, 0x40 
END 7

TEST    8
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    HL, #0xDEAD
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        CMPW    AX, HL
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_H, 0xDE
        ASSERT_REG  REG_L, 0xAD
        ASSERT_REG  REG_PSW, 0x40 
END 8

TEST    9
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV    !LOWW(testdata+0), #0xAD
        MOV    !LOWW(testdata+1), #0xDE
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        CMPW    AX, !LOWW(testdata)
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_MEM  testdata, 1, 0xDE
        ASSERT_MEM  testdata, 0, 0xAD
        ASSERT_REG  REG_PSW, 0x40 
END 9

TEST    10
    ARRANGE
        MOVW    AX, #0xDEAD
        MOV    !LOWW(testdata+2), #0xAD
        MOV    !LOWW(testdata+3), #0xDE
        MOVW    HL, #LOWW(testdata)
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        CMPW    AX, [HL+2]
    ASSERT
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
        ASSERT_MEM  testdata, 3, 0xDE
        ASSERT_MEM  testdata, 2, 0xAD
        ASSERT_REG  REG_PSW, 0x40 
END 10

TEST_FOOTER