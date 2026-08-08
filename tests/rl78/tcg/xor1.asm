$INCLUDE    "../harness/prelude.asm"

; ==============================================================================
; XOR1 Instruction Test Macros
; ==============================================================================

XOR1_CY_Abit_TEST .MACRO test_number, bit_pos, input_a, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        XOR1 CY, A.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

XOR1_CY_HLbit_TEST .MACRO test_number, bit_pos, hl_val, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV !test_mem, #hl_val
        MOVW HL, #LOWW(test_mem)
        MOV PSW, #init_cy
    ACT
        XOR1 CY, [HL].bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

XOR1_CY_saddrbit_TEST .MACRO test_number, bit_pos, saddr_val, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFE20), #saddr_val
        MOV PSW, #init_cy
    ACT
        XOR1 CY, 0xFFE20.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

XOR1_CY_sfrbit_TEST .MACRO test_number, bit_pos, sfr_val, init_cy, expected_cy
IGNORE_TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFF40), #sfr_val
        MOV PSW, #init_cy
    ACT
        XOR1 CY, 0xFFF40.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

XOR1_CY_PSWbit_TEST .MACRO test_number, bit_pos, psw_init, expected_psw
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
    ACT
        XOR1 CY, PSW.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ==============================================================================
; Test Cases
; ==============================================================================

TEST_HEADER

; ==============================================================================
; XOR1 CY, saddr.bit
; Truth table: CY XOR bit → CY
;   0 XOR 0 = 0
;   0 XOR 1 = 1
;   1 XOR 0 = 1
;   1 XOR 1 = 0
; ==============================================================================

XOR1_CY_saddrbit_TEST   1, 0, 0xFE, 0, 0
XOR1_CY_saddrbit_TEST   2, 0, 0x01, 0, 1
XOR1_CY_saddrbit_TEST   3, 7, 0x7F, 0, 0
XOR1_CY_saddrbit_TEST   4, 7, 0x80, 0, 1
XOR1_CY_saddrbit_TEST   5, 3, 0xF7, 0, 0
XOR1_CY_saddrbit_TEST   6, 3, 0xF7, 1, 1
XOR1_CY_saddrbit_TEST   7, 3, 0x08, 0, 1
XOR1_CY_saddrbit_TEST   8, 3, 0x08, 1, 0

; ==============================================================================
; XOR1 CY, A.bit
; ==============================================================================

XOR1_CY_Abit_TEST   9, 0, 0xFE, 0, 0
XOR1_CY_Abit_TEST  10, 0, 0x01, 0, 1
XOR1_CY_Abit_TEST  11, 7, 0x7F, 0, 0
XOR1_CY_Abit_TEST  12, 7, 0x80, 0, 1
XOR1_CY_Abit_TEST  13, 3, 0xF7, 0, 0
XOR1_CY_Abit_TEST  14, 3, 0xF7, 1, 1
XOR1_CY_Abit_TEST  15, 3, 0x08, 0, 1
XOR1_CY_Abit_TEST  16, 3, 0x08, 1, 0

; ==============================================================================
; XOR1 CY, [HL].bit
; ==============================================================================

XOR1_CY_HLbit_TEST  17, 0, 0xFE, 0, 0
XOR1_CY_HLbit_TEST  18, 0, 0x01, 0, 1
XOR1_CY_HLbit_TEST  19, 7, 0x7F, 0, 0
XOR1_CY_HLbit_TEST  20, 7, 0x80, 0, 1
XOR1_CY_HLbit_TEST  21, 4, 0xEF, 0, 0
XOR1_CY_HLbit_TEST  22, 4, 0xEF, 1, 1
XOR1_CY_HLbit_TEST  23, 4, 0x10, 0, 1
XOR1_CY_HLbit_TEST  24, 4, 0x10, 1, 0

; ==============================================================================
; XOR1 CY, PSW.bit
; ==============================================================================

XOR1_CY_PSWbit_TEST  25, 0, 0x00, 0x00
XOR1_CY_PSWbit_TEST  26, 0, 0x01, 0x00
XOR1_CY_PSWbit_TEST  27, 7, 0x7E, 0x7E
XOR1_CY_PSWbit_TEST  28, 7, 0x80, 0x81
XOR1_CY_PSWbit_TEST  29, 4, 0xEF, 0xEF
XOR1_CY_PSWbit_TEST  30, 4, 0xEE, 0xEE
XOR1_CY_PSWbit_TEST  31, 4, 0x10, 0x11
XOR1_CY_PSWbit_TEST  32, 4, 0x11, 0x10

; ==============================================================================
; XOR1 CY, sfr.bit
; ==============================================================================

XOR1_CY_sfrbit_TEST  33, 0, 0xFE, 0, 0
XOR1_CY_sfrbit_TEST  34, 0, 0x01, 0, 1
XOR1_CY_sfrbit_TEST  35, 7, 0x7F, 0, 0
XOR1_CY_sfrbit_TEST  36, 7, 0x80, 0, 1
XOR1_CY_sfrbit_TEST  37, 3, 0xF7, 0, 0
XOR1_CY_sfrbit_TEST  38, 3, 0xF7, 1, 1
XOR1_CY_sfrbit_TEST  39, 3, 0x08, 0, 1
XOR1_CY_sfrbit_TEST  40, 3, 0x08, 1, 0

TEST_FOOTER

.SECTION .data, DATA
test_mem:
    .DS 1
