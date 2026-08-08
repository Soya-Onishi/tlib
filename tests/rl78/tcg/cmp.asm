$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER
TEST    1
    ARRANGE
        MOV A, #5
        MOV PSW, #(PSW_AC | PSW_CY)
    ACT
        CMP A, #5
    ASSERT
        ASSERT_REG  REG_A, 5
        ASSERT_REG  REG_PSW, 0x40
END 1

TEST    2
    ARRANGE
        MOV A, #0
        MOV PSW, #(PSW_AC | PSW_CY)
    ACT
        CMP A, #0
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 2

TEST    3
    ARRANGE
        MOV A, #0x10
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        CMP A, #1
    ASSERT
        ASSERT_REG  REG_A, 0x10
        ASSERT_REG  REG_PSW, 0x10
END 3

TEST    4
    ARRANGE
        MOV A, #0x0F
        MOV PSW, #(PSW_Z | PSW_AC)
    ACT
        CMP A, #0x10
    ASSERT
        ASSERT_REG  REG_A, 0x0F
        ASSERT_REG  REG_PSW, 0x01
END 4

TEST    5
    ARRANGE
        MOV A, #0
        MOV PSW, #(PSW_Z)
    ACT
        CMP A, #1
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x11
END 5

TEST    6
    ARRANGE
        MOV A, #0
        MOV PSW, #0
    ACT
        CMP0    A
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 6

TEST    7
    ARRANGE
        MOV A, #10
        MOV PSW, #(PSW_Z)
    ACT
        CMP0    A
    ASSERT
        ASSERT_REG  REG_A, 10
        ASSERT_REG  REG_PSW, 0x00
END 7

TEST    9
    ARRANGE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+13), #0
        MOV     PSW, #0
        MOV     X, #0
    ACT
        CMPS    X, [HL+13]
    ASSERT
        ASSERT_REG  REG_X, 0
        ASSERT_MEM  testdata, 13, 0
        ASSERT_REG  REG_PSW, 0x41
END 9

TEST    10
    ARRANGE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+14), #56
        MOV     PSW, #0
	MOV	A, #1
        MOV     X, #56
    ACT
        CMPS    X, [HL+14]
    ASSERT
        ASSERT_REG  REG_X, 56
        ASSERT_MEM  testdata, 14, 56
        ASSERT_REG  REG_PSW, 0x40
END 10

TEST    11
    ARRANGE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+15), #1
        MOV     PSW, #0
        MOV     X, #0x10
    ACT
        CMPS    X, [HL+15]
    ASSERT
        ASSERT_REG  REG_X, 0x10
        ASSERT_REG  REG_PSW, 0x11
END 11

TEST    12
    ARRANGE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata+16), #0x01
        MOV     PSW, #0
        MOV     X, #0x10
    ACT
        CMPS    X, [HL+16]
    ASSERT
        ASSERT_REG  REG_PSW, 0x11
END 12

TEST    13
    ARRANGE
        MOV     !LOWW(testdata+17), #0x01
        MOV     PSW, #0
    ACT
        CMP0    !LOWW(testdata+17)
    ASSERT
        ASSERT_REG  REG_PSW, 0x00
END 13

TEST    14
    ARRANGE
        MOV     !LOWW(testdata+18), #0x00
        MOV     PSW, #0
    ACT
        CMP0    !LOWW(testdata+18)
    ASSERT
        ASSERT_REG  REG_PSW, 0x40
END 14

TEST_FOOTER
