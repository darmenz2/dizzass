# Offline original-domain recovery. No production sources are added.
CC ?= cc
LD ?= ld
GP135_DIR ?= build/gpio-power-135$(if $(SANITIZE),-san,)
GP135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -fPIC -ffunction-sections -fdata-sections
GP135_SAN = $(if $(SANITIZE),-fsanitize=address$(comma)undefined -fno-omit-frame-pointer,)
comma := ,
GP135_PSU_SOURCE ?= libbitmain/src/psu.c
GP135_SOURCES = libbitmain/src/gpio.c src/backend/base.c
GP135_HEADER = integration/gpio_power_135.h integration/backend_resume_135.h
GP135_AML_HEADERS = integration/i2c_init_135.h integration/i2c_soft_135.h integration/i2c_transport_135.h
$(GP135_DIR):
	mkdir -p $@
$(GP135_DIR)/aml-all.o: libbitmain/src/aml/psu.c $(GP135_HEADER) $(GP135_AML_HEADERS) | $(GP135_DIR)
	$(CC) $(GP135_FLAGS) $(GP135_SAN) -c $< -o $@
# Isolate the two NEW power entries from the unchanged init/getter. This is
# explicit link-time section selection, NOT fake definitions for dependencies.
$(GP135_DIR)/aml-power.o: $(GP135_DIR)/aml-all.o
	$(LD) -r --gc-sections --undefined=vn135_aml_psu_on_135 --undefined=vn135_aml_psu_off_135 $< -o $@
$(GP135_DIR)/libgpio.so: $(GP135_SOURCES) $(GP135_HEADER) $(GP135_DIR)/aml-power.o
	$(CC) $(GP135_FLAGS) -shared $(GP135_SOURCES) $(GP135_DIR)/aml-power.o -Wl,-z,defs -o $@
$(GP135_DIR)/libcomposed.so: $(GP135_SOURCES) $(GP135_HEADER) $(GP135_DIR)/aml-power.o $(GP135_PSU_SOURCE) integration/psu_setup_135.h integration/psu_protocol_135.h
	$(CC) $(GP135_FLAGS) -shared $(GP135_SOURCES) $(GP135_DIR)/aml-power.o $(GP135_PSU_SOURCE) -lm -Wl,-z,defs -o $@
$(GP135_DIR)/native-test: $(GP135_SOURCES) $(GP135_HEADER) $(GP135_DIR)/aml-power.o integration/tests/test_gpio_power_135.c
	$(CC) $(GP135_FLAGS) $(GP135_SAN) $(GP135_SOURCES) $(GP135_DIR)/aml-power.o integration/tests/test_gpio_power_135.c -o $@
.PHONY: dizzass-gpio135-original dizzass-gpio135-composed dizzass-gpio135-test
dizzass-gpio135-original: $(GP135_DIR)/libgpio.so
	python3 integration/tests/test_gpio_power_135.py $< --summary $(GP135_DIR)/original.json
dizzass-gpio135-composed: $(GP135_DIR)/libcomposed.so
	python3 integration/tests/test_gpio_power_psu_135.py $< --summary $(GP135_DIR)/composed.json
dizzass-gpio135-test: $(GP135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
