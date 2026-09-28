CC ?= cc
CLEANUP135_DIR ?= build/sensor-cleanup-binding135$(if $(filter 1,$(SANITIZE)),-san,)
CLEANUP135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135 -DVN135_SENSOR_CLEANUP_BINDING_135
CLEANUP135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
CLEANUP135_SOURCES = src/backend/base.c src/backend/temp.c reconstruction/support/sensor_cleanup_135.c reconstruction/support/sensor_cleanup_binding_135.c
CLEANUP135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-cleanup135-evidence dizzass-cleanup135-original dizzass-cleanup135-test dizzass-cleanup135-negative
$(CLEANUP135_DIR):
	mkdir -p $@
$(CLEANUP135_DIR)/libcleanup.so: $(CLEANUP135_SOURCES) $(CLEANUP135_HEADERS) integration/sensor-cleanup-binding-135.mk | $(CLEANUP135_DIR)
	$(CC) $(CLEANUP135_FLAGS) -shared -fPIC $(CLEANUP135_SOURCES) -Wl,-z,defs -o $@
dizzass-cleanup135-evidence:
	python3 integration/tests/check_sensor_cleanup_binding_evidence_135.py
dizzass-cleanup135-original: $(CLEANUP135_DIR)/libcleanup.so dizzass-cleanup135-evidence
	python3 integration/tests/test_sensor_cleanup_binding_135.py $< --summary $(CLEANUP135_DIR)/original.json
$(CLEANUP135_DIR)/native-test: $(CLEANUP135_SOURCES) integration/tests/test_sensor_cleanup_binding_135.c $(CLEANUP135_HEADERS) | $(CLEANUP135_DIR)
	$(CC) $(CLEANUP135_FLAGS) $(CLEANUP135_SAN) $(CLEANUP135_SOURCES) integration/tests/test_sensor_cleanup_binding_135.c -o $@
dizzass-cleanup135-test: $(CLEANUP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-cleanup135-negative:
	python3 integration/tests/test_sensor_cleanup_binding_negative_135.py --cc $(CC) --out $(CLEANUP135_DIR)/negative
