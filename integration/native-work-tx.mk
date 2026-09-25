# Run after configuring/building the real native cgminer tree.
# No production source changes, model dispatch, UART access or device registration.
include integration/native-nonce.mk
DIZZASS_WORK_TX_DIR = build/native-work-tx$(if $(SANITIZE),-san,)
DIZZASS_WORK_TX_WARN = -Wall -Wextra -Werror $(if $(findstring clang,$(CC)),-Wno-error=unused-command-line-argument,)
DIZZASS_WORK_TX_OBJS = $(DIZZASS_WORK_TX_DIR)/test.o $(DIZZASS_WORK_TX_DIR)/native.o $(DIZZASS_WORK_TX_DIR)/packet.o

$(DIZZASS_WORK_TX_DIR):
	mkdir -p $@
$(DIZZASS_WORK_TX_DIR)/test.o: integration/tests/test_native_work_tx.c integration/tests/native_work_tx_cases.h integration/native_work_tx.h integration/work_tx86.h integration/native_nonce.h miner.h cgminer.c config.h tests/fixtures/genesis_work.h integration/native-work-tx.mk integration/native-nonce.mk | $(DIZZASS_WORK_TX_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) -c $< -o $@
$(DIZZASS_WORK_TX_DIR)/native.o: integration/native_work_tx.c integration/native_work_tx.h integration/work_tx86.h miner.h config.h integration/native-work-tx.mk integration/native-nonce.mk | $(DIZZASS_WORK_TX_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) $(DIZZASS_WORK_TX_WARN) -c $< -o $@
$(DIZZASS_WORK_TX_DIR)/packet.o: integration/work_tx86.c integration/work_tx86.h integration/native-work-tx.mk integration/native-nonce.mk | $(DIZZASS_WORK_TX_DIR)
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Wpedantic -Werror -c $< -o $@
$(DIZZASS_WORK_TX_DIR)/libtx86.so: integration/work_tx86.c integration/work_tx86.h integration/native-work-tx.mk | $(DIZZASS_WORK_TX_DIR)
	$(CC) -I$(top_srcdir) -O2 -std=c11 -Wall -Wextra -Wpedantic -Werror -fPIC -shared $< -o $@
$(DIZZASS_WORK_TX_DIR)/test: $(DIZZASS_WORK_TX_OBJS) $(DIZZASS_CORE_OTHER) integration/native-work-tx.mk integration/native-nonce.mk
	$(CC) $(DIZZASS_NONCE_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init -o $@ $(DIZZASS_WORK_TX_OBJS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS)

.PHONY: dizzass-native-work-tx-test dizzass-tx86-differential
dizzass-tx86-differential: $(DIZZASS_WORK_TX_DIR)/libtx86.so
	python3 integration/tests/test_tx86_differential.py $(abspath $(DIZZASS_WORK_TX_DIR)/libtx86.so)
dizzass-native-work-tx-test: $(DIZZASS_WORK_TX_DIR)/test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_WORK_TX_DIR)/test > $(DIZZASS_WORK_TX_DIR)/results.log
	grep '^NATIVE_.*PASS' $(DIZZASS_WORK_TX_DIR)/results.log
	nm --defined-only $(DIZZASS_WORK_TX_DIR)/test > $(DIZZASS_WORK_TX_DIR)/symbols.txt
	python3 integration/tests/check_native_work_tx_output.py $(DIZZASS_WORK_TX_DIR)/results.log $(DIZZASS_WORK_TX_DIR)/symbols.txt
	grep -q ' dizzass_native_work_tx86$$' $(DIZZASS_WORK_TX_DIR)/symbols.txt
	grep -q ' dizzass_work_tx86_encode$$' $(DIZZASS_WORK_TX_DIR)/symbols.txt
