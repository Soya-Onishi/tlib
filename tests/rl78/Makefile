.SECONDEXPANSION:

# Assemble RL78 TCG tests with CCRL into ELF32 .abs images.
# Place the Renesas device file next to this Makefile (see DEVICE).

CCRL ?= ccrl
DEVICE ?= $(CURDIR)/device/DR7F100GLG.DVF

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
	@if [ ! -f "$(DEVICE)" ]; then \
		echo "Missing device file: $(DEVICE)" >&2; \
		echo "Provide the CCRL DVF (issue #9) or set DEVICE=..." >&2; \
		exit 1; \
	fi
	$(CCRL) $(CCRLFLAGS) -obj_path=$(dir $@) -lnkopt=-OUTPUT=$@ $<

clean:
	rm -rf $(OUT_DIR)

.PHONY: all clean
