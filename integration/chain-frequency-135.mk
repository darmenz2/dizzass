CC ?= cc
CHAINFREQ135_DIR ?= build/chain-frequency135$(if $(filter 1,$(SANITIZE)),-san,)
CHAINFREQ135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_CHAIN_FREQUENCY_135 -DVN135_FREQUENCY_WORKER_135 -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_FREQUENCY_FALL_135
CHAINFREQ135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
CHAINFREQ135_SRC = src/backend/chain-frequency.c src/backend/frequency-worker.c src/backend/base.c
.PHONY: dizzass-chainfreq135-original dizzass-chainfreq135-test dizzass-chainfreq135-negative dizzass-chainfreq135-evidence
$(CHAINFREQ135_DIR):
	mkdir -p $@
$(CHAINFREQ135_DIR)/libchainfreq.so: $(CHAINFREQ135_SRC) $(wildcard integration/*135.h) integration/chain-frequency-135.mk | $(CHAINFREQ135_DIR)
	$(CC) $(CHAINFREQ135_FLAGS) -shared -fPIC $(CHAINFREQ135_SRC) -Wl,-z,defs -o $@
dizzass-chainfreq135-evidence:
	python3 integration/tests/check_chain_frequency_evidence_135.py
dizzass-chainfreq135-original: $(CHAINFREQ135_DIR)/libchainfreq.so dizzass-chainfreq135-evidence
	python3 integration/tests/test_chain_frequency_135.py $< --summary $(CHAINFREQ135_DIR)/original.json
$(CHAINFREQ135_DIR)/native-test: $(CHAINFREQ135_SRC) integration/tests/test_chain_frequency_135.c $(wildcard integration/*135.h) integration/chain-frequency-135.mk | $(CHAINFREQ135_DIR)
	$(CC) $(CHAINFREQ135_FLAGS) $(CHAINFREQ135_SAN) $(CHAINFREQ135_SRC) integration/tests/test_chain_frequency_135.c -o $@
dizzass-chainfreq135-test: $(CHAINFREQ135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-chainfreq135-negative:
	python3 integration/tests/test_chain_frequency_negative_135.py --cc $(CC) --out $(CHAINFREQ135_DIR)/negative
