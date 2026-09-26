CC ?= cc
EXIT135_DIR ?= build/exit-cleanup135$(if $(filter 1,$(SANITIZE)),-san,)
EXIT135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135
EXIT135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
EXIT135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-exit135-evidence dizzass-exit135-original dizzass-exit135-test dizzass-exit135-negative
$(EXIT135_DIR):
	mkdir -p $@
$(EXIT135_DIR)/libexit.so: src/backend/base.c $(EXIT135_HEADERS) integration/exit-cleanup-135.mk | $(EXIT135_DIR)
	$(CC) $(EXIT135_FLAGS) -shared -fPIC src/backend/base.c -Wl,-z,defs -o $@
dizzass-exit135-evidence:
	python3 integration/tests/check_exit_cleanup_evidence_135.py
dizzass-exit135-original: $(EXIT135_DIR)/libexit.so dizzass-exit135-evidence
	python3 integration/tests/test_exit_cleanup_135.py $< --summary $(EXIT135_DIR)/original.json
$(EXIT135_DIR)/native-test: src/backend/base.c integration/tests/test_exit_cleanup_135.c integration/tests/stop_policy_bridge_135.c $(EXIT135_HEADERS) integration/exit-cleanup-135.mk | $(EXIT135_DIR)
	$(CC) $(EXIT135_FLAGS) $(EXIT135_SAN) src/backend/base.c integration/tests/test_exit_cleanup_135.c integration/tests/stop_policy_bridge_135.c -o $@
dizzass-exit135-test: $(EXIT135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-exit135-negative:
	python3 integration/tests/test_exit_cleanup_negative_135.py --cc $(CC) --out $(EXIT135_DIR)/negative
