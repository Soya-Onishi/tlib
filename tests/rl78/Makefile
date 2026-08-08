.SECONDEXPANSION:

# Assemble RL78 harness smoke guests with CCRL into ELF32 .abs images.
# Instruction-level TCG suites are added in later PRs; this Makefile only
# covers harness-owned sources under tcg/ (currently pass_mmio.asm).

CCRL ?= ccrl
# CCRL looks up the DVF by name from its install path; override if needed.
DEVICE ?= DR7F100GLG.DVF

CCRLFLAGS = \
	-cpu=S3 \
	-asmopt=-debug \
	-lnkopt=-DEBUG \
	-lnkopt=-DEVICE=$(DEVICE) \
	-lnkopt=-AUTO_SECTION_LAYOUT \
	-lnkopt=-ROM=.data=.data_R \
	-lnkopt=-ROM=.sdata=.sdata_R \
	-lnkopt=-MEMORY=High

ASM_FILES := $(filter-out ./harness/% harness/%,$(shell find . -type f -name '*.asm'))
OUT_DIR ?= out
ABS_FILES := $(addprefix $(OUT_DIR)/,$(patsubst ./%,%,$(ASM_FILES:.asm=.abs)))

all: $(ABS_FILES)

%/:
	mkdir -p $@

$(OUT_DIR)/%.abs: %.asm | $$(@D)/
	$(CCRL) $(CCRLFLAGS) -obj_path=$(dir $@) -lnkopt=-OUTPUT=$@ $<

clean:
	rm -rf $(OUT_DIR)

.PHONY: all clean
