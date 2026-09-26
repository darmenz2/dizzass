CC ?= cc
GENERAL135_DIR ?= build/general-monitor135$(if $(filter 1,$(SANITIZE)),-san,)
GENERAL135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135
GENERAL135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
GENERAL135_HEADERS = $(wildcard integration/*135.h)
GENERAL135_FAN = libbitmain/src/fan_ctrl.c reconstruction/support/pid_135.c
.PHONY: dizzass-general135-original dizzass-general135-test dizzass-general135-evidence
dizzass-general135-evidence:
	python3 integration/tests/check_general_monitor_evidence_135.py
$(GENERAL135_DIR):
	mkdir -p $@
$(GENERAL135_DIR)/libgeneral.so: src/backend/base.c $(GENERAL135_HEADERS) integration/general-monitor-135.mk | $(GENERAL135_DIR)
	$(CC) $(GENERAL135_FLAGS) -shared -fPIC $< -Wl,-z,defs -o $@
dizzass-general135-original: $(GENERAL135_DIR)/libgeneral.so dizzass-general135-evidence
	python3 integration/tests/test_general_monitor_135.py $< --summary $(GENERAL135_DIR)/original.json
$(GENERAL135_DIR)/native-test: src/backend/base.c integration/tests/test_general_monitor_135.c $(GENERAL135_HEADERS) $(GENERAL135_FAN) integration/general-monitor-135.mk | $(GENERAL135_DIR)
	$(CC) $(GENERAL135_FLAGS) $(GENERAL135_SAN) src/backend/base.c $(GENERAL135_FAN) integration/tests/test_general_monitor_135.c -lm -o $@
dizzass-general135-test: $(GENERAL135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
