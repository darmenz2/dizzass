# Run after the real native Autotools build, from its source/build directory.
# No production Makefile modification or driver registration.
include integration/native-nonce.mk
DIZZASS_JOBS_DIR = build/native-jobs$(if $(SANITIZE),-san,)
DIZZASS_JOBS_FLAGS = $(DIZZASS_NONCE_FLAGS) -fno-builtin-strdup
# The pinned core CPPFLAGS also contain -l flags. Clang diagnoses these at
# compile-only steps; keep that driver warning non-fatal, not C diagnostics.
DIZZASS_JOBS_WARNINGS = -Wall -Wextra -Werror $(if $(findstring clang,$(CC)),-Wno-error=unused-command-line-argument,)
DIZZASS_JOBS_OBJS = $(DIZZASS_JOBS_DIR)/test.o $(DIZZASS_JOBS_DIR)/jobs.o $(DIZZASS_NONCE_DIR)/adapter.o $(DIZZASS_NONCE_DIR)/rx.o $(DIZZASS_NONCE_DIR)/stream.o

$(DIZZASS_JOBS_DIR):
	mkdir -p $@
$(DIZZASS_JOBS_DIR)/test.o: integration/tests/test_native_nonce.c integration/tests/native_jobs_cases.h integration/native_jobs.h integration/native_nonce.h miner.h cgminer.c config.h tests/fixtures/genesis_work.h integration/native-jobs.mk integration/native-nonce.mk | $(DIZZASS_JOBS_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_JOBS_FLAGS) -DDIZZASS_TEST_NATIVE_JOBS -c $< -o $@
$(DIZZASS_JOBS_DIR)/jobs.o: integration/native_jobs.c integration/native_jobs.h integration/native_submit.h integration/native_nonce.h miner.h config.h integration/native-jobs.mk integration/native-nonce.mk | $(DIZZASS_JOBS_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_JOBS_FLAGS) $(DIZZASS_JOBS_WARNINGS) -c $< -o $@
$(DIZZASS_JOBS_DIR)/test: $(DIZZASS_JOBS_OBJS) $(DIZZASS_CORE_OTHER) integration/native-jobs.mk integration/native-nonce.mk
	$(CC) $(DIZZASS_JOBS_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init,--wrap=strdup -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup -o $@ $(DIZZASS_JOBS_OBJS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS)

.PHONY: dizzass-native-jobs-test
dizzass-native-jobs-test: $(DIZZASS_JOBS_DIR)/test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_JOBS_DIR)/test > $(DIZZASS_JOBS_DIR)/results.log
	python3 integration/tests/check_native_nonce_output.py $(DIZZASS_JOBS_DIR)/results.log
	grep '^NATIVE_.*PASS\|^NATIVE_JOBS_THREADS' $(DIZZASS_JOBS_DIR)/results.log
	nm --defined-only $(DIZZASS_JOBS_DIR)/test > $(DIZZASS_JOBS_DIR)/symbols.txt
	python3 integration/tests/check_native_nonce_symbols.py $(DIZZASS_JOBS_DIR)/symbols.txt
	python3 integration/tests/check_native_jobs_output.py $(DIZZASS_JOBS_DIR)/results.log $(DIZZASS_JOBS_DIR)/symbols.txt
