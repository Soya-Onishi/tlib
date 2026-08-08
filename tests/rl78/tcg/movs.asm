$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
testdata:
    .DS 256

TEST_HEADER

TEST    1
    ARRANGE
        MOV     PSW, #(PSW_Z | PSW_CY)
        MOV     A, #13
        MOV     X, #0x42
        MOVW    HL, #LOWW(testdata)
    ACT
        MOVS    [HL+0], X
    ASSERT
        ASSERT_REG  REG_PSW, 0x00
        ASSERT_MEM  testdata, 0, 0x42
END 1

TEST    2
    ARRANGE
        MOV     PSW, #(PSW_Z)
        MOV     A, #0
        MOV     X, #0x43
        MOVW    HL, #LOWW(testdata)
    ACT
        MOVS    [HL+255], X
    ASSERT
        ASSERT_REG  REG_PSW, 0x01
        ASSERT_MEM  testdata, 255, 0x43
END 2

TEST    3
    ARRANGE
        MOV     PSW, #(PSW_Z)
        MOV     A, #13
        MOV     X, #0
        MOVW    HL, #LOWW(testdata)
    ACT
        MOVS    [HL+255], X
    ASSERT
        ASSERT_REG  REG_PSW, 0x41
        ASSERT_MEM  testdata, 255, 0
END 3

TEST_FOOTER