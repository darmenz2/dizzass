# Pure verified gate/thermal logic and new checked I/O; never runs on hardware.
CC ?= cc
DIZZASS_POWER_DIR ?= build/aml-power$(if $(SANITIZE),-san,)
DIZZASS_POWER_FLAGS = -std=c11 -O1 -g -Wall -Wextra -Werror -I. $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
$(DIZZASS_POWER_DIR):
	mkdir -p $@
$(DIZZASS_POWER_DIR)/libpower.so: integration/aml_power.c integration/aml_power.h | $(DIZZASS_POWER_DIR)
	$(CC) -std=c11 -O2 -Wall -Wextra -Werror -I. -fPIC -shared $< -o $@
$(DIZZASS_POWER_DIR)/power-test: integration/tests/test_aml_power.c integration/aml_power.c integration/aml_power.h | $(DIZZASS_POWER_DIR)
	$(CC) $(DIZZASS_POWER_FLAGS) integration/tests/test_aml_power.c integration/aml_power.c -o $@
$(DIZZASS_POWER_DIR)/gpio-test: integration/tests/test_gpio_value_io.c integration/gpio_value_io.c integration/gpio_value_io.h integration/aml_power.h | $(DIZZASS_POWER_DIR)
	$(CC) $(DIZZASS_POWER_FLAGS) integration/tests/test_gpio_value_io.c integration/gpio_value_io.c -Wl,--wrap=write,--wrap=close -o $@
.PHONY: dizzass-aml-power-original dizzass-aml-power-test
dizzass-aml-power-original: $(DIZZASS_POWER_DIR)/libpower.so
	python3 integration/tests/test_aml_power_original.py $<
dizzass-aml-power-test: $(DIZZASS_POWER_DIR)/power-test $(DIZZASS_POWER_DIR)/gpio-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_POWER_DIR)/power-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$(DIZZASS_POWER_DIR)/gpio-test
