.DEFAULT_GOAL := test
ROOT ?= $(abspath ../../../..)
BUILD_DIR ?= $(ROOT)/build/register-pair135
CC ?= cc
PYTHON ?= python3
include $(ROOT)/integration/bm1368-register-write-135.mk
PAIR_SRC = $(addprefix $(ROOT)/,$(REG1368_SRC)) \
    $(ROOT)/libbitmain/src/chip/chip1368-register-pair.c
PAIR_HEADERS = $(addprefix $(ROOT)/,$(REG1368_HEADERS)) \
    $(ROOT)/integration/bm1368_register_pair_135.h \
    $(wildcard $(ROOT)/include/xminer/recovery/*.h) \
    $(ROOT)/integration/bm1368-register-write-135.mk
PAIR_FLAGS = $(REG1368_FLAGS) -I$(ROOT) -I$(ROOT)/include -DVN135_BM1368_REGISTER_PAIR_135
.PHONY: test sanitize controls evidence
$(BUILD_DIR):
	mkdir -p $@
$(BUILD_DIR)/host-test: $(PAIR_SRC) $(PAIR_HEADERS) tests/test_register_pair.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(PAIR_FLAGS) $(PAIR_SRC) tests/test_register_pair.c $(LDFLAGS) -o $@
$(BUILD_DIR)/sanitized-test: $(PAIR_SRC) $(PAIR_HEADERS) tests/test_register_pair.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(PAIR_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer $(PAIR_SRC) tests/test_register_pair.c $(LDFLAGS) -fsanitize=address,undefined -o $@
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
