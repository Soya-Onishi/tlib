$INCLUDE    "../harness/prelude.asm"


TEST_HEADER

TEST    1
    ARRANGE
        MOVW    BC, #0xDEAD
    ACT
        MOVW    AX, BC
    ASSERT
        ASSERT_REGS 0xAD, 0xDE, 0xAD, 0xDE, 0, 0, 0, 0
END 1

TEST    2
    ARRANGE
        MOVW    DE, #0xBEEF
    ACT
        MOVW    AX, DE
    ASSERT
        ASSERT_REGS 0xEF, 0xBE, 0, 0, 0xEF, 0xBE, 0, 0
END 2

TEST    3
    ARRANGE
        MOVW    HL, #0xDEAD
    ACT
        MOVW    AX, HL
    ASSERT
        ASSERT_REGS 0xAD, 0xDE, 0, 0, 0, 0, 0xAD, 0xDE
END 3

TEST    4
    ARRANGE
        MOVW    AX, #0xBEEF
    ACT
        MOVW    BC, AX
    ASSERT
        ASSERT_REGS 0xEF, 0xBE, 0xEF, 0xBE, 0, 0, 0, 0
END 4

TEST    5
    ARRANGE
        MOVW    AX, #0xDEAD
    ACT
        MOVW    DE, AX
    ASSERT
        ASSERT_REGS 0xAD, 0xDE, 0, 0, 0xAD, 0xDE, 0, 0
END 5

TEST    6
    ARRANGE
        MOVW    AX, #0xBEEF
    ACT
        MOVW    HL, AX
    ASSERT
        ASSERT_REGS 0xEF, 0xBE, 0, 0, 0, 0, 0xEF, 0xBE
END 6

TEST    7
    ARRANGE
        MOVW    SP, #0x1234
    ACT
        MOVW    AX, SP
    ASSERT
        ASSERT_REGS 0x34, 0x12, 0, 0, 0, 0, 0, 0
END 7

TEST    8
    ARRANGE
        MOVW    SP, #0x5678
    ACT
        MOVW    BC, SP
    ASSERT
        ASSERT_REGS 0, 0, 0x78, 0x56, 0, 0, 0, 0
END 8

TEST    9
    ARRANGE
        MOVW    SP, #0x9ABC
    ACT
        MOVW    DE, SP
    ASSERT
        ASSERT_REGS 0, 0, 0, 0, 0xBC, 0x9A, 0, 0
END 9

TEST    10
    ARRANGE
        MOVW    SP, #0xDEF0
    ACT
        MOVW    HL, SP
    ASSERT
        ASSERT_REGS 0, 0, 0, 0, 0, 0, 0xF0, 0xDE
END 10

TEST    11
    ARRANGE
        MOVW    AX, #0xDEAD
    ACT
        MOVW    SP, AX
    ASSERT
        ASSERT_SP   0xDEAC
END 11

TEST    12
    ARRANGE
        MOVW    AX, #0x1234
    ACT
        MOVW    SP, AX
    ASSERT
        ASSERT_SP   0x1234
END 12

TEST_FOOTER