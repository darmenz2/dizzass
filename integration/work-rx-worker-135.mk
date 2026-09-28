# Isolated reconstruction; never included by production Makefile.am.
CC ?= cc
RX_DIR ?= build/work-rx-worker-135
RX_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
RX_SOURCE = src/backend/work-gen/work-rx-worker.c src/backend/work-gen/work-gen.c reconstruction/support/sha256_midstate.c
RX_HEADER = integration/work_rx_worker_135.h include/xminer/recovery/work_nonce.h include/xminer/recovery/work_rx.h integration/thermal_routes_135.h
.PHONY: all evidence original native sanitize negative regressions
all: evidence original native
$(RX_DIR):
	mkdir -p $@
$(RX_DIR)/librx.so: $(RX_SOURCE) $(RX_HEADER) integration/work-rx-worker-135.mk | $(RX_DIR)
	$(CC) $(RX_FLAGS) -O2 -shared -fPIC $(RX_SOURCE) -o $@
$(RX_DIR)/native: $(RX_SOURCE) $(RX_HEADER) integration/tests/test_work_rx_worker_135.c integration/work-rx-worker-135.mk | $(RX_DIR)
	$(CC) $(RX_FLAGS) -O2 $(RX_SOURCE) integration/tests/test_work_rx_worker_135.c -o $@
$(RX_DIR)/san: $(RX_SOURCE) $(RX_HEADER) integration/tests/test_work_rx_worker_135.c integration/work-rx-worker-135.mk | $(RX_DIR)
	$(CC) $(RX_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(RX_SOURCE) integration/tests/test_work_rx_worker_135.c -o $@
evidence:
	python3 integration/tests/check_work_rx_worker_evidence_135.py
original: $(RX_DIR)/librx.so
	python3 integration/tests/test_work_rx_worker_135.py $(RX_DIR)/librx.so
native: $(RX_DIR)/native
	./$(RX_DIR)/native
sanitize: $(RX_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(RX_DIR)/san
negative: | $(RX_DIR)
	python3 integration/tests/test_work_rx_worker_negative_135.py $(RX_DIR)/negative --cc $(CC)
regressions: | $(RX_DIR)
	$(CC) $(RX_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie src/backend/work-gen/work-gen.c reconstruction/support/sha256_midstate.c reconstruction/support/work_rx_stream.c tests/test_work_rx.c -o $(RX_DIR)/rx-regression
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(RX_DIR)/rx-regression
