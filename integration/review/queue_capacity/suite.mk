# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
QC11_DIR ?= build/queue-capacity
QC11_DEPS ?= .
QC11_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
QC11_FLAGS += -fno-pie -no-pie
endif
QC11_SOURCES = integration/review/queue_capacity/test.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/native/queued_work_tx.c integration/native/queue_step.c integration/rx_crc5.c $(QC11_DEPS)/integration/native_jobs.c $(QC11_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
QC11_OBJECTS = $(addprefix $(QC11_DIR)/,$(QC11_SOURCES:.c=.o))
$(QC11_DIR)/%.o: %.c integration/review/queue_capacity/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(QC11_DEPS) $(DIZZASS_NATIVE_CPP) $(QC11_FLAGS) -MMD -MP -c $< -o $@
$(QC11_DIR)/test: $(QC11_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(QC11_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=pthread_create,--wrap=dizzass_io_queue_enter,--wrap=dizzass_io_capacity,--wrap=get_queued,--wrap=work_completed,--wrap=dizzass_io_send_work,--wrap=submit_nonce,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce,--undefined=get_queued,--undefined=__get_queued,--undefined=work_completed -o $@ $(QC11_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: queue-capacity-test
queue-capacity-test: $(QC11_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(QC11_DIR)/test
-include $(QC11_OBJECTS:.o=.d)
# Expand inherited pkg-config substitutions BEFORE dropping link-only flags.
QC11_STRICT_CPP = $(filter-out -l% -L% -Wl%,$(shell printf '%s ' $(DIZZASS_NATIVE_CPP)))
.PHONY: queue-capacity-strict
queue-capacity-strict:
	$(CC) $(QC11_STRICT_CPP) $(QC11_FLAGS) -Wall -Wextra -Werror -c integration/native/queue_step.c -o build/r11-strict.o
