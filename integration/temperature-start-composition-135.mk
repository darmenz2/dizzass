CC ?= cc
TC135_DIR ?= build/temperature-start-composition-135
TC135_DEPS ?= build/a11-deps
TC135_FLAGS = -I$(TC135_DEPS) -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_CHAIN_TEMPERATURE_SETUP_135 -DVN135_CHIP_SENSOR_CHECK_135
TC135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
TC135_SRC = integration/native/temperature_start_composition_135.c $(TC135_DEPS)/src/backend/temperature-setup.c $(TC135_DEPS)/src/backend/chain-temperature-setup.c $(TC135_DEPS)/src/backend/chip-sensor-check.c src/backend/base.c src/backend/temp.c
TC135_HDR = $(wildcard integration/*135.h) $(wildcard $(TC135_DEPS)/integration/*135.h)
.PHONY: temperature-composition-evidence temperature-composition-original temperature-composition-test temperature-composition-negative
$(TC135_DIR):
	mkdir -p $@
	printf '*\n' > $@/.gitignore
temperature-composition-evidence:
	python3 tools/prepare_temperature_start_composition_135.py --out $(TC135_DEPS) --check
$(TC135_DIR)/libtemperature-start.so: $(TC135_SRC) $(TC135_HDR) integration/temperature-start-composition-135.mk | $(TC135_DIR)
	$(CC) $(TC135_FLAGS) -shared -fPIC $(TC135_SRC) -Wl,-z,defs -o $@
temperature-composition-original: $(TC135_DIR)/libtemperature-start.so temperature-composition-evidence
	python3 integration/tests/test_temperature_start_composition_135.py $< --summary $(TC135_DIR)/original.json
$(TC135_DIR)/native-test: $(TC135_SRC) $(TC135_HDR) integration/tests/test_temperature_start_composition_135.c integration/temperature-start-composition-135.mk | $(TC135_DIR)
	$(CC) $(TC135_FLAGS) $(TC135_SAN) $(TC135_SRC) integration/tests/test_temperature_start_composition_135.c -lm -o $@
temperature-composition-test: $(TC135_DIR)/native-test temperature-composition-evidence
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
temperature-composition-negative:
	python3 integration/tests/test_temperature_start_composition_negative_135.py --cc $(CC) --deps $(TC135_DEPS) --out $(TC135_DIR)/negative
