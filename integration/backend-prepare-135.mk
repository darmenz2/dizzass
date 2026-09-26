# Isolated preparation / fan-poll recovery; no production sources changed.
CC ?= cc
PREP135_DIR ?= build/backend-prepare-135$(if $(SANITIZE),-san,)
PREP135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
PREP135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
PREP135_HEADERS = $(wildcard integration/backend_*135.h) integration/gpio_power_135.h
$(PREP135_DIR):
	mkdir -p $@
$(PREP135_DIR)/libprepare.so: src/backend/base.c $(PREP135_HEADERS) integration/backend-prepare-135.mk | $(PREP135_DIR)
	$(CC) $(PREP135_FLAGS) -shared -fPIC $< -Wl,-z,defs -o $@
.PHONY: dizzass-prepare135-original dizzass-prepare135-test
# Python differential tests execute the actual reference words, never vendor ELF as a process.
dizzass-prepare135-original: $(PREP135_DIR)/libprepare.so
	python3 integration/tests/test_backend_prepare_135.py $< --summary $(PREP135_DIR)/original.json
$(PREP135_DIR)/native-test: src/backend/base.c integration/tests/test_backend_prepare_135.c $(PREP135_HEADERS) integration/backend-prepare-135.mk | $(PREP135_DIR)
	$(CC) $(PREP135_FLAGS) $(PREP135_SAN) src/backend/base.c integration/tests/test_backend_prepare_135.c -o $@
dizzass-prepare135-test: $(PREP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$<

# Current PSU API is mandatory by default. Archival local checks must opt in
# explicitly with PREP135_COMPOSE_ARGS=--allow-archive and are reported as such.
PREP135_PSU_SOURCE ?= libbitmain/src/psu.c
PREP135_COMPOSE_ARGS ?=
$(PREP135_DIR)/libcomposed.so: src/backend/base.c $(PREP135_PSU_SOURCE) $(PREP135_HEADERS) integration/psu_setup_135.h integration/psu_protocol_135.h integration/backend-prepare-135.mk | $(PREP135_DIR)
	$(CC) $(PREP135_FLAGS) -shared -fPIC src/backend/base.c $(PREP135_PSU_SOURCE) -lm -Wl,-z,defs -o $@
.PHONY: dizzass-prepare135-composed
dizzass-prepare135-composed: $(PREP135_DIR)/libcomposed.so
	python3 integration/tests/test_backend_prepare_psu_135.py $< $(PREP135_COMPOSE_ARGS) --summary $(PREP135_DIR)/composed.json
