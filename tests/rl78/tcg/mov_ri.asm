$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST 1
    ARRANGE

    ACT
    MOV X, #1

    ASSERT
    ASSERT_REGS 1, 0, 0, 0, 0, 0, 0, 0

TEST 2
    ARRANGE

    ACT
    MOV A, #2

    ASSERT
    ASSERT_REGS 0, 2, 0, 0, 0, 0, 0, 0

TEST 3
    ARRANGE

    ACT
    MOV C, #3

    ASSERT
    ASSERT_REGS 0, 0, 3, 0, 0, 0, 0, 0

TEST 4
    ARRANGE

    ACT
    MOV B, #4

    ASSERT
    ASSERT_REGS 0, 0, 0, 4, 0, 0, 0, 0

TEST 5
    ARRANGE

    ACT
    MOV E, #5

    ASSERT
    ASSERT_REGS 0, 0, 0, 0, 5, 0, 0, 0

TEST 6
    ARRANGE

    ACT
    MOV D, #6

    ASSERT
    ASSERT_REGS 0, 0, 0, 0, 0, 6, 0, 0

TEST 7
    ARRANGE

    ACT
    MOV L, #7

    ASSERT
    ASSERT_REGS 0, 0, 0, 0, 0, 0, 7, 0

TEST 8
    ARRANGE

    ACT
    MOV H, #8

    ASSERT
    ASSERT_REGS 0, 0, 0, 0, 0, 0, 0, 8

TEST 9
    ARRANGE

    ACT
    MOV A, #255

    ASSERT
    ASSERT_REGS 0, 255, 0, 0, 0, 0, 0, 0

TEST 10
    ARRANGE

    ACT
    MOV A, #0

    ASSERT
    ASSERT_REGS 0, 0, 0, 0, 0, 0, 0, 0

TEST 11
    ARRANGE
    ACT
        MOV PSW, #0xAA
    
    ASSERT
        ASSERT_REG  REG_PSW, 0xAA

TEST 12
    ARRANGE
    ACT
        MOV PSW, #0x55

    ASSERT
        ASSERT_REG  REG_PSW, 0x55

TEST_FOOTER