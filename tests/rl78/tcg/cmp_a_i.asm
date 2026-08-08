$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
        MOV A, #255
        MOV PSW, #(PSW_AC | PSW_CY)
    
    ACT 
        CMP A, #255

    ASSERT
        ASSERT_REG  REG_PSW, 0x40

TEST    2
    ARRANGE
        MOV A, #255
        MOV PSW, #(PSW_Z | PSW_AC | PSW_CY)
    
    ACT
        CMP A, #254

    ASSERT
        ASSERT_REG  REG_PSW, 0x00

TEST    3
    ARRANGE
        MOV A, #255
        MOV PSW, #(PSW_Z | PSW_AC | PSW_CY)
    
    ACT
        CMP A, #0

    ASSERT
        ASSERT_REG  REG_PSW, 0x00

TEST    4
    ARRANGE 
        MOV A, #0
        MOV PSW, #(PSW_Z)

    ACT
        CMP A, #255
    
    ASSERT
        ASSERT_REG  REG_PSW, 0x11

TEST    5
    ARRANGE
        MOV A, #0
        MOV PSW, #(PSW_Z)

    ACT
        CMP A, #1
    
    ASSERT
        ASSERT_REG  REG_PSW, 0x11

TEST    6
    ARRANGE
        MOV A, #0
        MOV PSW, #(PSW_AC | PSW_CY)
    
    ACT 
        CMP A, #0

    ASSERT
        ASSERT_REG  REG_PSW, 0x40

TEST    7
    ARRANGE
        MOV A, #254
        MOV PSW, #(PSW_Z | PSW_CY)

    ACT
        CMP A, #0x0F

    ASSERT
        ASSERT_REG  REG_PSW, 0x10

TEST    8
    ARRANGE
        MOV A, #0
        MOV PSW, #(PSW_Z | PSW_AC)

    ACT
        CMP A, #0x10

    ASSERT
        ASSERT_REG  REG_PSW, 0x01

TEST_FOOTER