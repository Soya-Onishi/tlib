$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 512

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #255
        MOV X, #1
        MOV PSW, #0
    ACT
        ADD A, X
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_PSW, 0x51
END 1

TEST    2
    ARRANGE
        MOV A, #254
        MOV C, #1
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD A, C
    ASSERT
        ASSERT_REG  REG_A, 255
        ASSERT_REG  REG_C, 1
        ASSERT_REG  REG_PSW, 0x00
END 2

TEST    3
    ARRANGE
        MOV A, #0xF0
        MOV B, #0x10
        MOV PSW, #(PSW_AC)
    ACT
        ADD A, B
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_B, 0x10
        ASSERT_REG  REG_PSW, 0x41
END 3

TEST    4
    ARRANGE
        MOV A, #0x0F
        MOV E, #0x01
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD A, E
    ASSERT
        ASSERT_REG  REG_A, 0x10
        ASSERT_REG  REG_E, 0x01
        ASSERT_REG  REG_PSW, 0x10
END 4

TEST    5
    ARRANGE
        MOV A, #0x00
        MOV D, #0x00
        MOV PSW, #(PSW_Z)
    ACT
        ADD A, D
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_D, 0
        ASSERT_REG  REG_PSW, 0x40
END 5

TEST    6
    ARRANGE
        MOV A, #255
        MOV L, #255
        MOV PSW, #(PSW_CY | PSW_AC)
    ACT
        ADD A, L
    ASSERT
        ASSERT_REG  REG_A, 254
        ASSERT_REG  REG_L, 255
        ASSERT_REG  REG_PSW, 0x11
END 6

TEST    7
    ARRANGE
        MOV A, #10
        MOV H, #42
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD A, H
    ASSERT
        ASSERT_REG  REG_A, 52
        ASSERT_REG  REG_H, 42
        ASSERT_REG  REG_PSW, 0x10
END 7

TEST    8
    ARRANGE
        MOV A, #10
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD A, A
    ASSERT
        ASSERT_REG  REG_A, 20
        ASSERT_REG  REG_PSW, 0x10
END 8

TEST    9
    ARRANGE
        MOV A, #255
        MOV X, #1
        MOV PSW, #0
    ACT
        ADD X, A
    ASSERT
        ASSERT_REG  REG_A, 255
        ASSERT_REG  REG_X, 0
        ASSERT_REG  REG_PSW, 0x51
END 9

TEST    10
    ARRANGE
        MOV A, #254
        MOV C, #1
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD C, A
    ASSERT
        ASSERT_REG  REG_A, 254
        ASSERT_REG  REG_C, 255
        ASSERT_REG  REG_PSW, 0x00
END 10

TEST    11
    ARRANGE
        MOV A, #0xF0
        MOV B, #0x10
        MOV PSW, #(PSW_AC)
    ACT
        ADD B, A
    ASSERT
        ASSERT_REG  REG_A, 0xF0
        ASSERT_REG  REG_B, 0
        ASSERT_REG  REG_PSW, 0x41
END 11

TEST    12
    ARRANGE
        MOV A, #0x0F
        MOV E, #0x01
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD E, A
    ASSERT
        ASSERT_REG  REG_A, 15
        ASSERT_REG  REG_E, 0x10
        ASSERT_REG  REG_PSW, 0x10
END 12

TEST    13
    ARRANGE
        MOV A, #0x00
        MOV D, #0x00
        MOV PSW, #(PSW_Z)
    ACT
        ADD D, A
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_D, 0x00
        ASSERT_REG  REG_PSW, 0x40
END 13

TEST    14
    ARRANGE
        MOV A, #255
        MOV L, #255
        MOV PSW, #(PSW_CY | PSW_AC)
    ACT
        ADD L, A
    ASSERT
        ASSERT_REG  REG_A, 255
        ASSERT_REG  REG_L, 254
        ASSERT_REG  REG_PSW, 0x11
END 14

TEST    15
    ARRANGE
        MOV A, #10
        MOV H, #42
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        ADD H, A
    ASSERT
        ASSERT_REG  REG_A, 10
        ASSERT_REG  REG_H, 52
        ASSERT_REG  REG_PSW, 0x10
END 15

TEST    16
    ARRANGE
        MOV A, #42
        MOV !LOWW(testdata), #10
    ACT
        ADD A, !LOWW(testdata)
    ASSERT
        ASSERT_REG  REG_A, 52
        ASSERT_MEM  testdata, 0, 10
END 16

TEST    17
    ARRANGE
        MOV A, #43
        MOV !LOWW(testdata), #11
        MOVW HL, #LOWW(testdata)
    ACT
        ADD A, [HL]
    ASSERT
        ASSERT_REG  REG_A, 54
        ASSERT_MEM  testdata, 0, 11
END 17

TEST    18
    ARRANGE
        MOV A, #44
        MOV !LOWW(testdata+255), #12
        MOVW HL, #LOWW(testdata)
    ACT
        ADD A, [HL+255]
    ASSERT
        ASSERT_REG  REG_A, 56
        ASSERT_MEM  testdata, 255, 12
END 18

TEST    19
    ARRANGE
        MOV     A, #45
        MOV     !LOWW(testdata+254), #13
        MOVW    HL, #LOWW(testdata)
        MOV     B, #254
    ACT
        ADD     A, [HL+B]
    ASSERT
        ASSERT_REG  REG_A, 58
        ASSERT_MEM  testdata, 254, 13
END 19

TEST    20
    ARRANGE
        MOV     A, #46
        MOV     !LOWW(testdata+253), #14
        MOVW    HL, #LOWW(testdata)
        MOV     C, #253
    ACT
        ADD     A, [HL+C]
    ASSERT
        ASSERT_REG  REG_A, 60
        ASSERT_MEM  testdata, 253, 14
END 20

TEST    21
    ARRANGE
        MOV     A, #47
    ACT
        ADD     A, #15
    ASSERT
        ASSERT_REG  REG_A, 62
END 21

TEST_FOOTER