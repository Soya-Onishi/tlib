$INCLUDE    "../harness/prelude.asm"

; ==============================================================================
; NOT1 Instruction Test Macros
; ==============================================================================

NOT1_CY_TEST .MACRO test_number, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV PSW, #init_cy
    ACT
        NOT1 CY
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ==============================================================================
; Test Cases
; ==============================================================================

TEST_HEADER

; ==============================================================================
; NOT1 CY
; ==============================================================================

NOT1_CY_TEST   1, 0x00, 0x01
NOT1_CY_TEST   2, 0x01, 0x00

TEST_FOOTER
