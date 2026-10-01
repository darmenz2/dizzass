# Opt-in HOST test only. Existing native source is compiled from this candidate.
include integration/native-nonce.mk
RXQ_DIR ?= build/early-rx
RXQ_DEPS ?= build/r02-deps
RXQ_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
RXQ_FLAGS += -fno-pie -no-pie
endif
RXQ_SOURCES = integration/review/early_rx/test.c integration/native_jobs.c integration/native_nonce.c integration/native_work_tx88.c integration/native/early_rx.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c $(RXQ_DEPS)/integration/native/uart_safe.c $(RXQ_DEPS)/integration/native/uart_posix.c $(RXQ_DEPS)/integration/native/uart_channel.c $(RXQ_DEPS)/integration/native/protocol_channel_tx.c $(RXQ_DEPS)/integration/native/native_job_channel_tx.c
RXQ_OBJECTS = $(addprefix $(RXQ_DIR)/,$(RXQ_SOURCES:.c=.o))
$(RXQ_DIR)/%.o: %.c integration/review/early_rx/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(RXQ_DEPS) $(DIZZASS_NATIVE_CPP) $(RXQ_FLAGS) -MMD -MP -c $< -o $@
$(RXQ_DIR)/test: $(RXQ_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(RXQ_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup -o $@ $(RXQ_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: early-rx-test
early-rx-test: $(RXQ_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $(RXQ_DIR)/test
-include $(RXQ_OBJECTS:.o=.d)
