ROOT := ../../../..
CC ?= cc
PYTHON ?= python3
.PHONY: test host controls sanitize evidence
host:
	$(PYTHON) -B tests/run_host.py --root $(ROOT) --build build/ordinary --cc $(CC)
controls:
	$(PYTHON) -B tests/negative_controls.py --root $(ROOT) --cc $(CC)
sanitize:
	$(PYTHON) -B tests/run_host.py --root $(ROOT) --build build/sanitized --cc $(CC) --sanitize
evidence:
	$(PYTHON) -B verify_evidence.py
	$(PYTHON) -B tests/test_evidence.py
	$(PYTHON) -O -B tests/test_evidence.py
test: host controls evidence
