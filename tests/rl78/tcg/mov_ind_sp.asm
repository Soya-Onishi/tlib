$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN  2
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE 
        MOVW    SP, #LOWW(testdata)
    ACT
        MOV [SP+0],   #0x42
        MOV [SP+255], #0x43
    ASSERT
        ASSERT_MEM  testdata,   0, 0x42
        ASSERT_MEM  testdata, 255, 0x43
END 1

TEST    2
    ARRANGE
        MOV     !LOWW(testdata+0), #0x44
        MOVW    SP, #LOWW(testdata)
    ACT
        MOV     A, [SP+0]
    ASSERT
        ASSERT_REG  REG_A, 0x44
END 2

TEST    3
    ARRANGE
        MOV     !LOWW(testdata+255), #0x45
        MOVW    SP, #LOWW(testdata)
    ACT
        MOV     A, [SP+255]
    ASSERT
        ASSERT_REG  REG_A, 0x45
END 3

TEST    4
    ARRANGE
        MOVW    SP, #LOWW(testdata)
    ACT
        MOV     A, #0x46
        MOV     [SP+0], A
        MOV     A, #0x47
        MOV     [SP+255], A
    ASSERT
        ASSERT_MEM  testdata, 0,   0x46
        ASSERT_MEM  testdata, 255, 0x47
END 4

TEST_FOOTER