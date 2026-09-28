# Offline original reconstruction only. Never links a production driver.
CC ?= cc
THERMAL135_DIR ?= build/thermal-sensors-135$(if $(SANITIZE),-san,)
THERMAL135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
THERMAL135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
THERMAL135_SRC = src/backend/temp.c reconstruction/support/thermal_trip_135.c
THERMAL135_HDR = integration/thermal_sensors_135.h
$(THERMAL135_DIR):
	mkdir -p $@
$(THERMAL135_DIR)/libthermal.so: $(THERMAL135_SRC) $(THERMAL135_HDR) | $(THERMAL135_DIR)
	$(CC) $(THERMAL135_FLAGS) -fPIC -shared $(THERMAL135_SRC) -Wl,-z,defs -o $@
$(THERMAL135_DIR)/native-test: $(THERMAL135_SRC) $(THERMAL135_HDR) integration/tests/test_thermal_sensors_135.c | $(THERMAL135_DIR)
	$(CC) $(THERMAL135_FLAGS) $(THERMAL135_SAN) $(THERMAL135_SRC) integration/tests/test_thermal_sensors_135.c -o $@
.PHONY: dizzass-thermal135-original dizzass-thermal135-test
dizzass-thermal135-original: $(THERMAL135_DIR)/libthermal.so
	python3 integration/tests/test_thermal_sensors_135.py $< --summary $(THERMAL135_DIR)/original.json
dizzass-thermal135-test: $(THERMAL135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
THERMAL135_FAN_SRC = libbitmain/src/fan_ctrl.c libbitmain/src/aml/fan_ctrl.c reconstruction/support/pid_135.c
THERMAL135_FAN_HDR = integration/fan_control_135.h integration/aml_fans_135.h
$(THERMAL135_DIR)/airflow-test: $(THERMAL135_SRC) $(THERMAL135_HDR) $(THERMAL135_FAN_SRC) $(THERMAL135_FAN_HDR) integration/tests/test_thermal_airflow_135.c | $(THERMAL135_DIR)
	$(CC) $(THERMAL135_FLAGS) $(THERMAL135_SAN) $(THERMAL135_SRC) $(THERMAL135_FAN_SRC) integration/tests/test_thermal_airflow_135.c -lm -o $@
.PHONY: dizzass-thermal135-airflow
dizzass-thermal135-airflow: $(THERMAL135_DIR)/airflow-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
