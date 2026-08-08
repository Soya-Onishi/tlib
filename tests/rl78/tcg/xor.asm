$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #0x55
        MOV PSW, #0
    ACT
        XOR A, #0x55
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 1

TEST    2
    ARRANGE
        MOV A, #0xAA
        MOV PSW, #(PSW_Z)
    ACT
        XOR A, #0x55
    ASSERT
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_PSW, 0x00
END 2

TEST    3
    ARRANGE
        MOV A, #0
        MOV PSW, #0
    ACT
        XOR A, #0
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 3

TEST_FOOTER