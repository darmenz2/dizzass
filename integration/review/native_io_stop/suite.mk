# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
S16_DIR ?= build/native-io-stop
S16_DEPS ?= .
S16_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
S16_FLAGS += -fno-pie -no-pie
endif
S16_SOURCES = integration/review/native_io_stop/test.c integration/native/native_io_stop.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/native/queued_work_tx.c integration/native/queue_step.c integration/native/queue_callback.c integration/rx_crc5.c $(S16_DEPS)/integration/native_jobs.c $(S16_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
S16_OBJECTS = $(addprefix $(S16_DIR)/,$(S16_SOURCES:.c=.o))
$(S16_DIR)/%.o: %.c integration/review/native_io_stop/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(S16_DEPS) $(DIZZASS_NATIVE_CPP) $(S16_FLAGS) -MMD -MP -c $< -o $@
$(S16_DIR)/test: $(S16_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(S16_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=_cgsem_wait,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=dizzass_io_request_stop,--wrap=dizzass_io_stop,--wrap=pthread_create,--wrap=dizzass_io_queue_enter,--wrap=get_queued,--wrap=work_completed,--wrap=dizzass_io_send_work,--wrap=dizzass_queued_work_step,--wrap=pthread_cond_timedwait,--wrap=submit_nonce,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce,--undefined=get_work,--undefined=get_queued,--undefined=__get_queued,--undefined=work_completed,--undefined=copy_work_noffset,--undefined=submit_nonce -o $@ $(S16_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: native-io-stop-test
native-io-stop-test: $(S16_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(S16_DIR)/test
-include $(S16_OBJECTS:.o=.d)

# Compile-only: expand inherited pkg-config flags, retaining pthread/FORTIFY.
S16_STRICT_FLAGS = $(filter-out -l% -L% -Wl% -no-pie,$(shell printf '%s ' $(DIZZASS_NATIVE_CPP) $(S16_FLAGS)))
.PHONY: native-io-stop-strict
native-io-stop-strict:
	$(CC) $(S16_STRICT_FLAGS) -Wall -Wextra -Werror -c integration/native/native_io_stop.c -o build/r16-strict.o
