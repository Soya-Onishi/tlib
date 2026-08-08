$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #0xFF00
    ACT
        ONEW    AX
    ASSERT
        ASSERT_REGS 1, 0, 0, 0, 0, 0, 0, 0
END 1

TEST    2
    ARRANGE
        MOVW    BC, #0xFF00
    ACT
        ONEW    BC
    ASSERT
        ASSERT_REGS 0, 0, 1, 0, 0, 0, 0, 0
END 2

TEST_FOOTER