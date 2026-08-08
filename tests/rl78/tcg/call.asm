$INCLUDE    "../harness/prelude.asm"

TEST_HEADER
TEST    1
    ARRANGE
        MOVW    SP, #0xFEE0
        MOV     CS, #HIGHW(testcall)
        MOVW    AX, #LOWW(testcall)
        MOV     !LOWW(testdata), #1
    ACT
        CALL    AX
        MOV !LOWW(testdata+100), #1
    ASSERT
        ASSERT_MEM  testdata, 255, 1 
        ASSERT_MEM  testdata, 100, 1
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xE0
END 1

TEST    2
    ARRANGE
        MOVW    SP, #0xFEDC
        MOV     CS, #HIGHW(testcall)
        MOVW    BC, #LOWW(testcall)
        MOV     !LOWW(testdata), #2
    ACT
        CALL    BC
        MOV !LOWW(testdata+100), #2
    ASSERT
        ASSERT_MEM  testdata, 255, 2
        ASSERT_MEM  testdata, 100, 2
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xDC
END 2

TEST    3
    ARRANGE
        MOVW    SP, #0xFED8
        MOV     CS, #HIGHW(testcall)
        MOVW    DE, #LOWW(testcall)
        MOV     !LOWW(testdata), #3
    ACT
        CALL    DE
        MOV !LOWW(testdata+100), #3
    ASSERT
        ASSERT_MEM  testdata, 255, 3
        ASSERT_MEM  testdata, 100, 3
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xD8
END 3

TEST    4
    ARRANGE
        MOVW    SP, #0xFED4
        MOV     CS, #HIGHW(testcall)
        MOVW    HL, #LOWW(testcall)
        MOV     !LOWW(testdata), #4
    ACT
        CALL    DE
        MOV !LOWW(testdata+100), #4
    ASSERT
        ASSERT_MEM  testdata, 255, 4
        ASSERT_MEM  testdata, 100, 4
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xD4
END 4

TEST    5
    ARRANGE
        MOVW    SP, #0xFED0
        MOV     !LOWW(testdata+10), #5
    ACT
        CALL    $!testcall_near
        MOV !LOWW(testdata+100), #5
    ASSERT
        ASSERT_MEM  testdata, 245, 5
        ASSERT_MEM  testdata, 100, 5
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xD0
END 5

TEST    6
    ARRANGE
        MOVW    SP, #0xFECC
        MOV     CS, #0x01
        MOV     !LOWW(testdata+10), #6
    ACT
        CALL    !LOWW(testcall_near)
        MOV !LOWW(testdata+100), #6
    ASSERT
        ASSERT_MEM  testdata, 245, 6
        ASSERT_MEM  testdata, 100, 6
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xCC
END 6

TEST    7
    ARRANGE
        MOVW    SP, #0xFEC8
        MOV     CS, #0x00
        MOV     !LOWW(testdata), #7
    ACT
        CALL    !!testcall
        MOV !LOWW(testdata+100), #7
    ASSERT
        ASSERT_MEM  testdata, 255, 7
        ASSERT_MEM  testdata, 100, 7
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xC8
END 7

TEST    8
    ARRANGE
        MOVW    SP, #0xFEC8
        MOV     CS, #0x00
        MOV     !LOWW(testdata), #8
    ACT
        CALL    !!testcall_indirect
        MOV !LOWW(testdata+100), #8
    ASSERT
        ASSERT_MEM  testdata, 255, 8
        ASSERT_MEM  testdata, 100, 8
        ASSERT_MEM  sp_storage, 1, 0xFE
        ASSERT_MEM  sp_storage, 0, 0xC8
END 8

TEST_FOOTER

.text   .CSEG   AT  0x07F00
testcall_near:
    MOV A, !LOWW(testdata+10)
    MOV !LOWW(testdata+245), A
    RET

.text   .CSEG   AT  0x0FF00
testcall_indirect:
    CALL    $!testcall
    RET    

.text   .CSEG   AT  0x10000
testcall:
    MOV A, !LOWW(testdata)
    MOV !LOWW(testdata+255), A
    RET

.bss    .DSEG   BSS
testdata:
    .DS 256