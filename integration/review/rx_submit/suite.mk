# Opt-in HOST test only. Existing native source is compiled from this candidate.
include integration/native-nonce.mk
R03_DIR ?= build/rx-submit
R03_DEPS ?= build/r02-deps
R03_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
R03_FLAGS += -fno-pie -no-pie
endif
R03_SOURCES = integration/review/rx_submit/test.c integration/native_jobs.c integration/native_nonce.c integration/native_work_tx88.c integration/native/early_rx.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c $(R03_DEPS)/integration/native/uart_safe.c $(R03_DEPS)/integration/native/uart_posix.c $(R03_DEPS)/integration/native/uart_channel.c $(R03_DEPS)/integration/native/protocol_channel_tx.c $(R03_DEPS)/integration/native/native_job_channel_tx.c
R03_OBJECTS = $(addprefix $(R03_DIR)/,$(R03_SOURCES:.c=.o))
$(R03_DIR)/%.o: %.c integration/review/rx_submit/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(R03_DEPS) $(DIZZASS_NATIVE_CPP) $(R03_FLAGS) -MMD -MP -c $< -o $@
$(R03_DIR)/test: $(R03_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(R03_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=submit_nonce,--wrap=write,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=test_nonce,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup -o $@ $(R03_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: rx-submit-test
rx-submit-test: $(R03_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $(R03_DIR)/test
-include $(R03_OBJECTS:.o=.d)

.PHONY: rx-submit-analyze
rx-submit-analyze:
	$(CC) --analyze $(DIZZASS_NATIVE_CPP) $(R03_FLAGS) -I$(R03_DEPS) -Xanalyzer -analyzer-output=text integration/native_jobs.c integration/native/early_rx.c
