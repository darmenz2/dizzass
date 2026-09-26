# Offline source recovery only. No production driver or physical I/O.
CC ?= cc
COMPLETION135_DIR ?= build/thermal-completion-135$(if $(SANITIZE),-san,)
COMPLETION135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_THERMAL_READER_135 -DVN135_BACKEND_SHUTDOWN_135
COMPLETION135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
COMPLETION135_HEADERS = $(wildcard integration/*135.h)
COMPLETION135_TESTS = $(wildcard integration/tests/*thermal*135.py) integration/tests/test_backend_shutdown_135.py
$(COMPLETION135_DIR):
	mkdir -p $@
$(COMPLETION135_DIR)/libreader.so: src/backend/temp.c $(COMPLETION135_HEADERS) | $(COMPLETION135_DIR)
	$(CC) $(COMPLETION135_FLAGS) -shared -fPIC $< -Wl,-z,defs -o $@
$(COMPLETION135_DIR)/libshutdown.so: src/backend/base.c $(COMPLETION135_HEADERS) | $(COMPLETION135_DIR)
	$(CC) $(COMPLETION135_FLAGS) -shared -fPIC $< -Wl,-z,defs -o $@
$(COMPLETION135_DIR)/native-test: src/backend/temp.c src/backend/base.c $(COMPLETION135_HEADERS) integration/tests/test_thermal_completion_135.c | $(COMPLETION135_DIR)
	$(CC) $(COMPLETION135_FLAGS) $(COMPLETION135_SAN) src/backend/temp.c src/backend/base.c integration/tests/test_thermal_completion_135.c -o $@
.PHONY: dizzass-completion135-original dizzass-completion135-test dizzass-completion135-route
dizzass-completion135-original: $(COMPLETION135_DIR)/libreader.so $(COMPLETION135_DIR)/libshutdown.so
	python3 integration/tests/test_thermal_reader_135.py $(COMPLETION135_DIR)/libreader.so --summary $(COMPLETION135_DIR)/reader-original.json
	python3 integration/tests/test_backend_shutdown_135.py $(COMPLETION135_DIR)/libshutdown.so --summary $(COMPLETION135_DIR)/shutdown-original.json
dizzass-completion135-route: | $(COMPLETION135_DIR)
	python3 integration/tests/test_thermal_request_route_135.py --summary $(COMPLETION135_DIR)/request-route.json
dizzass-completion135-test: $(COMPLETION135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
