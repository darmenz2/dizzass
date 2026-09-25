# Isolated original-domain PSU recovery. No production cgminer sources changed.
CC ?= cc
PYTHON ?= python3
DIZZASS_PSU135_DIR ?= build/psu-protocol-135$(if $(SANITIZE),-san,)
comma := ,
PSU135_FLAGS = -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -ffp-contract=off -fno-fast-math $(if $(SANITIZE),-fsanitize=address$(comma)undefined -fno-omit-frame-pointer,)
PSU135_SRC = libbitmain/src/psu.c
PSU135_HDR = integration/psu_protocol_135.h
$(DIZZASS_PSU135_DIR):
	mkdir -p $@
$(DIZZASS_PSU135_DIR)/libpsu.so: $(PSU135_SRC) $(PSU135_HDR) integration/psu-protocol-135.mk | $(DIZZASS_PSU135_DIR)
	$(CC) -I. $(PSU135_FLAGS) -fPIC -shared $(PSU135_SRC) -o $@
$(DIZZASS_PSU135_DIR)/native-test: integration/tests/test_psu_protocol_135.c $(PSU135_SRC) $(PSU135_HDR) integration/psu-protocol-135.mk | $(DIZZASS_PSU135_DIR)
	$(CC) -I. $(PSU135_FLAGS) $(PSU135_SRC) $< -lm -o $@
.PHONY: dizzass-psu135-original dizzass-psu135-test
dizzass-psu135-original: $(DIZZASS_PSU135_DIR)/libpsu.so
	$(PYTHON) integration/tests/test_psu_protocol_135.py $< --summary $(DIZZASS_PSU135_DIR)/original.json
dizzass-psu135-test: $(DIZZASS_PSU135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 60 ./$<
