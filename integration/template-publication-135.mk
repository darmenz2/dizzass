# Offline comparison only; not included by production Makefile.am.
CC ?= cc
TEMPLATE_DIR ?= build/template-publication-135
FLAGS = -I. -Iinclude -std=c11 -Wall -Wextra -Wpedantic -Werror
SRC = src/backend/work-gen/template-publication.c reconstruction/support/record_fifo.c reconstruction/support/nonce_fifo.c
HDR = integration/template_publication_135.h include/xminer/recovery/nonce_fifo.h
ifneq ($(TEMPLATE_OLD_TEST),1)
.PHONY: all evidence original native sanitize negative regressions
all: evidence original native
$(TEMPLATE_DIR):
	mkdir -p $@
$(TEMPLATE_DIR)/libtemplate.so: $(SRC) $(HDR) | $(TEMPLATE_DIR)
	$(CC) $(FLAGS) -O2 -shared -fPIC $(SRC) -Wl,-z,defs -o $@
$(TEMPLATE_DIR)/native: $(SRC) $(HDR) integration/tests/test_template_publication_135.c | $(TEMPLATE_DIR)
	$(CC) $(FLAGS) -O2 $(SRC) integration/tests/test_template_publication_135.c -o $@
$(TEMPLATE_DIR)/san: $(SRC) $(HDR) integration/tests/test_template_publication_135.c | $(TEMPLATE_DIR)
	$(CC) $(FLAGS) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(SRC) integration/tests/test_template_publication_135.c -o $@
evidence:
	python3 integration/tests/check_template_publication_evidence_135.py
original: $(TEMPLATE_DIR)/libtemplate.so
	python3 integration/tests/test_template_publication_135.py $(TEMPLATE_DIR)/libtemplate.so
native: $(TEMPLATE_DIR)/native
	./$(TEMPLATE_DIR)/native
sanitize: $(TEMPLATE_DIR)/san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(TEMPLATE_DIR)/san
negative: $(TEMPLATE_DIR)/libtemplate.so
	python3 integration/tests/test_template_publication_negative_135.py $(TEMPLATE_DIR)/negative --cc $(CC) --baseline $(TEMPLATE_DIR)/libtemplate.so
endif
# The historical C test contains a complete nonce pipeline as well as FIFO
# checks. Read its original SOURCES from Makefile.recovery in the recursive
# invocation instead of pretending three FIFO files satisfy that dependency.
$(TEMPLATE_DIR)/fifo-san: $(SOURCES) tests/test_nonce_fifo.c Makefile.recovery integration/template-publication-135.mk
	$(if $(SOURCES),,$(error Invoke this target with Makefile.recovery first))
	mkdir -p $(TEMPLATE_DIR)
	$(CC) $(FLAGS) -ffp-contract=off -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fno-pie -no-pie $(SOURCES) tests/test_nonce_fifo.c -o $@
ifneq ($(TEMPLATE_OLD_TEST),1)
regressions: | $(TEMPLATE_DIR)
	$(CC) $(FLAGS) -O2 -shared -fPIC reconstruction/support/record_fifo.c reconstruction/support/nonce_fifo.c reconstruction/support/nonce_record_bridge.c -Wl,-z,defs -o $(TEMPLATE_DIR)/libfifo.so
	VN135_TEST_LIBRARY=$(TEMPLATE_DIR)/libfifo.so python3 tests/test_stage13_differential.py
	$(MAKE) -f Makefile.recovery -f integration/template-publication-135.mk CC=$(CC) TEMPLATE_DIR=$(TEMPLATE_DIR) TEMPLATE_OLD_TEST=1 $(TEMPLATE_DIR)/fifo-san
	ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 ./$(TEMPLATE_DIR)/fifo-san
	$(CC) $(FLAGS) -O2 -shared -fPIC integration/work_route.c integration/work_tx88.c -o $(TEMPLATE_DIR)/libroute.so
	python3 integration/tests/test_work_route.py $(TEMPLATE_DIR)/libroute.so
endif
