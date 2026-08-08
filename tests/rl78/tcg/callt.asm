$INCLUDE    "../harness/prelude.asm"

CALLT_TEST  .MACRO  test_number, offset, expect_val
TEST    test_number
    ARRANGE
        MOVW    SP, #0xFEE0
    ACT
        CALLT   [offset]
    ASSERT
        ASSERT_MEM  testdata, 0, expect_val
        ASSERT_MEM  testdata, 1, 0
END test_number
.ENDM


TEST_HEADER
CALLT_TEST  1, 0x80, 1
CALLT_TEST  2, 0x9E, 2
CALLT_TEST  3, 0xBE, 3
TEST_FOOTER

.text   .CSEG   AT  0x00800
func1_before:
    MOV !LOWW(testdata+1), #1
func1:
    MOV !LOWW(testdata), #1
    RET

.text   .CSEG   AT  0x07F00
func2_before:
    MOV !LOWW(testdata+1), #2
func2:
    MOV !LOWW(testdata), #2
    RET

.text   .CSEG   AT  0x0FF00
func3_before:
    MOV !LOWW(testdata+1), #3
func3:
    MOV !LOWW(testdata), #3
    RET


.callt0 .CSEG   CALLT0
    .DB2    func1
.OFFSET 0x1E
    .DB2    func2
.OFFSET 0x3E
    .DB2    func3

.bss    .DSEG   BSS
testdata:
    .DS 256