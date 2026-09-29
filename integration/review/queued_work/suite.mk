# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
Q09_DIR ?= build/queued-work
Q09_DEPS ?= .
Q09_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
Q09_FLAGS += -fno-pie -no-pie
endif
Q09_SOURCES = integration/review/queued_work/test.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/native/queued_work_tx.c integration/rx_crc5.c $(Q09_DEPS)/integration/native_jobs.c $(Q09_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
Q09_OBJECTS = $(addprefix $(Q09_DIR)/,$(Q09_SOURCES:.c=.o))
$(Q09_DIR)/%.o: %.c integration/review/queued_work/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(Q09_DEPS) $(DIZZASS_NATIVE_CPP) $(Q09_FLAGS) -MMD -MP -c $< -o $@
$(Q09_DIR)/test: $(Q09_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(Q09_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=pthread_create,--wrap=dizzass_io_queue_enter,--wrap=get_queued,--wrap=work_completed,--wrap=dizzass_io_send_work,--wrap=submit_nonce,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce,--undefined=get_queued,--undefined=__get_queued,--undefined=work_completed -o $@ $(Q09_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: queued-work-test
queued-work-test: $(Q09_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(Q09_DIR)/test
-include $(Q09_OBJECTS:.o=.d)
# Expand inherited pkg-config substitutions BEFORE dropping link-only flags.
Q09_STRICT_CPP = $(filter-out -l% -L% -Wl%,$(shell printf '%s ' $(DIZZASS_NATIVE_CPP)))
.PHONY: queued-work-strict
queued-work-strict:
	$(CC) $(Q09_STRICT_CPP) $(Q09_FLAGS) -Wall -Wextra -Werror -c integration/native/queued_work_tx.c -o build/r09-strict.o
