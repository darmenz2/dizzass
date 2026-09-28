# Independent host-only target; never links a production device driver.
CC ?= cc
CHAINSET135_DIR ?= build/chain-temperature-setup-135$(if $(filter 1,$(SANITIZE)),-san,)
CHAINSET135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_CHAIN_TEMPERATURE_SETUP_135
CHAINSET135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
CHAINSET135_SRC = src/backend/chain-temperature-setup.c src/backend/temp.c
CHAINSET135_HDR = $(wildcard integration/*135.h)
.PHONY: dizzass-chainset135-original dizzass-chainset135-test dizzass-chainset135-negative dizzass-chainset135-evidence
$(CHAINSET135_DIR):
	mkdir -p $@
$(CHAINSET135_DIR)/libchainset.so: $(CHAINSET135_SRC) $(CHAINSET135_HDR) integration/chain-temperature-setup-135.mk | $(CHAINSET135_DIR)
	$(CC) $(CHAINSET135_FLAGS) -shared -fPIC $(CHAINSET135_SRC) -Wl,-z,defs -o $@
$(CHAINSET135_DIR)/native-test: $(CHAINSET135_SRC) $(CHAINSET135_HDR) integration/tests/test_chain_temperature_setup_135.c integration/chain-temperature-setup-135.mk | $(CHAINSET135_DIR)
	$(CC) $(CHAINSET135_FLAGS) $(CHAINSET135_SAN) $(CHAINSET135_SRC) integration/tests/test_chain_temperature_setup_135.c -o $@
dizzass-chainset135-original: $(CHAINSET135_DIR)/libchainset.so dizzass-chainset135-evidence
	python3 integration/tests/test_chain_temperature_setup_135.py $< --summary $(CHAINSET135_DIR)/original.json
dizzass-chainset135-test: $(CHAINSET135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-chainset135-negative:
	python3 integration/tests/test_chain_temperature_setup_negative_135.py --cc $(CC) --out $(CHAINSET135_DIR)/negative
dizzass-chainset135-evidence:
	python3 integration/tests/check_chain_temperature_setup_evidence_135.py
