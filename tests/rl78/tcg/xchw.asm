$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    BC, #0xBEEF
    ACT
        XCHW    AX, BC
    ASSERT
        ASSERT_REGS 0xEF, 0xBE, 0xAD, 0xDE, 0, 0, 0, 0
END 1

TEST    2
    ARRANGE
        MOVW    AX, #0x1234
        MOVW    DE, #0x5678
    ACT
        XCHW    AX, DE
    ASSERT
        ASSERT_REGS 0x78, 0x56, 0, 0, 0x34, 0x12, 0, 0
END 2

TEST    3
    ARRANGE
        MOVW    AX, #0xBEEF
        MOVW    HL, #0xDEAD
    ACT
        XCHW    AX, HL
    ASSERT
        ASSERT_REGS 0xAD, 0xDE, 0, 0, 0, 0, 0xEF, 0xBE
END 3

TEST_FOOTER