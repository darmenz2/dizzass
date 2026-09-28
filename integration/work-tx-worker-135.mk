# Isolated recovery only; never included by production Makefile.am.
CC ?= cc
TX_DIR ?= build/work-tx-worker-135
TX_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
TX_SOURCE = src/backend/work-gen/work-tx-worker.c integration/work_tx88.c
TX_HEADER = integration/work_tx_worker_135.h integration/work_tx88.h include/xminer/recovery/work_nonce.h integration/thermal_routes_135.h
.PHONY: all original native sanitize negative evidence regressions
all: evidence original native
$(TX_DIR):
	mkdir -p $@
$(TX_DIR)/libtx.so: $(TX_SOURCE) $(TX_HEADER) integration/work-tx-worker-135.mk | $(TX_DIR)
	$(CC) $(TX_FLAGS) -O2 -shared -fPIC $(TX_SOURCE) -o $@
$(TX_DIR)/native: $(TX_SOURCE) $(TX_HEADER) integration/tests/test_work_tx_worker_135.c integration/work-tx-worker-135.mk | $(TX_DIR)
	$(CC) $(TX_FLAGS) -O2 $(TX_SOURCE) integration/tests/test_work_tx_worker_135.c -o $@
$(TX_DIR)/san: $(TX_SOURCE) $(TX_HEADER) integration/tests/test_work_tx_worker_135.c integration/work-tx-worker-135.mk | $(TX_DIR)
	$(CC) $(TX_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(TX_SOURCE) integration/tests/test_work_tx_worker_135.c -o $@
evidence:
	python3 integration/tests/check_work_tx_worker_evidence_135.py
original: $(TX_DIR)/libtx.so
	python3 integration/tests/test_work_tx_worker_135.py $(TX_DIR)/libtx.so
native: $(TX_DIR)/native
	./$(TX_DIR)/native
sanitize: $(TX_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(TX_DIR)/san
negative: | $(TX_DIR)
	python3 integration/tests/test_work_tx_worker_negative_135.py $(TX_DIR)/negative --cc $(CC)
regressions: | $(TX_DIR)
	$(CC) $(TX_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(TX_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(TX_DIR)/libroute.so
	$(CC) $(TX_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(TX_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(TX_DIR)/route-bounds
