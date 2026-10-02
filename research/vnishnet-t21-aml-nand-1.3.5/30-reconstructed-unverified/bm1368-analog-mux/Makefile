.DEFAULT_GOAL := test
ROOT ?= $(abspath ../../../..)
BUILD_DIR ?= $(ROOT)/build/analog-mux135
CC ?= cc
PYTHON ?= python3
include $(ROOT)/integration/bm1368-register-write-135.mk
MUX_SRC = $(addprefix $(ROOT)/,$(REG1368_SRC)) \
    $(ROOT)/libbitmain/src/chip/chip1398.c \
    $(ROOT)/libbitmain/src/chip/chip1368-analog-mux.c
MUX_HEADERS = $(addprefix $(ROOT)/,$(REG1368_HEADERS)) \
    $(ROOT)/integration/bm1368_analog_mux_135.h \
    $(ROOT)/integration/bm1368-register-write-135.mk
MUX_FLAGS = $(REG1368_FLAGS) -I$(ROOT) -I$(ROOT)/include -DVN135_BM1368_ANALOG_MUX_135
.PHONY: test sanitize evidence controls
$(BUILD_DIR):
	mkdir -p $@
$(BUILD_DIR)/host-test: $(MUX_SRC) $(MUX_HEADERS) tests/test_analog_mux.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(MUX_FLAGS) $(MUX_SRC) tests/test_analog_mux.c $(LDFLAGS) -o $@
$(BUILD_DIR)/sanitized-test: $(MUX_SRC) $(MUX_HEADERS) tests/test_analog_mux.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(MUX_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer $(MUX_SRC) tests/test_analog_mux.c $(LDFLAGS) -fsanitize=address,undefined -o $@
test: $(BUILD_DIR)/host-test
	timeout 45 $<
sanitize: $(BUILD_DIR)/sanitized-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
evidence:
	$(PYTHON) -B verify_evidence.py
	$(PYTHON) -B -m unittest discover -s tests -p test_evidence.py -v
	$(PYTHON) -O -B -m unittest discover -s tests -p test_evidence.py -v
controls:
	$(PYTHON) -B tests/test_negative.py --root $(ROOT) --cc $(CC) --build $(BUILD_DIR)/controls
