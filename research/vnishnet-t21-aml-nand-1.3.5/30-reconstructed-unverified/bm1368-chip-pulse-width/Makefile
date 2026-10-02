.DEFAULT_GOAL := test
ROOT ?= $(abspath ../../../..)
BUILD_DIR ?= $(ROOT)/build/chip-pulse135
CC ?= cc
PYTHON ?= python3
include $(ROOT)/integration/bm1368-register-write-135.mk
CHIP_PULSE_SRC = $(addprefix $(ROOT)/,$(REG1368_SRC)) \
    $(ROOT)/libbitmain/src/chip/chip1368-pulse-width.c \
    $(ROOT)/libbitmain/src/chip/chip1368-chip-pulse-width.c
CHIP_PULSE_TEST = $(abspath tests/test_chip_pulse_width.c)
CHIP_PULSE_HEADERS = $(ROOT)/integration/bm1368_chip_pulse_width_135.h \
    $(ROOT)/integration/bm1368_pulse_width_135.h $(addprefix $(ROOT)/,$(REG1368_HEADERS)) \
    $(wildcard $(ROOT)/include/xminer/recovery/*.h)
CHIP_PULSE_FLAGS = $(REG1368_FLAGS) -I$(ROOT) -I$(ROOT)/include \
    -DVN135_BM1368_PULSE_WIDTH_135 -DVN135_BM1368_CHIP_PULSE_WIDTH_135
.PHONY: test sanitize controls
$(BUILD_DIR):
	mkdir -p $@
$(BUILD_DIR)/host-test: $(CHIP_PULSE_SRC) $(CHIP_PULSE_TEST) $(CHIP_PULSE_HEADERS) Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CHIP_PULSE_FLAGS) $(CHIP_PULSE_SRC) $(CHIP_PULSE_TEST) $(LDFLAGS) -o $@
$(BUILD_DIR)/sanitized-test: $(CHIP_PULSE_SRC) $(CHIP_PULSE_TEST) $(CHIP_PULSE_HEADERS) Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CHIP_PULSE_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer \
	    $(CHIP_PULSE_SRC) $(CHIP_PULSE_TEST) $(LDFLAGS) -fsanitize=address,undefined -o $@
test: $(BUILD_DIR)/host-test
	timeout 45 $<
sanitize: $(BUILD_DIR)/sanitized-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
controls:
	$(PYTHON) -B tests/test_negative.py --root $(ROOT) --cc $(CC) --build $(BUILD_DIR)/controls
