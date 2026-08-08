$INCLUDE    "../harness/prelude.asm"

TEST_HEADER
TEST    1
    ARRANGE
        MOV A, #0x00
        MOV X, #0x00
    ACT
        MULU    X
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
END 1

TEST    2
    ARRANGE
        MOV A, #0xFF
        MOV X, #0xFF
    ACT
        MULU    X
    ASSERT
        ASSERT_REG  REG_A, 0xFE
        ASSERT_REG  REG_X, 0x01
END 2

TEST    3
    ARRANGE
        MOV A, #0x42
        MOV X, #0x00
    ACT 
        MULU    X
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
END 3

TEST    4
    ARRANGE
        MOV A, #0x00
        MOV X, #0x42
    ACT 
        MULU    X
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
END 4

TEST    5
    ARRANGE
        MOV A, #0xFF
        MOV X, #0x01
    ACT
        MULU    X
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0xFF
END 5

TEST    6
    ARRANGE
        MOV A, #0x01
        MOV X, #0xFF
    ACT
        MULU    X
    ASSERT
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0xFF
END 6

TEST_FOOTER