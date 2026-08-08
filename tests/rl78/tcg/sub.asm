$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOV     A, #8
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUB     A, #8
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 1

TEST    2
    ARRANGE
        MOV     A, #7
        MOV     PSW, #(PSW_Z)
    ACT
        SUB     A, #8
    ASSERT
        ASSERT_REG  REG_A, 255
        ASSERT_REG  REG_PSW, 0x11
END 2

TEST    3
    ARRANGE
        MOV     A, #8
        MOV     PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        SUB     A, #7
    ASSERT
        ASSERT_REG  REG_A, 1
        ASSERT_REG  REG_PSW, 0
END 3

TEST    4
    ARRANGE
        MOV     A, #0x10
        MOV     PSW, #(PSW_Z | PSW_AC)
    ACT
        SUB     A, #0x20
    ASSERT
        ASSERT_REG  REG_A, 0xF0
        ASSERT_REG  REG_PSW, 0x01
END 4


TEST_FOOTER