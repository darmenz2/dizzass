CC ?= cc
CLEANUP135_DIR ?= build/chain-cleanup135$(if $(filter 1,$(SANITIZE)),-san,)
CLEANUP135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -DVN135_CHAIN_CLEANUP_135
CLEANUP135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer -fno-pie -no-pie,)
CLEANUP135_SRC = src/backend/chain-cleanup.c src/backend/chain.c
.PHONY: dizzass-cleanup135-original dizzass-cleanup135-test dizzass-cleanup135-negative
$(CLEANUP135_DIR):
	mkdir -p $@
$(CLEANUP135_DIR)/libcleanup.so: $(CLEANUP135_SRC) $(wildcard integration/*135.h) integration/chain-cleanup-135.mk | $(CLEANUP135_DIR)
	$(CC) $(CLEANUP135_FLAGS) -shared -fPIC $(CLEANUP135_SRC) -Wl,-z,defs -o $@
dizzass-cleanup135-original: $(CLEANUP135_DIR)/libcleanup.so
	python3 integration/tests/check_chain_cleanup_evidence_135.py
	python3 integration/tests/test_chain_cleanup_135.py $< --summary $(CLEANUP135_DIR)/original.json
$(CLEANUP135_DIR)/native-test: $(CLEANUP135_SRC) integration/tests/test_chain_cleanup_135.c $(wildcard integration/*135.h) integration/chain-cleanup-135.mk | $(CLEANUP135_DIR)
	$(CC) $(CLEANUP135_FLAGS) $(CLEANUP135_SAN) $(CLEANUP135_SRC) integration/tests/test_chain_cleanup_135.c -o $@
dizzass-cleanup135-test: $(CLEANUP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-cleanup135-negative:
	python3 integration/tests/test_chain_cleanup_negative_135.py --cc $(CC) --out $(CLEANUP135_DIR)/negative
