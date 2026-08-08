$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

TEST    1
    ARRANGE
    ACT
        MOVW    AX, #0xDEAD

    ASSERT
        ASSERT_REGS 0xAD, 0xDE, 0, 0, 0, 0, 0, 0

TEST    2
    ARRANGE
    ACT
        MOVW    BC, #0xBEEF
    
    ASSERT
        ASSERT_REGS 0, 0, 0xEF, 0xBE, 0, 0, 0, 0

TEST    3
    ARRANGE
    ACT
        MOVW    DE, #0xDEAD
    
    ASSERT
        ASSERT_REGS 0, 0, 0, 0, 0xAD, 0xDE, 0, 0

TEST    4
    ARRANGE
    ACT
        MOVW    HL, #0xBEEF

    ASSERT 
        ASSERT_REGS 0, 0, 0, 0, 0, 0, 0xEF, 0xBE
END 4

TEST    5
    ARRANGE
    ACT
        MOVW    SP, #0xDEAD
    ASSERT
        ASSERT_SP 0xDEAC
END 5

TEST    6
    ARRANGE
    ACT
        MOVW    SP, #0xDEAE
    ASSERT
        ASSERT_SP 0xDEAE
END 6


TEST_FOOTER