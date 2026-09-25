# Isolated extraction of original software-I2C. No production linkage or I/O.
CC ?= cc
SOFT135_DIR ?= build/i2c-soft-135$(if $(SANITIZE),-san,)
SOFT135_PSU_SOURCE ?= libbitmain/src/psu.c
SOFT135_FLAGS = -std=c11 -O1 -g -I. -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
SOFT135_SAN = $(if $(SANITIZE),-fsanitize=address$(comma)undefined -fno-omit-frame-pointer,)
comma := ,
SOFT135_HEADERS = integration/i2c_soft_135.h integration/i2c_transport_135.h
$(SOFT135_DIR):
	mkdir -p $@
$(SOFT135_DIR)/libsoft.so: libbitmain/src/i2c.c $(SOFT135_HEADERS) integration/i2c-soft-135.mk | $(SOFT135_DIR)
	$(CC) $(SOFT135_FLAGS) -shared -fPIC $< -o $@
$(SOFT135_DIR)/libcomposed.so: libbitmain/src/i2c.c $(SOFT135_PSU_SOURCE) $(SOFT135_HEADERS) integration/psu_protocol_135.h integration/psu_setup_135.h integration/i2c-soft-135.mk | $(SOFT135_DIR)
	$(CC) $(SOFT135_FLAGS) -shared -fPIC libbitmain/src/i2c.c $(SOFT135_PSU_SOURCE) -lm -o $@
$(SOFT135_DIR)/native-test: libbitmain/src/i2c.c integration/tests/test_i2c_soft_135.c $(SOFT135_HEADERS) integration/i2c-soft-135.mk | $(SOFT135_DIR)
	$(CC) $(SOFT135_FLAGS) $(SOFT135_SAN) libbitmain/src/i2c.c integration/tests/test_i2c_soft_135.c -o $@
.PHONY: dizzass-soft135-original dizzass-soft135-composed dizzass-soft135-test
dizzass-soft135-original: $(SOFT135_DIR)/libsoft.so
	python3 integration/tests/test_i2c_soft_135.py $< --summary $(SOFT135_DIR)/original.json
dizzass-soft135-composed: $(SOFT135_DIR)/libcomposed.so
	python3 integration/tests/test_i2c_soft_psu_135.py $< --summary $(SOFT135_DIR)/composed.json
dizzass-soft135-test: $(SOFT135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$<
