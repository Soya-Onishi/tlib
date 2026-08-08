$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE 
        MOV     A, #8
        MOV     PSW, #(PSW_Z | PSW_AC)
    ACT
        SUBC    A, #7
    ASSERT
        ASSERT_REG  REG_A, 1
        ASSERT_REG  REG_PSW, 0x0
END 1

TEST    2
    ARRANGE 
        MOV     A, #8
        MOV     PSW, #(PSW_AC)
    ACT
        SUBC    A, #8
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 2

TEST    3
    ARRANGE 
        MOV     A, #8
        MOV     PSW, #(PSW_AC | PSW_CY)
    ACT
        SUBC    A, #7
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 3

TEST    4
    ARRANGE 
        MOV     A, #8
        MOV     PSW, #(PSW_Z | PSW_AC | PSW_CY)
    ACT
        SUBC    A, #8
    ASSERT
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_PSW, 0x11
END 4

TEST    5
    ARRANGE
        MOV     A, #0x10
        MOV     PSW, #(PSW_Z | PSW_CY)
    ACT
        SUBC    A, #0
    ASSERT
        ASSERT_REG  REG_A, 0x0F
        ASSERT_REG  REG_PSW, 0x10
END 5

TEST    6
    ARRANGE
        MOV     A, #0x0
        MOV     PSW, #(PSW_Z | PSW_CY)
    ACT
        SUBC    A, #0
    ASSERT
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_PSW, 0x11
END 6


TEST_FOOTER