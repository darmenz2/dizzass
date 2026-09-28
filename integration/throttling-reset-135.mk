CC ?= cc
THROTTLE135_DIR ?= build/throttling-reset135$(if $(filter 1,$(SANITIZE)),-san,)
THROTTLE135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -DVN135_THROTTLING_RESET_135 -DVN135_MINING_STOP_135
THROTTLE135_SOURCES = src/backend/throttling-reset.c src/backend/base.c
THROTTLE135_HEADERS = $(wildcard integration/*135.h)
THROTTLE135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
.PHONY: dizzass-throttle135-original dizzass-throttle135-test dizzass-throttle135-evidence dizzass-throttle135-negative
$(THROTTLE135_DIR):
	mkdir -p $@
$(THROTTLE135_DIR)/libthrottle.so: $(THROTTLE135_SOURCES) $(THROTTLE135_HEADERS) integration/throttling-reset-135.mk | $(THROTTLE135_DIR)
	$(CC) $(THROTTLE135_FLAGS) -shared -fPIC $(THROTTLE135_SOURCES) -Wl,-z,defs -o $@
dizzass-throttle135-evidence:
	python3 integration/tests/check_throttling_reset_evidence_135.py
dizzass-throttle135-original: $(THROTTLE135_DIR)/libthrottle.so dizzass-throttle135-evidence
	python3 integration/tests/test_throttling_reset_135.py $< --summary $(THROTTLE135_DIR)/original.json
$(THROTTLE135_DIR)/native-test: $(THROTTLE135_SOURCES) $(THROTTLE135_HEADERS) integration/tests/test_throttling_reset_135.c integration/throttling-reset-135.mk | $(THROTTLE135_DIR)
	$(CC) $(THROTTLE135_FLAGS) $(THROTTLE135_SAN) $(THROTTLE135_SOURCES) integration/tests/test_throttling_reset_135.c -o $@
dizzass-throttle135-test: $(THROTTLE135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-throttle135-negative:
	python3 integration/tests/test_throttling_reset_negative_135.py --cc $(CC) --out $(THROTTLE135_DIR)/negative
