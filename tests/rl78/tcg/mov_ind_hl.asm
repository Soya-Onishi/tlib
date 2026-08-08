$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 512

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    HL, #LOWW(testdata)
        MOV     !LOWW(testdata), #42
    ACT
        MOV A, [HL]
    ASSERT
        ASSERT_REG REG_A, 42
END 1

TEST    2
    ARRANGE
        MOVW    HL, #LOWW(testdata+1)
        MOV     A, #43
    ACT 
        MOV [HL], A
    ASSERT
        ASSERT_MEM  testdata, 1, 43
END 2

TEST    3
    ARRANGE
        MOVW    HL, #LOWW(testdata)
    ACT
        MOV [HL+0], #44
    ASSERT
        ASSERT_MEM  testdata, 0, 44
END 3

TEST    4
    ARRANGE
        MOVW    HL, #LOWW(testdata)
    ACT
        MOV [HL+1], #45
    ASSERT
        ASSERT_MEM  testdata, 1, 45
END 4

TEST    5
    ARRANGE
        MOVW    HL, #LOWW(testdata)
    ACT
        MOV [HL+255], #46
    ASSERT
        ASSERT_MEM  testdata, 255, 46
END 5

TEST    6
    ARRANGE
        MOVW    HL, #LOWW(testdata)
	MOV	A, #47
	MOV	!LOWW(testdata+0), A
    ACT
        MOV 	A, [HL+0]
    ASSERT
        ASSERT_REG  REG_A, 47
END 6

TEST    7
    ARRANGE
        MOVW    HL, #LOWW(testdata)
	MOV	A, #48
	MOV	!LOWW(testdata+1), A
    ACT
        MOV 	A, [HL+1]
    ASSERT
        ASSERT_REG REG_A, 48
END 7

TEST    8
    ARRANGE
        MOVW    HL, #LOWW(testdata)
	MOV	A, #49
	MOV	!LOWW(testdata+255), A
    ACT
        MOV 	A, [HL+255]
    ASSERT
        ASSERT_REG REG_A, 49
END 8


TEST    9
    ARRANGE
        MOVW HL, #LOWW(testdata)
        MOV B, #5
        MOV !LOWW(testdata+5), #50
    ACT
        MOV A, [HL+B]
    ASSERT
        ASSERT_REG REG_A, 50
END 9

TEST    10
    ARRANGE
        MOVW HL, #LOWW(testdata)
        MOV B, #6
        MOV A, #51
    ACT 
        MOV [HL+B], A
    ASSERT
        ASSERT_MEM  testdata, 6, 51
END 10

TEST    11
    ARRANGE
        MOVW HL, #LOWW(testdata)
        MOV C, #7
        MOV !LOWW(testdata+7), #52
    ACT
        MOV A, [HL+C]
    ASSERT
        ASSERT_REG REG_A, 52
END 11

TEST    12
    ARRANGE
        MOVW HL, #LOWW(testdata)
        MOV C, #8
        MOV A, #53
    ACT
        MOV [HL+C], A
    ASSERT
        ASSERT_MEM testdata, 8, 53
END 12

TEST_FOOTER
