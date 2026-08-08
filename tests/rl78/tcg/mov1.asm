$INCLUDE    "../harness/prelude.asm"

; ==============================================================================
; MOV1 Instruction Test Macros
; ==============================================================================

; ------------------------------------------------------------------------------
; MOV1 CY, A.bit - Move bit from A register to CY
; ------------------------------------------------------------------------------
MOV1_CY_Abit_TEST .MACRO test_number, bit_pos, input_a, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #init_cy
    ACT
        MOV1 CY, A.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 A.bit, CY - Move CY to bit in A register
; ------------------------------------------------------------------------------
MOV1_Abit_CY_TEST .MACRO test_number, bit_pos, input_a, cy_val, expected_a, expected_cy
TEST    test_number
    ARRANGE
        MOV A, #input_a
        MOV PSW, #cy_val
    ACT
        MOV1 A.bit_pos, CY
    ASSERT
        ASSERT_REG  REG_A, expected_a
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 CY, [HL].bit - Move bit from [HL] to CY
; ------------------------------------------------------------------------------
MOV1_CY_HLbit_TEST .MACRO test_number, bit_pos, hl_val, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV !test_mem, #hl_val
        MOVW HL, #LOWW(test_mem)
        MOV PSW, #init_cy
    ACT
        MOV1 CY, [HL].bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 [HL].bit, CY - Move CY to bit in [HL]
; ------------------------------------------------------------------------------
MOV1_HLbit_CY_TEST .MACRO test_number, bit_pos, hl_init, cy_val, expected_hl, expected_cy
TEST    test_number
    ARRANGE
        MOV !test_mem, #hl_init
        MOVW HL, #LOWW(test_mem)
        MOV PSW, #cy_val
    ACT
        MOV1 [HL].bit_pos, CY
    ASSERT
        ASSERT_MEM  test_mem, 0, expected_hl
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 CY, saddr.bit - Move bit from saddr to CY
; ------------------------------------------------------------------------------
MOV1_CY_saddrbit_TEST .MACRO test_number, bit_pos, saddr_val, init_cy, expected_cy
TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFE20), #saddr_val
        MOV PSW, #init_cy
    ACT
        MOV1 CY, 0xFFE20.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 saddr.bit, CY - Move CY to bit in saddr
; ------------------------------------------------------------------------------
MOV1_saddrbit_CY_TEST .MACRO test_number, bit_pos, saddr_init, cy_val, expected_saddr, expected_cy
TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFE20), #saddr_init
        MOV PSW, #cy_val
    ACT
        MOV1 0xFFE20.bit_pos, CY
    ASSERT
        ASSERT_MEM  0xFFE20, 0, expected_saddr
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 CY, sfr.bit - Move bit from sfr to CY
; ------------------------------------------------------------------------------
MOV1_CY_sfrbit_TEST .MACRO test_number, bit_pos, sfr_val, init_cy, expected_cy
IGNORE_TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFF40), #sfr_val
        MOV PSW, #init_cy
    ACT
        MOV1 CY, 0xFFF40.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 sfr.bit, CY - Move CY to bit in sfr
; ------------------------------------------------------------------------------
MOV1_sfrbit_CY_TEST .MACRO test_number, bit_pos, sfr_init, cy_val, expected_sfr, expected_cy
IGNORE_TEST    test_number
    ARRANGE
        MOV !LOWW(0xFFF40), #sfr_init
        MOV PSW, #cy_val
    ACT
        MOV1 0xFFF40.bit_pos, CY
    ASSERT
        ASSERT_MEM  0xFFF40, 0, expected_sfr
        ASSERT_REG  REG_PSW, expected_cy
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 CY, PSW.bit - Move bit from PSW to CY
; Note: psw_init already contains the initial CY value
; ------------------------------------------------------------------------------
MOV1_CY_PSWbit_TEST .MACRO test_number, bit_pos, psw_init, expected_psw
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
    ACT
        MOV1 CY, PSW.bit_pos
    ASSERT
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ------------------------------------------------------------------------------
; MOV1 PSW.bit, CY - Move CY to bit in PSW
; ------------------------------------------------------------------------------
MOV1_PSWbit_CY_TEST .MACRO test_number, bit_pos, psw_init, expected_psw
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
    ACT
        MOV1 PSW.bit_pos, CY
    ASSERT
        ASSERT_REG  REG_PSW, expected_psw
END test_number
.ENDM

; ==============================================================================
; Test Cases
; ==============================================================================

TEST_HEADER

; ==============================================================================
; Group 1: MOV1 CY, A.bit (7 cases)
; ==============================================================================

MOV1_CY_Abit_TEST   1, 0, 0xAA, 0, 0    ; bit 0 = 0
MOV1_CY_Abit_TEST   2, 1, 0xAA, 0, 1    ; bit 1 = 1
MOV1_CY_Abit_TEST   3, 7, 0xAA, 1, 1    ; bit 7 = 1 (MSB)
MOV1_CY_Abit_TEST   4, 0, 0x55, 0, 1    ; bit 0 = 1
MOV1_CY_Abit_TEST   5, 7, 0x55, 1, 0    ; bit 7 = 0
MOV1_CY_Abit_TEST   6, 3, 0x00, 1, 0    ; All bits 0
MOV1_CY_Abit_TEST   7, 5, 0xFF, 0, 1    ; All bits 1

; ==============================================================================
; Group 2: MOV1 A.bit, CY (6 cases)
; ==============================================================================

MOV1_Abit_CY_TEST   8, 0, 0x00, 1, 0x01, 1    ; Set bit 0
MOV1_Abit_CY_TEST   9, 7, 0x00, 1, 0x80, 1    ; Set bit 7 (MSB)
MOV1_Abit_CY_TEST  10, 3, 0xFF, 0, 0xF7, 0    ; Clear bit 3
MOV1_Abit_CY_TEST  11, 0, 0xFE, 1, 0xFF, 1    ; Preserve other bits
MOV1_Abit_CY_TEST  12, 4, 0xAA, 1, 0xBA, 1    ; Pattern test
MOV1_Abit_CY_TEST  13, 5, 0x55, 0, 0x55, 0    ; Bit already 0

; ==============================================================================
; Group 3: MOV1 CY, [HL].bit (5 cases)
; ==============================================================================

MOV1_CY_HLbit_TEST  14, 0, 0xAA, 1, 0    ; bit 0 = 0
MOV1_CY_HLbit_TEST  15, 1, 0xAA, 0, 1    ; bit 1 = 1
MOV1_CY_HLbit_TEST  16, 7, 0x80, 0, 1    ; MSB only set
MOV1_CY_HLbit_TEST  17, 3, 0x08, 0, 1    ; bit 3 only set
MOV1_CY_HLbit_TEST  18, 6, 0x00, 1, 0    ; All bits 0

; ==============================================================================
; Group 4: MOV1 [HL].bit, CY (5 cases)
; ==============================================================================

MOV1_HLbit_CY_TEST  19, 0, 0x00, 1, 0x01, 1    ; Set bit 0
MOV1_HLbit_CY_TEST  20, 7, 0x00, 1, 0x80, 1    ; Set bit 7
MOV1_HLbit_CY_TEST  21, 3, 0xFF, 0, 0xF7, 0    ; Clear bit 3
MOV1_HLbit_CY_TEST  22, 6, 0xAA, 1, 0xEA, 1    ; Pattern test
MOV1_HLbit_CY_TEST  23, 4, 0x55, 0, 0x45, 0    ; Pattern test

; ==============================================================================
; Group 5: MOV1 CY, saddr.bit (5 cases)
; ==============================================================================

MOV1_CY_saddrbit_TEST  24, 0, 0x01, 0, 1    ; bit 0 set
MOV1_CY_saddrbit_TEST  25, 7, 0x80, 0, 1    ; bit 7 set
MOV1_CY_saddrbit_TEST  26, 3, 0x00, 1, 0    ; All bits 0
MOV1_CY_saddrbit_TEST  27, 5, 0xAA, 0, 1    ; Pattern
MOV1_CY_saddrbit_TEST  28, 5, 0x55, 1, 0    ; Pattern

; ==============================================================================
; Group 6: MOV1 saddr.bit, CY (5 cases)
; ==============================================================================

MOV1_saddrbit_CY_TEST  29, 0, 0x00, 1, 0x01, 1    ; Set bit 0
MOV1_saddrbit_CY_TEST  30, 7, 0x00, 1, 0x80, 1    ; Set bit 7
MOV1_saddrbit_CY_TEST  31, 3, 0xFF, 0, 0xF7, 0    ; Clear bit 3
MOV1_saddrbit_CY_TEST  32, 2, 0xAA, 1, 0xAE, 1    ; Pattern
MOV1_saddrbit_CY_TEST  33, 6, 0x55, 0, 0x15, 0    ; Pattern

; ==============================================================================
; Group 7: MOV1 CY, sfr.bit (3 cases)
; ==============================================================================

MOV1_CY_sfrbit_TEST  34, 0, 0x01, 0, 1    ; bit 0
MOV1_CY_sfrbit_TEST  35, 7, 0x80, 0, 1    ; bit 7
MOV1_CY_sfrbit_TEST  36, 3, 0xAA, 1, 1    ; Pattern

; ==============================================================================
; Group 8: MOV1 sfr.bit, CY (3 cases)
; ==============================================================================

MOV1_sfrbit_CY_TEST  37, 0, 0x00, 1, 0x01, 1    ; Set bit 0
MOV1_sfrbit_CY_TEST  38, 7, 0xFF, 0, 0x7F, 0    ; Clear bit 7
MOV1_sfrbit_CY_TEST  39, 4, 0xAA, 0, 0xAA, 0    ; Bit already 0

; ==============================================================================
; Group 9: MOV1 CY, PSW.bit - All bit positions (9 cases)
; ==============================================================================

MOV1_CY_PSWbit_TEST  40, 0, 0x01, 0x01    ; CY (bit 0) = 1
MOV1_CY_PSWbit_TEST  41, 0, 0x00, 0x00    ; CY (bit 0) = 0
MOV1_CY_PSWbit_TEST  42, 1, 0x02, 0x03    ; ISP0 (bit 1) = 1
MOV1_CY_PSWbit_TEST  43, 2, 0x04, 0x05    ; ISP1 (bit 2) = 1
MOV1_CY_PSWbit_TEST  44, 3, 0x08, 0x09    ; RBS0 (bit 3) = 1
MOV1_CY_PSWbit_TEST  45, 4, 0x10, 0x11    ; AC (bit 4) = 1
MOV1_CY_PSWbit_TEST  46, 5, 0x20, 0x21    ; RBS1 (bit 5) = 1
MOV1_CY_PSWbit_TEST  47, 6, 0x40, 0x41    ; Z (bit 6) = 1
MOV1_CY_PSWbit_TEST  48, 7, 0x80, 0x81    ; IE (bit 7) = 1

; ==============================================================================
; Group 10: MOV1 PSW.bit, CY - All bit positions (9 cases)
; ==============================================================================

MOV1_PSWbit_CY_TEST  49, 0, 0x01, 0x01    ; CY (bit 0) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  50, 0, 0x00, 0x00    ; CY (bit 0) clear, PSW=0x00 (CY=0)
MOV1_PSWbit_CY_TEST  51, 1, 0x01, 0x03    ; ISP0 (bit 1) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  52, 2, 0x01, 0x05    ; ISP1 (bit 2) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  53, 3, 0x01, 0x09    ; RBS0 (bit 3) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  54, 4, 0x01, 0x11    ; AC (bit 4) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  55, 5, 0x01, 0x21    ; RBS1 (bit 5) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  56, 6, 0x01, 0x41    ; Z (bit 6) set, PSW=0x01 (CY=1)
MOV1_PSWbit_CY_TEST  57, 7, 0x01, 0x81    ; IE (bit 7) set, PSW=0x01 (CY=1)

; ==============================================================================
; Group 11: Edge Cases (3 cases)
; ==============================================================================

; Test 58: Sequential bit scan - A.0→CY, A.1→CY, ... A.7→CY
TEST    58
    ARRANGE
        MOV A, #0xAA    ; Pattern: 10101010
        MOV PSW, #0
    ACT
        MOV1 CY, A.0    ; Should be 0
        MOV1 CY, A.1    ; Should be 1
        MOV1 CY, A.2    ; Should be 0
        MOV1 CY, A.3    ; Should be 1
        MOV1 CY, A.4    ; Should be 0
        MOV1 CY, A.5    ; Should be 1
        MOV1 CY, A.6    ; Should be 0
        MOV1 CY, A.7    ; Should be 1
    ASSERT
        ASSERT_REG  REG_PSW, 1    ; Final CY should be 1
END 58

; Test 59: Bit preservation - MOV1 A.3, CY should preserve other 7 bits
TEST    59
    ARRANGE
        MOV A, #0xF7    ; 11110111 (bit 3 = 0)
        MOV PSW, #1     ; CY = 1
    ACT
        MOV1 A.3, CY    ; Set bit 3
    ASSERT
        ASSERT_REG  REG_A, 0xFF    ; Should be 11111111
        ASSERT_REG  REG_PSW, 1
END 59

; Test 60: Flag non-destructive - Z=1, AC=1 should be preserved
TEST    60
    ARRANGE
        MOV A, #0xAA
        MOV PSW, #0x51  ; CY=1, AC=1, Z=1 (01010001)
    ACT
        MOV1 CY, A.0    ; Read bit (CY will become 0)
        MOV1 A.4, CY    ; Write bit
    ASSERT
        ASSERT_REG  REG_A, 0xAA    ; A.4 was already 0, should stay same
        ASSERT_REG  REG_PSW, 0x50  ; Z and AC preserved, CY=0
END 60

TEST_FOOTER

; ==============================================================================
; Data Sections
; ==============================================================================

.SECTION .data, DATA
test_mem:
    .DS 1    ; [HL] test memory
