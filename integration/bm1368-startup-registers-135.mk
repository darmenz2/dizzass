# Standalone host tests. No default production-source or firmware linkage.
CC ?= cc
DIZZASS_STARTUP_DIR ?= build/bm1368-startup-registers$(if $(filter 1,$(SANITIZE)),-san,)
DIZZASS_STARTUP_COMMA := ,
DIZZASS_STARTUP_SOURCES = libbitmain/src/chip/chip1368-startup-registers.c libbitmain/src/chip/chip1368-register-write.c libbitmain/src/reg_cache.c integration/bm1368_control.c reconstruction/support/crc5.c integration/tests/test_bm1368_startup_registers_135.c
DIZZASS_STARTUP_HEADERS = integration/bm1368_startup_registers_135.h integration/bm1368_register_write_135.h integration/bm1368_frequency_135.h integration/bm1368_control.h include/xminer/recovery/reg_cache.h include/xminer/recovery/chip1398.h include/xminer/recovery/pll.h reconstruction/data/reg_cache_defaults.inc
DIZZASS_STARTUP_FLAGS = -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -Wshadow -DVN135_BM1368_STARTUP_REGISTERS_135 -DVN135_BM1368_REGISTER_WRITE_135 $(if $(filter 1,$(SANITIZE)),-fsanitize=address$(DIZZASS_STARTUP_COMMA)undefined -fno-omit-frame-pointer -fno-pie -no-pie,)
$(DIZZASS_STARTUP_DIR):
	mkdir -p $@
$(DIZZASS_STARTUP_DIR)/host-test: $(DIZZASS_STARTUP_SOURCES) $(DIZZASS_STARTUP_HEADERS) integration/bm1368-startup-registers-135.mk | $(DIZZASS_STARTUP_DIR)
	$(CC) $(DIZZASS_STARTUP_FLAGS) $(DIZZASS_STARTUP_SOURCES) -o $@
.PHONY: dizzass-startup-registers135-test dizzass-startup-registers135-static
dizzass-startup-registers135-test: $(DIZZASS_STARTUP_DIR)/host-test
	ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 "$<"
dizzass-startup-registers135-static:
	python3 -B research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-startup-registers/verify.py --with-reference
	python3 -B research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-startup-registers/test_evidence.py
