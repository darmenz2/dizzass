include integration/mining-stop-135.mk
PLATFORM135_DIR ?= build/platform-stop135$(if $(filter 1,$(SANITIZE)),-san,)
PLATFORM135_FLAGS = $(MINING135_FLAGS) -DVN135_PLATFORM_STOP_135
PLATFORM135_SOURCES = libbitmain/src/platform-stop.c $(MINING135_SOURCES)
.PHONY: dizzass-platform135-evidence dizzass-platform135-original dizzass-platform135-test dizzass-platform135-negative
$(PLATFORM135_DIR):
	mkdir -p $@
$(PLATFORM135_DIR)/libplatform.so: $(PLATFORM135_SOURCES) $(wildcard integration/*135.h) integration/platform-stop-135.mk | $(PLATFORM135_DIR)
	$(CC) $(PLATFORM135_FLAGS) -shared -fPIC $(PLATFORM135_SOURCES) -Wl,-z,defs -o $@
dizzass-platform135-evidence:
	python3 integration/tests/check_platform_stop_evidence_135.py
dizzass-platform135-original: $(PLATFORM135_DIR)/libplatform.so dizzass-platform135-evidence
	python3 integration/tests/test_platform_stop_135.py $< --summary $(PLATFORM135_DIR)/original.json
$(PLATFORM135_DIR)/native-test: $(PLATFORM135_SOURCES) integration/tests/test_platform_stop_135.c $(wildcard integration/*135.h) integration/platform-stop-135.mk | $(PLATFORM135_DIR)
	$(CC) $(PLATFORM135_FLAGS) $(MINING135_SAN) $(PLATFORM135_SOURCES) integration/tests/test_platform_stop_135.c -o $@
dizzass-platform135-test: $(PLATFORM135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-platform135-negative:
	python3 integration/tests/test_platform_stop_negative_135.py --cc $(CC) --out $(PLATFORM135_DIR)/negative
