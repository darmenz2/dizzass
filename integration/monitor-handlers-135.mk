CC ?= cc
HANDLERS135_DIR ?= build/monitor-handlers135$(if $(filter 1,$(SANITIZE)),-san,)
HANDLERS135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135
HANDLERS135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
HANDLERS135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-handlers135-evidence dizzass-handlers135-original dizzass-handlers135-test
$(HANDLERS135_DIR):
	mkdir -p $@
$(HANDLERS135_DIR)/libhandlers.so: src/backend/base.c $(HANDLERS135_HEADERS) integration/monitor-handlers-135.mk | $(HANDLERS135_DIR)
	$(CC) $(HANDLERS135_FLAGS) -shared -fPIC $< -Wl,-z,defs -o $@
dizzass-handlers135-evidence:
	python3 integration/tests/check_monitor_handlers_evidence_135.py
dizzass-handlers135-original: $(HANDLERS135_DIR)/libhandlers.so dizzass-handlers135-evidence
	python3 integration/tests/test_monitor_handlers_135.py $< --summary $(HANDLERS135_DIR)/original.json
$(HANDLERS135_DIR)/native-test: src/backend/base.c integration/tests/test_monitor_handlers_135.c $(HANDLERS135_HEADERS) integration/monitor-handlers-135.mk | $(HANDLERS135_DIR)
	$(CC) $(HANDLERS135_FLAGS) $(HANDLERS135_SAN) src/backend/base.c integration/tests/test_monitor_handlers_135.c -lm -o $@
dizzass-handlers135-test: $(HANDLERS135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
