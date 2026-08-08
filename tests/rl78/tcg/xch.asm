$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #0xDE
        MOV X, #0xAD
    ACT
        XCH A, X
    ASSERT
        ASSERT_REGS 0xDE, 0xAD, 0, 0, 0, 0, 0, 0
END 1

TEST    2
    ARRANGE
        MOV A, #0xBE
        MOV C, #0xEF
    ACT
        XCH A, C
    ASSERT
        ASSERT_REGS 0, 0xEF, 0xBE, 0, 0, 0, 0, 0
END 2

TEST    3
    ARRANGE
        MOV A, #0xDE
        MOV B, #0xAD
    ACT
        XCH A, B
    ASSERT
        ASSERT_REGS 0, 0xAD, 0, 0xDE, 0, 0, 0, 0
END 3

TEST    4
    ARRANGE
        MOV A, #0xBE
        MOV E, #0xEF
    ACT
        XCH A, E
    ASSERT
        ASSERT_REGS 0, 0xEF, 0 ,0 ,0xBE, 0, 0, 0
END 4

TEST    5
    ARRANGE
        MOV A, #0xDE
        MOV D, #0xAD
    ACT
        XCH A, D
    ASSERT
        ASSERT_REGS 0, 0xAD, 0, 0, 0, 0xDE, 0, 0
END 5

TEST    6
    ARRANGE
        MOV A, #0xBE
        MOV L, #0xEF
    ACT
        XCH A, L
    ASSERT
        ASSERT_REGS 0, 0xEF, 0, 0, 0, 0, 0xBE, 0
END 6

TEST    7
    ARRANGE
        MOV A, #0xDE
        MOV H, #0xAD
    ACT
        XCH A, H
    ASSERT
        ASSERT_REGS 0, 0xAD, 0, 0, 0, 0, 0, 0xDE
END 7

TEST    8
    ARRANGE
        MOV A, #0xBE
        MOV !testdata, #0xEF
    ACT
        XCH A, !testdata
    ASSERT
        ASSERT_REGS 0, 0xEF, 0, 0, 0, 0, 0, 0
        ASSERT_MEM  testdata, 0, 0xBE
END 8

TEST    9
    ARRANGE
        MOV     A, #0xDE
        MOVW    DE, #LOWW(testdata)
        MOV     !testdata, #0xAD
    ACT
        XCH     A, [DE]
    ASSERT
        ASSERT_REG  REG_A, 0xAD
        ASSERT_MEM  testdata, 0, 0xDE
END 9

TEST    10
    ARRANGE
        MOV     A, #0xBE
        MOVW    DE, #LOWW(testdata)
        MOV     !LOWW(testdata+255), #0xEF
    ACT
        XCH     A, [DE+255]
    ASSERT
        ASSERT_REG  REG_A, 0xEF
        ASSERT_MEM  testdata, 255, 0xBE
END 10

TEST    11
    ARRANGE
        MOV     A, #0xDE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata), #0xAD
    ACT
        XCH     A, [HL]
    ASSERT
        ASSERT_REG  REG_A, 0xAD
        ASSERT_MEM  testdata, 0, 0xDE
END 11

TEST    12
    ARRANGE 
        MOV     A, #0xBE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+255), #0xEF
    ACT
        XCH     A, [HL+255]
    ASSERT
        ASSERT_REG  REG_A, 0xEF
        ASSERT_MEM  testdata, 255, 0xBE
END 12

TEST    13
    ARRANGE
        MOV     A, #0xDE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+42), #0xAD
        MOV     B, #42
    ACT
        XCH     A, [HL+B]
    ASSERT 
        ASSERT_REG  REG_A, 0xAD
        ASSERT_MEM  testdata, 42, 0xDE
END 13

TEST    14
    ARRANGE
        MOV     A, #0xBE
        MOVW    HL, #LOWW(testdata)
        MOV    !LOWW(testdata+43), #0xEF
        MOV     C, #43
    ACT
        XCH     A, [HL+C]
    ASSERT
        ASSERT_REG  REG_A, 0xEF
        ASSERT_MEM  testdata, 43, 0xBE
END 14

TEST_FOOTER