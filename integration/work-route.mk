# Offline composition after the normal cgminer Autotools build.
# Uses the existing native registry; no production source or runtime changes.
include integration/native-jobs.mk
DIZZASS_ROUTE_DIR = build/work-route$(if $(SANITIZE),-san,)
DIZZASS_ROUTE_OBJS = $(DIZZASS_ROUTE_DIR)/test.o $(DIZZASS_ROUTE_DIR)/native.o $(DIZZASS_ROUTE_DIR)/route.o $(DIZZASS_ROUTE_DIR)/packet.o $(DIZZASS_JOBS_DIR)/jobs.o $(DIZZASS_NONCE_DIR)/adapter.o
DIZZASS_ROUTE_HEADERS = integration/native_work_tx88.h integration/work_route.h integration/work_tx88.h integration/native_jobs.h integration/native_nonce.h

$(DIZZASS_ROUTE_DIR):
	mkdir -p $@
$(DIZZASS_ROUTE_DIR)/route.o: integration/work_route.c integration/work_route.h integration/work-route.mk | $(DIZZASS_ROUTE_DIR)
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Wpedantic -Werror -c $< -o $@
$(DIZZASS_ROUTE_DIR)/packet.o: integration/work_tx88.c integration/work_tx88.h integration/work-route.mk | $(DIZZASS_ROUTE_DIR)
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Wpedantic -Werror -c $< -o $@
$(DIZZASS_ROUTE_DIR)/libroute.so: integration/work_route.c integration/work_tx88.c integration/work_route.h integration/work_tx88.h integration/work-route.mk | $(DIZZASS_ROUTE_DIR)
	$(CC) -I$(top_srcdir) -O2 -std=c11 -Wall -Wextra -Wpedantic -Werror -shared -fPIC integration/work_route.c integration/work_tx88.c -o $@
$(DIZZASS_ROUTE_DIR)/bounds: integration/tests/test_work_route_bounds.c $(DIZZASS_ROUTE_DIR)/route.o $(DIZZASS_ROUTE_DIR)/packet.o integration/work-route.mk
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Wpedantic -Werror $< $(DIZZASS_ROUTE_DIR)/route.o $(DIZZASS_ROUTE_DIR)/packet.o -o $@
$(DIZZASS_ROUTE_DIR)/native.o: integration/native_work_tx88.c $(DIZZASS_ROUTE_HEADERS) miner.h config.h integration/work-route.mk integration/native-jobs.mk integration/native-nonce.mk | $(DIZZASS_ROUTE_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_JOBS_FLAGS) $(DIZZASS_JOBS_WARNINGS) -c $< -o $@
$(DIZZASS_ROUTE_DIR)/test.o: integration/tests/test_work_route_native.c $(DIZZASS_ROUTE_HEADERS) miner.h cgminer.c config.h tests/fixtures/genesis_work.h integration/work-route.mk integration/native-jobs.mk integration/native-nonce.mk | $(DIZZASS_ROUTE_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_JOBS_FLAGS) -c $< -o $@
$(DIZZASS_ROUTE_DIR)/native-test: $(DIZZASS_ROUTE_OBJS) $(DIZZASS_CORE_OTHER) integration/work-route.mk integration/native-jobs.mk integration/native-nonce.mk
	$(CC) $(DIZZASS_JOBS_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init,--wrap=strdup -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup -o $@ $(DIZZASS_ROUTE_OBJS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS)

.PHONY: dizzass-work-route-original dizzass-work-route-bounds dizzass-work-route-native
dizzass-work-route-original: $(DIZZASS_ROUTE_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(abspath $(DIZZASS_ROUTE_DIR)/libroute.so)
dizzass-work-route-bounds: $(DIZZASS_ROUTE_DIR)/bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_ROUTE_DIR)/bounds
dizzass-work-route-native: $(DIZZASS_ROUTE_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_ROUTE_DIR)/native-test > $(DIZZASS_ROUTE_DIR)/native-results.log
	grep '^WORK_ROUTE_NATIVE_PASS' $(DIZZASS_ROUTE_DIR)/native-results.log
	nm --defined-only $(DIZZASS_ROUTE_DIR)/native-test > $(DIZZASS_ROUTE_DIR)/symbols.txt
	python3 integration/tests/check_work_route_native.py $(DIZZASS_ROUTE_DIR)/native-results.log $(DIZZASS_ROUTE_DIR)/symbols.txt
