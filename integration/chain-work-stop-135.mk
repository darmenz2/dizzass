# Offline comparison only; not included by production Makefile.am.
CC ?= cc
CHAIN_STOP_DIR ?= build/chain-work-stop-135
CHAIN_STOP_FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
CHAIN_STOP_SRC = src/backend/work-gen/chain-work-stop.c libbitmain/src/uart.c
CHAIN_STOP_HDR = integration/chain_work_stop_135.h integration/backend_shutdown_135.h include/xminer/recovery/uart.h
.PHONY: all evidence original native sanitize negative regressions
all: evidence original native
$(CHAIN_STOP_DIR):
	mkdir -p $@
$(CHAIN_STOP_DIR)/libchainstop.so: $(CHAIN_STOP_SRC) $(CHAIN_STOP_HDR) integration/chain-work-stop-135.mk | $(CHAIN_STOP_DIR)
	$(CC) $(CHAIN_STOP_FLAGS) -O2 -shared -fPIC $(CHAIN_STOP_SRC) -Wl,-z,defs -o $@
$(CHAIN_STOP_DIR)/native: $(CHAIN_STOP_SRC) $(CHAIN_STOP_HDR) integration/tests/test_chain_work_stop_135.c | $(CHAIN_STOP_DIR)
	$(CC) $(CHAIN_STOP_FLAGS) -O2 $(CHAIN_STOP_SRC) integration/tests/test_chain_work_stop_135.c -o $@
$(CHAIN_STOP_DIR)/san: $(CHAIN_STOP_SRC) $(CHAIN_STOP_HDR) integration/tests/test_chain_work_stop_135.c | $(CHAIN_STOP_DIR)
	$(CC) $(CHAIN_STOP_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(CHAIN_STOP_SRC) integration/tests/test_chain_work_stop_135.c -o $@
evidence:
	python3 integration/tests/check_chain_work_stop_evidence_135.py
original: $(CHAIN_STOP_DIR)/libchainstop.so
	python3 integration/tests/test_chain_work_stop_135.py $(CHAIN_STOP_DIR)/libchainstop.so
native: $(CHAIN_STOP_DIR)/native
	./$(CHAIN_STOP_DIR)/native
sanitize: $(CHAIN_STOP_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(CHAIN_STOP_DIR)/san
negative: $(CHAIN_STOP_DIR)/libchainstop.so
	python3 integration/tests/test_chain_work_stop_negative_135.py $(CHAIN_STOP_DIR)/negative --cc $(CC) --baseline $(CHAIN_STOP_DIR)/libchainstop.so
regressions: | $(CHAIN_STOP_DIR)
	$(CC) $(CHAIN_STOP_FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(CHAIN_STOP_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(CHAIN_STOP_DIR)/libroute.so
	$(CC) $(CHAIN_STOP_FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie integration/work_route.c integration/work_tx88.c integration/tests/test_work_route_bounds.c -o $(CHAIN_STOP_DIR)/route-bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(CHAIN_STOP_DIR)/route-bounds
	mkdir -p $(CHAIN_STOP_DIR)/legacy/tests $(CHAIN_STOP_DIR)/legacy/build
	cp tests/test_stage5_uart_differential.py tests/test_stage5_aml_uart_differential.py $(CHAIN_STOP_DIR)/legacy/tests/
	python3 -c "from pathlib import Path; r=Path('$(CHAIN_STOP_DIR)/legacy'); [(r/n).symlink_to(Path(n).resolve(),target_is_directory=True) for n in ('tools','reference') if not (r/n).exists()]"
	$(CC) $(CHAIN_STOP_FLAGS) -O2 -shared -fPIC libbitmain/src/uart.c libbitmain/src/aml/chip.c -Wl,-z,defs -o $(CHAIN_STOP_DIR)/legacy/build/libvn135_recovered.so
	python3 $(CHAIN_STOP_DIR)/legacy/tests/test_stage5_uart_differential.py
	python3 $(CHAIN_STOP_DIR)/legacy/tests/test_stage5_aml_uart_differential.py
