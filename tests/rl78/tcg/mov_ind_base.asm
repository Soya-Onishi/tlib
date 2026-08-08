$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        MOV B, #1
    ACT
        MOV LOWW(testdata)[B], #41
    ASSERT
        ASSERT_MEM  testdata, 1, 41
END 1

TEST    2
    ARRANGE
        MOV !LOWW(testdata+2), #42
        MOV B, #2
    ACT
        MOV A, LOWW(testdata)[B]
    ASSERT
        ASSERT_REG  REG_A, 42
END 2

TEST    3
    ARRANGE
        MOV B, #3
        MOV A, #43
    ACT 
        MOV LOWW(testdata)[B], A
    ASSERT
        ASSERT_MEM  testdata, 3, 43
END 3

TEST    4
    ARRANGE
        MOV C, #4
    ACT
        MOV LOWW(testdata)[C], #44
    ASSERT
        ASSERT_MEM  testdata, 4, 44
END 4

TEST    5
    ARRANGE
        MOV !LOWW(testdata+5), #45
        MOV C, #5
    ACT
        MOV A, LOWW(testdata)[C]
    ASSERT
        ASSERT_REG  REG_A, 45
END 5

TEST    6
    ARRANGE
        MOV C, #6
        MOV A, #46
    ACT 
        MOV LOWW(testdata)[C], A
    ASSERT
        ASSERT_MEM  testdata, 6, 46
END 6

TEST    7
    ARRANGE
        MOVW BC, #7
    ACT
        MOV LOWW(testdata)[BC], #47
    ASSERT
        ASSERT_MEM  testdata, 7, 47
END 7

TEST    8
    ARRANGE
        MOV !LOWW(testdata+8), #48
        MOVW BC, #8
    ACT
        MOV A, LOWW(testdata)[BC]
    ASSERT
        ASSERT_REG  REG_A, 48
END 8

TEST    9
    ARRANGE
        MOVW BC, #9
        MOV A, #49
    ACT 
        MOV LOWW(testdata)[BC], A
    ASSERT
        ASSERT_MEM  testdata, 9, 49
END 9

TEST_FOOTER