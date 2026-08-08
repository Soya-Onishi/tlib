$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
    ACT
        ONEB    A
    ASSERT
        ASSERT_REGS 0, 1, 0, 0, 0, 0, 0, 0
END 1

TEST    2
    ARRANGE
    ACT
        ONEB    X
    ASSERT
        ASSERT_REGS 1, 0, 0, 0, 0, 0, 0, 0
END 2

TEST    3
    ARRANGE
    ACT
        ONEB    B
    ASSERT
        ASSERT_REGS 0, 0, 0, 1, 0, 0, 0, 0
END 3

TEST    4
    ARRANGE
    ACT
        ONEB    C
    ASSERT
        ASSERT_REGS 0, 0, 1, 0, 0, 0, 0, 0
END 4

TEST    5
    ARRANGE
        MOV !LOWW(testdata), #0
    ACT
        ONEB    !LOWW(testdata)
    ASSERT
        ASSERT_MEM  testdata, 0, 1
END 5

TEST_FOOTER