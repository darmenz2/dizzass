# Isolated 1.3.5 extraction. No production miner or hardware I/O.
CC ?= cc
COLD135_DIR ?= build/backend-cold-135$(if $(SANITIZE),-san,)
COLD135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
COLD135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
COLD135_HEADERS = integration/backend_cold_135.h integration/backend_peripheral_135.h integration/backend_resume_135.h integration/gpio_power_135.h
COLD135_SOURCE = src/backend/base.c
$(COLD135_DIR):
	mkdir -p $@
$(COLD135_DIR)/libcold.so: $(COLD135_SOURCE) $(COLD135_HEADERS) integration/tests/test_backend_cold_135.c integration/backend-cold-135.mk | $(COLD135_DIR)
	$(CC) $(COLD135_FLAGS) -fPIC -shared -DVN135_FIXTURE_ONLY $(COLD135_SOURCE) integration/tests/test_backend_cold_135.c -Wl,-z,defs -o $@
$(COLD135_DIR)/libperipheral.so: $(COLD135_SOURCE) $(COLD135_HEADERS) integration/tests/test_backend_peripheral_135.c integration/backend-cold-135.mk | $(COLD135_DIR)
	$(CC) $(COLD135_FLAGS) -fPIC -shared -DVN135_FIXTURE_ONLY $(COLD135_SOURCE) integration/tests/test_backend_peripheral_135.c -Wl,-z,defs -o $@
$(COLD135_DIR)/cold-native: $(COLD135_SOURCE) $(COLD135_HEADERS) integration/tests/test_backend_cold_135.c integration/backend-cold-135.mk | $(COLD135_DIR)
	$(CC) $(COLD135_FLAGS) $(COLD135_SAN) $(COLD135_SOURCE) integration/tests/test_backend_cold_135.c -o $@
$(COLD135_DIR)/peripheral-native: $(COLD135_SOURCE) $(COLD135_HEADERS) integration/tests/test_backend_peripheral_135.c integration/backend-cold-135.mk | $(COLD135_DIR)
	$(CC) $(COLD135_FLAGS) $(COLD135_SAN) $(COLD135_SOURCE) integration/tests/test_backend_peripheral_135.c -o $@
.PHONY: dizzass-cold135-original dizzass-cold135-boundaries dizzass-cold135-test
dizzass-cold135-original: $(COLD135_DIR)/libcold.so $(COLD135_DIR)/libperipheral.so
	python3 integration/tests/test_backend_cold_135.py $(COLD135_DIR)/libcold.so --summary $(COLD135_DIR)/constructor.json
	python3 integration/tests/test_backend_peripheral_135.py $(COLD135_DIR)/libperipheral.so --summary $(COLD135_DIR)/peripheral.json
dizzass-cold135-boundaries: | $(COLD135_DIR)
	python3 integration/tests/test_backend_cold_boundaries_135.py --summary $(COLD135_DIR)/boundaries.json
dizzass-cold135-test: $(COLD135_DIR)/cold-native $(COLD135_DIR)/peripheral-native
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $(COLD135_DIR)/cold-native
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $(COLD135_DIR)/peripheral-native
