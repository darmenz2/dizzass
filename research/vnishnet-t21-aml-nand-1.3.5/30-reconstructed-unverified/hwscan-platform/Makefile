CC ?= cc
PYTHON ?= python3
BUILD_DIR ?= build
WARNINGS = -std=c11 -Wall -Wextra -Werror -Wconversion -Wshadow -pedantic
SOURCES = hwscan_platform_135.c tests/test_hwscan_platform_135.c

.PHONY: test sanitize evidence

test: $(BUILD_DIR)/test_hwscan_platform_135 evidence
	$(BUILD_DIR)/test_hwscan_platform_135

sanitize: $(BUILD_DIR)/test_hwscan_platform_135_sanitize evidence
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 $(BUILD_DIR)/test_hwscan_platform_135_sanitize

evidence:
	$(PYTHON) -B -m unittest discover -s tests -p 'test_*.py' -v

$(BUILD_DIR)/test_hwscan_platform_135: $(SOURCES) hwscan_platform_135.h
	mkdir -p $(BUILD_DIR)
	$(CC) $(WARNINGS) -O2 -I. $(SOURCES) -o $@

$(BUILD_DIR)/test_hwscan_platform_135_sanitize: $(SOURCES) hwscan_platform_135.h
	mkdir -p $(BUILD_DIR)
	$(CC) $(WARNINGS) -O1 -g -fno-omit-frame-pointer -fsanitize=address,undefined -I. $(SOURCES) -o $@
