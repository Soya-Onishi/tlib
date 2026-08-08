$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #255
        MOV PSW, #0
    ACT
        ADDC A, #1
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x51
END 1

TEST    2
    ARRANGE
        MOV A, #255
        MOV PSW, #(PSW_CY)
    ACT 
        ADDC A, #0
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x51
END 2

TEST    3
    ARRANGE
        MOV     A, #0x0F
        MOV     PSW, #0
    ACT
        ADDC    A, #1
    ASSERT 
        ASSERT_REG  REG_A, 0x10
        ASSERT_REG  REG_PSW, 0x10
END 3

TEST    4
    ARRANGE
        MOV     A, #0x0E
        MOV     PSW, #PSW_CY
    ACT
        ADDC    A, #1
    ASSERT
        ASSERT_REG  REG_A, 0x10
        ASSERT_REG  REG_PSW, 0x10
END 4

TEST    5
    ARRANGE
        MOV     A, #1
        MOV     PSW, #(PSW_Z | PSW_AC)
    ACT
        ADDC    A, #2
    ASSERT
        ASSERT_REG  REG_A, 3
        ASSERT_REG  REG_PSW, 0x0
END 5

TEST    6
    ARRANGE
        MOV     A, #0
        MOV     PSW, #0
    ACT
        ADDC    A, #0
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 6

TEST_FOOTER