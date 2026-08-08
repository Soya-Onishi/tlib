$INCLUDE    "../harness/prelude.asm"


TEST_SKC    .MACRO  test_number, psw_init, noskip
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
        MOV C, #noskip

    ACT
        MOV A, #0
        SKC
        MOV A, #1
        SKC
        SKC
        MOV X, #1
        SKC
        BR  !branch_?test_number
        MOV C, #0
branch_?test_number:
 
    ASSERT
        ASSERT_REG  REG_A, noskip
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_C, noskip

END test_number
.ENDM

TEST_SKNC    .MACRO  test_number, psw_init, noskip
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
        MOV C, #noskip

    ACT
        MOV A, #0
        SKNC
        MOV A, #1
        SKNC
        SKNC
        MOV X, #1
        SKNC
        BR  !branch_?test_number
        MOV C, #0
branch_?test_number:
  
    ASSERT
        ASSERT_REG  REG_A, noskip
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_C, noskip

END test_number
.ENDM

TEST_SKZ    .MACRO  test_number, psw_init, noskip
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
        MOV C, #noskip

    ACT
        MOV A, #0
        SKZ
        MOV A, #1
        SKZ
        SKZ
        MOV X, #1
        SKZ
        BR  !branch_?test_number
        MOV C, #0
branch_?test_number:
 
    ASSERT
        ASSERT_REG  REG_A, noskip
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_C, noskip

END test_number
.ENDM

TEST_SKNZ    .MACRO  test_number, psw_init, noskip
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
        MOV C, #noskip

    ACT
        MOV A, #0
        SKNZ
        MOV A, #1
        SKNZ
        SKNZ
        MOV X, #1
        SKNZ
        BR  !branch_?test_number
        MOV C, #0
branch_?test_number:
    
    ASSERT
        ASSERT_REG  REG_A, noskip
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_C, noskip

END test_number
.ENDM

TEST_SKH    .MACRO  test_number, psw_init, noskip
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
        MOV C, #noskip

    ACT
        MOV A, #0
        SKH
        MOV A, #1
        SKH 
        SKH
        MOV X, #1
        SKH
        BR  !branch_?test_number
        MOV C, #0
branch_?test_number:

    ASSERT
        ASSERT_REG  REG_A, noskip
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_C, noskip

END test_number
.ENDM

TEST_SKNH    .MACRO  test_number, psw_init, noskip
TEST    test_number
    ARRANGE
        MOV PSW, #psw_init
        MOV C, #noskip

    ACT
        MOV A, #0
        SKNH
        MOV A, #1
        SKNH
        SKNH
        MOV X, #1
        SKNH
        BR  !branch_?test_number
        MOV C, #0
branch_?test_number:
 
    ASSERT
        ASSERT_REG  REG_A, noskip
        ASSERT_REG  REG_X, 1
        ASSERT_REG  REG_C, noskip

END test_number
.ENDM

TEST_HEADER

TEST_SKC    1, 0x00, 1
TEST_SKC    2, 0x01, 0
TEST_SKC    3, 0x40, 1
TEST_SKC    4, 0x41, 0
TEST_SKNC   5, 0x00, 0
TEST_SKNC   6, 0x01, 1
TEST_SKNC   7, 0x40, 0
TEST_SKNC   8, 0x41, 1

TEST_SKZ     9, 0x00, 1
TEST_SKZ    10, 0x01, 1
TEST_SKZ    11, 0x40, 0
TEST_SKZ    12, 0x41, 0
TEST_SKNZ   13, 0x00, 0
TEST_SKNZ   14, 0x01, 0
TEST_SKNZ   15, 0x40, 1
TEST_SKNZ   16, 0x41, 1

TEST_SKH    17, 0x00, 1
TEST_SKH    18, 0x01, 0
TEST_SKH    19, 0x40, 0
TEST_SKH    20, 0x41, 0
TEST_SKNH   21, 0x00, 0
TEST_SKNH   22, 0x01, 1
TEST_SKNH   23, 0x40, 1
TEST_SKNH   24, 0x41, 1

TEST_FOOTER