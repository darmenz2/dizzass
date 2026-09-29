# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
DS7_DIR ?= build/device-stop
DS7_DEPS ?= .
DS7_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
DS7_FLAGS += -fno-pie -no-pie
endif
DS7_SOURCES = integration/review/device_stop/test.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/native/io_stop_many.c $(DS7_DEPS)/integration/native_jobs.c $(DS7_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
DS7_OBJECTS = $(addprefix $(DS7_DIR)/,$(DS7_SOURCES:.c=.o))
$(DS7_DIR)/%.o: %.c integration/review/device_stop/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(DS7_DEPS) $(DIZZASS_NATIVE_CPP) $(DS7_FLAGS) -MMD -MP -c $< -o $@
$(DS7_DIR)/test: $(DS7_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(DS7_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=pthread_create,--wrap=submit_nonce,--wrap=dizzass_io_request_stop,--wrap=dizzass_io_stop,--wrap=dizzass_jobs_finish,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce -o $@ $(DS7_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: device-stop-test
device-stop-test: $(DS7_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(DS7_DIR)/test
-include $(DS7_OBJECTS:.o=.d)
