$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #0

    ACT 
        BR  !jump0
        MOV A, #1
jump0:

    ASSERT
        ASSERT_REG  REG_A, 0

TEST    2
    ARRANGE
        MOV A, #0
    
    ACT
        BR  !jump1
        MOV A, #1
jump1:
        MOV A, #2

    ASSERT
        ASSERT_REG  REG_A, 2

TEST_FOOTER