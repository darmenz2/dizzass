CC ?= cc
UART_SAFE_DIR ?= build/uart-safe$(if $(filter 1,$(SANITIZE)),-san,)
UART_SAFE_FLAGS = -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror
# Non-PIE only for this host sanitizer harness: Clang 14 PIE/ASan also crashes
# intermittently with an empty main on the local WSL kernel. No production flags.
UART_SAFE_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer -fno-pie -no-pie,)
UART_SAFE_SRC = integration/native/uart_safe.c
UART_SAFE_FIXTURE = libbitmain/src/chip/chip1398.c libbitmain/src/aml/chip.c libbitmain/src/reg_cache.c reconstruction/support/crc5.c
.PHONY: uart-safe-test uart-safe-negative
$(UART_SAFE_DIR):
	mkdir -p $@
$(UART_SAFE_DIR)/test: $(UART_SAFE_SRC) integration/native/uart_safe.h integration/tests/test_uart_safe.c $(UART_SAFE_FIXTURE) $(wildcard include/xminer/recovery/*.h) reconstruction/data/reg_cache_defaults.inc integration/uart-safe.mk | $(UART_SAFE_DIR)
	$(CC) $(UART_SAFE_FLAGS) $(UART_SAFE_SAN) $(UART_SAFE_SRC) $(UART_SAFE_FIXTURE) integration/tests/test_uart_safe.c -o $@
uart-safe-test: $(UART_SAFE_DIR)/test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 30 $<
uart-safe-negative:
	python3 integration/tests/test_uart_safe_negative.py --cc $(CC) --out $(UART_SAFE_DIR)/negative
