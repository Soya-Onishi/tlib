$INCLUDE    "../harness/prelude.asm"

TEST_HEADER

MOV !LOWW(0xFFE20), #1
; MOV !LOWW(0xFFEFF), #2
; MOV !LOWW(0xFFF00), #3
; MOV !LOWW(0xFFF1F), #4

TEST    1
    ARRANGE
    ACT
        MOV ES, #0
    
    ASSERT
        ASSERT_REG  REG_ES, 0
END 1

IGNORE_TEST    2
    ARRANGE
    ACT
        MOV ES, #0x42
    
    ASSERT
        ASSERT_REG  REG_ES, 0x02
END 2

IGNORE_TEST    3
    ARRANGE
    ACT
        MOV ES, 0xFFE20

    ASSERT
        ASSERT_REG  REG_ES, 0x01
END 3

IGNORE_TEST    4
    ARRANGE
    ACT
        MOV ES, 0xFFF00

    ASSERT
        ASSERT_REG  REG_ES, 0x02
END 4


TEST    5
    ARRANGE
        MOV A, #0x42

    ACT
        MOV ES, A
    
    ASSERT
        ASSERT_REG  REG_ES, 0x02
END 5

TEST    6
    ARRANGE
        MOV ES, #0x00

    ACT
        MOV A, ES

    ASSERT
        ASSERT_REG  REG_A, 0x00
END 6

TEST    7
    ARRANGE
        MOV ES, #0x0F

    ACT
        MOV A, ES

    ASSERT
        ASSERT_REG  REG_A, 0x0F
END 7


TEST_FOOTER