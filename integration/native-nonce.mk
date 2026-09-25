# Invoke AFTER the normal native Autotools build, in its source/build directory:
# make -f Makefile -f integration/native-nonce.mk dizzass-native-nonce-test
# No production Makefile changes, no device registration, no network.
DIZZASS_NONCE_DIR = build/native-nonce$(if $(SANITIZE),-san,)
DIZZASS_COMMA := ,
DIZZASS_NONCE_FLAGS = -O1 -g -fcommon -ffunction-sections -fdata-sections $(if $(SANITIZE),-fsanitize=address$(DIZZASS_COMMA)undefined -fno-omit-frame-pointer,)
DIZZASS_NATIVE_CPP = $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(cgminer_CPPFLAGS) -I$(top_srcdir) -I$(top_srcdir)/include
DIZZASS_CORE_OTHER = $(filter-out cgminer-cgminer.$(OBJEXT),$(cgminer_OBJECTS))
DIZZASS_NONCE_OBJS = $(DIZZASS_NONCE_DIR)/test.o $(DIZZASS_NONCE_DIR)/adapter.o $(DIZZASS_NONCE_DIR)/rx.o $(DIZZASS_NONCE_DIR)/stream.o

$(DIZZASS_NONCE_DIR):
	mkdir -p $@
$(DIZZASS_NONCE_DIR)/adapter.o: integration/native_nonce.c integration/native_nonce.h | $(DIZZASS_NONCE_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) -c $< -o $@
$(DIZZASS_NONCE_DIR)/test.o: integration/tests/test_native_nonce.c integration/native_nonce.h cgminer.c miner.h tests/fixtures/genesis_work.h | $(DIZZASS_NONCE_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) -c $< -o $@
$(DIZZASS_NONCE_DIR)/rx.o: src/backend/work-gen/work-gen.c | $(DIZZASS_NONCE_DIR)
	$(CC) -I$(top_srcdir)/include $(DIZZASS_NONCE_FLAGS) -std=c11 -c $< -o $@
$(DIZZASS_NONCE_DIR)/stream.o: reconstruction/support/work_rx_stream.c | $(DIZZASS_NONCE_DIR)
	$(CC) -I$(top_srcdir)/include $(DIZZASS_NONCE_FLAGS) -std=c11 -c $< -o $@
$(DIZZASS_NONCE_DIR)/test: $(DIZZASS_NONCE_OBJS) $(DIZZASS_CORE_OTHER)
	$(CC) $(DIZZASS_NONCE_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init -o $@ $(DIZZASS_NONCE_OBJS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS)

.PHONY: dizzass-native-nonce-test
dizzass-native-nonce-test: $(DIZZASS_NONCE_DIR)/test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_NONCE_DIR)/test > $(DIZZASS_NONCE_DIR)/results.log
	python3 integration/tests/check_native_nonce_output.py $(DIZZASS_NONCE_DIR)/results.log
	grep '^NATIVE_NONCE_PASS ' $(DIZZASS_NONCE_DIR)/results.log
	nm --defined-only $(DIZZASS_NONCE_DIR)/test > $(DIZZASS_NONCE_DIR)/symbols.txt
	python3 integration/tests/check_native_nonce_symbols.py $(DIZZASS_NONCE_DIR)/symbols.txt
