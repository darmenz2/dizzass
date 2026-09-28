CC ?= cc
REG1368_DIR ?= build/bm1368-register135$(if $(filter 1,$(SANITIZE)),-san,)
REG1368_FLAGS = -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_BM1368_REGISTER_WRITE_135 -DVN135_BM1368_FREQUENCY_135
REG1368_SAN = $(if $(filter 1,$(SANITIZE)),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
REG1368_SRC = libbitmain/src/chip/chip1368-register-write.c libbitmain/src/chip/chip1368-frequency.c libbitmain/src/pll.c libbitmain/src/reg_cache.c integration/bm1368_control.c reconstruction/support/crc5.c
REG1368_HEADERS = integration/bm1368_register_write_135.h integration/bm1368_frequency_135.h integration/bm1368_control.h $(wildcard include/xminer/recovery/*.h) reconstruction/data/reg_cache_defaults.inc
.PHONY: dizzass-reg1368-original dizzass-reg1368-test dizzass-reg1368-negative dizzass-reg1368-evidence
$(REG1368_DIR):
	mkdir -p $@
$(REG1368_DIR)/libregister.so: $(REG1368_SRC) $(REG1368_HEADERS) integration/bm1368-register-write-135.mk | $(REG1368_DIR)
	$(CC) $(REG1368_FLAGS) -shared -fPIC $(REG1368_SRC) -Wl,-z,defs -o $@
dizzass-reg1368-original: $(REG1368_DIR)/libregister.so dizzass-reg1368-evidence
	python3 integration/tests/test_bm1368_register_write_135.py $< --summary $(REG1368_DIR)/original.json
$(REG1368_DIR)/native-test: $(REG1368_SRC) $(REG1368_HEADERS) integration/tests/test_bm1368_register_write_135.c integration/bm1368-register-write-135.mk | $(REG1368_DIR)
	$(CC) $(REG1368_FLAGS) $(REG1368_SAN) $(REG1368_SRC) integration/tests/test_bm1368_register_write_135.c -o $@
dizzass-reg1368-test: $(REG1368_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
dizzass-reg1368-negative:
	python3 integration/tests/test_bm1368_register_write_negative_135.py --cc $(CC) --out $(REG1368_DIR)/negative
dizzass-reg1368-evidence:
	python3 integration/tests/check_bm1368_register_write_evidence_135.py
