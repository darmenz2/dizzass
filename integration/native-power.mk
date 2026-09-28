# Normal upstream configure/make first. New guard remains outside production.
include integration/hwscan-io.mk
DIZZASS_NATIVE_POWER_DIR ?= build/native-power$(if $(SANITIZE),-san,)
DIZZASS_NATIVE_POWER_HEADERS = integration/aml_power.h integration/gpio_value_io.h integration/native_power_guard.h $(DIZZASS_HWIO_HEADERS)
DIZZASS_NATIVE_POWER_OBJECTS = $(DIZZASS_NATIVE_POWER_DIR)/test.o $(DIZZASS_NATIVE_POWER_DIR)/aml_power.o $(DIZZASS_NATIVE_POWER_DIR)/gpio_value_io.o $(DIZZASS_NATIVE_POWER_DIR)/native_power_guard.o
$(DIZZASS_NATIVE_POWER_DIR):
	mkdir -p $@
$(DIZZASS_NATIVE_POWER_DIR)/%.o: integration/%.c $(DIZZASS_NATIVE_POWER_HEADERS) config.h integration/native-power.mk | $(DIZZASS_NATIVE_POWER_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) $(DIZZASS_HWIO_WARN) -c $< -o $@
$(DIZZASS_NATIVE_POWER_DIR)/test.o: integration/tests/test_native_power_guard.c integration/tests/hwscan_fixture.h $(DIZZASS_NATIVE_POWER_HEADERS) miner.h cgminer.c config.h integration/native-power.mk | $(DIZZASS_NATIVE_POWER_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_NONCE_FLAGS) -c $< -o $@
$(DIZZASS_NATIVE_POWER_DIR)/test: $(DIZZASS_NATIVE_POWER_OBJECTS) $(DIZZASS_HWIO_OBJS) $(DIZZASS_ROUTE_DIR)/native.o $(DIZZASS_ROUTE_DIR)/route.o $(DIZZASS_ROUTE_DIR)/packet.o $(DIZZASS_JOBS_DIR)/jobs.o $(DIZZASS_NONCE_DIR)/adapter.o $(DIZZASS_NONCE_DIR)/rx.o $(DIZZASS_NONCE_DIR)/stream.o $(DIZZASS_CORE_OTHER) integration/native-power.mk
	$(CC) $(DIZZASS_NONCE_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=write,--wrap=socket,--wrap=connect,--wrap=libusb_init -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init -o $@ $(filter %.o,$^) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: dizzass-native-power-test
dizzass-native-power-test: $(DIZZASS_NATIVE_POWER_DIR)/test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$<
