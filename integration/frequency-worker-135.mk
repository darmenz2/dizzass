CC ?= cc
WORKER135_DIR ?= build/frequency-worker135$(if $(filter 1,$(SANITIZE)),-san,)
WORKER135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_FREQUENCY_FALL_135 -DVN135_FREQUENCY_WORKER_135
WORKER135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
WORKER135_SRC = src/backend/base.c src/backend/frequency-worker.c
.PHONY: dizzass-worker135-original dizzass-worker135-test dizzass-worker135-lifetime
$(WORKER135_DIR):
	mkdir -p $@
$(WORKER135_DIR)/libworker.so: $(WORKER135_SRC) $(wildcard integration/*135.h) integration/frequency-worker-135.mk | $(WORKER135_DIR)
	$(CC) $(WORKER135_FLAGS) -shared -fPIC $(WORKER135_SRC) -Wl,-z,defs -o $@
dizzass-worker135-original: $(WORKER135_DIR)/libworker.so
	python3 integration/tests/test_frequency_worker_135.py $< --summary $(WORKER135_DIR)/original.json
$(WORKER135_DIR)/native-test: $(WORKER135_SRC) integration/tests/test_frequency_worker_135.c $(wildcard integration/*135.h) integration/frequency-worker-135.mk | $(WORKER135_DIR)
	$(CC) $(WORKER135_FLAGS) $(WORKER135_SAN) $(WORKER135_SRC) integration/tests/test_frequency_worker_135.c -o $@
dizzass-worker135-test: $(WORKER135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-worker135-lifetime:
	python3 integration/tests/test_frequency_worker_lifetime_135.py
