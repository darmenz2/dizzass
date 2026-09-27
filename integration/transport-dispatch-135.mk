CC ?= cc
TRANSPORT135_DIR ?= build/transport-dispatch135$(if $(filter 1,$(SANITIZE)),-san,)
TRANSPORT135_FLAGS = -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_TRANSPORT_DISPATCH_135 -DVN135_BM1368_REGISTER_WRITE_135 -DVN135_BM1368_FREQUENCY_135
TRANSPORT135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
TRANSPORT135_SRC = libbitmain/src/transport-dispatch.c libbitmain/src/aml/chip.c libbitmain/src/uart.c libbitmain/src/chip/chip1368-register-write.c libbitmain/src/chip/chip1368-frequency.c libbitmain/src/pll.c libbitmain/src/reg_cache.c integration/bm1368_control.c reconstruction/support/crc5.c
TRANSPORT135_HEADERS = $(wildcard integration/*135.h) $(wildcard include/xminer/recovery/*.h) integration/bm1368_control.h reconstruction/data/reg_cache_defaults.inc
.PHONY: dizzass-dispatch135-original dizzass-dispatch135-test dizzass-dispatch135-evidence dizzass-dispatch135-negative
$(TRANSPORT135_DIR):
	mkdir -p $@
$(TRANSPORT135_DIR)/libtransport.so: $(TRANSPORT135_SRC) $(TRANSPORT135_HEADERS) integration/transport-dispatch-135.mk | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) -shared -fPIC $(TRANSPORT135_SRC) -Wl,-z,defs -o $@
dizzass-dispatch135-original: $(TRANSPORT135_DIR)/libtransport.so dizzass-dispatch135-evidence
	python3 integration/tests/test_transport_dispatch_135.py $< --summary $(TRANSPORT135_DIR)/original.json
$(TRANSPORT135_DIR)/native-test: $(TRANSPORT135_SRC) $(TRANSPORT135_HEADERS) integration/tests/test_transport_dispatch_135.c integration/transport-dispatch-135.mk | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) $(TRANSPORT135_SAN) $(TRANSPORT135_SRC) integration/tests/test_transport_dispatch_135.c -o $@
dizzass-dispatch135-test: $(TRANSPORT135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-dispatch135-evidence:
	python3 integration/tests/check_transport_dispatch_evidence_135.py
dizzass-dispatch135-negative:
	python3 integration/tests/test_transport_dispatch_negative_135.py --cc $(CC) --out $(TRANSPORT135_DIR)/negative
