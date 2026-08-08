$INCLUDE    "../harness/prelude.asm"

; ==============================================================================
; Shift Instruction Test Macros
; ==============================================================================

; ------------------------------------------------------------------------------
; SHR - Shift Right (Logical) for A register
; ------------------------------------------------------------------------------
SHR_A_TEST .MACRO test_number, input_a, count, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        SHR A, count
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SHRW - Shift Right Word (Logical) for AX register
; ------------------------------------------------------------------------------
SHRW_AX_TEST .MACRO test_number, input_ax, count, init_cy, expected_a, expected_x, expected_psw
TEST    test_number
    ARRANGE
        MOVW AX, #input_ax
        MOV PSW, #init_cy
    ACT
        SHRW AX, count
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_X, expected_x
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SHL - Shift Left (Logical) for A register
; ------------------------------------------------------------------------------
SHL_A_TEST .MACRO test_number, input_a, count, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        SHL A, count
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SHL - Shift Left (Logical) for B register
; ------------------------------------------------------------------------------
SHL_B_TEST .MACRO test_number, input_b, count, init_cy, expected_b, expected_psw
TEST    test_number
    ARRANGE
        MOV B, #input_b
        MOV PSW, #init_cy
    ACT
        SHL B, count
    ASSERT
        ASSERT_REG  REG_B, expected_b
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SHL - Shift Left (Logical) for C register
; ------------------------------------------------------------------------------
SHL_C_TEST .MACRO test_number, input_c, count, init_cy, expected_c, expected_psw
TEST    test_number
    ARRANGE
        MOV C, #input_c
        MOV PSW, #init_cy
    ACT
        SHL C, count
    ASSERT
        ASSERT_REG  REG_C, expected_c
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SHLW - Shift Left Word (Logical) for AX register
; ------------------------------------------------------------------------------
SHLW_AX_TEST .MACRO test_number, input_ax, count, init_cy, expected_a, expected_x, expected_psw
TEST    test_number
    ARRANGE
        MOVW AX, #input_ax
        MOV PSW, #init_cy
    ACT
        SHLW AX, count
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_X, expected_x
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SHLW - Shift Left Word (Logical) for BC register
; ------------------------------------------------------------------------------
SHLW_BC_TEST .MACRO test_number, input_bc, count, init_cy, expected_b, expected_c, expected_psw
TEST    test_number
    ARRANGE
        MOVW BC, #input_bc
        MOV PSW, #init_cy
    ACT
        SHLW BC, count
    ASSERT
        ASSERT_REG  REG_B, expected_b
        ASSERT_REG  REG_C, expected_c
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SAR - Shift Arithmetic Right for A register
; ------------------------------------------------------------------------------
SAR_A_TEST .MACRO test_number, input_a, count, init_cy, expected_a, expected_psw
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        SAR A, count
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; SARW - Shift Arithmetic Right Word for AX register
; ------------------------------------------------------------------------------
SARW_AX_TEST .MACRO test_number, input_ax, count, init_cy, expected_a, expected_x, expected_psw
TEST    test_number
    ARRANGE
        MOVW AX, #input_ax
        MOV PSW, #init_cy
    ACT
        SARW AX, count
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_X, expected_x
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ==============================================================================
; Test Cases
; ==============================================================================

TEST_HEADER

; ==============================================================================
; SHR (Shift Right - Logical) Tests
; ==============================================================================

SHR_A_TEST   1, 0xF5, 3, 0, 0x1E, 1    ; Document example
SHR_A_TEST   2, 0xFF, 1, 0, 0x7F, 1    ; All bits 1, shift 1
SHR_A_TEST   3, 0x00, 1, 1, 0x00, 0    ; Zero shift
SHR_A_TEST   4, 0x01, 1, 0, 0x00, 1    ; Minimum value to zero
SHR_A_TEST   5, 0x80, 7, 0, 0x01, 0    ; 0x80 shift 7
SHR_A_TEST   6, 0xAA, 4, 0, 0x0A, 1    ; Alternating bit pattern
SHR_A_TEST   7, 0x55, 4, 1, 0x05, 0    ; Inverse alternating
SHR_A_TEST   8, 0xFE, 1, 1, 0x7F, 0    ; Initial CY check
SHR_A_TEST   9, 0xFF, 7, 0, 0x01, 1    ; All bits 1, shift 7
SHR_A_TEST  10, 0x00, 7, 1, 0x00, 0    ; Zero shift 7

; ==============================================================================
; SHRW (Shift Right Word - Logical) Tests
; ==============================================================================

SHRW_AX_TEST  11, 0xAAF5, 3, 0, 0x15, 0x5E, 1    ; Document example
SHRW_AX_TEST  12, 0xFFFF, 1, 0, 0x7F, 0xFF, 1    ; All bits 1
SHRW_AX_TEST  13, 0x0000, 1, 1, 0x00, 0x00, 0    ; Zero shift
SHRW_AX_TEST  14, 0x0001, 1, 0, 0x00, 0x00, 1    ; Minimum value
SHRW_AX_TEST  15, 0x8000, 15, 0, 0x00, 0x01, 0   ; 0x8000 shift 15
SHRW_AX_TEST  16, 0xAAAA, 8, 0, 0x00, 0xAA, 1    ; 8-bit shift
SHRW_AX_TEST  17, 0x5555, 8, 1, 0x00, 0x55, 0    ; 8-bit shift inverse
SHRW_AX_TEST  18, 0xFFFF, 15, 0, 0x00, 0x01, 1   ; All bits 1, shift 15
SHRW_AX_TEST  19, 0x0000, 15, 1, 0x00, 0x00, 0   ; Zero shift 15

; ==============================================================================
; SHL (Shift Left - Logical) Tests
; ==============================================================================

SHL_A_TEST   20, 0x5D, 3, 0, 0xE8, 0    ; Document example
SHL_A_TEST   21, 0xFF, 1, 0, 0xFE, 1    ; All bits 1
SHL_B_TEST   22, 0x00, 1, 1, 0x00, 0    ; Zero shift
SHL_C_TEST   23, 0x80, 1, 0, 0x00, 1    ; MSB only set
SHL_A_TEST   24, 0x01, 7, 0, 0x80, 0    ; 0x01 shift 7
SHL_B_TEST   25, 0xAA, 4, 1, 0xA0, 0    ; Alternating bit
SHL_C_TEST   26, 0x55, 4, 0, 0x50, 1    ; Inverse alternating
SHL_A_TEST   27, 0xFF, 7, 0, 0x80, 1    ; All bits 1, shift 7
SHL_B_TEST   28, 0x00, 7, 1, 0x00, 0    ; Zero shift 7

; ==============================================================================
; SHLW (Shift Left Word - Logical) Tests
; ==============================================================================

SHLW_BC_TEST  29, 0xC35D, 3, 0, 0x1A, 0xE8, 0    ; Document example
SHLW_AX_TEST  30, 0xFFFF, 1, 0, 0xFF, 0xFE, 1    ; All bits 1
SHLW_BC_TEST  31, 0x0000, 1, 1, 0x00, 0x00, 0    ; Zero shift
SHLW_AX_TEST  32, 0x8000, 1, 0, 0x00, 0x00, 1    ; MSB only set
SHLW_BC_TEST  33, 0x0001, 15, 0, 0x80, 0x00, 0   ; 0x0001 shift 15
SHLW_AX_TEST  34, 0xAAAA, 8, 1, 0xAA, 0x00, 0    ; 8-bit shift
SHLW_AX_TEST  35, 0x5555, 8, 0, 0x55, 0x00, 1    ; 8-bit shift
SHLW_BC_TEST  36, 0xFFFF, 15, 0, 0x80, 0x00, 1   ; All bits 1, shift 15
SHLW_AX_TEST  37, 0x0000, 15, 1, 0x00, 0x00, 0   ; Zero shift 15

; ==============================================================================
; SAR (Shift Arithmetic Right) Tests
; ==============================================================================

SAR_A_TEST   38, 0x8C, 4, 0, 0xF8, 1    ; Document example (negative)
SAR_A_TEST   39, 0xFF, 1, 0, 0xFF, 1    ; -1 shift
SAR_A_TEST   40, 0x7F, 1, 0, 0x3F, 1    ; Positive max
SAR_A_TEST   41, 0x80, 7, 0, 0xFF, 0    ; Negative min, shift 7
SAR_A_TEST   42, 0x00, 1, 1, 0x00, 0    ; Zero shift
SAR_A_TEST   43, 0xFE, 1, 0, 0xFF, 0    ; -2 shift
SAR_A_TEST   44, 0x7E, 7, 0, 0x00, 1    ; Positive to zero
SAR_A_TEST   45, 0xFF, 7, 0, 0xFF, 1    ; All bits 1, shift 7 (sign extend)
SAR_A_TEST   46, 0x00, 7, 1, 0x00, 0    ; Zero shift 7
SAR_A_TEST   47, 0x7F, 7, 0, 0x00, 1    ; Positive max, shift 7
SAR_A_TEST   48, 0xAA, 1, 1, 0xD5, 0    ; Negative alternating, shift 1
SAR_A_TEST   49, 0xAA, 4, 0, 0xFA, 1    ; Negative alternating, shift 4
SAR_A_TEST   50, 0x55, 1, 0, 0x2A, 1    ; Positive alternating, shift 1
SAR_A_TEST   51, 0x55, 4, 1, 0x05, 0    ; Positive alternating, shift 4

; ==============================================================================
; SARW (Shift Arithmetic Right Word) Tests
; ==============================================================================

SARW_AX_TEST  52, 0xA28C, 4, 0, 0xFA, 0x28, 1     ; Document example
SARW_AX_TEST  53, 0xFFFF, 1, 0, 0xFF, 0xFF, 1     ; -1 shift
SARW_AX_TEST  54, 0x7FFF, 1, 0, 0x3F, 0xFF, 1     ; Positive max
SARW_AX_TEST  55, 0x8000, 15, 0, 0xFF, 0xFF, 0    ; Negative min, shift 15
SARW_AX_TEST  56, 0x0000, 1, 1, 0x00, 0x00, 0     ; Zero shift
SARW_AX_TEST  57, 0xFFFE, 1, 0, 0xFF, 0xFF, 0     ; -2 shift
SARW_AX_TEST  58, 0x7FFE, 15, 0, 0x00, 0x00, 1    ; Positive to zero
SARW_AX_TEST  59, 0xFFFF, 15, 0, 0xFF, 0xFF, 1    ; All bits 1, shift 15 (sign extend)
SARW_AX_TEST  60, 0x0000, 15, 1, 0x00, 0x00, 0    ; Zero shift 15
SARW_AX_TEST  61, 0x7FFF, 15, 0, 0x00, 0x00, 1    ; Positive max, shift 15
SARW_AX_TEST  62, 0xAAAA, 1, 1, 0xD5, 0x55, 0     ; Negative alternating, shift 1
SARW_AX_TEST  63, 0xAAAA, 8, 0, 0xFF, 0xAA, 1     ; Negative alternating, shift 8
SARW_AX_TEST  64, 0x5555, 1, 0, 0x2A, 0xAA, 1     ; Positive alternating, shift 1
SARW_AX_TEST  65, 0x5555, 8, 1, 0x00, 0x55, 0     ; Positive alternating, shift 8

TEST_FOOTER
