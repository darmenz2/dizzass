CC ?= cc
PLL1368_DIR ?= build/bm1368-frequency135$(if $(filter 1,$(SANITIZE)),-san,)
PLL1368_FLAGS = -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_BM1368_FREQUENCY_135 -DVN135_CHAIN_FREQUENCY_135 -DVN135_FREQUENCY_WORKER_135 -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_FREQUENCY_FALL_135
PLL1368_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
PLL1368_SRC = libbitmain/src/chip/chip1368-frequency.c libbitmain/src/pll.c integration/bm1368_control.c reconstruction/support/crc5.c src/backend/chain-frequency.c src/backend/frequency-worker.c src/backend/base.c
PLL1368_HEADERS = $(wildcard integration/*135.h) include/xminer/recovery/pll.h integration/bm1368_control.h
.PHONY: dizzass-pll1368-original dizzass-pll1368-test dizzass-pll1368-negative dizzass-pll1368-evidence
$(PLL1368_DIR):
	mkdir -p $@
$(PLL1368_DIR)/libpll1368.so: $(PLL1368_SRC) $(PLL1368_HEADERS) integration/bm1368-frequency-135.mk | $(PLL1368_DIR)
	$(CC) $(PLL1368_FLAGS) -shared -fPIC $(PLL1368_SRC) -Wl,-z,defs -o $@
dizzass-pll1368-original: $(PLL1368_DIR)/libpll1368.so dizzass-pll1368-evidence
	python3 integration/tests/test_bm1368_frequency_135.py $< --summary $(PLL1368_DIR)/original.json
$(PLL1368_DIR)/native-test: $(PLL1368_SRC) $(PLL1368_HEADERS) integration/tests/test_bm1368_frequency_135.c integration/bm1368-frequency-135.mk | $(PLL1368_DIR)
	$(CC) $(PLL1368_FLAGS) $(PLL1368_SAN) $(PLL1368_SRC) integration/tests/test_bm1368_frequency_135.c -o $@
dizzass-pll1368-test: $(PLL1368_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-pll1368-negative:
	python3 integration/tests/test_bm1368_frequency_negative_135.py --cc $(CC) --out $(PLL1368_DIR)/negative
dizzass-pll1368-evidence:
	python3 integration/tests/check_bm1368_frequency_evidence_135.py
