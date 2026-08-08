$INCLUDE    "../harness/prelude.asm"

.bss    .DSEG   BSS
invalid_data:
    .DS 1
invalid_data2:
    .DS 1
valid_data:
    .DS 1
valid_data2:
    .DS 1
branch_data1:
    .DS 1
branch_data2:
    .DS 1
testdata:
    .DS 1
    
TEST_BC .MACRO  test_number, init_psw, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_psw
    ACT
        BC  $test?test_number?_dest
        MOV !LOWW(branch_data1), #1
test?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1 
END test_number
.ENDM

TEST_BNC .MACRO  test_number, init_psw, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_psw
    ACT
        BNC  $test?test_number?_dest
        MOV !LOWW(branch_data1), #1
test?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1 
END test_number
.ENDM

TEST_BZ .MACRO  test_number, init_psw, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_psw
    ACT
        BZ  $test?test_number?_dest
        MOV !LOWW(branch_data1), #1
test?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1 
END test_number
.ENDM

TEST_BNZ .MACRO  test_number, init_psw, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_psw
    ACT
        BNZ  $test?test_number?_dest
        MOV !LOWW(branch_data1), #1
test?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1 
END test_number
.ENDM

TEST_BH .MACRO  test_number, init_psw, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_psw
    ACT
        BH  $test?test_number?_dest
        MOV !LOWW(branch_data1), #1
test?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1 
END test_number
.ENDM

TEST_BNH .MACRO  test_number, init_psw, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_psw
    ACT
        BNH  $test?test_number?_dest
        MOV !LOWW(branch_data1), #1
test?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1 
END test_number
.ENDM

TEST_BT_saddr   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV 0xFFE20, #init_value
    ACT
        BT  0xFFE20.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BT_sfr   .MACRO  test_number, init_value, bit, nobranch
IGNORE_TEST    test_number
    ARRANGE
        RESET_DATA
        MOV 0xFFE20, #init_value
    ACT
        BT  0xFFE20.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BT_A   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV A, #init_value
    ACT
        BT  A.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BT_PSW   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_value
    ACT
        BT  PSW.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BT_indHL   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     !LOWW(testdata), #init_value
        MOVW    HL, #LOWW(testdata)
    ACT
        BT  [HL].bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BF_saddr   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV 0xFFE20, #init_value
    ACT
        BF  0xFFE20.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BF_sfr   .MACRO  test_number, init_value, bit, nobranch
IGNORE_TEST    test_number
    ARRANGE
        RESET_DATA
        MOV 0xFFE20, #init_value
    ACT
        BF  0xFFE20.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BF_A   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV A, #init_value
    ACT
        BF  A.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BF_PSW   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_value
    ACT
        BF  PSW.bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

TEST_BF_indHL   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     !LOWW(testdata), #init_value
        MOVW    HL, #LOWW(testdata)
    ACT
        BF  [HL].bit, $test_?test_number?_dest
        MOV !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM  branch_data1, 0, nobranch
        ASSERT_MEM  branch_data2, 0, 1
END test_number
.ENDM

ASSERT_MEMBIT   .MACRO  address, offset, bit, expect
    _ASSERTNO    .SET    (_ASSERTNO + 1)
    MOVW    AX, #LOWW(address)
    ADDW    AX, #offset
    MOVW    HL, AX
    MOV1    CY, [HL].bit
    MOV     A, #expect
    XOR1    CY, A.0
    MOV     A, #0
    MOV1    A.0, CY
    MOV     X, #expect
    MOV     H, #_TESTNO
    MOV     L, #_ASSERTNO
    SKNC
    BR      !test_fail
.ENDM

TEST_BTCLR_saddr   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     0xFFE20, #init_value
    ACT
        BTCLR   0xFFE20.bit, $test_?test_number?_dest
        MOV     !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV     !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM      branch_data1, 0, nobranch
        ASSERT_MEM      branch_data2, 0, 1
        ASSERT_MEMBIT   0xFFE20, 0, bit, 0
END test_number
.ENDM

TEST_BTCLR_sfr   .MACRO  test_number, init_value, bit, nobranch
IGNORE_TEST    test_number
    ARRANGE
        RESET_DATA
        MOV 0xFFF20, #init_value
    ACT
        BTCLR   0xFFF20.bit, $test_?test_number?_dest
        MOV     !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM      branch_data1, 0, nobranch
        ASSERT_MEM      branch_data2, 0, 1
        ASSERT_MEMBIT   0xFFF20, 0, bit, 0
END test_number
.ENDM

TEST_BTCLR_A   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     A, #init_value
    ACT
        BTCLR   A.bit, $test_?test_number?_dest
        MOV     !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV     !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM      branch_data1, 0, nobranch
        ASSERT_MEM      branch_data2, 0, 1
        ASSERT_MEMBIT   status_storage, REG_A, bit, 0
END test_number
.ENDM

TEST_BTCLR_PSW   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     PSW, #init_value
    ACT
        BTCLR   PSW.bit, $test_?test_number?_dest
        MOV     !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV     !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM      branch_data1, 0, nobranch
        ASSERT_MEM      branch_data2, 0, 1
        ASSERT_MEMBIT   status_storage, REG_PSW, bit, 0
END test_number
.ENDM

TEST_BTCLR_indHL   .MACRO  test_number, init_value, bit, nobranch
TEST    test_number
    ARRANGE
        RESET_DATA
        MOV     !LOWW(testdata), #init_value
        MOVW    HL, #LOWW(testdata)
    ACT
        BTCLR   [HL].bit, $test_?test_number?_dest
        MOV     !LOWW(branch_data1), #1
test_?test_number?_dest:
        MOV     !LOWW(branch_data2), #1
    ASSERT
        ASSERT_MEM      branch_data1, 0, nobranch
        ASSERT_MEM      branch_data2, 0, 1
        ASSERT_MEMBIT   testdata, 0, bit, 0
END test_number
.ENDM

RESET_DATA  .MACRO
    MOV !LOWW(invalid_data), #0
    MOV !LOWW(invalid_data2), #0
    MOV !LOWW(valid_data), #0
    MOV !LOWW(valid_data2), #0
    MOV !LOWW(branch_data1), #0
    MOV !LOWW(branch_data2), #0
.ENDM

TEST_HEADER

TEST    1
    ARRANGE
        MOVW    AX, #LOWW(test1_dest)
        MOV     CS, #HIGHW(test1_dest)
        RESET_DATA
    ACT
        BR  AX
        MOV !LOWW(invalid_data), #1
test1_dest:
        MOV !LOWW(valid_data), #1
    ASSERT
        ASSERT_MEM  invalid_data, 0, 0
        ASSERT_MEM  valid_data, 0, 1 
END 1

TEST    2
    ARRANGE
        RESET_DATA
    ACT
        BR  $test2_dest
        MOV !LOWW(invalid_data), #1
test2_dest:
        MOV !LOWW(valid_data), #1
    ASSERT
        ASSERT_MEM  invalid_data, 0, 0
        ASSERT_MEM  valid_data, 0, 1 
END 2

TEST    3
    ARRANGE
        RESET_DATA
    ACT
        BR  $!test3_dest
        MOV !LOWW(invalid_data), #1
test3_dest:
        MOV !LOWW(valid_data), #1
    ASSERT
        ASSERT_MEM  invalid_data, 0, 0
        ASSERT_MEM  valid_data, 0, 1 
END 3

TEST    4
    ARRANGE
        RESET_DATA
    ACT
        BR  !test4_dest
        MOV !LOWW(invalid_data), #1
test4_dest:
        MOV !LOWW(valid_data), #1
    ASSERT
        ASSERT_MEM  invalid_data, 0, 0
        ASSERT_MEM  valid_data, 0, 1 
END 4

TEST    5
    ARRANGE
        RESET_DATA
    ACT
        BR  !!test5_dest1
        MOV !LOWW(invalid_data), #1
test5_dest2:
        MOV !LOWW(valid_data), #1
    ASSERT
        ASSERT_MEM  invalid_data, 0, 0
        ASSERT_MEM  invalid_data2, 0, 0
        ASSERT_MEM  valid_data, 0, 1 
        ASSERT_MEM  valid_data2, 0, 1
END 5

TEST_BC     6, 0x01, 0
TEST_BC     7, 0x00, 1

TEST_BNC    8, 0x01, 1
TEST_BNC    9, 0x00, 0

TEST_BZ    10, 0x40, 0
TEST_BZ    11, 0x00, 1

TEST_BNZ   12, 0x40, 1
TEST_BNZ   13, 0x00, 0

TEST_BH    14, 0x01, 0
TEST_BH    15, 0x40, 0
TEST_BH    16, 0x41, 0
TEST_BH    17, 0x00, 1

TEST_BNH   18, 0x01, 1
TEST_BNH   19, 0x40, 1
TEST_BNH   20, 0x41, 1
TEST_BNH   21, 0x00, 0

TEST_BT_saddr   22, 0x01, 0, 0
TEST_BT_saddr   23, 0xFE, 0, 1
TEST_BT_saddr   24, 0x80, 7, 0
TEST_BT_saddr   25, 0x7F, 7, 1

TEST_BT_sfr     26, 0x01, 0, 0
TEST_BT_sfr     27, 0xFE, 0, 1
TEST_BT_sfr     28, 0x80, 7, 0
TEST_BT_sfr     29, 0x7F, 7, 1

TEST_BT_A       30, 0x01, 0, 0
TEST_BT_A       31, 0xFE, 0, 1
TEST_BT_A       32, 0x80, 7, 0
TEST_BT_A       33, 0x7F, 7, 1

TEST_BT_PSW     34, 0x01, 0, 0
TEST_BT_PSW     35, 0xFE, 0, 1
TEST_BT_PSW     36, 0x80, 7, 0
TEST_BT_PSW     37, 0x7F, 7, 1

TEST_BT_indHL   38, 0x01, 0, 0
TEST_BT_indHL   39, 0xFE, 0, 1
TEST_BT_indHL   40, 0x80, 7, 0
TEST_BT_indHL   41, 0x7F, 7, 1

TEST_BF_saddr   42, 0x01, 0, 1 
TEST_BF_saddr   43, 0xFE, 0, 0
TEST_BF_saddr   44, 0x80, 7, 1
TEST_BF_saddr   45, 0x7F, 7, 0

TEST_BF_sfr     46, 0x01, 0, 1 
TEST_BF_sfr     47, 0xFE, 0, 0 
TEST_BF_sfr     48, 0x80, 7, 1 
TEST_BF_sfr     49, 0x7F, 7, 0 

TEST_BF_A       50, 0x01, 0, 1 
TEST_BF_A       51, 0xFE, 0, 0 
TEST_BF_A       52, 0x80, 7, 1 
TEST_BF_A       53, 0x7F, 7, 0 

TEST_BF_PSW     54, 0x01, 0, 1 
TEST_BF_PSW     55, 0xFE, 0, 0 
TEST_BF_PSW     56, 0x80, 7, 1 
TEST_BF_PSW     57, 0x7F, 7, 0 

TEST_BF_indHL   58, 0x01, 0, 1 
TEST_BF_indHL   59, 0xFE, 0, 0 
TEST_BF_indHL   60, 0x80, 7, 1 
TEST_BF_indHL   61, 0x7F, 7, 0 

TEST_BTCLR_saddr   62, 0x01, 0, 0
TEST_BTCLR_saddr   63, 0xFE, 0, 1
TEST_BTCLR_saddr   64, 0x80, 7, 0
TEST_BTCLR_saddr   65, 0x7F, 7, 1

TEST_BTCLR_sfr     66, 0x01, 0, 0
TEST_BTCLR_sfr     67, 0xFE, 0, 1
TEST_BTCLR_sfr     68, 0x80, 7, 0
TEST_BTCLR_sfr     69, 0x7F, 7, 1

TEST_BTCLR_A       70, 0x01, 0, 0
TEST_BTCLR_A       71, 0xFE, 0, 1
TEST_BTCLR_A       72, 0x80, 7, 0
TEST_BTCLR_A       73, 0x7F, 7, 1

TEST_BTCLR_PSW     74, 0x01, 0, 0
TEST_BTCLR_PSW     75, 0xFE, 0, 1
TEST_BTCLR_PSW     76, 0x80, 7, 0
TEST_BTCLR_PSW     77, 0x7F, 7, 1

TEST_BTCLR_indHL   78, 0x01, 0, 0
TEST_BTCLR_indHL   79, 0xFE, 0, 1
TEST_BTCLR_indHL   80, 0x80, 7, 0
TEST_BTCLR_indHL   81, 0x7F, 7, 1

TEST_FOOTER

.text   .CSEG   AT  0x10000
    MOV !LOWW(invalid_data2), #1
test5_dest1:
    MOV !LOWW(valid_data2), #1
    BR  !!test5_dest2