# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
N15_DIR ?= build/null-driver
N15_DEPS ?= .
N15_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
N15_FLAGS += -fno-pie -no-pie
endif
N15_SOURCES = integration/review/null_driver/test.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/native/queued_work_tx.c integration/native/queue_step.c integration/native/queue_callback.c integration/rx_crc5.c $(N15_DEPS)/integration/native_jobs.c $(N15_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
N15_OBJECTS = $(addprefix $(N15_DIR)/,$(N15_SOURCES:.c=.o))
$(N15_DIR)/%.o: %.c integration/review/null_driver/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(N15_DEPS) $(DIZZASS_NATIVE_CPP) $(N15_FLAGS) -MMD -MP -c $< -o $@
$(N15_DIR)/test: $(N15_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(N15_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=pthread_create,--wrap=dizzass_io_queue_enter,--wrap=get_queued,--wrap=work_completed,--wrap=dizzass_io_send_work,--wrap=dizzass_queued_work_step,--wrap=pthread_cond_timedwait,--wrap=submit_nonce,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce,--undefined=get_work,--undefined=get_queued,--undefined=__get_queued,--undefined=work_completed,--undefined=copy_work_noffset,--undefined=submit_nonce,--undefined=null_device_drv,--undefined=fill_device_drv,--undefined=copy_drv -o $@ $(N15_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: null-driver-test
null-driver-test: $(N15_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(N15_DIR)/test
-include $(N15_OBJECTS:.o=.d)
