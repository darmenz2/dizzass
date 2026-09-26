# Explicit isolated source selection. No production driver or core changes.
CC ?= cc
ROUTES135_DIR ?= build/thermal-routes-135$(if $(SANITIZE),-san,)
ROUTES135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off -DVN135_THERMAL_ROUTES_135
ROUTES135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
ROUTES135_SOURCES = src/backend/base.c src/backend/temp.c src/backend/chain.c libbitmain/src/aml/platform.c reconstruction/support/thermal_routes_135.c
ROUTES135_COMPOSE = reconstruction/support/thermal_trip_135.c libbitmain/src/gpio.c libbitmain/src/fan_ctrl.c libbitmain/src/aml/fan_ctrl.c reconstruction/support/pid_135.c
ROUTES135_HEADERS = $(wildcard integration/*135.h)
$(ROUTES135_DIR):
	mkdir -p $@
$(ROUTES135_DIR)/libroutes.so: $(ROUTES135_SOURCES) $(ROUTES135_HEADERS) | $(ROUTES135_DIR)
	$(CC) $(ROUTES135_FLAGS) -shared -fPIC $(ROUTES135_SOURCES) -Wl,-z,defs -o $@
$(ROUTES135_DIR)/native-test: $(ROUTES135_SOURCES) $(ROUTES135_COMPOSE) $(ROUTES135_HEADERS) integration/tests/test_thermal_routes_135.c | $(ROUTES135_DIR)
	$(CC) $(ROUTES135_FLAGS) $(ROUTES135_SAN) $(ROUTES135_SOURCES) $(ROUTES135_COMPOSE) integration/tests/test_thermal_routes_135.c -lm -o $@
.PHONY: dizzass-routes135-original dizzass-routes135-test
dizzass-routes135-original: $(ROUTES135_DIR)/libroutes.so
	python3 integration/tests/test_thermal_routes_135.py $< --summary $(ROUTES135_DIR)/original.json
dizzass-routes135-test: $(ROUTES135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 $<
