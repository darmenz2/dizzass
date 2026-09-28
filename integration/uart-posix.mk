CC ?= cc
UP_DIR ?= build/uart-posix$(if $(filter 1,$(SANITIZE)),-san,)
UP_DEPS ?= build/a13-deps
UP_SOURCE ?= integration/native/uart_posix.c
CPPFLAGS += -I. -Iinclude -I$(UP_DEPS)
UP_FLAGS = -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror
ifeq ($(SANITIZE),1)
UP_FLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer
endif
UP_INPUT = $(UP_SOURCE) $(UP_DEPS)/integration/native/uart_safe.c
UP_HEADERS = integration/native/uart_posix.h $(UP_DEPS)/integration/native/uart_safe.h
UP_WRAP = -Wl,--wrap=fcntl,--wrap=tcgetattr,--wrap=clock_gettime,--wrap=write,--wrap=poll
.PHONY: uart-posix-check uart-posix-test uart-posix-negative
uart-posix-check:
	python3 tools/prepare_uart_posix.py --out $(UP_DEPS) --check
$(UP_DIR):
	mkdir -p $@
$(UP_DIR)/unit: $(UP_INPUT) $(UP_HEADERS) integration/tests/test_uart_posix.c integration/uart-posix.mk | uart-posix-check $(UP_DIR)
	$(CC) $(CPPFLAGS) $(UP_FLAGS) $(UP_INPUT) integration/tests/test_uart_posix.c $(UP_WRAP) -o $@
$(UP_DIR)/pty: $(UP_INPUT) $(UP_HEADERS) integration/tests/test_uart_posix_pty.c integration/bm1368_control.c reconstruction/support/crc5.c integration/uart-posix.mk | uart-posix-check $(UP_DIR)
	$(CC) $(CPPFLAGS) $(UP_FLAGS) $(UP_INPUT) integration/tests/test_uart_posix_pty.c integration/bm1368_control.c reconstruction/support/crc5.c -Wl,--wrap=write,--wrap=poll -pthread -lutil -o $@
uart-posix-test: uart-posix-check $(UP_DIR)/unit $(UP_DIR)/pty
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(UP_DIR)/unit
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 $(UP_DIR)/pty
uart-posix-negative: uart-posix-check
	python3 integration/tests/test_uart_posix_negative.py --cc $(CC) --deps $(UP_DEPS) --out $(UP_DIR)/negative
