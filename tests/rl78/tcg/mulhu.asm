$INCLUDE    "../harness/prelude.asm"

TEST_HEADER
TEST    1
    ARRANGE
        MOVW AX, #0x00
        MOVW BC, #0x00
    ACT
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
END 1

TEST    2
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    BC, #0xFFFF
    ACT
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0xFF
        ASSERT_REG  REG_C, 0xFE
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x01
END 2

TEST    3
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    BC, #0x0000
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
END 3

TEST    4
    ARRANGE
        MOVW    AX, #0x0000
        MOVW    BC, #0xDEAD
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0x00
        ASSERT_REG  REG_X, 0x00
END 4

TEST    5
    ARRANGE
        MOVW    AX, #0xDEAD
        MOVW    BC, #0x0001
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
END 5

TEST    6
    ARRANGE
        MOVW    AX, #0x0001
        MOVW    BC, #0xDEAD
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0xDE
        ASSERT_REG  REG_X, 0xAD
END 6

TEST    7
    ARRANGE
        MOVW    AX, #0xFFFF
        MOVW    BC, #0x0001
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_X, 0xFF
END 7

TEST    8
    ARRANGE
        MOVW    AX, #0x0001
        MOVW    BC, #0xFFFF
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0x00
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_X, 0xFF
END 8

TEST    9
    ARRANGE
        MOVW    AX, #0x8000
        MOVW    BC, #0xFFFF
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x7F
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_A, 0x80
        ASSERT_REG  REG_X, 0x00
END 9

TEST    10
    ARRANGE
        MOVW    AX, #0x0100
        MOVW    BC, #0xFFFF
    ACT 
        MULHU
    ASSERT
        ASSERT_REG  REG_B, 0x00
        ASSERT_REG  REG_C, 0xFF
        ASSERT_REG  REG_A, 0xFF
        ASSERT_REG  REG_X, 0x00
END 10

TEST_FOOTER