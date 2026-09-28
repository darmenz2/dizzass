CC ?= cc
RT135_DIR ?= build/resume-temperature-135
RT135_DEPS ?= build/a12-deps
RT135_FLAGS = -I$(RT135_DEPS) -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_CHAIN_TEMPERATURE_SETUP_135 -DVN135_CHIP_SENSOR_CHECK_135 -DVN135_BACKEND_SHUTDOWN_135
RT135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
RT135_SRC = integration/native/resume_temperature_135.c $(RT135_DEPS)/integration/native/temperature_start_composition_135.c $(RT135_DEPS)/src/backend/temperature-setup.c $(RT135_DEPS)/src/backend/chain-temperature-setup.c $(RT135_DEPS)/src/backend/chip-sensor-check.c src/backend/base.c src/backend/temp.c
RT135_TEST = integration/tests/test_resume_temperature_135.c
RT135_HDR = $(wildcard integration/*135.h) $(wildcard $(RT135_DEPS)/integration/*135.h) integration/tests/resume_temperature_fixture_135.h
.PHONY: resume-temperature-evidence resume-temperature-original resume-temperature-test resume-temperature-negative
$(RT135_DIR):
	mkdir -p $@
	printf '*\n' > $@/.gitignore
resume-temperature-evidence:
	python3 tools/prepare_resume_temperature_135.py --out $(RT135_DEPS) --check
$(RT135_DIR)/libresume-temperature.so: $(RT135_SRC) $(RT135_TEST) $(RT135_HDR) integration/resume-temperature-135.mk | $(RT135_DIR)
	$(CC) $(RT135_FLAGS) -DRT135_LIBRARY -shared -fPIC $(RT135_SRC) $(RT135_TEST) -Wl,-z,defs -o $@
resume-temperature-original: $(RT135_DIR)/libresume-temperature.so resume-temperature-evidence
	python3 integration/tests/test_resume_temperature_135.py $< --summary $(RT135_DIR)/original.json
$(RT135_DIR)/native-test: $(RT135_SRC) $(RT135_TEST) $(RT135_HDR) integration/resume-temperature-135.mk | $(RT135_DIR)
	$(CC) $(RT135_FLAGS) $(RT135_SAN) $(RT135_SRC) $(RT135_TEST) -lm -o $@
resume-temperature-test: $(RT135_DIR)/native-test resume-temperature-evidence
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
resume-temperature-negative:
	python3 integration/tests/test_resume_temperature_negative_135.py --cc $(CC) --deps $(RT135_DEPS) --out $(RT135_DIR)/negative
