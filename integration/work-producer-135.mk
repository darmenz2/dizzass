# Bounded reconstruction only, never included by production Makefile.am.
CC ?= cc
PRODUCER_DIR ?= build/work-producer-135
PRODUCER_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
PRODUCER_SOURCE = src/backend/work-gen/work-producer.c reconstruction/support/sha256_bytes.c reconstruction/support/sha256_midstate.c
PRODUCER_HEADER = integration/work_producer_135.h include/xminer/recovery/work_rebuild.h include/xminer/recovery/work_nonce.h
.PHONY: all evidence original native sanitize negative regressions
all: evidence original native
$(PRODUCER_DIR):
	mkdir -p $@
$(PRODUCER_DIR)/libproducer.so: $(PRODUCER_SOURCE) $(PRODUCER_HEADER) integration/work-producer-135.mk | $(PRODUCER_DIR)
	$(CC) $(PRODUCER_FLAGS) -O2 -shared -fPIC $(PRODUCER_SOURCE) -o $@
$(PRODUCER_DIR)/native: $(PRODUCER_SOURCE) $(PRODUCER_HEADER) integration/tests/test_work_producer_135.c integration/work-producer-135.mk | $(PRODUCER_DIR)
	$(CC) $(PRODUCER_FLAGS) -O2 $(PRODUCER_SOURCE) integration/tests/test_work_producer_135.c -o $@
$(PRODUCER_DIR)/san: $(PRODUCER_SOURCE) $(PRODUCER_HEADER) integration/tests/test_work_producer_135.c integration/work-producer-135.mk | $(PRODUCER_DIR)
	$(CC) $(PRODUCER_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(PRODUCER_SOURCE) integration/tests/test_work_producer_135.c -o $@
evidence:
	python3 integration/tests/check_work_producer_evidence_135.py
original: $(PRODUCER_DIR)/libproducer.so
	python3 integration/tests/test_work_producer_135.py $(PRODUCER_DIR)/libproducer.so
native: $(PRODUCER_DIR)/native
	./$(PRODUCER_DIR)/native
sanitize: $(PRODUCER_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(PRODUCER_DIR)/san
negative: | $(PRODUCER_DIR)
	python3 integration/tests/test_work_producer_negative_135.py $(PRODUCER_DIR)/negative --cc $(CC)
regressions: | $(PRODUCER_DIR)
	$(CC) $(PRODUCER_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(PRODUCER_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(PRODUCER_DIR)/libroute.so
	$(CC) $(PRODUCER_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(PRODUCER_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(PRODUCER_DIR)/route-bounds
