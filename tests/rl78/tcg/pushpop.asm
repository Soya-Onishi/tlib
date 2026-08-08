$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN 2
testdata:
    .DS 2
testdata1:
    .DS 2
testdata2:
    .DS 2
testdata3:
    .DS 2
testdata_tail:

TEST_HEADER
TEST    1
    ARRANGE
        MOVW    SP, #LOWW(testdata_tail)
        MOVW    AX, #0x5678
        MOVW    BC, #0x1234
        MOVW    DE, #0xBEEF
        MOVW    HL, #0xDEAD
    ACT
        PUSH    AX
        PUSH    BC
        PUSH    DE
        PUSH    HL
    ASSERT
        ASSERT_SP   testdata
        ASSERT_MEM  testdata, 0, 0xAD
        ASSERT_MEM  testdata, 1, 0xDE
        ASSERT_MEM  testdata, 2, 0xEF
        ASSERT_MEM  testdata, 3, 0xBE
        ASSERT_MEM  testdata, 4, 0x34
        ASSERT_MEM  testdata, 5, 0x12
        ASSERT_MEM  testdata, 6, 0x78
        ASSERT_MEM  testdata, 7, 0x56
END 1

TEST    2
    ARRANGE
        MOVW    SP, #LOWW(testdata_tail)
        MOV     !LOWW(testdata+6), #0xFF
        MOV     !LOWW(testdata+7), #0xFF
        MOV     PSW, #0xD7
    ACT
        PUSH    PSW
    ASSERT
        ASSERT_SP   testdata3
        ASSERT_MEM  testdata, 6, 0x00
        ASSERT_MEM  testdata, 7, 0xD7
END 2

TEST    3
    ARRANGE
        MOVW    SP, #LOWW(testdata)
        MOV     !LOWW(testdata+0), #0xDE
        MOV     !LOWW(testdata+1), #0xAD
        MOV     !LOWW(testdata+2), #0xBE
        MOV     !LOWW(testdata+3), #0xEF
        MOV     !LOWW(testdata+4), #0x12
        MOV     !LOWW(testdata+5), #0x34
        MOV     !LOWW(testdata+6), #0x56
        MOV     !LOWW(testdata+7), #0x78
    ACT
        POP     AX
        POP     BC
        POP     DE
        POP     HL
    ASSERT
        ASSERT_REGS 0xDE, 0xAD, 0xBE, 0xEF, 0x12, 0x34, 0x56, 0x78
        ASSERT_SP   testdata_tail
END 3

TEST    4
    ARRANGE
        MOVW    SP, #LOWW(testdata)
        MOV     !LOWW(testdata+0), #0x00
        MOV     !LOWW(testdata+1), #0xD7
        MOV     PSW, #0x00
    ACT
        POP     PSW
    ASSERT
        ASSERT_REG  REG_PSW, 0xD7
        ASSERT_SP   testdata1
END 4

TEST_FOOTER
