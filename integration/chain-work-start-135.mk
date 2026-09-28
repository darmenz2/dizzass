# Offline comparison only; not included by production Makefile.am.
CC ?= cc
CHAIN_START_DIR ?= build/chain-work-start-135
CHAIN_START_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
CHAIN_START_SRC = src/backend/work-gen/chain-work-start.c libbitmain/src/uart.c reconstruction/support/record_fifo.c
CHAIN_START_HDR = integration/chain_work_start_135.h integration/backend_shutdown_135.h include/xminer/recovery/uart.h include/xminer/recovery/nonce_fifo.h
.PHONY: all evidence original native sanitize negative regressions
all: evidence original native
$(CHAIN_START_DIR):
	mkdir -p $@
$(CHAIN_START_DIR)/libchainstart.so: $(CHAIN_START_SRC) $(CHAIN_START_HDR) integration/chain-work-start-135.mk | $(CHAIN_START_DIR)
	$(CC) $(CHAIN_START_FLAGS) -O2 -shared -fPIC $(CHAIN_START_SRC) -Wl,-z,defs -o $@
$(CHAIN_START_DIR)/native: $(CHAIN_START_SRC) $(CHAIN_START_HDR) integration/tests/test_chain_work_start_135.c | $(CHAIN_START_DIR)
	$(CC) $(CHAIN_START_FLAGS) -O2 $(CHAIN_START_SRC) integration/tests/test_chain_work_start_135.c -o $@
$(CHAIN_START_DIR)/san: $(CHAIN_START_SRC) $(CHAIN_START_HDR) integration/tests/test_chain_work_start_135.c | $(CHAIN_START_DIR)
	$(CC) $(CHAIN_START_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(CHAIN_START_SRC) integration/tests/test_chain_work_start_135.c -o $@
evidence:
	python3 integration/tests/check_chain_work_start_evidence_135.py
original: $(CHAIN_START_DIR)/libchainstart.so
	python3 integration/tests/test_chain_work_start_135.py $(CHAIN_START_DIR)/libchainstart.so
native: $(CHAIN_START_DIR)/native
	./$(CHAIN_START_DIR)/native
sanitize: $(CHAIN_START_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(CHAIN_START_DIR)/san
negative: $(CHAIN_START_DIR)/libchainstart.so
	python3 integration/tests/test_chain_work_start_negative_135.py $(CHAIN_START_DIR)/negative --cc $(CC) --baseline $(CHAIN_START_DIR)/libchainstart.so
regressions: | $(CHAIN_START_DIR)
	$(CC) $(CHAIN_START_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(CHAIN_START_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(CHAIN_START_DIR)/libroute.so
	$(CC) $(CHAIN_START_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(CHAIN_START_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(CHAIN_START_DIR)/route-bounds
	mkdir -p $(CHAIN_START_DIR)/legacy/tests $(CHAIN_START_DIR)/legacy/build
	cp tests/test_stage5_uart_differential.py tests/test_stage5_aml_uart_differential.py $(CHAIN_START_DIR)/legacy/tests/
	python3 -c "from pathlib import Path; r=Path('$(CHAIN_START_DIR)/legacy'); [(r/n).symlink_to(Path(n).resolve(),target_is_directory=True) for n in ('tools','reference') if not (r/n).exists()]"
	$(CC) $(CHAIN_START_FLAGS) -O2 -shared -fPIC libbitmain/src/uart.c libbitmain/src/aml/chip.c -Wl,-z,defs -o $(CHAIN_START_DIR)/legacy/build/libvn135_recovered.so
	python3 $(CHAIN_START_DIR)/legacy/tests/test_stage5_uart_differential.py
	python3 $(CHAIN_START_DIR)/legacy/tests/test_stage5_aml_uart_differential.py
	$(CC) $(CHAIN_START_FLAGS) -O2 -shared -fPIC reconstruction/support/record_fifo.c reconstruction/support/nonce_fifo.c reconstruction/support/nonce_record_bridge.c -Wl,-z,defs -o $(CHAIN_START_DIR)/libfifo.so
	cp tests/test_stage13_differential.py tests/nonce_fifo_oracle.py tests/nonce_oracle.py $(CHAIN_START_DIR)/legacy/tests/
	VN135_TEST_LIBRARY=$(CHAIN_START_DIR)/libfifo.so python3 $(CHAIN_START_DIR)/legacy/tests/test_stage13_differential.py
