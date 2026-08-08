REG_X       .SET    0
REG_A       .SET    1
REG_C       .SET    2
REG_B       .SET    3
REG_E       .SET    4
REG_D       .SET    5
REG_L       .SET    6
REG_H       .SET    7
REG_PSW     .SET    8
REG_ES      .SET    9
REG_CS      .SET    10

PSW_IE      .SET    0x80
PSW_Z       .SET    0x40
PSW_AC      .SET    0x10
PSW_CY      .SET    0x01

; Test MMIO window is at 0xF0000. Near !addr16 addressing targets this page.
TEST_MMIO_STATUS     .SET    0x0000
TEST_MMIO_TEST_ID    .SET    0x0002
TEST_MMIO_ASSERT_ID  .SET    0x0004
TEST_MMIO_EXPECT     .SET    0x0006
TEST_MMIO_ACTUAL     .SET    0x0008
TEST_MMIO_IGNORED    .SET    0x000A

; Utility Macros

TEST_HEADER .MACRO
    _TESTNO .SET    0
    .text   .CSEG   TEXT
    start:
.ENDM

; Copy BSS diagnostics into MMIO, then write STATUS (0=PASS, non-zero=FAIL).
; STATUS write terminates the host harness process.
PUBLISH_RESULT .MACRO  STATUS_VALUE
        MOVW    AX, !LOWW(unit_test_test_number)
        MOVW    !TEST_MMIO_TEST_ID, AX
        MOVW    AX, !LOWW(unit_test_assert_number)
        MOVW    !TEST_MMIO_ASSERT_ID, AX
        MOVW    AX, !LOWW(unit_test_expect)
        MOVW    !TEST_MMIO_EXPECT, AX
        MOVW    AX, !LOWW(unit_test_actual)
        MOVW    !TEST_MMIO_ACTUAL, AX
        MOVW    AX, !LOWW(unit_test_ignored_count)
        MOVW    !TEST_MMIO_IGNORED, AX
        MOVW    AX, #STATUS_VALUE
        MOVW    !TEST_MMIO_STATUS, AX
.ENDM

TEST_FOOTER .MACRO
    test_end:
    test_success:
        PUBLISH_RESULT  0
        BR      !test_success
    test_fail:
        PUBLISH_RESULT  1
        BR      !test_fail
.ENDM

TEST    .MACRO  ARG_TESTNO
    _TESTNO  .SET      ARG_TESTNO
    _ASSERTNO .SET  0
    testno?ARG_TESTNO:
.ENDM

IGNORE_TEST .MACRO  ARG_TESTNO
    _TESTNO  .SET      ARG_TESTNO
    _ASSERTNO .SET  0
    testno?ARG_TESTNO:
        MOV     A, !LOWW(unit_test_ignored_count)
        CMP     A, #255
        SKZ
        INC     A
        MOV     !LOWW(unit_test_ignored_count), A
        BR      !end_testno?ARG_TESTNO
.ENDM

END     .MACRO  ARG_TESTNO
end_testno?ARG_TESTNO:
.ENDM

ARRANGE .MACRO
    .text   .CSEG   TEXT
        MOV X, #0
        MOV A, #0
        MOV C, #0
        MOV B, #0
        MOV E, #0
        MOV D, #0
        MOV L, #0
        MOV H, #0
        MOV PSW, A
        MOV ES, #0x0F
        MOV CS, #0x00
.ENDM

ACT .MACRO
.ENDM

ASSERT    .MACRO
    MOV !status_storage + REG_A, A
    MOV A, X
    MOV !status_storage + REG_X, A
    MOV A, C
    MOV !status_storage + REG_C, A
    MOV A, B
    MOV !status_storage + REG_B, A
    MOV A, E
    MOV !status_storage + REG_E, A
    MOV A, D
    MOV !status_storage + REG_D, A
    MOV A, L
    MOV !status_storage + REG_L, A
    MOV A, H
    MOV !status_storage + REG_H, A
    MOV A, PSW
    MOV !status_storage + REG_PSW, A
    MOV A, ES
    MOV !status_storage + REG_ES, A
    MOV A, CS
    MOV !status_storage + REG_CS, A
    MOVW AX, SP
    MOVW !sp_storage, AX
.ENDM

ASSERT_VALUE  .MACRO  VALUE
    _ASSERTNO    .SET    (_ASSERTNO + 1)
        CMP     A, #VALUE
        MOV     !LOWW(unit_test_actual), A
        MOV     A, #VALUE
        MOV     !LOWW(unit_test_expect), A
        MOV     A, #_TESTNO
        MOV     !LOWW(unit_test_test_number), A
        MOV     A, #_ASSERTNO
        MOV     !LOWW(unit_test_assert_number), A
        SKZ
        BR      !test_fail
.ENDM

ASSERT_REG  .MACRO  REGNAME, VALUE
    MOV A, !(status_storage + REGNAME)
    ASSERT_VALUE  VALUE
.ENDM

ASSERT_REGS  .MACRO  VAL_X, VAL_A, VAL_C, VAL_B, VAL_E, VAL_D, VAL_L, VAL_H
    ASSERT_REG  REG_X, VAL_X
    ASSERT_REG  REG_A, VAL_A
    ASSERT_REG  REG_C, VAL_C
    ASSERT_REG  REG_B, VAL_B
    ASSERT_REG  REG_E, VAL_E
    ASSERT_REG  REG_D, VAL_D
    ASSERT_REG  REG_L, VAL_L
    ASSERT_REG  REG_H, VAL_H
.ENDM

ASSERT_SP   .MACRO  VALUE
_ASSERTNO    .SET    (_ASSERTNO + 1)
    MOVW    AX, !LOWW(sp_storage)
    CMPW    AX, #LOWW(VALUE)
    MOVW    !LOWW(unit_test_actual), AX
    MOVW    AX, #LOWW(VALUE)
    MOVW    !LOWW(unit_test_expect), AX
    MOV     A, #_TESTNO
    MOV     !LOWW(unit_test_test_number), A
    MOV     A, #_ASSERTNO
    MOV     !LOWW(unit_test_assert_number), A
    SKZ
    BR      !test_fail
.ENDM

ASSERT_MEM  .MACRO  BASE, OFFSET, VALUE
    MOV             A, !LOWW(BASE + OFFSET)
    ASSERT_VALUE    VALUE
.ENDM

;========================
; Test Harness Header
;========================
start   .VECTOR   0x00000

.SECTION    .stack_area,     BSS_AT 0xFFAE0
stack_area:
    .DS 1024

.bss    .DSEG   BSS
status_storage:
    .DS 8           ; for registers
    .DS 1           ; for PSW
    .DS 1           ; for ES
    .DS 1           ; for CS

    .ALIGN 2
sp_storage:
    .DS 2           ; for SP

    .ALIGN  2
unit_test_complete:
    .DS 2
unit_test_success:
    .DS 2
unit_test_expect:
    .DS 2
unit_test_actual:
    .DS 2
unit_test_test_number:
    .DS 2
unit_test_assert_number:
    .DS 2
unit_test_ignored_count:
    .DS 2

ignored_test:
    .DS 1

.SECTION    .dataR, DATA
.SECTION    .sdataR, SDATA
.SECTION    .data, DATA
.L_section_data:
.SECTION    .sdata, SDATA
.L_section_sdata:
