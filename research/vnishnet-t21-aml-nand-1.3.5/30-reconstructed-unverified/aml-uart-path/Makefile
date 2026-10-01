CC ?= cc
PYTHON ?= python3
ROOT := $(abspath ../../../..)
BUILD_DIR ?= build
WARNINGS := -std=c11 -Wall -Wextra -Werror -Wconversion -Wshadow -pedantic
SOURCE := $(ROOT)/libbitmain/src/aml/platform.c
HEADER := $(ROOT)/include/xminer/recovery/aml_platform.h
TEST := tests/test_aml_uart_path.c

.PHONY: test sanitize evidence controls caller

test: $(BUILD_DIR)/test_aml_uart_path evidence controls caller
	$(BUILD_DIR)/test_aml_uart_path

sanitize: $(BUILD_DIR)/test_aml_uart_path_sanitize $(BUILD_DIR)/test_caller_seam_sanitize
	ASAN_OPTIONS=detect_leaks=0 UBSAN_OPTIONS=halt_on_error=1 $(BUILD_DIR)/test_aml_uart_path_sanitize
	ASAN_OPTIONS=detect_leaks=0 UBSAN_OPTIONS=halt_on_error=1 $(BUILD_DIR)/test_caller_seam_sanitize

caller: $(BUILD_DIR)/test_caller_seam
	$(BUILD_DIR)/test_caller_seam

evidence:
	$(PYTHON) -B verify_evidence.py
	$(PYTHON) -B -m unittest discover -s tests -p test_static_evidence.py -v

controls:
	$(PYTHON) -B tests/test_semantic_controls.py --cc "$(CC)" --build "$(BUILD_DIR)/controls"

$(BUILD_DIR)/test_aml_uart_path: $(SOURCE) $(HEADER) $(TEST) $(ROOT)/integration/thermal_routes_135.h $(ROOT)/integration/thermal_sensors_135.h
	mkdir -p $(BUILD_DIR)
	$(CC) $(WARNINGS) -O2 -I$(ROOT) -I$(ROOT)/include $(SOURCE) $(TEST) -o $@

$(BUILD_DIR)/test_aml_uart_path_sanitize: $(SOURCE) $(HEADER) $(TEST) $(ROOT)/integration/thermal_routes_135.h $(ROOT)/integration/thermal_sensors_135.h
	mkdir -p $(BUILD_DIR)
	$(CC) $(WARNINGS) -O1 -g -fno-omit-frame-pointer -fsanitize=address,undefined -I$(ROOT) -I$(ROOT)/include $(SOURCE) $(TEST) -o $@

CALLER := $(ROOT)/src/backend/work-gen/chain-work-start.c
CALLER_HEADERS := $(ROOT)/integration/chain_work_start_135.h $(ROOT)/integration/backend_shutdown_135.h $(ROOT)/integration/gpio_power_135.h

$(BUILD_DIR)/test_caller_seam: $(SOURCE) $(HEADER) $(CALLER) $(CALLER_HEADERS) tests/test_caller_seam.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(WARNINGS) -O2 -I$(ROOT) -I$(ROOT)/include $(SOURCE) $(CALLER) tests/test_caller_seam.c -o $@

$(BUILD_DIR)/test_caller_seam_sanitize: $(SOURCE) $(HEADER) $(CALLER) $(CALLER_HEADERS) tests/test_caller_seam.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(WARNINGS) -O1 -g -fno-omit-frame-pointer -fsanitize=address,undefined -I$(ROOT) -I$(ROOT)/include $(SOURCE) $(CALLER) tests/test_caller_seam.c -o $@
