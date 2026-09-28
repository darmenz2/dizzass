CC ?= cc
SETUP135_DIR ?= build/temperature-setup135$(if $(filter 1,$(SANITIZE)),-san,)
SETUP135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_GENERAL_MONITOR_135 -DVN135_MONITOR_HANDLERS_135
SETUP135_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
SETUP135_SOURCE = src/backend/temperature-setup.c src/backend/base.c
SETUP135_HEADERS = $(wildcard integration/*135.h)
.PHONY: dizzass-setup135-evidence dizzass-setup135-original dizzass-setup135-test dizzass-setup135-negative
$(SETUP135_DIR):
	mkdir -p $@
$(SETUP135_DIR)/libsetup.so: $(SETUP135_SOURCE) $(SETUP135_HEADERS) integration/temperature-setup-135.mk | $(SETUP135_DIR)
	$(CC) $(SETUP135_FLAGS) -shared -fPIC $(SETUP135_SOURCE) -Wl,-z,defs -o $@
dizzass-setup135-evidence:
	python3 integration/tests/check_temperature_setup_evidence_135.py
dizzass-setup135-original: $(SETUP135_DIR)/libsetup.so dizzass-setup135-evidence
	python3 integration/tests/test_temperature_setup_135.py $< --summary $(SETUP135_DIR)/original.json
$(SETUP135_DIR)/native-test: $(SETUP135_SOURCE) integration/tests/test_temperature_setup_135.c $(SETUP135_HEADERS) integration/temperature-setup-135.mk | $(SETUP135_DIR)
	$(CC) $(SETUP135_FLAGS) $(SETUP135_SAN) $(SETUP135_SOURCE) integration/tests/test_temperature_setup_135.c -lm -o $@
dizzass-setup135-test: $(SETUP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-setup135-negative: | $(SETUP135_DIR)
	python3 integration/tests/test_temperature_setup_negative_135.py --cc $(CC) --out $(SETUP135_DIR)/negative
