CC ?= cc
FALL135_DIR ?= build/frequency-fall135$(if $(filter 1,$(SANITIZE)),-san,)
FALL135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135 -DVN135_BACKEND_SHUTDOWN_135 -DVN135_STOP_POLICY_135 -DVN135_EXIT_CLEANUP_135 -DVN135_RESCUE_STOP_135 -DVN135_VOLTAGE_STOP_135 -DVN135_MINING_STOP_135 -DVN135_FREQUENCY_FALL_135
FALL135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
FALL135_SOURCES = src/backend/base.c src/backend/volt-ctrl.c src/frontend/rescue.c
FALL135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-fall135-evidence dizzass-fall135-original dizzass-fall135-test dizzass-fall135-negative
$(FALL135_DIR):
	mkdir -p $@
$(FALL135_DIR)/libfall.so: $(FALL135_SOURCES) $(FALL135_HEADERS) integration/frequency-fall-135.mk | $(FALL135_DIR)
	$(CC) $(FALL135_FLAGS) -shared -fPIC $(FALL135_SOURCES) -Wl,-z,defs -o $@
dizzass-fall135-evidence:
	python3 integration/tests/check_frequency_fall_evidence_135.py
dizzass-fall135-original: $(FALL135_DIR)/libfall.so dizzass-fall135-evidence
	python3 integration/tests/test_frequency_fall_135.py $< --summary $(FALL135_DIR)/original.json
	python3 integration/tests/test_frequency_fall_nested_135.py $< --summary $(FALL135_DIR)/nested.json
$(FALL135_DIR)/mining_stop_fixture_135.inc: integration/tests/test_mining_stop_135.c | $(FALL135_DIR)
	python3 -c 'from pathlib import Path; s=Path("$<").read_text(); assert s.count("int main(void)")==1; Path("$@").write_text(s.replace("int main(void)","int mining_stop_fixture_main(void)"))'
$(FALL135_DIR)/native-test: $(FALL135_DIR)/mining_stop_fixture_135.inc  $(FALL135_SOURCES) integration/tests/test_frequency_fall_135.c integration/tests/test_mining_stop_135.c integration/tests/test_exit_cleanup_135.c integration/tests/stop_policy_bridge_135.c $(FALL135_HEADERS) integration/frequency-fall-135.mk | $(FALL135_DIR)
	$(CC) $(FALL135_FLAGS) -Iintegration/tests -I$(FALL135_DIR) $(FALL135_SAN) $(FALL135_SOURCES) integration/tests/test_frequency_fall_135.c integration/tests/stop_policy_bridge_135.c -o $@
dizzass-fall135-test: $(FALL135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-fall135-negative:
	python3 integration/tests/test_frequency_fall_negative_135.py --cc $(CC) --out $(FALL135_DIR)/negative
