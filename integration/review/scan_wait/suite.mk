# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
S17_DIR ?= build/scan-wait
S17_DEPS ?= .
S17_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
S17_FLAGS += -fno-pie -no-pie
endif
S17_SOURCES = integration/review/scan_wait/test.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/native/queued_work_tx.c integration/native/queue_step.c integration/native/scan_wait.c integration/native/queue_callback.c integration/native/native_io_stop.c integration/rx_crc5.c $(S17_DEPS)/integration/native_jobs.c $(S17_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
S17_OBJECTS = $(addprefix $(S17_DIR)/,$(S17_SOURCES:.c=.o))
$(S17_DIR)/%.o: %.c integration/review/scan_wait/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(S17_DEPS) $(DIZZASS_NATIVE_CPP) $(S17_FLAGS) -MMD -MP -c $< -o $@
$(S17_DIR)/test: $(S17_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(S17_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=_cgsem_wait,--wrap=pthread_cond_broadcast,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=pthread_create,--wrap=dizzass_io_queue_enter,--wrap=get_queued,--wrap=work_completed,--wrap=dizzass_io_send_work,--wrap=dizzass_queued_work_step,--wrap=pthread_cond_timedwait,--wrap=submit_nonce,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce,--undefined=get_work,--undefined=get_queued,--undefined=__get_queued,--undefined=work_completed,--undefined=copy_work_noffset,--undefined=submit_nonce -o $@ $(S17_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: scan-wait-test
scan-wait-test: $(S17_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(S17_DIR)/test
-include $(S17_OBJECTS:.o=.d)
# Expand inherited pkg-config substitutions BEFORE dropping link-only flags.
S17_STRICT_FLAGS = $(filter-out -l% -L% -Wl% -no-pie,$(shell printf '%s ' $(DIZZASS_NATIVE_CPP) $(S17_FLAGS)))
.PHONY: scan-wait-strict
scan-wait-strict:
	$(CC) $(S17_STRICT_FLAGS) -Wall -Wextra -Werror -c integration/native/scan_wait.c -o build/r17-strict.o
