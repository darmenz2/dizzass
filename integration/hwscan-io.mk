# After normal native cgminer build. No production sources are modified.
include integration/work-route.mk
DIZZASS_HWIO_DIR = build/hwscan-io$(if $(SANITIZE),-san,)
DIZZASS_HWIO_WARN = -Wall -Wextra -Werror $(if $(findstring clang,$(CC)),-Wno-error=unused-command-line-argument,)
DIZZASS_HWIO_MODULES = hwscan_profile posix_tx88 native_tx_channel
DIZZASS_HWIO_OBJS = $(addprefix $(DIZZASS_HWIO_DIR)/,$(addsuffix .o,$(DIZZASS_HWIO_MODULES)))
DIZZASS_HWIO_HEADERS = integration/hwscan_profile.h integration/posix_tx88.h integration/native_tx_channel.h $(DIZZASS_ROUTE_HEADERS)
$(DIZZASS_HWIO_DIR):
	mkdir -p $@
$(DIZZASS_HWIO_DIR)/%.o: integration/%.c $(DIZZASS_HWIO_HEADERS) config.h integration/hwscan-io.mk | $(DIZZASS_HWIO_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) $(DIZZASS_HWIO_WARN) -c $< -o $@
$(DIZZASS_HWIO_DIR)/test_native.o: integration/tests/test_native_tx_channel.c integration/tests/hwscan_fixture.h $(DIZZASS_HWIO_HEADERS) cgminer.c miner.h config.h integration/hwscan-io.mk | $(DIZZASS_HWIO_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) -c $< -o $@
$(DIZZASS_HWIO_DIR)/profile-test: integration/tests/test_hwscan_profile.c integration/tests/hwscan_fixture.h $(DIZZASS_HWIO_DIR)/hwscan_profile.o integration/hwscan-io.mk
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) $(DIZZASS_HWIO_WARN) $< $(DIZZASS_HWIO_DIR)/hwscan_profile.o -o $@ $(cgminer_LDADD) $(LIBS)
$(DIZZASS_HWIO_DIR)/pty-test: integration/tests/test_posix_tx88.c $(DIZZASS_HWIO_DIR)/posix_tx88.o $(DIZZASS_ROUTE_DIR)/packet.o integration/hwscan-io.mk
	$(CC) -I$(top_srcdir) $(DIZZASS_NONCE_FLAGS) -std=c11 -Wall -Wextra -Werror $< $(DIZZASS_HWIO_DIR)/posix_tx88.o $(DIZZASS_ROUTE_DIR)/packet.o -Wl,--wrap=write,--wrap=poll -lutil -o $@
$(DIZZASS_HWIO_DIR)/native-test: $(DIZZASS_HWIO_DIR)/test_native.o $(DIZZASS_HWIO_OBJS) $(DIZZASS_ROUTE_DIR)/native.o $(DIZZASS_ROUTE_DIR)/route.o $(DIZZASS_ROUTE_DIR)/packet.o $(DIZZASS_JOBS_DIR)/jobs.o $(DIZZASS_NONCE_DIR)/adapter.o $(DIZZASS_NONCE_DIR)/rx.o $(DIZZASS_NONCE_DIR)/stream.o $(DIZZASS_CORE_OTHER) integration/hwscan-io.mk
	$(CC) $(DIZZASS_NONCE_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=write,--wrap=socket,--wrap=connect,--wrap=libusb_init -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init -o $@ $(filter %.o,$^) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: dizzass-hwscan-io-test
dizzass-hwscan-io-test: $(DIZZASS_HWIO_DIR)/profile-test $(DIZZASS_HWIO_DIR)/pty-test $(DIZZASS_HWIO_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_HWIO_DIR)/profile-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_HWIO_DIR)/pty-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_HWIO_DIR)/native-test
	python3 integration/tests/test_hwscan_schema_original.py
