# Explicit offline selection. No physical IO, production linkage, or miner main.
CC ?= cc
TRANSPORT135_DIR ?= build/transport-monitor135$(if $(SANITIZE),-san,)
TRANSPORT135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
TRANSPORT135_DEFINES = -DVN135_SENSOR_MONITOR_135 -DVN135_THERMAL_READER_135 -DVN135_BACKEND_SHUTDOWN_135
TRANSPORT135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
TRANSPORT135_HEADERS = $(wildcard integration/*135.h)
TRANSPORT135_BUS = libbitmain/src/i2c.c libbitmain/src/aml/i2c.c
TRANSPORT135_COMPOSED = src/backend/temp.c $(TRANSPORT135_BUS) reconstruction/support/sensor_cleanup_135.c
TRANSPORT135_PIPELINE = src/backend/base.c $(TRANSPORT135_COMPOSED) reconstruction/support/thermal_routes_135.c
$(TRANSPORT135_DIR):
	mkdir -p $@
$(TRANSPORT135_DIR)/libsmbus.so: $(TRANSPORT135_BUS) $(TRANSPORT135_HEADERS) | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) -shared -fPIC $(TRANSPORT135_BUS) -Wl,-z,defs -o $@
$(TRANSPORT135_DIR)/libmonitor.so: src/backend/base.c $(TRANSPORT135_HEADERS) | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) -DVN135_SENSOR_MONITOR_135 -shared -fPIC $< -Wl,-z,defs -o $@
$(TRANSPORT135_DIR)/libcomposed.so: $(TRANSPORT135_COMPOSED) $(TRANSPORT135_HEADERS) | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) -DVN135_THERMAL_READER_135 -shared -fPIC $(TRANSPORT135_COMPOSED) -Wl,-z,defs -o $@
$(TRANSPORT135_DIR)/smbus-test: $(TRANSPORT135_BUS) integration/tests/test_aml_smbus_135.c $(TRANSPORT135_HEADERS) | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) $(TRANSPORT135_SAN) $(TRANSPORT135_BUS) integration/tests/test_aml_smbus_135.c -o $@
$(TRANSPORT135_DIR)/pipeline-test: $(TRANSPORT135_PIPELINE) integration/tests/test_sensor_pipeline_135.c $(TRANSPORT135_HEADERS) | $(TRANSPORT135_DIR)
	$(CC) $(TRANSPORT135_FLAGS) $(TRANSPORT135_DEFINES) $(TRANSPORT135_SAN) $(TRANSPORT135_PIPELINE) integration/tests/test_sensor_pipeline_135.c -o $@
.PHONY: dizzass-transport135-original dizzass-transport135-test dizzass-transport135-evidence
dizzass-transport135-evidence:
	python3 integration/tests/check_transport_monitor_evidence_135.py
dizzass-transport135-original: dizzass-transport135-evidence $(TRANSPORT135_DIR)/libsmbus.so $(TRANSPORT135_DIR)/libmonitor.so $(TRANSPORT135_DIR)/libcomposed.so
	python3 integration/tests/test_aml_smbus_135.py $(TRANSPORT135_DIR)/libsmbus.so --summary $(TRANSPORT135_DIR)/smbus-original.json
	python3 integration/tests/test_sensor_monitor_135.py $(TRANSPORT135_DIR)/libmonitor.so --summary $(TRANSPORT135_DIR)/monitor-original.json
	python3 integration/tests/test_sensor_bus_composed_135.py $(TRANSPORT135_DIR)/libcomposed.so --summary $(TRANSPORT135_DIR)/composed-original.json
dizzass-transport135-test: $(TRANSPORT135_DIR)/smbus-test $(TRANSPORT135_DIR)/pipeline-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $(TRANSPORT135_DIR)/smbus-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $(TRANSPORT135_DIR)/pipeline-test
