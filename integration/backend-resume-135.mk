# Isolated original caller recovery; not a registered device or production core.
CC ?= cc
RESUME135_DIR ?= build/backend-resume-135$(if $(SANITIZE),-san,)
RESUME135_FLAGS = -I. -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-fast-math -ffp-contract=off
RESUME135_SAN = $(if $(SANITIZE),-fsanitize=address -fsanitize=undefined -fno-omit-frame-pointer,)
RESUME135_HEADERS = integration/backend_resume_135.h integration/gpio_power_135.h integration/backend_cold_135.h integration/backend_peripheral_135.h
$(RESUME135_DIR):
	mkdir -p $@
$(RESUME135_DIR)/libresume.so: src/backend/base.c $(RESUME135_HEADERS) integration/backend-resume-135.mk | $(RESUME135_DIR)
	$(CC) $(RESUME135_FLAGS) -shared -fPIC $< -Wl,-z,defs -o $@
$(RESUME135_DIR)/native-test: src/backend/base.c $(RESUME135_HEADERS) integration/tests/test_backend_resume_135.c integration/backend-resume-135.mk | $(RESUME135_DIR)
	$(CC) $(RESUME135_FLAGS) $(RESUME135_SAN) src/backend/base.c integration/tests/test_backend_resume_135.c -o $@
.PHONY: dizzass-resume135-original dizzass-resume135-test
dizzass-resume135-original: $(RESUME135_DIR)/libresume.so
	python3 integration/tests/test_backend_resume_135.py $< --summary $(RESUME135_DIR)/original.json
dizzass-resume135-test: $(RESUME135_DIR)/native-test
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 timeout 45 ./$<
