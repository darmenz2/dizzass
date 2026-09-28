# Isolated original recovery; no production linkage or physical device calls.
CC ?= cc
FANCTL135_DIR ?= build/fan-control-135$(if $(SANITIZE),-san,)
FANCTL135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
FANCTL135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
FANCTL135_SOURCES = libbitmain/src/fan_ctrl.c reconstruction/support/pid_135.c reconstruction/support/fan_records_135.c
$(FANCTL135_DIR):
	mkdir -p $@
$(FANCTL135_DIR)/libcontrol.so: $(FANCTL135_SOURCES) integration/fan_control_135.h integration/fan-control-135.mk | $(FANCTL135_DIR)
	$(CC) $(FANCTL135_FLAGS) -fPIC -shared $(FANCTL135_SOURCES) -Wl,-z,defs -lm -o $@
$(FANCTL135_DIR)/native-test: $(FANCTL135_SOURCES) integration/fan_control_135.h integration/tests/test_fan_control_135.c libbitmain/src/aml/fan_ctrl.c integration/aml_fans_135.h integration/fan-control-135.mk | $(FANCTL135_DIR)
	$(CC) $(FANCTL135_FLAGS) $(FANCTL135_SAN) $(FANCTL135_SOURCES) integration/tests/test_fan_control_135.c libbitmain/src/aml/fan_ctrl.c -lm -o $@
.PHONY: dizzass-fanctl135-original dizzass-fanctl135-test
dizzass-fanctl135-original: $(FANCTL135_DIR)/libcontrol.so
	python3 integration/tests/test_fan_control_135.py $< --summary $(FANCTL135_DIR)/original.json
dizzass-fanctl135-test: $(FANCTL135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
