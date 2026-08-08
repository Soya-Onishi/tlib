$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #42

    ACT
        MOV X, A

    ASSERT
        ASSERT_REGS 42, 42, 0, 0, 0, 0, 0, 0

TEST    2
    ARRANGE
        MOV A, #43

    ACT
        MOV C, A
    
    ASSERT
        ASSERT_REGS 0, 43, 43, 0, 0, 0, 0, 0

TEST    3
    ARRANGE
        MOV A, #44

    ACT
        MOV B, A
    
    ASSERT
        ASSERT_REGS 0, 44, 0, 44, 0, 0, 0, 0

TEST    4
    ARRANGE
        MOV A, #45

    ACT
        MOV E, A
    
    ASSERT
        ASSERT_REGS 0, 45, 0, 0, 45, 0, 0, 0

TEST    5
    ARRANGE
        MOV A, #46

    ACT
        MOV D, A
    
    ASSERT
        ASSERT_REGS 0, 46, 0, 0, 0, 46, 0, 0

TEST    6
    ARRANGE 
        MOV A, #47

    ACT
        MOV L, A
    
    ASSERT
        ASSERT_REGS 0, 47, 0, 0, 0, 0, 47, 0

TEST    7
    ARRANGE 
        MOV A, #48

    ACT
        MOV H, A
    
    ASSERT
        ASSERT_REGS 0, 48, 0, 0, 0, 0, 0, 48

TEST    8
    ARRANGE 
        MOV X, #49

    ACT
        MOV A, X
    
    ASSERT
        ASSERT_REGS 49, 49, 0, 0, 0, 0, 0, 0

TEST    9
    ARRANGE 
        MOV C, #50

    ACT
        MOV A, C
    
    ASSERT
        ASSERT_REGS 0, 50, 50, 0, 0, 0, 0, 0

TEST    10
    ARRANGE 
        MOV B, #51

    ACT
        MOV A, B
    
    ASSERT
        ASSERT_REGS 0, 51, 0, 51, 0, 0, 0, 0

TEST    11
    ARRANGE 
        MOV E, #52

    ACT
        MOV A, E
    
    ASSERT
        ASSERT_REGS 0, 52, 0, 0, 52, 0, 0, 0

TEST    12
    ARRANGE 
        MOV D, #53

    ACT
        MOV A, D
    
    ASSERT
        ASSERT_REGS 0, 53, 0, 0, 0, 53, 0, 0

TEST    13
    ARRANGE 
        MOV L, #54

    ACT
        MOV A, L
    
    ASSERT
        ASSERT_REGS 0, 54, 0, 0, 0, 0, 54, 0

TEST    14
    ARRANGE 
        MOV H, #55

    ACT
        MOV A, H
    
    ASSERT
        ASSERT_REGS 0, 55, 0, 0, 0, 0, 0, 55

TEST    15
    ARRANGE 
        MOV A, #255

    ACT
        MOV X, A
    
    ASSERT
        ASSERT_REGS 255, 255, 0, 0, 0, 0, 0, 0

TEST    16
    ARRANGE 
        MOV A, #0

    ACT
        MOV X, A
    
    ASSERT
        ASSERT_REGS 0, 0, 0, 0, 0, 0, 0, 0

TEST    17
    ARRANGE 
        MOV X, #255

    ACT
        MOV A, X
    
    ASSERT
        ASSERT_REGS 255, 255, 0, 0, 0, 0, 0, 0

TEST    18
    ARRANGE 
        MOV X, #0

    ACT
        MOV A, X
    
    ASSERT
        ASSERT_REGS 0, 0, 0, 0, 0, 0, 0, 0

TEST    19
    ARRANGE
        MOV A, #0xAA
    
    ACT
        MOV PSW, A

    ASSERT
        ASSERT_REG  REG_PSW, 0xAA

TEST    20
    ARRANGE
        MOV A, #0x55
    
    ACT
        MOV PSW, A

    ASSERT
        ASSERT_REG  REG_PSW, 0x55

TEST    21
    ARRANGE
        MOV PSW, #0xAA
    
    ACT
        MOV A, PSW

    ASSERT 
        ASSERT_REGS 0, 0xAA, 0, 0, 0, 0, 0, 0

TEST    22
    ARRANGE
        MOV PSW, #0x55
    
    ACT
        MOV A, PSW

    ASSERT 
        ASSERT_REGS 0, 0x55, 0, 0, 0, 0, 0, 0

TEST_FOOTER

