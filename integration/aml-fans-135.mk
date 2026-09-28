# Isolated reconstruction. No production driver or hardware access.
CC ?= cc
FAN135_DIR ?= build/aml-fans-135$(if $(SANITIZE),-san,)
FAN135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror
FAN135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
FAN135_SRC = libbitmain/src/aml/fan_ctrl.c
FAN135_HDR = integration/aml_fans_135.h
$(FAN135_DIR):
	mkdir -p $@
$(FAN135_DIR)/libfans.so: $(FAN135_SRC) $(FAN135_HDR) integration/aml-fans-135.mk | $(FAN135_DIR)
	$(CC) $(FAN135_FLAGS) -fPIC -shared $(FAN135_SRC) -Wl,-z,defs -o $@
$(FAN135_DIR)/native-test: $(FAN135_SRC) $(FAN135_HDR) integration/tests/test_aml_fans_135.c integration/aml-fans-135.mk | $(FAN135_DIR)
	$(CC) $(FAN135_FLAGS) $(FAN135_SAN) $(FAN135_SRC) integration/tests/test_aml_fans_135.c -o $@
.PHONY: dizzass-fans135-original dizzass-fans135-test
dizzass-fans135-original: $(FAN135_DIR)/libfans.so
	python3 integration/tests/test_aml_fans_135.py $< --summary $(FAN135_DIR)/original.json
dizzass-fans135-test: $(FAN135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$<
