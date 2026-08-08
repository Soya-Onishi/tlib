$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
    ACT
        MOV CS, #0x42
    
    ASSERT
        ASSERT_REG  REG_CS, 0x02
END 1

TEST    2
    ARRANGE
        MOV A, #0xAB
    ACT
        MOV CS, A
    
    ASSERT
        ASSERT_REG  REG_CS, 0x0B
END 2


TEST    3
    ARRANGE
        MOV CS, #0x00

    ACT
        MOV A, CS

    ASSERT
        ASSERT_REG  REG_A, 0x00
END 3

TEST    4
    ARRANGE
        MOV CS, #0x0F

    ACT
        MOV A, CS

    ASSERT
        ASSERT_REG  REG_A, 0x0F
END 4


TEST_FOOTER