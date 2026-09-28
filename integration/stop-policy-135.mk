CC ?= cc
STOP135_DIR ?= build/stop-policy135$(if $(filter 1,$(SANITIZE)),-san,)
STOP135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135
STOP135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
STOP135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-stop135-evidence dizzass-stop135-original dizzass-stop135-test
$(STOP135_DIR):
	mkdir -p $@
$(STOP135_DIR)/libstop.so: src/backend/base.c integration/tests/stop_policy_bridge_135.c $(STOP135_HEADERS) integration/stop-policy-135.mk | $(STOP135_DIR)
	$(CC) $(STOP135_FLAGS) -shared -fPIC src/backend/base.c integration/tests/stop_policy_bridge_135.c -Wl,-z,defs -o $@
dizzass-stop135-evidence:
	python3 integration/tests/check_stop_policy_evidence_135.py
dizzass-stop135-original: $(STOP135_DIR)/libstop.so dizzass-stop135-evidence
	python3 integration/tests/test_stop_policy_135.py $< --summary $(STOP135_DIR)/original.json
$(STOP135_DIR)/native-test: src/backend/base.c integration/tests/test_stop_policy_135.c $(STOP135_HEADERS) integration/stop-policy-135.mk | $(STOP135_DIR)
	$(CC) $(STOP135_FLAGS) $(STOP135_SAN) src/backend/base.c integration/tests/test_stop_policy_135.c -lm -o $@
dizzass-stop135-test: $(STOP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
