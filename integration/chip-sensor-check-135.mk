CC ?= cc
CHIPSENSE135_DIR ?= build/chip-sensor-check135$(if $(filter 1,$(SANITIZE)),-san,)
CHIPSENSE135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_CHIP_SENSOR_CHECK_135
CHIPSENSE135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
CHIPSENSE135_SRC = src/backend/chip-sensor-check.c src/backend/base.c
.PHONY: dizzass-chipsense135-original dizzass-chipsense135-test dizzass-chipsense135-negative dizzass-chipsense135-evidence
$(CHIPSENSE135_DIR):
	mkdir -p $@
$(CHIPSENSE135_DIR)/libchipsense.so: $(CHIPSENSE135_SRC) $(wildcard integration/*135.h) integration/chip-sensor-check-135.mk | $(CHIPSENSE135_DIR)
	$(CC) $(CHIPSENSE135_FLAGS) -shared -fPIC $(CHIPSENSE135_SRC) -Wl,-z,defs -o $@
dizzass-chipsense135-evidence:
	python3 integration/tests/check_chip_sensor_check_evidence_135.py
dizzass-chipsense135-original: $(CHIPSENSE135_DIR)/libchipsense.so dizzass-chipsense135-evidence
	python3 integration/tests/test_chip_sensor_check_135.py $< --summary $(CHIPSENSE135_DIR)/original.json
$(CHIPSENSE135_DIR)/native-test: $(CHIPSENSE135_SRC) integration/tests/test_chip_sensor_check_135.c $(wildcard integration/*135.h) integration/chip-sensor-check-135.mk | $(CHIPSENSE135_DIR)
	$(CC) $(CHIPSENSE135_FLAGS) $(CHIPSENSE135_SAN) $(CHIPSENSE135_SRC) integration/tests/test_chip_sensor_check_135.c -o $@
dizzass-chipsense135-test: $(CHIPSENSE135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-chipsense135-negative:
	python3 integration/tests/test_chip_sensor_check_negative_135.py --cc $(CC) --out $(CHIPSENSE135_DIR)/negative
