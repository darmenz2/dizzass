.DEFAULT_GOAL := test
ROOT ?= $(abspath ../../../..)
BUILD_DIR ?= $(ROOT)/build/chain-drive-strength135
CC ?= cc
PYTHON ?= python3
include $(ROOT)/integration/bm1368-register-write-135.mk
DRIVE_SRC = $(addprefix $(ROOT)/,$(REG1368_SRC)) \
    $(ROOT)/libbitmain/src/chip/chip1368-chain-drive-strength.c
DRIVE_HEADERS = $(addprefix $(ROOT)/,$(REG1368_HEADERS)) \
    $(ROOT)/integration/bm1368_chain_drive_strength_135.h \
    $(ROOT)/integration/bm1368_drive_strength_135.h \
    $(wildcard $(ROOT)/include/xminer/recovery/*.h) \
    $(ROOT)/integration/bm1368-register-write-135.mk
DRIVE_FLAGS = $(REG1368_FLAGS) -I$(ROOT) -I$(ROOT)/include -DVN135_BM1368_CHAIN_DRIVE_STRENGTH_135
.PHONY: test sanitize controls evidence
$(BUILD_DIR):
	mkdir -p $@
$(BUILD_DIR)/host-test: $(DRIVE_SRC) $(DRIVE_HEADERS) tests/test_chain_drive_strength.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(DRIVE_FLAGS) $(DRIVE_SRC) tests/test_chain_drive_strength.c $(LDFLAGS) -o $@
$(BUILD_DIR)/sanitized-test: $(DRIVE_SRC) $(DRIVE_HEADERS) tests/test_chain_drive_strength.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(DRIVE_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer $(DRIVE_SRC) tests/test_chain_drive_strength.c $(LDFLAGS) -fsanitize=address,undefined -o $@
test: $(BUILD_DIR)/host-test
	timeout 45 $<
sanitize: $(BUILD_DIR)/sanitized-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
controls:
	$(PYTHON) -B tests/test_negative.py --root $(ROOT) --cc $(CC) --build $(BUILD_DIR)/controls
evidence:
	$(PYTHON) -B verify_evidence.py
	$(PYTHON) -B -m unittest discover -s tests -p test_evidence.py -v
	$(PYTHON) -O -B -m unittest discover -s tests -p test_evidence.py -v
