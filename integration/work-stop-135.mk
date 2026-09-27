# Offline source comparison, never included by production Makefile.am.
CC ?= cc
STOP_DIR ?= build/work-stop-135
STOP_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
STOP_SRC = src/backend/work-gen/work-stop.c
STOP_HDR = integration/work_stop_135.h integration/backend_shutdown_135.h
.PHONY: all evidence original native sanitize negative regressions backend-regressions
all: evidence original native
$(STOP_DIR):
	mkdir -p $@
$(STOP_DIR)/libstop.so: $(STOP_SRC) $(STOP_HDR) integration/work-stop-135.mk | $(STOP_DIR)
	$(CC) $(STOP_FLAGS) -O2 -shared -fPIC $(STOP_SRC) -o $@
$(STOP_DIR)/native: $(STOP_SRC) $(STOP_HDR) integration/tests/test_work_stop_135.c | $(STOP_DIR)
	$(CC) $(STOP_FLAGS) -O2 $(STOP_SRC) integration/tests/test_work_stop_135.c -o $@
$(STOP_DIR)/san: $(STOP_SRC) $(STOP_HDR) integration/tests/test_work_stop_135.c | $(STOP_DIR)
	$(CC) $(STOP_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(STOP_SRC) integration/tests/test_work_stop_135.c -o $@
evidence:
	python3 integration/tests/check_work_stop_evidence_135.py
original: $(STOP_DIR)/libstop.so
	python3 integration/tests/test_work_stop_135.py $(STOP_DIR)/libstop.so
native: $(STOP_DIR)/native
	./$(STOP_DIR)/native
sanitize: $(STOP_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(STOP_DIR)/san
negative: $(STOP_DIR)/libstop.so
	python3 integration/tests/test_work_stop_negative_135.py $(STOP_DIR)/negative --cc $(CC) --baseline $(STOP_DIR)/libstop.so
regressions: | $(STOP_DIR)
	$(CC) $(STOP_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(STOP_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(STOP_DIR)/libroute.so
	$(CC) $(STOP_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(STOP_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(STOP_DIR)/route-bounds
backend-regressions:
	$(MAKE) -f integration/mining-stop-135.mk CC=$(CC) MINING135_DIR=$(STOP_DIR)/mining dizzass-mining135-original dizzass-mining135-test
