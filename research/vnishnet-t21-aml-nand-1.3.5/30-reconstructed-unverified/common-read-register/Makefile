ROOT := ../../../..
CC ?= cc
PYTHON ?= python3
TEST := tests/test_common_read_register.c
.PHONY: test host controls sanitize evidence
host:
	$(PYTHON) -B tests/run_host.py --root $(ROOT) --test $(TEST) --build build/ordinary --cc $(CC)
controls:
	$(PYTHON) -B tests/negative_controls.py --root $(ROOT) --test $(TEST) --cc $(CC)
sanitize:
	$(PYTHON) -B tests/run_host.py --root $(ROOT) --test $(TEST) --build build/sanitized --cc $(CC) --sanitize
evidence:
	$(PYTHON) -B verify_evidence.py --root $(ROOT)
	$(PYTHON) -B tests/test_evidence.py --root $(ROOT)
	$(PYTHON) -O -B tests/test_evidence.py --root $(ROOT)
test: host controls evidence
