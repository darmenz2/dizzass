# Isolated host comparison. No production linkage or real GPIO access.
CC ?= cc
LED135_DIR ?= build/led-output135$(if $(filter 1,$(SANITIZE)),-san,)
LED135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_LED_OUTPUT_135 -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135
LED135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
LED135_SRC = libbitmain/src/led-output.c libbitmain/src/gpio.c src/backend/base.c
LED135_HEADERS = $(wildcard integration/*135.h)
$(LED135_DIR):
	mkdir -p $@
$(LED135_DIR)/libled.so: $(LED135_SRC) $(LED135_HEADERS) integration/led-output-135.mk | $(LED135_DIR)
	$(CC) $(LED135_FLAGS) -shared -fPIC $(LED135_SRC) -Wl,-z,defs -o $@
$(LED135_DIR)/native-test: $(LED135_SRC) $(LED135_HEADERS) integration/tests/test_led_output_135.c integration/led-output-135.mk | $(LED135_DIR)
	$(CC) $(LED135_FLAGS) $(LED135_SAN) $(LED135_SRC) integration/tests/test_led_output_135.c -o $@
.PHONY: dizzass-led135-evidence dizzass-led135-original dizzass-led135-test dizzass-led135-negative
dizzass-led135-evidence:
	python3 integration/tests/check_led_output_evidence_135.py
dizzass-led135-original: $(LED135_DIR)/libled.so dizzass-led135-evidence
	python3 integration/tests/test_led_output_135.py $< --summary $(LED135_DIR)/original.json
dizzass-led135-test: $(LED135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-led135-negative:
	python3 integration/tests/test_led_output_negative_135.py --cc $(CC) --out $(LED135_DIR)/negative
