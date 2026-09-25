# Use after a normal host cgminer build. No production-source changes.
include integration/native-nonce.mk
DIZZASS_BM1368_DIR = build/bm1368$(if $(SANITIZE),-san,)
DIZZASS_BM1368_OBJS = $(DIZZASS_BM1368_DIR)/native-test.o $(DIZZASS_BM1368_DIR)/chip.o $(DIZZASS_NONCE_DIR)/adapter.o $(DIZZASS_NONCE_DIR)/rx.o $(DIZZASS_NONCE_DIR)/stream.o

$(DIZZASS_BM1368_DIR):
	mkdir -p $@
$(DIZZASS_BM1368_DIR)/chip.o: libbitmain/src/chip/chip1368.c integration/bm1368_nonce.h integration/bm1368-nonce.mk | $(DIZZASS_BM1368_DIR)
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Wpedantic -Werror -c $< -o $@
$(DIZZASS_BM1368_DIR)/libchip.so: libbitmain/src/chip/chip1368.c integration/bm1368_nonce.h integration/bm1368-nonce.mk | $(DIZZASS_BM1368_DIR)
	$(CC) -I$(top_srcdir) -O2 -std=c11 -Wall -Wextra -Wpedantic -Werror -shared -fPIC $< -o $@
$(DIZZASS_BM1368_DIR)/bounds: integration/tests/test_bm1368_bounds.c $(DIZZASS_BM1368_DIR)/chip.o integration/bm1368_nonce.h integration/bm1368-nonce.mk
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Wpedantic -Werror $< $(DIZZASS_BM1368_DIR)/chip.o -o $@
$(DIZZASS_BM1368_DIR)/native-test.o: integration/tests/test_bm1368_native.c integration/bm1368_nonce.h integration/native_nonce.h include/xminer/recovery/work_rx.h tests/fixtures/genesis_work.h miner.h cgminer.c config.h integration/bm1368-nonce.mk integration/native-nonce.mk | $(DIZZASS_BM1368_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) -c $< -o $@
$(DIZZASS_BM1368_DIR)/native-test: $(DIZZASS_BM1368_OBJS) $(DIZZASS_CORE_OTHER) integration/bm1368-nonce.mk integration/native-nonce.mk
	$(CC) $(DIZZASS_NONCE_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init -o $@ $(DIZZASS_BM1368_OBJS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS)

.PHONY: dizzass-bm1368-differential dizzass-bm1368-native-test dizzass-bm1368-bounds
dizzass-bm1368-differential: $(DIZZASS_BM1368_DIR)/libchip.so
	python3 integration/tests/test_bm1368_differential.py $(abspath $(DIZZASS_BM1368_DIR)/libchip.so)
dizzass-bm1368-bounds: $(DIZZASS_BM1368_DIR)/bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_BM1368_DIR)/bounds
dizzass-bm1368-native-test: $(DIZZASS_BM1368_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_BM1368_DIR)/native-test > $(DIZZASS_BM1368_DIR)/native-results.log
	grep '^BM1368_NATIVE_PASS' $(DIZZASS_BM1368_DIR)/native-results.log
	nm --defined-only $(DIZZASS_BM1368_DIR)/native-test > $(DIZZASS_BM1368_DIR)/symbols.txt
	python3 integration/tests/check_bm1368_native.py $(DIZZASS_BM1368_DIR)/native-results.log $(DIZZASS_BM1368_DIR)/symbols.txt
