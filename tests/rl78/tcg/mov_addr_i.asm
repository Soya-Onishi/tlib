$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 16

TEST_HEADER

TEST    1
    ARRANGE
    ACT
        MOV !(testdata + 0), #1
        MOV !(testdata + 1), #2

    ASSERT
        ASSERT_MEM  testdata, 0, 1
        ASSERT_MEM  testdata, 1, 2

TEST    2
    ARRANGE
    ACT
        MOV !(testdata + 0), #3
        MOV !(testdata + 1), #4
    ASSERT
        ASSERT_MEM  testdata, 0, 3
        ASSERT_MEM  testdata, 1, 4

TEST    3
    ARRANGE
    ACT
        MOV !(testdata + 0), #0

    ASSERT
        ASSERT_MEM  testdata, 0, 0

TEST    4
    ARRANGE
    ACT
        MOV !(testdata + 0), #255

    ASSERT
        ASSERT_MEM  testdata, 0, 255

TEST_FOOTER