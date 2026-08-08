$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 16

TEST_HEADER
    MOV !testdata+0, #1
    MOV !testdata+1, #2
    MOV !testdata+2, #3
    MOV !testdata+3, #4
    MOV !testdata+4, #5
    MOV !testdata+5, #6
    MOV !testdata+6, #0
    MOV !testdata+7, #255

TEST    1
    ARRANGE
    ACT
        MOV A, !testdata+0
    
    ASSERT
        ASSERT_REGS 0, 1, 0, 0, 0, 0, 0, 0
END 1

TEST    2
    ARRANGE
    ACT
        MOV A, !testdata+6
    
    ASSERT
        ASSERT_REGS 0, 0, 0, 0, 0, 0, 0, 0
END 2

TEST    3
    ARRANGE
    ACT
        MOV A, !testdata+7
    
    ASSERT
        ASSERT_REGS 0, 255, 0, 0, 0, 0, 0, 0
END 3

TEST    4
    ARRANGE
    ACT
        MOV B, !testdata+0
    ASSERT
        ASSERT_REGS 0, 0, 0, 1, 0, 0, 0, 0
END 4

TEST    5
    ARRANGE
    ACT
        MOV C, !testdata+0
    ASSERT 
        ASSERT_REGS 0, 0, 1, 0, 0, 0, 0, 0
END 5

TEST    6
    ARRANGE
    ACT
        MOV X, !testdata+0
    ASSERT
        ASSERT_REGS 1, 0, 0, 0, 0, 0, 0, 0
END 6

; TEST    7
;     ARRANGE
;         MOV ES, #0x0F
;     ACT
;         MOV A, ES:!LOWW(testdata+0)
;     ASSERT
;         ASSERT_REGS 0, 1, 0, 0, 0, 0, 0, 0
; END 7

TEST_FOOTER