ROOT := ../../../..
CC ?= cc
PYTHON ?= python3
CFLAGS := -std=c11 -O2 -g -Wall -Wextra -Werror -Wconversion -Wshadow -pedantic
CPPFLAGS := -I$(ROOT) -DVN135_TRANSPORT_INITIALIZE_135
SOURCE := $(ROOT)/libbitmain/src/transport-dispatch.c
TEST := tests/test_transport_initialize.c
.PHONY: test host sanitize evidence controls compat clean
host: build/test_transport_initialize
	./build/test_transport_initialize
build/test_transport_initialize: $(SOURCE) $(TEST) $(ROOT)/integration/transport_initialize_135.h
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SOURCE) $(TEST) -o $@
evidence:
	$(PYTHON) -B verify_evidence.py
	$(PYTHON) -B -m unittest discover -s tests -p test_evidence.py -v
controls:
	$(PYTHON) -B tests/test_semantic_controls.py --cc $(CC)
compat:
	mkdir -p build
	$(CC) $(CPPFLAGS) -I$(ROOT)/include -DVN135_TRANSPORT_DISPATCH_135 $(CFLAGS) -c $(SOURCE) -o build/both-macros.o
test: host evidence controls compat
sanitize:
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) -O1 -fno-omit-frame-pointer -fsanitize=address,undefined $(SOURCE) $(TEST) -o build/test_transport_initialize_sanitize
	ASAN_OPTIONS=detect_leaks=0:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 ./build/test_transport_initialize_sanitize
clean:
	rm -rf build
