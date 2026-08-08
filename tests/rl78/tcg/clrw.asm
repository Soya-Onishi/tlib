$INCLUDE    "../harness/prelude.asm"

INIT_REGS   .MACRO
MOVW    AX, #0xFFFF
MOVW    BC, #0xFFFF
MOVW    DE, #0xFFFF
MOVW    HL, #0xFFFF
.ENDM

TEST_HEADER

TEST    1
    ARRANGE
        INIT_REGS
    ACT
        CLRW    AX
    ASSERT
        ASSERT_REGS 0, 0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
END 1

TEST    2
    ARRANGE
        INIT_REGS
    ACT
        CLRW    BC
    ASSERT
        ASSERT_REGS 0xFF, 0xFF, 0, 0, 0xFF, 0xFF, 0xFF, 0xFF
END 2

TEST_FOOTER