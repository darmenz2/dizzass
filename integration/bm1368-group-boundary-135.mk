CC ?= cc
BOUNDARY135_DIR ?= build/bm1368-group-boundary135$(if $(filter 1,$(SANITIZE)),-san,)
BOUNDARY135_FLAGS = -I. -Iinclude -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -Wshadow -DVN135_BM1368_GROUP_BOUNDARY_135 -DVN135_BM1368_REGISTER_WRITE_135
ifeq ($(SANITIZE),1)
BOUNDARY135_SAN = -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie
else
BOUNDARY135_SAN =
endif
BOUNDARY135_SRC = integration/bm1368_group_boundary_135.c libbitmain/src/chip/chip1368-group-boundary.c libbitmain/src/chip/chip1368-register-write.c libbitmain/src/reg_cache.c integration/bm1368_control.c reconstruction/support/crc5.c
BOUNDARY135_HEADERS = integration/bm1368_group_boundary_135.h integration/bm1368_register_write_135.h integration/bm1368_frequency_135.h integration/bm1368_control.h $(wildcard include/xminer/recovery/*.h) reconstruction/data/reg_cache_defaults.inc
.PHONY: dizzass-boundary135-test
$(BOUNDARY135_DIR):
	mkdir -p $@
$(BOUNDARY135_DIR)/host-test: $(BOUNDARY135_SRC) $(BOUNDARY135_HEADERS) integration/tests/test_bm1368_group_boundary_135.c integration/bm1368-group-boundary-135.mk | $(BOUNDARY135_DIR)
	$(CC) $(BOUNDARY135_FLAGS) $(BOUNDARY135_SAN) $(BOUNDARY135_SRC) integration/tests/test_bm1368_group_boundary_135.c -o $@
dizzass-boundary135-test: $(BOUNDARY135_DIR)/host-test
	ASAN_OPTIONS=detect_leaks=0:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
