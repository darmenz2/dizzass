# Isolated original-domain recovery; no production cgminer source changes.
CC ?= cc
INIT135_DIR ?= build/i2c-init-135$(if $(SANITIZE),-san,)
INIT135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
INIT135_PSU_SOURCE ?= libbitmain/src/psu.c
INIT135_SRC = libbitmain/src/gpio.c libbitmain/src/i2c.c libbitmain/src/aml/i2c.c libbitmain/src/aml/psu.c
INIT135_HEADERS = integration/gpio_power_135.h integration/i2c_init_135.h integration/i2c_soft_135.h integration/i2c_transport_135.h
$(INIT135_DIR):
	mkdir -p $@
$(INIT135_DIR)/libinit.so: $(INIT135_SRC) $(INIT135_HEADERS) integration/i2c-init-135.mk | $(INIT135_DIR)
	$(CC) $(INIT135_FLAGS) -fPIC -shared $(INIT135_SRC) -o $@
$(INIT135_DIR)/native-test: $(INIT135_SRC) $(INIT135_HEADERS) $(INIT135_PSU_SOURCE) integration/psu_protocol_135.h integration/tests/test_i2c_init_135.c integration/i2c-init-135.mk | $(INIT135_DIR)
	$(CC) $(INIT135_FLAGS) $(INIT135_SRC) $(INIT135_PSU_SOURCE) integration/tests/test_i2c_init_135.c -lm -o $@
.PHONY: dizzass-init135-original dizzass-init135-route dizzass-init135-test
dizzass-init135-original: $(INIT135_DIR)/libinit.so
	python3 integration/tests/test_i2c_init_135.py $< --summary $(INIT135_DIR)/original.json
dizzass-init135-route: | $(INIT135_DIR)
	python3 integration/tests/test_i2c_init_route_135.py --summary $(INIT135_DIR)/route.json
dizzass-init135-test: $(INIT135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$<
