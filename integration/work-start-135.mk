# Offline original-code comparison; never included by production Makefile.am.
CC ?= cc
START_DIR ?= build/work-start-135
START_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
START_SRC = src/backend/work-gen/work-start.c
START_HDR = integration/work_start_135.h
.PHONY: all evidence original native sanitize negative regressions backend-regressions
all: evidence original native
$(START_DIR):
	mkdir -p $@
$(START_DIR)/libstart.so: $(START_SRC) $(START_HDR) integration/work-start-135.mk | $(START_DIR)
	$(CC) $(START_FLAGS) -O2 -shared -fPIC $(START_SRC) -o $@
$(START_DIR)/native: $(START_SRC) $(START_HDR) integration/tests/test_work_start_135.c | $(START_DIR)
	$(CC) $(START_FLAGS) -O2 $(START_SRC) integration/tests/test_work_start_135.c -o $@
$(START_DIR)/san: $(START_SRC) $(START_HDR) integration/tests/test_work_start_135.c | $(START_DIR)
	$(CC) $(START_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(START_SRC) integration/tests/test_work_start_135.c -o $@
evidence:
	python3 integration/tests/check_work_start_evidence_135.py
original: $(START_DIR)/libstart.so
	python3 integration/tests/test_work_start_135.py $(START_DIR)/libstart.so
native: $(START_DIR)/native
	./$(START_DIR)/native
sanitize: $(START_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(START_DIR)/san
negative: $(START_DIR)/libstart.so
	python3 integration/tests/test_work_start_negative_135.py $(START_DIR)/negative --cc $(CC) --baseline $(START_DIR)/libstart.so
regressions: | $(START_DIR)
	$(CC) $(START_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(START_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(START_DIR)/libroute.so
	$(CC) $(START_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(START_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(START_DIR)/route-bounds
backend-regressions:
	$(MAKE) -f integration/backend-resume-135.mk CC=$(CC) RESUME135_DIR=$(START_DIR)/resume dizzass-resume135-original dizzass-resume135-test
	$(MAKE) -f integration/backend-prepare-135.mk CC=$(CC) PREP135_DIR=$(START_DIR)/prepare dizzass-prepare135-original dizzass-prepare135-test
