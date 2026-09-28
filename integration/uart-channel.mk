CC ?= cc
UC_DIR ?= build/uart-channel
UC_DEPS ?= build/a14-deps
UC_SOURCE ?= integration/native/uart_channel.c
UC_FLAGS = -I. -I$(UC_DEPS) -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -pthread $(CFLAGS)
ifeq ($(SANITIZE),1)
UC_FLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer
endif
ifeq ($(SANITIZE),thread)
UC_FLAGS += -fsanitize=thread -fno-omit-frame-pointer
endif
UC_INPUT = $(UC_SOURCE) $(UC_DEPS)/integration/native/uart_posix.c $(UC_DEPS)/integration/native/uart_safe.c
UC_HEADERS = integration/native/uart_channel.h $(UC_DEPS)/integration/native/uart_posix.h $(UC_DEPS)/integration/native/uart_safe.h
UC_WRAP = -Wl,--wrap=dizzass_uart_posix_write_all,--wrap=dizzass_uart_posix_now_ms,--wrap=pthread_condattr_setclock,--wrap=pthread_cond_init,--wrap=pthread_cond_timedwait
.PHONY: uart-channel-check uart-channel-test uart-channel-negative
uart-channel-check:
	python3 tools/prepare_uart_channel.py --out $(UC_DEPS) --check
$(UC_DIR):
	mkdir -p $@
$(UC_DIR)/control: $(UC_INPUT) $(UC_HEADERS) integration/tests/test_uart_channel.c integration/uart-channel.mk | uart-channel-check $(UC_DIR)
	$(CC) $(UC_FLAGS) $(UC_INPUT) integration/tests/test_uart_channel.c $(UC_WRAP) -o $@
$(UC_DIR)/pty: $(UC_INPUT) $(UC_HEADERS) integration/tests/test_uart_channel_pty.c integration/uart-channel.mk | uart-channel-check $(UC_DIR)
	$(CC) $(UC_FLAGS) $(UC_INPUT) integration/tests/test_uart_channel_pty.c -Wl,--wrap=write -lutil -o $@
uart-channel-test: $(UC_DIR)/control $(UC_DIR)/pty
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(UC_DIR)/control
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(UC_DIR)/pty
uart-channel-negative: uart-channel-check
	python3 integration/tests/test_uart_channel_negative.py --cc $(CC) --deps $(UC_DEPS) --out $(UC_DIR)/negative
