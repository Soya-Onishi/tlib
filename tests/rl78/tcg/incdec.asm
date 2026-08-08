$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
    .ALIGN  2
testdata:
    .DS 512

TEST_HEADER

; ============================================================
; INC (Increment) Tests
; INC dst: dst <- dst + 1
; Flags: Z (set if result = 0), AC (set if carry from bit 3 to 4), CY (unchanged)
; ============================================================

; Test 1: INC r (X register) - basic increment
TEST    1
    ARRANGE
        MOV X, #10
        MOV PSW, #0
    ACT
        INC X
    ASSERT
        ASSERT_REG  REG_X, 11
        ASSERT_REG  REG_PSW, 0x00
END 1

; Test 2: INC r (A register) - result is zero (0xFF -> 0x00)
TEST    2
    ARRANGE
        MOV A, #0xFF
        MOV PSW, #0
    ACT
        INC A
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_PSW, 0x50  ; Z flag set
END 2

; Test 3: INC r (C register) - AC flag set (0x0F -> 0x10)
TEST    3
    ARRANGE
        MOV C, #0x0F
        MOV PSW, #0
    ACT
        INC C
    ASSERT
        ASSERT_REG  REG_C, 0x10
        ASSERT_REG  REG_PSW, 0x10  ; AC flag set
END 3

; Test 4: INC r (B register) - both Z and AC flags set (0xFF -> 0x00)
TEST    4
    ARRANGE
        MOV B, #0xFF
        MOV PSW, #0
    ACT
        INC B
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x50  ; Z and AC flags set
END 4

; Test 5: INC r (E register) - CY flag unchanged
TEST    5
    ARRANGE
        MOV E, #42
        MOV PSW, #PSW_CY
    ACT
        INC E
    ASSERT
        ASSERT_REG  REG_E, 43
        ASSERT_REG  REG_PSW, 0x01  ; CY flag remains set
END 5

; Test 6: INC r (D register) - no flags set
TEST    6
    ARRANGE
        MOV D, #0x20
        MOV PSW, #(PSW_Z | PSW_AC)
    ACT
        INC D
    ASSERT
        ASSERT_REG  REG_D, 0x21
        ASSERT_REG  REG_PSW, 0x00  ; All flags cleared
END 6

; Test 7: INC r (L register) - AC flag at boundary (0x1F -> 0x20)
TEST    7
    ARRANGE
        MOV L, #0x1F
        MOV PSW, #0
    ACT
        INC L
    ASSERT
        ASSERT_REG  REG_L, 0x20
        ASSERT_REG  REG_PSW, 0x10  ; AC flag set
END 7

; Test 8: INC r (H register) - from 0 to 1
TEST    8
    ARRANGE
        MOV H, #0
        MOV PSW, #PSW_Z
    ACT
        INC H
    ASSERT
        ASSERT_REG  REG_H, 1
        ASSERT_REG  REG_PSW, 0x00  ; Z flag cleared
END 8

; Test 9: INC !addr16 - memory location
TEST    9
    ARRANGE
        MOV !LOWW(testdata), #100
        MOV PSW, #0
    ACT
        INC !LOWW(testdata)
    ASSERT
        ASSERT_MEM  testdata, 0, 101
END 9

; Test 10: INC saddr - short address (0xFF -> 0x00)
IGNORE_TEST    10
    ARRANGE
        MOV !LOWW(0xFFE20), #0xFF
        MOV PSW, #0
    ACT
        INC 0xFFE20
    ASSERT
        ASSERT_MEM  testdata, 25, 0x00
END 10

; Test 11: INC [HL+byte] - indirect with offset
TEST    11
    ARRANGE
        MOV !LOWW(testdata+50), #99
        MOVW HL, #LOWW(testdata)
        MOV PSW, #0
    ACT
        INC [HL+50]
    ASSERT
        ASSERT_MEM  testdata, 50, 100
END 11

; ============================================================
; DEC (Decrement) Tests
; DEC dst: dst <- dst - 1
; Flags: Z (set if result = 0), AC (set if borrow from bit 4 to 3), CY (unchanged)
; ============================================================

; Test 12: DEC r (X register) - basic decrement
TEST    12
    ARRANGE
        MOV X, #10
        MOV PSW, #0
    ACT
        DEC X
    ASSERT
        ASSERT_REG  REG_X, 9
        ASSERT_REG  REG_PSW, 0x00
END 12

; Test 13: DEC r (A register) - result is zero (1 -> 0)
TEST    13
    ARRANGE
        MOV A, #1
        MOV PSW, #0
    ACT
        DEC A
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_PSW, 0x40  ; Z flag set
END 13

; Test 14: DEC r (C register) - AC flag set (0x10 -> 0x0F)
TEST    14
    ARRANGE
        MOV C, #0x10
        MOV PSW, #0
    ACT
        DEC C
    ASSERT
        ASSERT_REG  REG_C, 0x0F
        ASSERT_REG  REG_PSW, 0x10  ; AC flag set
END 14

; Test 15: DEC r (B register) - wrap around (0x00 -> 0xFF)
TEST    15
    ARRANGE
        MOV B, #0x00
        MOV PSW, #0
    ACT
        DEC B
    ASSERT
        ASSERT_REG  REG_B, 0xFF
        ASSERT_REG  REG_PSW, 0x10  ; AC flag set
END 15

; Test 16: DEC r (E register) - CY flag unchanged
TEST    16
    ARRANGE
        MOV E, #42
        MOV PSW, #PSW_CY
    ACT
        DEC E
    ASSERT
        ASSERT_REG  REG_E, 41
        ASSERT_REG  REG_PSW, 0x01  ; CY flag remains set
END 16

; Test 17: DEC r (D register) - no flags set
TEST    17
    ARRANGE
        MOV D, #0x21
        MOV PSW, #(PSW_Z | PSW_CY)
    ACT
        DEC D
    ASSERT
        ASSERT_REG  REG_D, 0x20
        ASSERT_REG  REG_PSW, 0x01
END 17

; Test 18: DEC r (L register) - AC flag at boundary (0x20 -> 0x1F)
TEST    18
    ARRANGE
        MOV L, #0x20
        MOV PSW, #0
    ACT
        DEC L
    ASSERT
        ASSERT_REG  REG_L, 0x1F
        ASSERT_REG  REG_PSW, 0x10  ; AC flag set
END 18

; Test 19: DEC r (H register) - decrement to 0
TEST    19
    ARRANGE
        MOV H, #1
        MOV PSW, #0
    ACT
        DEC H
    ASSERT
        ASSERT_REG  REG_H, 0
        ASSERT_REG  REG_PSW, 0x40  ; Z flag set
END 19

; Test 20: DEC !addr16 - memory location
TEST    20
    ARRANGE
        MOV !LOWW(testdata+10), #100
        MOV PSW, #0
    ACT
        DEC !LOWW(testdata+10)
    ASSERT
        ASSERT_MEM  testdata, 10, 99
END 20

; Test 21: DEC saddr - short address (1 -> 0)
IGNORE_TEST    21
    ARRANGE
        MOV !LOWW(0xFFE20), #1
        MOV PSW, #0
    ACT
        DEC 0xFFE20
    ASSERT
        ASSERT_MEM  testdata, 26, 0x00
END 21

; Test 22: DEC [HL+byte] - indirect with offset
TEST    22
    ARRANGE
        MOV !LOWW(testdata+100), #50
        MOVW HL, #LOWW(testdata)
        MOV PSW, #0
    ACT
        DEC [HL+100]
    ASSERT
        ASSERT_MEM  testdata, 100, 49
END 22

; ============================================================
; INCW (Increment Word) Tests
; INCW dst: dst <- dst + 1
; Flags: Z, AC, CY - all unchanged
; ============================================================

; Test 23: INCW rp (AX register) - basic increment
TEST    23
    ARRANGE
        MOVW AX, #0x1234
        MOV PSW, #0
    ACT
        INCW AX
    ASSERT
        ASSERT_REG  REG_X, 0x35
        ASSERT_REG  REG_A, 0x12
        ASSERT_REG  REG_PSW, 0x00
END 23

; Test 24: INCW rp (BC register) - low byte overflow
TEST    24
    ARRANGE
        MOVW BC, #0x12FF
        MOV PSW, #0
    ACT
        INCW BC
    ASSERT
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x13
        ASSERT_REG  REG_PSW, 0x00  ; No flags changed
END 24

; Test 25: INCW rp (DE register) - word overflow (0xFFFF -> 0x0000)
TEST    25
    ARRANGE
        MOVW DE, #0xFFFF
        MOV PSW, #0
    ACT
        INCW DE
    ASSERT
        ASSERT_REG  REG_E, 0x00
        ASSERT_REG  REG_D, 0x00
        ASSERT_REG  REG_PSW, 0x00  ; No flags changed
END 25

; Test 26: INCW rp (HL register) - flags unchanged
TEST    26
    ARRANGE
        MOVW HL, #0x5678
        MOV PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        INCW HL
    ASSERT
        ASSERT_REG  REG_L, 0x79
        ASSERT_REG  REG_H, 0x56
        ASSERT_REG  REG_PSW, 0x51  ; All flags unchanged
END 26

; Test 27: INCW rp (BC register) - from 0 to 1
TEST    27
    ARRANGE
        MOVW BC, #0x0000
        MOV PSW, #PSW_Z
    ACT
        INCW BC
    ASSERT
        ASSERT_REG  REG_C, 0x01
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x40  ; Z flag unchanged
END 27

; Test 28: INCW !addr16 - memory location
TEST    28
    ARRANGE
        MOV !LOWW(testdata+20), #0x34
        MOV !LOWW(testdata+21), #0x12
        MOV PSW, #0
    ACT
        INCW !LOWW(testdata+20)
    ASSERT
        ASSERT_MEM  testdata, 20, 0x35
        ASSERT_MEM  testdata, 21, 0x12
END 28

; Test 29: INCW saddrp - short address pair
IGNORE_TEST    29
    ARRANGE
        MOV !LOWW(0xFFE20), #0xFF
        MOV !LOWW(0xFFE21), #0xFF
        MOV PSW, #0
    ACT
        INCW 0xFFE20
    ASSERT
        ASSERT_MEM  testdata, 28, 0x00
        ASSERT_MEM  testdata, 29, 0x00
END 29

; Test 30: INCW [HL+byte] - indirect with offset
TEST    30
    ARRANGE
        MOV !LOWW(testdata+150), #0x99
        MOV !LOWW(testdata+151), #0x88
        MOVW HL, #LOWW(testdata)
        MOV PSW, #0
    ACT
        INCW [HL+150]
    ASSERT
        ASSERT_MEM  testdata, 150, 0x9A
        ASSERT_MEM  testdata, 151, 0x88
END 30

; Test 31: INCW [HL+byte] - indirect with offset at odd address
TEST    31
    ARRANGE
        MOV !LOWW(testdata+160), #0xAD
        MOV !LOWW(testdata+161), #0xDE
        MOVW HL, #LOWW(testdata)
        MOV PSW, #0
    ACT
        INCW [HL+161]
    ASSERT
        ASSERT_MEM  testdata, 160, 0xAE
        ASSERT_MEM  testdata, 161, 0xDE
END 31

; ============================================================
; DECW (Decrement Word) Tests
; DECW dst: dst <- dst - 1
; Flags: Z, AC, CY - all unchanged
; ============================================================

; Test 32: DECW rp (AX register) - basic decrement
TEST    32
    ARRANGE
        MOVW AX, #0x1234
        MOV PSW, #0
    ACT
        DECW AX
    ASSERT
        ASSERT_REG  REG_X, 0x33
        ASSERT_REG  REG_A, 0x12
        ASSERT_REG  REG_PSW, 0x00
END 32

; Test 33: DECW rp (BC register) - low byte borrow
TEST    33
    ARRANGE
        MOVW BC, #0x1200
        MOV PSW, #0
    ACT
        DECW BC
    ASSERT
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_B, 0x11
        ASSERT_REG  REG_PSW, 0x00  ; No flags changed
END 33

; Test 34: DECW rp (DE register) - word underflow (0x0000 -> 0xFFFF)
TEST    34
    ARRANGE
        MOVW DE, #0x0000
        MOV PSW, #0
    ACT
        DECW DE
    ASSERT
        ASSERT_REG  REG_E, 0xFF
        ASSERT_REG  REG_D, 0xFF
        ASSERT_REG  REG_PSW, 0x00  ; No flags changed
END 34

; Test 35: DECW rp (HL register) - flags unchanged
TEST    35
    ARRANGE
        MOVW HL, #0x5678
        MOV PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        DECW HL
    ASSERT
        ASSERT_REG  REG_L, 0x77
        ASSERT_REG  REG_H, 0x56
        ASSERT_REG  REG_PSW, 0x51  ; All flags unchanged
END 35

; Test 36: DECW rp (BC register) - to 0
TEST    36
    ARRANGE
        MOVW BC, #0x0001
        MOV PSW, #0
    ACT
        DECW BC
    ASSERT
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00  ; Flags unchanged (Z not set)
END 36

; Test 37: DECW !addr16 - memory location
TEST    37
    ARRANGE
        MOV !LOWW(testdata+30), #0x34
        MOV !LOWW(testdata+31), #0x12
        MOV PSW, #0
    ACT
        DECW !LOWW(testdata+30)
    ASSERT
        ASSERT_MEM  testdata, 30, 0x33
        ASSERT_MEM  testdata, 31, 0x12
END 37

; Test 38: DECW saddrp - short address pair
IGNORE_TEST    38
    ARRANGE
        MOV !LOWW(0xFFE20), #0x00
        MOV !LOWW(0xFFE21), #0x00
        MOV PSW, #0
    ACT
        DECW 0xFFE20
    ASSERT
        ASSERT_MEM  0xFFE10, 0, 0xFF
        ASSERT_MEM  0xFFE10, 1, 0xFF
END 38

; Test 39: DECW [HL+byte] - indirect with offset
TEST    39
    ARRANGE
        MOV !LOWW(testdata+200), #0x00
        MOV !LOWW(testdata+201), #0x10
        MOVW HL, #LOWW(testdata)
        MOV PSW, #0
    ACT
        DECW [HL+200]
    ASSERT
        ASSERT_MEM  testdata, 200, 0xFF
        ASSERT_MEM  testdata, 201, 0x0F
END 39

; Test 40: DECW [HL+byte] - indirect with offset at odd address
TEST    40
    ARRANGE
        MOV !LOWW(testdata+210), #0xAD
        MOV !LOWW(testdata+211), #0xDE
        MOVW HL, #LOWW(testdata)
        MOV PSW, #0
    ACT
        DECW [HL+211]
    ASSERT
        ASSERT_MEM  testdata, 210, 0xAC
        ASSERT_MEM  testdata, 211, 0xDE
END 40


TEST_FOOTER
