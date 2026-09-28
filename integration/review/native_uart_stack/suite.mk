# Offline review harness; never added to production Makefile.am.
include integration/native-nonce.mk
R01_DIR ?= build/r01-test
R01_DEPS ?= build/r01-deps
R01_FLAGS = $(DIZZASS_NONCE_FLAGS) -pthread
# Host-only sanitizer executables: WSL Clang14 PIE runtime also crashed on empty main.
ifeq ($(SANITIZE),1)
R01_FLAGS += -fno-pie -no-pie
endif
R01_OBJECTS = $(R01_DIR)/test.o $(R01_DIR)/jobs.o $(R01_DIR)/nonce.o $(R01_DIR)/native_tx.o $(R01_DIR)/rx.o $(R01_DIR)/stream.o $(R01_DIR)/encode.o $(R01_DIR)/route.o $(R01_DIR)/commands.o $(R01_DIR)/crc.o $(R01_DIR)/safe.o $(R01_DIR)/posix.o $(R01_DIR)/channel.o $(R01_DIR)/protocol.o
$(R01_DIR):
	mkdir -p $@
$(R01_DIR)/test.o: integration/review/native_uart_stack/test_stack.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/jobs.o: integration/native_jobs.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/nonce.o: integration/native_nonce.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/native_tx.o: integration/native_work_tx88.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/rx.o: src/backend/work-gen/work-gen.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/stream.o: reconstruction/support/work_rx_stream.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/encode.o: integration/work_tx88.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/route.o: integration/work_route.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/commands.o: integration/bm1368_control.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/crc.o: reconstruction/support/crc5.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/safe.o: $(R01_DEPS)/integration/native/uart_safe.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/posix.o: $(R01_DEPS)/integration/native/uart_posix.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/channel.o: $(R01_DEPS)/integration/native/uart_channel.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/protocol.o: $(R01_DEPS)/integration/native/protocol_channel_tx.c config.h integration/review/native_uart_stack/suite.mk | $(R01_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(R01_FLAGS) -I$(R01_DEPS) -std=gnu11 -c $< -o $@
$(R01_DIR)/test: $(R01_OBJECTS) $(DIZZASS_CORE_OTHER)
	$(CC) $(R01_FLAGS) $(cgminer_LDFLAGS) $(LDFLAGS) -Wl,--gc-sections,--wrap=write,--wrap=socket,--wrap=connect,--wrap=libusb_init,--undefined=__wrap_socket,--undefined=__wrap_connect,--undefined=__wrap_libusb_init -o $@ $(R01_OBJECTS) $(DIZZASS_CORE_OTHER) $(cgminer_LDADD) $(LIBS) -lutil
.PHONY: r01-test
r01-test: $(R01_DIR)/test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 30 $(R01_DIR)/test
