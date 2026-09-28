CC ?= cc
MINING135_DIR ?= build/mining-stop135$(if $(filter 1,$(SANITIZE)),-san,)
MINING135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135 -DVN135_RESCUE_STOP_135 -DVN135_VOLTAGE_STOP_135 -DVN135_MINING_STOP_135
MINING135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
MINING135_SOURCES = src/backend/base.c src/backend/volt-ctrl.c src/frontend/rescue.c
MINING135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-mining135-evidence dizzass-mining135-original dizzass-mining135-test dizzass-mining135-negative
$(MINING135_DIR):
	mkdir -p $@
$(MINING135_DIR)/libmining.so: $(MINING135_SOURCES) $(MINING135_HEADERS) integration/mining-stop-135.mk | $(MINING135_DIR)
	$(CC) $(MINING135_FLAGS) -shared -fPIC $(MINING135_SOURCES) -Wl,-z,defs -o $@
dizzass-mining135-evidence:
	python3 integration/tests/check_mining_stop_evidence_135.py
	python3 integration/tests/check_voltage_stop_evidence_135.py
dizzass-mining135-original: $(MINING135_DIR)/libmining.so dizzass-mining135-evidence
	python3 integration/tests/test_mining_stop_135.py $< --summary $(MINING135_DIR)/original.json
	python3 integration/tests/test_mining_stop_nested_135.py $< --summary $(MINING135_DIR)/nested.json
	python3 integration/tests/test_mining_stop_provenance_135.py
$(MINING135_DIR)/native-test: $(MINING135_SOURCES) integration/tests/test_mining_stop_135.c integration/tests/test_exit_cleanup_135.c integration/tests/stop_policy_bridge_135.c $(MINING135_HEADERS) integration/mining-stop-135.mk | $(MINING135_DIR)
	$(CC) $(MINING135_FLAGS) $(MINING135_SAN) $(MINING135_SOURCES) integration/tests/test_mining_stop_135.c integration/tests/stop_policy_bridge_135.c -o $@
dizzass-mining135-test: $(MINING135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-mining135-negative:
	python3 integration/tests/test_mining_stop_negative_135.py --cc $(CC) --out $(MINING135_DIR)/negative
