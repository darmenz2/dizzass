include integration/transport-dispatch-135.mk
PULSE135_DIR ?= build/bm1368-pulse135$(if $(filter 1,$(SANITIZE)),-san,)
PULSE135_FLAGS = $(TRANSPORT135_FLAGS) -DVN135_BM1368_PULSE_WIDTH_135 -DVN135_CHAIN_FREQUENCY_135
PULSE135_SRC = $(TRANSPORT135_SRC) libbitmain/src/chip/chip1368-pulse-width.c src/backend/chain-frequency.c
.PHONY: dizzass-pulse135-original dizzass-pulse135-test dizzass-pulse135-evidence dizzass-pulse135-negative
$(PULSE135_DIR):
	mkdir -p $@
$(PULSE135_DIR)/libpulse.so: $(PULSE135_SRC) $(TRANSPORT135_HEADERS) integration/bm1368-pulse-width-135.mk | $(PULSE135_DIR)
	$(CC) $(PULSE135_FLAGS) -shared -fPIC $(PULSE135_SRC) -Wl,-z,defs -o $@
dizzass-pulse135-original: $(PULSE135_DIR)/libpulse.so dizzass-pulse135-evidence
	python3 integration/tests/test_bm1368_pulse_width_135.py $< --summary $(PULSE135_DIR)/original.json
$(PULSE135_DIR)/native-test: $(PULSE135_SRC) $(TRANSPORT135_HEADERS) integration/tests/test_bm1368_pulse_width_135.c integration/tests/test_transport_dispatch_135.c integration/bm1368-pulse-width-135.mk | $(PULSE135_DIR)
	$(CC) $(PULSE135_FLAGS) $(TRANSPORT135_SAN) -Iintegration/tests $(PULSE135_SRC) integration/tests/test_bm1368_pulse_width_135.c -o $@
dizzass-pulse135-test: $(PULSE135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-pulse135-evidence:
	python3 integration/tests/check_bm1368_pulse_width_evidence_135.py
dizzass-pulse135-negative:
	python3 integration/tests/test_bm1368_pulse_width_negative_135.py --cc $(CC) --out $(PULSE135_DIR)/negative
