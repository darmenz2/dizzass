CC ?= cc
VOLTAGE135_DIR ?= build/voltage-stop135$(if $(filter 1,$(SANITIZE)),-san,)
VOLTAGE135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135 -DVN135_RESCUE_STOP_135 -DVN135_VOLTAGE_STOP_135
VOLTAGE135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
VOLTAGE135_SOURCES = src/backend/base.c src/backend/volt-ctrl.c src/frontend/rescue.c
VOLTAGE135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-voltage135-evidence dizzass-voltage135-original dizzass-voltage135-test dizzass-voltage135-negative
$(VOLTAGE135_DIR):
	mkdir -p $@
$(VOLTAGE135_DIR)/libvoltage.so: $(VOLTAGE135_SOURCES) $(VOLTAGE135_HEADERS) integration/voltage-stop-135.mk | $(VOLTAGE135_DIR)
	$(CC) $(VOLTAGE135_FLAGS) -shared -fPIC $(VOLTAGE135_SOURCES) -Wl,-z,defs -o $@
dizzass-voltage135-evidence:
	python3 integration/tests/check_voltage_stop_evidence_135.py
dizzass-voltage135-original: $(VOLTAGE135_DIR)/libvoltage.so dizzass-voltage135-evidence
	python3 integration/tests/test_voltage_stop_135.py $< --summary $(VOLTAGE135_DIR)/original.json
	python3 integration/tests/test_voltage_stop_nested_135.py $< --summary $(VOLTAGE135_DIR)/nested.json
$(VOLTAGE135_DIR)/native-test: $(VOLTAGE135_SOURCES) integration/tests/test_voltage_stop_135.c integration/tests/test_exit_cleanup_135.c integration/tests/stop_policy_bridge_135.c $(VOLTAGE135_HEADERS) integration/voltage-stop-135.mk | $(VOLTAGE135_DIR)
	$(CC) $(VOLTAGE135_FLAGS) $(VOLTAGE135_SAN) $(VOLTAGE135_SOURCES) integration/tests/test_voltage_stop_135.c integration/tests/stop_policy_bridge_135.c -o $@
dizzass-voltage135-test: $(VOLTAGE135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-voltage135-negative:
	python3 integration/tests/test_voltage_stop_negative_135.py --cc $(CC) --out $(VOLTAGE135_DIR)/negative
