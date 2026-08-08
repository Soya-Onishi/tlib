$INCLUDE    "../harness/prelude.asm"

INIT_REGS   .MACRO
MOV X, #255
MOV A, #255
MOV C, #255
MOV B, #255
MOV E, #255
MOV D, #255
MOV L, #255
MOV H, #255
.ENDM

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        INIT_REGS
    ACT
        CLRB    A
    ASSERT
        ASSERT_REGS 255, 0, 255, 255, 255, 255, 255, 255
END 1

TEST    2
    ARRANGE
        INIT_REGS
    ACT
        CLRB    X
    ASSERT
        ASSERT_REGS 0, 255, 255, 255, 255, 255, 255, 255
END 2

TEST    3
    ARRANGE
        INIT_REGS
    ACT
        CLRB    B
    ASSERT
        ASSERT_REGS 255, 255, 255, 0, 255, 255, 255, 255
END 3

TEST    4
    ARRANGE
        INIT_REGS
    ACT
        CLRB    C
    ASSERT
        ASSERT_REGS 255, 255, 0, 255, 255, 255, 255, 255
END 4

TEST    5
    ARRANGE
        MOV !LOWW(testdata), #255
    ACT
        CLRB    !LOWW(testdata)
    ASSERT
        ASSERT_MEM  testdata, 0, 0
END 5

TEST_FOOTER