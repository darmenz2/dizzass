# Opt-in host build. Accepted UART/parser/A-16 come from the CURRENT tree.
include integration/native-nonce.mk
CI8_DIR ?= build/rx-integrity
CI8_DEPS ?= .
CI8_FLAGS = $(DIZZASS_NONCE_FLAGS) -std=gnu11 -pthread -fno-builtin-strdup
ifeq ($(SANITIZE),1)
CI8_FLAGS += -fno-pie -no-pie
endif
CI8_SOURCES = integration/review/rx_integrity/test.c integration/native/rx_owner.c integration/native/io_lifecycle.c integration/rx_crc5.c $(CI8_DEPS)/integration/native_jobs.c $(CI8_DEPS)/integration/native/early_rx.c integration/native_nonce.c integration/native_work_tx88.c src/backend/work-gen/work-gen.c reconstruction/support/work_rx_stream.c integration/work_tx88.c integration/work_route.c integration/bm1368_control.c reconstruction/support/crc5.c integration/native/uart_safe.c integration/native/uart_posix.c integration/native/uart_channel.c integration/native/protocol_channel_tx.c integration/native/native_job_channel_tx.c
CI8_OBJECTS = $(addprefix $(CI8_DIR)/,$(CI8_SOURCES:.c=.o))
$(CI8_DIR)/%.o: %.c integration/review/rx_integrity/suite.mk config.h
	mkdir -p $(dir $@)
	$(CC) -I$(CI8_DEPS) $(DIZZASS_NATIVE_CPP) $(CI8_FLAGS) -MMD -MP -c $< -o $@
$(CI8_DIR)/test: $(CI8_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(CI8_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=read,--wrap=__read_chk,--wrap=poll,--wrap=__poll_chk,--wrap=eventfd,--wrap=pthread_create,--wrap=submit_nonce,--wrap=strdup,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init,--undefined=__wrap_strdup,--undefined=__wrap_read,--undefined=__wrap_poll,--undefined=__wrap___read_chk,--undefined=__wrap___poll_chk,--undefined=test_nonce -o $@ $(CI8_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: rx-integrity-test
rx-integrity-test: $(CI8_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 $(CI8_DIR)/test
-include $(CI8_OBJECTS:.o=.d)
