$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN  2
testdata:
    .DS 512

TEST_HEADER

MOV !(testdata+0), #0xAD
MOV !(testdata+1), #0xDE
MOV !(testdata+2), #0xEF
MOV !(testdata+3), #0xBE
MOV !(testdata+4), #0x34
MOV !(testdata+5), #0x12
MOV !(testdata+6), #0x78
MOV !(testdata+7), #0x56

TEST    1
    ARRANGE
    ACT
        MOVW    AX, !LOWW(testdata+0)
        MOVW    BC, !LOWW(testdata+2)
        MOVW    DE, !LOWW(testdata+4)
        MOVW    HL, !LOWW(testdata+6)
    ASSERT
        ASSERT_REGS 0xAD, 0xDE, 0xEF, 0xBE, 0x34, 0x12, 0x78, 0x56
END 1

TEST    2
    ARRANGE 
        MOVW    DE, #LOWW(testdata)
    ACT
        MOVW    AX, [DE]
    ASSERT
        ASSERT_REG REG_X, 0xAD
        ASSERT_REG REG_A, 0xDE
END 2

TEST    3
    ARRANGE 
        MOVW    HL, #LOWW(testdata+2)
    ACT
        MOVW    AX, [HL]
    ASSERT
        ASSERT_REG REG_X, 0xEF
        ASSERT_REG REG_A, 0xBE
END 3

TEST    4
    ARRANGE 
        MOVW    DE, #LOWW(testdata+1)
    ACT
        MOVW    AX, [DE]
    ASSERT
        ASSERT_REG REG_X, 0xAD
        ASSERT_REG REG_A, 0xDE
END 4

TEST    5
    ARRANGE 
        MOVW    HL, #LOWW(testdata+3)
    ACT
        MOVW    AX, [HL]
    ASSERT
        ASSERT_REG REG_X, 0xEF
        ASSERT_REG REG_A, 0xBE
END 5

TEST    6
    ARRANGE
        MOVW    DE, #LOWW(testdata)
    ACT
        MOVW    AX, [DE+4]
    ASSERT
        ASSERT_REG  REG_X, 0x34
        ASSERT_REG  REG_A, 0x12
END 6

TEST    7
    ARRANGE
        MOVW    HL, #LOWW(testdata)
    ACT
        MOVW    AX, [HL+6]
    ASSERT
        ASSERT_REG  REG_X, 0x78
        ASSERT_REG  REG_A, 0x56
END 7

TEST    8
    ARRANGE
        MOVW    DE, #LOWW(testdata+254)
        MOVW    AX, #0x1234
    ACT
        MOVW    [DE], AX
    ASSERT
        ASSERT_MEM  testdata, 254, 0x34
        ASSERT_MEM  testdata, 255, 0x12
END 8

TEST    9
    ARRANGE
        MOVW    HL, #LOWW(testdata+252)
        MOVW    AX, #0x5678
    ACT
        MOVW    [HL], AX
    ASSERT
        ASSERT_MEM  testdata, 252, 0x78
        ASSERT_MEM  testdata, 253, 0x56
END 9

TEST    10
    ARRANGE
        MOVW    DE, #LOWW(testdata)
        MOVW    AX, #0xDEAD
    ACT
        MOVW    [DE+250], AX
    ASSERT
        ASSERT_MEM  testdata, 250, 0xAD
        ASSERT_MEM  testdata, 251, 0xDE
END 10


TEST    11
    ARRANGE
        MOVW    HL, #LOWW(testdata)
        MOVW    AX, #0xBEEF
    ACT
        MOVW    [HL+248], AX
    ASSERT
        ASSERT_MEM  testdata, 248, 0xEF
        ASSERT_MEM  testdata, 249, 0xBE
END 11

TEST    12
    ARRANGE
        MOVW    SP, #LOWW(testdata)
    ACT
        MOVW    AX, [SP+2]
    ASSERT
        ASSERT_REG  REG_X, 0xEF
        ASSERT_REG  REG_A, 0xBE
END 12

TEST    13
    ARRANGE
        MOVW    SP, #LOWW(testdata)
        MOVW    AX, #0x1234
    ACT
        MOVW    [SP+246], AX
    ASSERT
        ASSERT_MEM  testdata, 246, 0x34
        ASSERT_MEM  testdata, 247, 0x12
END 13

TEST    14
    ARRANGE
        MOV     B, #4
    ACT
        MOVW    AX, LOWW(testdata)[B]
    ASSERT
        ASSERT_REG  REG_X, 0x34
        ASSERT_REG  REG_A, 0x12
END 14

TEST    15
    ARRANGE
        MOV     C, #2
    ACT
        MOVW    AX, LOWW(testdata)[C]
    ASSERT
        ASSERT_REG  REG_X, 0xEF
        ASSERT_REG  REG_A, 0xBE
END 15

TEST    16
    ARRANGE
        MOVW    BC, #256
        MOVW    AX, #0xDEAD
        MOVW    !LOWW(testdata+256), AX
        MOVW    AX, #0x0
    ACT
        MOVW    AX, LOWW(testdata)[BC]
    ASSERT
        ASSERT_REG  REG_X, 0xAD
        ASSERT_REG  REG_A, 0xDE
END 16

TEST    17
    ARRANGE
        MOVW    BC, #258
        MOVW    AX, #0xBEEF
    ACT
        MOVW    LOWW(testdata)[BC], AX
    ASSERT
        ASSERT_MEM  testdata, 258, 0xEF
        ASSERT_MEM  testdata, 259, 0xBE
END 17

TEST_FOOTER