$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    !0xFFF2, AX
        MOVW    AX, #0xFFFF
        MOVW    BC, #0xFFFF
        MOV     PSW, #(PSW_AC)
    ACT
        MACHU
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x01
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0xFE
        ASSERT_REG  REG_B, 0xFF 
        ASSERT_REG  REG_PSW, 0x00
END     1

TEST    2
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    !0xFFF2, AX
        MOVW    AX, #0xFFFF
        MOVW    BC, #0xFFFF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x01
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00
END     2

TEST    3
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0000
        MOVW    BC, #0x0000
    ACT
        MACHU   
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00
END     3

TEST    4
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0000
        MOVW    BC, #0x0000
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00
END     4

TEST    5
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF0, AX
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0001
        MOVW    BC, #0x0001
        MOV     PSW, #(PSW_AC)
    ACT
        MACHU
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x01
END     5

TEST    6
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF0, AX
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0001
        MOVW    BC, #0x0001
        MOV     PSW, #(PSW_AC)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00
END     6

TEST    7
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF0, AX
        MOVW    AX, #0x7FFF
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0001
        MOVW    BC, #0x0001
        MOV     PSW, #(PSW_AC)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x80
        ASSERT_REG  REG_PSW, 0x11
END     7

TEST    8
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    AX, #0x8000
        MOVW    !0xFFF2, AX
        MOVW    AX, #0xFFFF
        MOVW    BC, #0x0001
        MOV     PSW, #(PSW_AC)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_B, 0x7F
        ASSERT_REG  REG_PSW, 0x01
END     8

TEST    9
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF0, AX
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0000
        MOVW    BC, #0x0000
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        MACHU
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_B, 0xFF
        ASSERT_REG  REG_PSW, 0x00
END     9

TEST    10
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF0, AX
        MOVW    AX, #0xFFFF
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0000
        MOVW    BC, #0x0000
        MOV     PSW, #(PSW_CY)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_B, 0xFF
        ASSERT_REG  REG_PSW, 0x10
END     10

TEST    11
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    AX, #0x0000
        MOVW    !0xFFF2, AX
        MOVW    AX, #0xFFFF
        MOVW    BC, #0x0001
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        MACHU
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00
END     11

TEST    12
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    AX, #0x0000
        MOVW    !0xFFF2, AX
        MOVW    AX, #0xFFFF
        MOVW    BC, #0x0001
        MOV     PSW, #(PSW_CY)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_B, 0xFF
        ASSERT_REG  REG_PSW, 0x10
END     12

TEST    13
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    AX, #0x0000
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0001
        MOVW    BC, #0xFFFF
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        MACHU
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_PSW, 0x00
END     13

TEST    14
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    !0xFFF0, AX
        MOVW    AX, #0x0000
        MOVW    !0xFFF2, AX
        MOVW    AX, #0x0001
        MOVW    BC, #0xFFFF
        MOV     PSW, #(PSW_CY)
    ACT
        MACH
        MOVW    AX, !0xFFF0
        MOVW    BC, !0xFFF2
    ASSERT
        ASSERT_REG  REG_X, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_B, 0xFF
        ASSERT_REG  REG_PSW, 0x10
END     14

TEST_FOOTER