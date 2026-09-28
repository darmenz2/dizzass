# Original I2C procedures only. No production source list or device is changed.
CC = gcc
I2C135_DIR ?= build/i2c135$(if $(SANITIZE),-san,)
I2C135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Werror -ffp-contract=off
ifneq ($(SANITIZE),)
I2C135_FLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer
endif
I2C135_SRC = libbitmain/src/i2c.c libbitmain/src/aml/i2c.c
I2C135_HEADERS = integration/i2c_transport_135.h
I2C135_PSU_HEADERS = $(wildcard integration/psu*135*.h)
$(I2C135_DIR):
	mkdir -p $@
$(I2C135_DIR)/libi2c135.so: $(I2C135_SRC) $(I2C135_HEADERS) $(I2C135_PSU_HEADERS) libbitmain/src/psu.c integration/i2c-transport-135.mk | $(I2C135_DIR)
	$(CC) $(I2C135_FLAGS) -fPIC -shared $(I2C135_SRC) libbitmain/src/psu.c -lm -o $@
$(I2C135_DIR)/native-test: integration/tests/test_i2c_transport_135.c $(I2C135_SRC) $(I2C135_HEADERS) integration/i2c-transport-135.mk | $(I2C135_DIR)
	$(CC) $(I2C135_FLAGS) $< $(I2C135_SRC) -o $@
.PHONY: dizzass-i2c135-original dizzass-i2c135-test
dizzass-i2c135-original: $(I2C135_DIR)/libi2c135.so
	python3 integration/tests/test_i2c_transport_135.py $<
dizzass-i2c135-test: $(I2C135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
