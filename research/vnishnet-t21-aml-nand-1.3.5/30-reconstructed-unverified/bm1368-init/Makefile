ROOT := ../../../..
CC ?= cc
PYTHON ?= python3
CFLAGS := -std=c11 -O2 -g -Wall -Wextra -Wpedantic -Werror -Wconversion -Wshadow
CPPFLAGS := -I$(ROOT) -DVN135_BM1368_INITIALIZE_135 -DVN135_TRANSPORT_INITIALIZE_135
CHIP := $(ROOT)/libbitmain/src/chip/chip1368.c
TRANSPORT := $(ROOT)/libbitmain/src/transport-dispatch.c
HEADERS := $(ROOT)/integration/bm1368_initialize_135.h $(ROOT)/integration/bm1368_nonce.h $(ROOT)/integration/transport_initialize_135.h
TEST := tests/test_constructor.c
.PHONY: test host evidence controls nonce sanitize
host: build/constructor
	./build/constructor
build/constructor: $(CHIP) $(TRANSPORT) $(TEST) $(HEADERS)
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CHIP) $(TRANSPORT) $(TEST) -o $@
evidence:
	$(PYTHON) -B verify_evidence.py
	$(PYTHON) -B tests/test_evidence.py
	$(PYTHON) -O -B tests/test_evidence.py
controls:
	$(PYTHON) -B tests/negative_controls.py --root $(ROOT) --test $(TEST) --cc $(CC)
nonce:
	mkdir -p build
	$(CC) -I$(ROOT) $(CFLAGS) $(CHIP) $(ROOT)/integration/tests/test_bm1368_bounds.c -o build/nonce-bounds
	./build/nonce-bounds
test: host evidence controls nonce
sanitize:
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) -O1 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-pie -no-pie $(CHIP) $(TRANSPORT) $(TEST) -o build/constructor-sanitize
	ASAN_OPTIONS=detect_leaks=0:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 ./build/constructor-sanitize
	$(CC) $(CPPFLAGS) $(CFLAGS) -O1 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-pie -no-pie $(CHIP) $(ROOT)/integration/tests/test_bm1368_bounds.c -o build/nonce-bounds-sanitize
	ASAN_OPTIONS=detect_leaks=0:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 ./build/nonce-bounds-sanitize
