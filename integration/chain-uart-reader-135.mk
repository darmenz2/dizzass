# Offline comparison only; not included by production Makefile.am.
CC ?= cc
CHAIN_READER_DIR ?= build/chain-uart-reader-135
CHAIN_READER_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
CHAIN_READER_SRC = src/backend/work-gen/chain-uart-reader.c libbitmain/src/uart.c reconstruction/support/record_fifo.c
CHAIN_READER_HDR = integration/chain_uart_reader_135.h include/xminer/recovery/uart.h include/xminer/recovery/nonce_fifo.h
.PHONY: all evidence original native sanitize negative regressions
all: evidence original native
$(CHAIN_READER_DIR):
	mkdir -p $@
# Reuse the existing policy without pulling its unrelated nonce/SHA paths into
# this offline library: hidden function sections allow the linker to discard them.
$(CHAIN_READER_DIR)/policy.o: src/backend/work-gen/work-gen.c include/xminer/recovery/work_rx.h integration/chain-uart-reader-135.mk | $(CHAIN_READER_DIR)
	$(CC) $(CHAIN_READER_FLAGS) -O2 -fPIC -ffunction-sections -fdata-sections -fvisibility=hidden -c $< -o $@
$(CHAIN_READER_DIR)/policy-san.o: src/backend/work-gen/work-gen.c include/xminer/recovery/work_rx.h integration/chain-uart-reader-135.mk | $(CHAIN_READER_DIR)
	$(CC) $(CHAIN_READER_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -ffunction-sections -fdata-sections -fvisibility=hidden -c $< -o $@
$(CHAIN_READER_DIR)/libchainreader.so: $(CHAIN_READER_SRC) $(CHAIN_READER_HDR) $(CHAIN_READER_DIR)/policy.o integration/chain-uart-reader-135.mk | $(CHAIN_READER_DIR)
	$(CC) $(CHAIN_READER_FLAGS) -O2 -shared -fPIC $(CHAIN_READER_SRC) $(CHAIN_READER_DIR)/policy.o -Wl,--gc-sections,-z,defs -o $@
	nm --defined-only $@ > $(CHAIN_READER_DIR)/symbols.txt
	python3 -c "from pathlib import Path; s=Path('$(CHAIN_READER_DIR)/symbols.txt').read_text(); assert 'vn135_work_rx_policy_init' in s; assert 'vn135_sha256' not in s and 'vn135_work_nonce_' not in s; print('CHAIN_UART_POLICY_LINK_PASS policy=present nonce_sha=absent')"
$(CHAIN_READER_DIR)/native: $(CHAIN_READER_SRC) $(CHAIN_READER_HDR) $(CHAIN_READER_DIR)/policy.o integration/tests/test_chain_uart_reader_135.c | $(CHAIN_READER_DIR)
	$(CC) $(CHAIN_READER_FLAGS) -O2 $(CHAIN_READER_SRC) $(CHAIN_READER_DIR)/policy.o integration/tests/test_chain_uart_reader_135.c -Wl,--gc-sections -o $@
$(CHAIN_READER_DIR)/san: $(CHAIN_READER_SRC) $(CHAIN_READER_HDR) $(CHAIN_READER_DIR)/policy-san.o integration/tests/test_chain_uart_reader_135.c | $(CHAIN_READER_DIR)
	$(CC) $(CHAIN_READER_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(CHAIN_READER_SRC) $(CHAIN_READER_DIR)/policy-san.o integration/tests/test_chain_uart_reader_135.c -Wl,--gc-sections -o $@
evidence:
	python3 integration/tests/check_chain_uart_reader_evidence_135.py
original: $(CHAIN_READER_DIR)/libchainreader.so
	python3 integration/tests/test_chain_uart_reader_135.py $(CHAIN_READER_DIR)/libchainreader.so
native: $(CHAIN_READER_DIR)/native
	./$(CHAIN_READER_DIR)/native
sanitize: $(CHAIN_READER_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(CHAIN_READER_DIR)/san
negative: $(CHAIN_READER_DIR)/libchainreader.so
	python3 integration/tests/test_chain_uart_reader_negative_135.py $(CHAIN_READER_DIR)/negative --cc $(CC) --baseline $(CHAIN_READER_DIR)/libchainreader.so --policy $(CHAIN_READER_DIR)/policy.o
regressions: | $(CHAIN_READER_DIR)
	$(CC) $(CHAIN_READER_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(CHAIN_READER_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(CHAIN_READER_DIR)/libroute.so
	$(CC) $(CHAIN_READER_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(CHAIN_READER_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(CHAIN_READER_DIR)/route-bounds
	mkdir -p $(CHAIN_READER_DIR)/legacy/tests $(CHAIN_READER_DIR)/legacy/build
	cp tests/test_stage5_uart_differential.py tests/test_stage5_aml_uart_differential.py $(CHAIN_READER_DIR)/legacy/tests/
	python3 -c "from pathlib import Path; r=Path('$(CHAIN_READER_DIR)/legacy'); [(r/n).symlink_to(Path(n).resolve(),target_is_directory=True) for n in ('tools','reference') if not (r/n).exists()]"
	$(CC) $(CHAIN_READER_FLAGS) -O2 -shared -fPIC libbitmain/src/uart.c libbitmain/src/aml/chip.c -Wl,-z,defs -o $(CHAIN_READER_DIR)/legacy/build/libvn135_recovered.so
	python3 $(CHAIN_READER_DIR)/legacy/tests/test_stage5_uart_differential.py
	python3 $(CHAIN_READER_DIR)/legacy/tests/test_stage5_aml_uart_differential.py
	$(CC) $(CHAIN_READER_FLAGS) -O2 -shared -fPIC reconstruction/support/record_fifo.c reconstruction/support/nonce_fifo.c reconstruction/support/nonce_record_bridge.c -Wl,-z,defs -o $(CHAIN_READER_DIR)/libfifo.so
	cp tests/test_stage13_differential.py tests/nonce_fifo_oracle.py tests/nonce_oracle.py $(CHAIN_READER_DIR)/legacy/tests/
	VN135_TEST_LIBRARY=$(CHAIN_READER_DIR)/libfifo.so python3 $(CHAIN_READER_DIR)/legacy/tests/test_stage13_differential.py
