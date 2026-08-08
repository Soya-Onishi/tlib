$INCLUDE    "../harness/prelude.asm"

func    .VECTOR 0x0007E

TEST_HEADER
TEST    1
    ARRANGE
        MOVW    SP, #0xFEE0
        MOV     PSW, #0xD7
        MOV     !LOWW(testdata+0), #0
        MOV     !LOWW(testdata+1), #0
        MOV     !LOWW(testdata+2), #0
    ACT 
        BRK
        MOV     !LOWW(testdata+2), #3
    ASSERT
        ASSERT_MEM  testdata, 0, 1
        ASSERT_MEM  testdata, 1, 0
        ASSERT_MEM  testdata, 2, 3
        ASSERT_MEM  psw_status, 0, 0x57
        ASSERT_REG  REG_PSW, 0xD7
        ASSERT_SP   0xFEE0
END 1

TEST    2
    ARRANGE
        MOVW    SP, #0xFEE0
        MOV     PSW, #0x57
        MOV     !LOWW(testdata+0), #0
        MOV     !LOWW(testdata+1), #0
        MOV     !LOWW(testdata+2), #0
    ACT 
        BRK
        MOV     !LOWW(testdata+2), #3
    ASSERT
        ASSERT_MEM  testdata, 0, 1
        ASSERT_MEM  testdata, 1, 0
        ASSERT_MEM  testdata, 2, 3
        ASSERT_MEM  psw_status, 0, 0x57
        ASSERT_REG  REG_PSW, 0x57
        ASSERT_SP   0xFEE0
END 2

TEST_FOOTER

.text   .CSEG   AT  0x07F00
func_before:
    MOV !LOWW(testdata+1), #2
func:
    MOV !LOWW(testdata), #1
    MOV A, PSW
    MOV !LOWW(psw_status), A
    RETB

.bss    .DSEG   BSS
testdata:
    .DS 256
psw_status:
    .DS 1