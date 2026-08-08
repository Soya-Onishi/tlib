$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE     
        MOV A, #0xFF
        MOV PSW, #0
    ACT
        AND A, #0
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 1

TEST    2
    ARRANGE
        MOV A, #0xAA
        MOV PSW, #0
    ACT 
        AND A, #0x55
    ASSERT
        ASSERT_REG  REG_A, 0
        ASSERT_REG  REG_PSW, 0x40
END 2

TEST    3
    ARRANGE
        MOV A, #0xAA
        MOV PSW, #(PSW_Z)
    ACT
        AND A, #0x02
    ASSERT
        ASSERT_REG  REG_A, 2
        ASSERT_REG  REG_PSW, 0x00
END 3

TEST_FOOTER