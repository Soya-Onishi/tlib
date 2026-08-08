$INCLUDE    "../harness/prelude.asm"

; Minimal smoke guest: no instruction body beyond TEST_FOOTER PASS via MMIO.
; Useful once NOP/MOV land; until then harness load/map can still be exercised
; with a prebuilt .abs supplied via --abs-dir.
TEST_HEADER
TEST_FOOTER
