$INCLUDE    "../harness/prelude.asm"

; ==============================================================================
; Rotate Instruction Test Macros
; ==============================================================================

; ------------------------------------------------------------------------------
; ROR - Rotate Right for A register
; ------------------------------------------------------------------------------
ROR_A_TEST .MACRO test_number, input_a, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        ROR A, 1
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; ROL - Rotate Left for A register
; ------------------------------------------------------------------------------
ROL_A_TEST .MACRO test_number, input_a, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        ROL A, 1
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; RORC - Rotate Right with Carry for A register
; ------------------------------------------------------------------------------
RORC_A_TEST .MACRO test_number, input_a, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        RORC A, 1
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; ROLC - Rotate Left with Carry for A register
; ------------------------------------------------------------------------------
ROLC_A_TEST .MACRO test_number, input_a, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        ROLC A, 1
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; ROLWC - Rotate Left Word with Carry for AX register
; ------------------------------------------------------------------------------
ROLWC_AX_TEST .MACRO test_number, input_ax, init_cy, expected_a, expected_x, expected_psw
TEST    test_number
    ARRANGE
        MOVW AX, #input_ax
        MOV PSW, #init_cy
    ACT
        ROLWC AX, 1
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_X, expected_x
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; ROLWC - Rotate Left Word with Carry for BC register
; ------------------------------------------------------------------------------
ROLWC_BC_TEST .MACRO test_number, input_bc, init_cy, expected_b, expected_c, expected_psw
TEST    test_number
    ARRANGE
        MOVW BC, #input_bc
        MOV PSW, #init_cy
    ACT
        ROLWC BC, 1
    ASSERT
        ASSERT_REG  REG_B, expected_b
        ASSERT_REG  REG_C, expected_c
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ==============================================================================
; Test Cases
; ==============================================================================

TEST_HEADER

; ==============================================================================
; ROR (Rotate Right) Tests
; ==============================================================================

ROR_A_TEST   1, 0xAA, 0, 0x55, 0    ; Alternating bit pattern
ROR_A_TEST   2, 0x55, 0, 0xAA, 1    ; Inverse alternating
ROR_A_TEST   3, 0x00, 1, 0x00, 0    ; Zero rotate
ROR_A_TEST   4, 0xFF, 0, 0xFF, 1    ; All bits 1
ROR_A_TEST   5, 0x01, 0, 0x80, 1    ; LSB only set
ROR_A_TEST   6, 0x80, 1, 0x40, 0    ; MSB only set

; ==============================================================================
; ROL (Rotate Left) Tests
; ==============================================================================

ROL_A_TEST   7, 0xAA, 0, 0x55, 1    ; Alternating bit pattern
ROL_A_TEST   8, 0x55, 0, 0xAA, 0    ; Inverse alternating
ROL_A_TEST   9, 0x00, 1, 0x00, 0    ; Zero rotate
ROL_A_TEST  10, 0xFF, 0, 0xFF, 1    ; All bits 1
ROL_A_TEST  11, 0x80, 0, 0x01, 1    ; MSB only set
ROL_A_TEST  12, 0x01, 1, 0x02, 0    ; LSB only set

; ==============================================================================
; RORC (Rotate Right with Carry) Tests
; ==============================================================================

RORC_A_TEST  13, 0xAA, 0, 0x55, 0    ; Alternating bit, CY=0
RORC_A_TEST  14, 0xAA, 1, 0xD5, 0    ; Alternating bit, CY=1
RORC_A_TEST  15, 0x55, 0, 0x2A, 1    ; Inverse alternating, CY=0
RORC_A_TEST  16, 0x55, 1, 0xAA, 1    ; Inverse alternating, CY=1
RORC_A_TEST  17, 0x00, 0, 0x00, 0    ; Zero, CY=0
RORC_A_TEST  18, 0x00, 1, 0x80, 0    ; Zero, CY=1
RORC_A_TEST  19, 0xFF, 0, 0x7F, 1    ; All bits 1, CY=0
RORC_A_TEST  20, 0xFF, 1, 0xFF, 1    ; All bits 1, CY=1

; ==============================================================================
; ROLC (Rotate Left with Carry) Tests
; ==============================================================================

ROLC_A_TEST  21, 0xAA, 0, 0x54, 1    ; Alternating bit, CY=0
ROLC_A_TEST  22, 0xAA, 1, 0x55, 1    ; Alternating bit, CY=1
ROLC_A_TEST  23, 0x55, 0, 0xAA, 0    ; Inverse alternating, CY=0
ROLC_A_TEST  24, 0x55, 1, 0xAB, 0    ; Inverse alternating, CY=1
ROLC_A_TEST  25, 0x00, 0, 0x00, 0    ; Zero, CY=0
ROLC_A_TEST  26, 0x00, 1, 0x01, 0    ; Zero, CY=1
ROLC_A_TEST  27, 0xFF, 0, 0xFE, 1    ; All bits 1, CY=0
ROLC_A_TEST  28, 0xFF, 1, 0xFF, 1    ; All bits 1, CY=1

; ==============================================================================
; ROLWC (Rotate Left Word with Carry) Tests
; ==============================================================================

ROLWC_AX_TEST  29, 0xAAAA, 0, 0x55, 0x54, 1    ; Alternating bit, CY=0
ROLWC_BC_TEST  30, 0xAAAA, 1, 0x55, 0x55, 1    ; Alternating bit, CY=1
ROLWC_AX_TEST  31, 0x5555, 0, 0xAA, 0xAA, 0    ; Inverse alternating, CY=0
ROLWC_BC_TEST  32, 0x5555, 1, 0xAA, 0xAB, 0    ; Inverse alternating, CY=1
ROLWC_AX_TEST  33, 0x0000, 0, 0x00, 0x00, 0    ; Zero, CY=0
ROLWC_BC_TEST  34, 0x0000, 1, 0x00, 0x01, 0    ; Zero, CY=1
ROLWC_AX_TEST  35, 0xFFFF, 0, 0xFF, 0xFE, 1    ; All bits 1, CY=0
ROLWC_BC_TEST  36, 0xFFFF, 1, 0xFF, 0xFF, 1    ; All bits 1, CY=1

TEST_FOOTER
