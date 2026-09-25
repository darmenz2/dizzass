# Isolated PSU original-domain recovery, no production source-list changes.
CC ?= cc
PYTHON ?= python3
DIZZASS_SETUP135_DIR ?= build/psu-setup-135$(if $(SANITIZE),-san,)
comma := ,
SETUP135_FLAGS = -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -ffp-contract=off -fno-fast-math $(if $(SANITIZE),-fsanitize=address$(comma)undefined -fno-omit-frame-pointer,)
SETUP135_SRC = libbitmain/src/psu.c
SETUP135_HDR = integration/psu_protocol_135.h integration/psu_setup_135.h integration/psu_crc16_135_table.h
$(DIZZASS_SETUP135_DIR):
	mkdir -p $@
$(DIZZASS_SETUP135_DIR)/libsetup.so: $(SETUP135_SRC) $(SETUP135_HDR) integration/psu-setup-135.mk | $(DIZZASS_SETUP135_DIR)
	$(CC) -I. $(SETUP135_FLAGS) -fPIC -shared $(SETUP135_SRC) -lm -o $@
$(DIZZASS_SETUP135_DIR)/native-test: integration/tests/test_psu_setup_135.c $(SETUP135_SRC) $(SETUP135_HDR) integration/psu-setup-135.mk | $(DIZZASS_SETUP135_DIR)
	$(CC) -I. $(SETUP135_FLAGS) $(SETUP135_SRC) $< -lm -o $@
.PHONY: dizzass-setup135-original dizzass-setup135-test dizzass-setup135-arm-forms
dizzass-setup135-original: $(DIZZASS_SETUP135_DIR)/libsetup.so
	$(PYTHON) integration/tests/test_psu_setup_135.py $< --summary $(DIZZASS_SETUP135_DIR)/original.json
dizzass-setup135-test: $(DIZZASS_SETUP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 ./$<

dizzass-setup135-arm-forms:
	$(PYTHON) integration/tests/test_psu_setup_arm_forms.py
