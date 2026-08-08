$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

IGNORE_TEST    1
    ARRANGE
    ACT
        STOP
    ASSERT
END 1

IGNORE_TEST    2
    ARRANGE
    ACT
        HALT
    ASSERT
END 2


TEST_FOOTER