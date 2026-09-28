CC ?= cc
RESCUE135_DIR ?= build/rescue-stop135$(if $(filter 1,$(SANITIZE)),-san,)
RESCUE135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135 -DVN135_RESCUE_STOP_135
RESCUE135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
RESCUE135_SOURCES = src/backend/base.c src/frontend/rescue.c
RESCUE135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-rescue135-evidence dizzass-rescue135-original dizzass-rescue135-test dizzass-rescue135-negative
$(RESCUE135_DIR):
	mkdir -p $@
$(RESCUE135_DIR)/librescue.so: $(RESCUE135_SOURCES) $(RESCUE135_HEADERS) integration/rescue-stop-135.mk | $(RESCUE135_DIR)
	$(CC) $(RESCUE135_FLAGS) -shared -fPIC $(RESCUE135_SOURCES) -Wl,-z,defs -o $@
dizzass-rescue135-evidence:
	python3 integration/tests/check_rescue_stop_evidence_135.py
dizzass-rescue135-original: $(RESCUE135_DIR)/librescue.so dizzass-rescue135-evidence
	python3 integration/tests/test_rescue_stop_135.py $< --summary $(RESCUE135_DIR)/original.json
	python3 integration/tests/test_rescue_stop_nested_135.py $< --summary $(RESCUE135_DIR)/nested.json
$(RESCUE135_DIR)/native-test: $(RESCUE135_SOURCES) integration/tests/test_rescue_stop_135.c integration/tests/test_exit_cleanup_135.c integration/tests/stop_policy_bridge_135.c $(RESCUE135_HEADERS) integration/rescue-stop-135.mk | $(RESCUE135_DIR)
	$(CC) $(RESCUE135_FLAGS) $(RESCUE135_SAN) $(RESCUE135_SOURCES) integration/tests/test_rescue_stop_135.c integration/tests/stop_policy_bridge_135.c -o $@
dizzass-rescue135-test: $(RESCUE135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-rescue135-negative:
	python3 integration/tests/test_rescue_stop_negative_135.py --cc $(CC) --out $(RESCUE135_DIR)/negative
