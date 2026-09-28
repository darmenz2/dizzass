# Standalone pure checks, no native miner or hardware startup.
CC ?= cc
DIZZASS_CONTROL_DIR ?= build/bm1368-control$(if $(SANITIZE),-san,)
DIZZASS_CONTROL_COMMA := ,
DIZZASS_CONTROL_FLAGS = -O1 -g -std=c11 -Wall -Wextra -Werror $(if $(SANITIZE),-fsanitize=address$(DIZZASS_CONTROL_COMMA)undefined -fno-omit-frame-pointer,)
DIZZASS_CONTROL_SOURCES = integration/bm1368_control.c integration/rx_crc5.c reconstruction/support/crc5.c
DIZZASS_CONTROL_HEADERS = integration/bm1368_control.h integration/rx_crc5.h include/xminer/recovery/chip1398.h
$(DIZZASS_CONTROL_DIR):
	mkdir -p $@
$(DIZZASS_CONTROL_DIR)/bounds: integration/tests/test_bm1368_control_bounds.c $(DIZZASS_CONTROL_SOURCES) $(DIZZASS_CONTROL_HEADERS) integration/bm1368-control.mk | $(DIZZASS_CONTROL_DIR)
	$(CC) -I. -Iinclude $(DIZZASS_CONTROL_FLAGS) $< $(DIZZASS_CONTROL_SOURCES) -o $@
$(DIZZASS_CONTROL_DIR)/control.so: $(DIZZASS_CONTROL_SOURCES) $(DIZZASS_CONTROL_HEADERS) integration/bm1368-control.mk | $(DIZZASS_CONTROL_DIR)
	$(CC) -I. -Iinclude -O1 -g -std=c11 -Wall -Wextra -Werror -fPIC -shared $(DIZZASS_CONTROL_SOURCES) -o $@
.PHONY: dizzass-control-bounds dizzass-control-original
dizzass-control-bounds: $(DIZZASS_CONTROL_DIR)/bounds
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(DIZZASS_CONTROL_DIR)/bounds
dizzass-control-original: $(DIZZASS_CONTROL_DIR)/control.so
	python3 integration/tests/test_bm1368_control.py $(DIZZASS_CONTROL_DIR)/control.so
