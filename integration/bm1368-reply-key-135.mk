# Isolated host tests; not a production build or runtime registration.
CC ?= cc
KEY135_DIR ?= build/bm1368-reply-key135$(if $(filter 1,$(SANITIZE)),-san,)
KEY135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135 -DVN135_BM1368_REPLY_KEY_135
KEY135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
KEY135_SOURCE = libbitmain/src/chip/chip1368-reply-key.c src/backend/base.c
KEY135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-key135-evidence dizzass-key135-original dizzass-key135-test dizzass-key135-negative
$(KEY135_DIR):
	mkdir -p $@
$(KEY135_DIR)/libkey.so: $(KEY135_SOURCE) $(KEY135_HEADERS) integration/bm1368-reply-key-135.mk | $(KEY135_DIR)
	$(CC) $(KEY135_FLAGS) -shared -fPIC $(KEY135_SOURCE) -Wl,-z,defs -o $@
dizzass-key135-evidence:
	python3 integration/tests/check_bm1368_reply_key_evidence_135.py
dizzass-key135-original: $(KEY135_DIR)/libkey.so dizzass-key135-evidence
	python3 integration/tests/test_bm1368_reply_key_135.py $< --summary $(KEY135_DIR)/original.json
$(KEY135_DIR)/native-test: $(KEY135_SOURCE) $(KEY135_HEADERS) integration/tests/test_bm1368_reply_key_135.c integration/bm1368-reply-key-135.mk | $(KEY135_DIR)
	$(CC) $(KEY135_FLAGS) $(KEY135_SAN) $(KEY135_SOURCE) integration/tests/test_bm1368_reply_key_135.c -o $@
dizzass-key135-test: $(KEY135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 30 $<
dizzass-key135-negative:
	python3 integration/tests/test_bm1368_reply_key_negative_135.py --cc $(CC) --out $(KEY135_DIR)/negative
