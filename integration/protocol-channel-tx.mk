CC ?= cc
PT_DIR ?= build/protocol-channel-tx
PT_DEPS ?= build/a15-deps
PT_SOURCE ?= integration/native/protocol_channel_tx.c
PT_FLAGS = -I$(PT_DEPS) -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -pthread $(CFLAGS)
ifeq ($(SANITIZE),1)
PT_FLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer
endif
ifeq ($(SANITIZE),thread)
PT_FLAGS += -fsanitize=thread -fno-omit-frame-pointer
endif
PT_INPUT = $(PT_SOURCE) $(PT_DEPS)/integration/native/uart_channel.c $(PT_DEPS)/integration/native/uart_posix.c $(PT_DEPS)/integration/native/uart_safe.c integration/bm1368_control.c integration/work_tx88.c integration/work_route.c reconstruction/support/crc5.c
PT_HEADERS = integration/native/protocol_channel_tx.h $(wildcard $(PT_DEPS)/integration/native/*.h) integration/bm1368_control.h integration/work_tx88.h integration/work_route.h
.PHONY: protocol-tx-check protocol-tx-test protocol-tx-negative
protocol-tx-check:
	python3 tools/prepare_protocol_channel_tx.py --out $(PT_DEPS) --check
$(PT_DIR):
	mkdir -p $@
$(PT_DIR)/control: $(PT_INPUT) $(PT_HEADERS) integration/tests/test_protocol_channel_tx.c integration/protocol-channel-tx.mk | protocol-tx-check $(PT_DIR)
	$(CC) $(PT_FLAGS) $(PT_INPUT) integration/tests/test_protocol_channel_tx.c -Wl,--wrap=dizzass_uart_posix_write_all,--wrap=dizzass_uart_posix_now_ms -o $@
$(PT_DIR)/pty: $(PT_INPUT) $(PT_HEADERS) integration/tests/test_protocol_channel_tx_pty.c integration/protocol-channel-tx.mk | protocol-tx-check $(PT_DIR)
	$(CC) $(PT_FLAGS) $(PT_INPUT) integration/tests/test_protocol_channel_tx_pty.c -Wl,--wrap=write -lutil -o $@
protocol-tx-test: $(PT_DIR)/control $(PT_DIR)/pty
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(PT_DIR)/control
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(PT_DIR)/pty
protocol-tx-negative: protocol-tx-check
	python3 integration/tests/test_protocol_channel_tx_negative.py --cc $(CC) --deps $(PT_DEPS) --out $(PT_DIR)/negative
