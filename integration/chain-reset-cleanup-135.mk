CC ?= cc
RESETCLEAN135_DIR ?= build/chain-reset-cleanup135$(if $(filter 1,$(SANITIZE)),-san,)
RESETCLEAN135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -DVN135_CHAIN_RESET_CLEANUP_135
RESETCLEAN135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer -fno-pie -no-pie,)
RESETCLEAN135_SRC = src/backend/chain-reset-cleanup.c src/backend/chain.c
.PHONY: dizzass-resetclean135-original dizzass-resetclean135-test dizzass-resetclean135-negative
$(RESETCLEAN135_DIR):
	mkdir -p $@
$(RESETCLEAN135_DIR)/libcleanup.so: $(RESETCLEAN135_SRC) $(wildcard integration/*135.h) integration/chain-reset-cleanup-135.mk | $(RESETCLEAN135_DIR)
	$(CC) $(RESETCLEAN135_FLAGS) -shared -fPIC $(RESETCLEAN135_SRC) -Wl,-z,defs -o $@
$(RESETCLEAN135_DIR)/routes/libroutes.so:
	$(MAKE) -f integration/thermal-routes-135.mk CC=$(CC) ROUTES135_DIR=$(RESETCLEAN135_DIR)/routes $(RESETCLEAN135_DIR)/routes/libroutes.so

dizzass-resetclean135-original: $(RESETCLEAN135_DIR)/libcleanup.so $(RESETCLEAN135_DIR)/routes/libroutes.so
	python3 integration/tests/check_chain_reset_cleanup_evidence_135.py
	python3 integration/tests/test_chain_reset_cleanup_135.py $< --routes-library $(RESETCLEAN135_DIR)/routes/libroutes.so --summary $(RESETCLEAN135_DIR)/original.json
$(RESETCLEAN135_DIR)/native-test: $(RESETCLEAN135_SRC) integration/tests/test_chain_reset_cleanup_135.c $(wildcard integration/*135.h) integration/chain-reset-cleanup-135.mk | $(RESETCLEAN135_DIR)
	$(CC) $(RESETCLEAN135_FLAGS) $(RESETCLEAN135_SAN) $(RESETCLEAN135_SRC) integration/tests/test_chain_reset_cleanup_135.c -o $@
dizzass-resetclean135-test: $(RESETCLEAN135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-resetclean135-negative:
	python3 integration/tests/test_chain_reset_cleanup_negative_135.py --cc $(CC) --out $(RESETCLEAN135_DIR)/negative
