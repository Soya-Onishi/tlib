$INCLUDE    "../harness/prelude.asm"

; ==============================================================================
; SET1 Instruction Test Macros
; ==============================================================================

SET1_CY_TEST .MACRO test_number, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV PSW, #init_cy
    ACT
        SET1 CY
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

SET1_Abit_TEST .MACRO test_number, bit_pos, input_a, expected_a
TEST    test_number
    ARRANGE
        MOV A, #input_a
    ACT
        SET1 A.bit_pos
    ASSERT
        ASSERT_REG  REG_A, expected_a
END test_number
.ENDM

SET1_HLbit_TEST .MACRO test_number, bit_pos, hl_val, expected_hl
TEST    test_number
    ARRANGE
        MOV !test_mem, #hl_val
        MOVW HL, #LOWW(test_mem)
    ACT
        SET1 [HL].bit_pos
    ASSERT
        ASSERT_MEM  test_mem, 0, expected_hl
END test_number
.ENDM

SET1_saddrbit_TEST .MACRO test_number, bit_pos, saddr_val, expected_saddr
TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFE20), #saddr_val
    ACT
        SET1 0xFFE20.bit_pos
    ASSERT
        ASSERT_MEM  0xFFE20, 0, expected_saddr
END test_number
.ENDM

SET1_sfrbit_TEST .MACRO test_number, bit_pos, sfr_val, expected_sfr
IGNORE_TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFF40), #sfr_val
    ACT
        SET1 0xFFF40.bit_pos
    ASSERT
        ASSERT_MEM  0xFFF40, 0, expected_sfr
END test_number
.ENDM

SET1_PSWbit_TEST .MACRO test_number, bit_pos, psw_init, expected_psw
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
    ACT
        SET1 PSW.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

SET1_addr_TEST .MACRO test_number, bit_pos, addr_val, expected_addr
TEST    test_number
    ARRANGE
        MOV !LOWW(test_mem), #addr_val
    ACT
        SET1 !LOWW(test_mem).bit_pos
    ASSERT
        ASSERT_MEM  test_mem, 0, expected_addr
END test_number
.ENDM

; ==============================================================================
; Test Cases
; ==============================================================================

TEST_HEADER

; ==============================================================================
; SET1 CY
; ==============================================================================

SET1_CY_TEST   1, 0x00, 0x01
SET1_CY_TEST   2, 0x01, 0x01

; ==============================================================================
; SET1 saddr.bit
; ==============================================================================

SET1_saddrbit_TEST   3, 0, 0xFE, 0xFF
SET1_saddrbit_TEST   4, 0, 0x01, 0x01
SET1_saddrbit_TEST   5, 7, 0x7F, 0xFF
SET1_saddrbit_TEST   6, 7, 0x80, 0x80
SET1_saddrbit_TEST   7, 3, 0xF7, 0xFF
SET1_saddrbit_TEST   8, 3, 0x08, 0x08

; ==============================================================================
; SET1 A.bit
; ==============================================================================

SET1_Abit_TEST   9, 0, 0xFE, 0xFF
SET1_Abit_TEST  10, 0, 0x01, 0x01
SET1_Abit_TEST  11, 7, 0x7F, 0xFF
SET1_Abit_TEST  12, 7, 0x80, 0x80
SET1_Abit_TEST  13, 3, 0xF7, 0xFF
SET1_Abit_TEST  14, 3, 0x08, 0x08

; ==============================================================================
; SET1 [HL].bit
; ==============================================================================

SET1_HLbit_TEST  15, 0, 0xFE, 0xFF
SET1_HLbit_TEST  16, 0, 0x01, 0x01
SET1_HLbit_TEST  17, 7, 0x7F, 0xFF
SET1_HLbit_TEST  18, 7, 0x80, 0x80
SET1_HLbit_TEST  19, 4, 0xEF, 0xFF
SET1_HLbit_TEST  20, 4, 0x10, 0x10

; ==============================================================================
; SET1 PSW.bit
; ==============================================================================

SET1_PSWbit_TEST  21, 0, 0x00, 0x01
SET1_PSWbit_TEST  22, 0, 0x01, 0x01
SET1_PSWbit_TEST  23, 7, 0x7F, 0xFF
SET1_PSWbit_TEST  24, 7, 0x80, 0x80
SET1_PSWbit_TEST  25, 4, 0xEF, 0xFF
SET1_PSWbit_TEST  26, 4, 0x10, 0x10

; ==============================================================================
; SET1 sfr.bit
; ==============================================================================

SET1_sfrbit_TEST  27, 0, 0xFE, 0xFF
SET1_sfrbit_TEST  28, 0, 0x01, 0x01
SET1_sfrbit_TEST  29, 7, 0x7F, 0xFF
SET1_sfrbit_TEST  30, 7, 0x80, 0x80
SET1_sfrbit_TEST  31, 3, 0xF7, 0xFF
SET1_sfrbit_TEST  32, 3, 0x08, 0x08

; ==============================================================================
; SET1 !addr16.bit
; ==============================================================================

SET1_addr_TEST  33, 0, 0xFE, 0xFF
SET1_addr_TEST  34, 0, 0x01, 0x01
SET1_addr_TEST  35, 7, 0x7F, 0xFF
SET1_addr_TEST  36, 7, 0x80, 0x80
SET1_addr_TEST  37, 3, 0xF7, 0xFF
SET1_addr_TEST  38, 3, 0x08, 0x08

TEST_FOOTER

.SECTION .data, DATA
test_mem:
    .DS 1
