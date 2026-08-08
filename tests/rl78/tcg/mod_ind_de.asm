$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER

MOV !(testdata+0),      #1
MOV !(testdata+1),      #2
MOV !(testdata+255),    #255

TEST    1
    ARRANGE
        MOVW DE, #LOWW(testdata)

    ACT
        MOV A, [DE]

    ASSERT
        ASSERT_REG REG_A, 1
END 1

TEST    2
    ARRANGE
        MOVW DE, #LOWW(testdata+1)

    ACT
        MOV A, [DE]

    ASSERT
        ASSERT_REG REG_A, 2
END 2

TEST    3
    ARRANGE
        MOVW DE, #LOWW(testdata+2)
        MOV A, #3
    
    ACT
        MOV [DE], A

    ASSERT
        ASSERT_MEM  testdata, 2, 3
END 3

TEST    4
    ARRANGE
        MOVW DE, #LOWW(testdata+3)
        MOV A, #4

    ACT
        MOV [DE], A
    
    ASSERT
        ASSERT_MEM  testdata, 3, 4
END 4

TEST    5
    ARRANGE
        MOVW DE, #LOWW(testdata)
        MOV !LOWW(testdata+0),   #0x00
        MOV !LOWW(testdata+255), #0x00
    ACT
        MOV [DE+0],   #0x42
        MOV [DE+255], #0x43
    ASSERT
        ASSERT_MEM  testdata, 0,   0x42
        ASSERT_MEM  testdata, 255, 0x43
END 5

TEST    6
    ARRANGE
        MOVW DE, #LOWW(testdata)
        MOV !LOWW(testdata+0),   #0x00
        MOV !LOWW(testdata+255), #0x00
    ACT
        MOV A, #0x44
        MOV [DE+0],   A
        MOV A, #0x45
        MOV [DE+255], A
    ASSERT
        ASSERT_MEM  testdata, 0,   0x44
        ASSERT_MEM  testdata, 255, 0x45
END 6

TEST    7
    ARRANGE
        MOVW DE, #LOWW(testdata)
        MOV !LOWW(testdata+0),   #0x46
    ACT
        MOV A, [DE+0]
    ASSERT
        ASSERT_REG  REG_A, 0x46
END 7

TEST    8
    ARRANGE
        MOVW DE, #LOWW(testdata)
        MOV !LOWW(testdata+255),   #0x47
    ACT
        MOV A, [DE+255]
    ASSERT
        ASSERT_REG  REG_A, 0x47
END 8

TEST_FOOTER