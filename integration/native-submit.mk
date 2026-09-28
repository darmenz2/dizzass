# Run after the native Autotools build. Production cgminer_SOURCES is unchanged.
include integration/native-jobs.mk
DIZZASS_SUBMIT_DIR = build/native-submit$(if $(SANITIZE),-san,)
DIZZASS_SUBMIT_OBJS = $(DIZZASS_SUBMIT_DIR)/test.o $(DIZZASS_JOBS_DIR)/jobs.o $(DIZZASS_NONCE_DIR)/adapter.o $(DIZZASS_NONCE_DIR)/rx.o $(DIZZASS_NONCE_DIR)/stream.o

$(DIZZASS_SUBMIT_DIR):
	mkdir -p $@
$(DIZZASS_SUBMIT_DIR)/test.o: integration/tests/test_native_nonce.c integration/tests/native_submit_cases.h integration/tests/native_jobs_cases.h integration/native_submit.h integration/native_jobs.h integration/native_nonce.h miner.h cgminer.c config.h tests/fixtures/genesis_work.h integration/native-submit.mk integration/native-jobs.mk integration/native-nonce.mk | $(DIZZASS_SUBMIT_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_JOBS_FLAGS) -DDIZZASS_TEST_NATIVE_JOBS -DDIZZASS_TEST_NATIVE_SUBMIT -c $< -o $@
$(DIZZASS_SUBMIT_DIR)/test: $(DIZZASS_SUBMIT_OBJS) $(DIZZASS_CORE_OTHER) integration/native-submit.mk
	$(CC) $(DIZZASS_JOBS_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init,--wrap=strdup,--wrap=tq_push -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_tq_push -o $@ $(DIZZASS_SUBMIT_OBJS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS)

.PHONY: dizzass-native-submit-test
dizzass-native-submit-test: $(DIZZASS_SUBMIT_DIR)/test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_SUBMIT_DIR)/test > $(DIZZASS_SUBMIT_DIR)/results.log
	python3 integration/tests/check_native_nonce_output.py $(DIZZASS_SUBMIT_DIR)/results.log
	grep '^NATIVE_.*PASS\|^NATIVE_.*THREADS' $(DIZZASS_SUBMIT_DIR)/results.log
	nm --defined-only $(DIZZASS_SUBMIT_DIR)/test > $(DIZZASS_SUBMIT_DIR)/symbols.txt
	python3 integration/tests/check_native_nonce_symbols.py $(DIZZASS_SUBMIT_DIR)/symbols.txt
	python3 integration/tests/check_native_jobs_output.py $(DIZZASS_SUBMIT_DIR)/results.log $(DIZZASS_SUBMIT_DIR)/symbols.txt
	python3 integration/tests/check_native_submit_output.py $(DIZZASS_SUBMIT_DIR)/results.log $(DIZZASS_SUBMIT_DIR)/symbols.txt
