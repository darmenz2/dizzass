# Run after configuring/building the actual native core. No production linkage.
include integration/native-nonce.mk
NJ_DIR ?= build/native-job-channel
NJ_DEPS ?= build/a16-deps
NJ_BINDING ?= $(NJ_DIR)/binding.o
NJ_CONTROL ?= $(NJ_DIR)/control
NJ_SOURCE ?= integration/native/native_job_channel_tx.c
NJ_FLAGS = -I$(NJ_DEPS) -I. -Iinclude -std=gnu11 -O1 -g -fcommon -ffunction-sections -fdata-sections -fno-builtin-strdup -pthread
ifeq ($(SANITIZE),1)
NJ_FLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer
endif
NJ_WARN = -Wall -Wextra -Werror $(if $(findstring clang,$(CC)),-Wno-error=unused-command-line-argument,)
NJ_WRAP = -Wl,--wrap=socket,--wrap=connect,--wrap=libusb_init,--wrap=strdup -Wl,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init
NJ_CONTROL_WRAP = -Wl,--wrap=dizzass_uart_posix_write_all,--wrap=dizzass_uart_posix_now_ms,--wrap=dizzass_jobs_finish
NJ_INPUTS = integration/native_jobs.c integration/native_work_tx88.c integration/native_nonce.c integration/work_route.c integration/work_tx88.c integration/bm1368_control.c reconstruction/support/crc5.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c
NJ_DEP_INPUTS = uart_channel uart_posix uart_safe protocol_channel_tx
NJ_OBJS = $(NJ_BINDING) $(foreach s,$(NJ_INPUTS),$(NJ_DIR)/$(subst /,_,$(s)).o) $(foreach s,$(NJ_DEP_INPUTS),$(NJ_DIR)/$(s).o)
.PHONY: native-job-check native-job-test native-job-negative
native-job-check:
	python3 tools/prepare_native_job_channel.py --out $(NJ_DEPS) --check
$(NJ_DIR):
	mkdir -p $@
$(NJ_BINDING): $(NJ_SOURCE) integration/native/native_job_channel_tx.h integration/native-job-channel-tx.mk | native-job-check $(NJ_DIR)
	$(CC) $(NJ_FLAGS) $(NJ_WARN) -c $(NJ_SOURCE) -o $@
define NJ_RULE
$(NJ_DIR)/$(subst /,_,$(1)).o: $(1) integration/native-job-channel-tx.mk | native-job-check $(NJ_DIR)
	$$(CC) $$(DIZZASS_NATIVE_CPP) $$(NJ_FLAGS) -c $(1) -o $$@
endef
$(foreach s,$(NJ_INPUTS),$(eval $(call NJ_RULE,$(s))))
$(NJ_DIR)/%.o: $(NJ_DEPS)/integration/native/%.c integration/native-job-channel-tx.mk | native-job-check $(NJ_DIR)
	$(CC) $(NJ_FLAGS) $(NJ_WARN) -c $< -o $@
$(NJ_DIR)/control.o: integration/tests/test_native_job_channel_tx.c integration/tests/native_job_channel_cases.h integration/native/native_job_channel_tx.h cgminer.c config.h integration/native-job-channel-tx.mk | native-job-check $(NJ_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(NJ_FLAGS) -DNJ_CONTROL -c $< -o $@
$(NJ_DIR)/pty.o: integration/tests/test_native_job_channel_tx.c integration/tests/native_job_channel_cases.h integration/native/native_job_channel_tx.h cgminer.c config.h integration/native-job-channel-tx.mk | native-job-check $(NJ_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(NJ_FLAGS) -c $< -o $@
$(NJ_CONTROL): $(NJ_DIR)/control.o $(NJ_OBJS) $(DIZZASS_CORE_OTHER)
	$(CC) $(NJ_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections $(NJ_WRAP) $(NJ_CONTROL_WRAP) -o $@ $^ $(cgminer_LDADD) $(LIBS) -lutil
$(NJ_DIR)/pty: $(NJ_DIR)/pty.o $(NJ_OBJS) $(DIZZASS_CORE_OTHER)
	$(CC) $(NJ_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections $(NJ_WRAP) -Wl,--wrap=write -o $@ $^ $(cgminer_LDADD) $(LIBS) -lutil
native-job-test: native-job-check $(NJ_DIR)/control $(NJ_DIR)/pty
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(NJ_DIR)/control
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(NJ_DIR)/pty
	nm --defined-only $(NJ_DIR)/control > $(NJ_DIR)/symbols.txt
	python3 integration/tests/test_native_job_channel_negative.py --symbols $(NJ_DIR)/symbols.txt
native-job-negative: native-job-test
	python3 integration/tests/test_native_job_channel_negative.py --cc $(CC) --deps $(NJ_DEPS) --build $(NJ_DIR)
