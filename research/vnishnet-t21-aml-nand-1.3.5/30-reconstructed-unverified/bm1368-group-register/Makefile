ROOT ?= $(CURDIR)
PACKET = $(ROOT)/research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-group-register
BUILD ?= /tmp/dizzass-bm1368-group-register-135
PYTHON ?= python3
CC ?= gcc

.PHONY: test verify static-controls host controls sanitize
test: verify static-controls host controls

verify:
	$(PYTHON) $(PACKET)/verify_evidence.py --root $(ROOT)
	$(PYTHON) -O $(PACKET)/verify_evidence.py --root $(ROOT)

static-controls:
	$(PYTHON) $(PACKET)/tests/test_evidence.py
	$(PYTHON) -O $(PACKET)/tests/test_evidence.py

host:
	$(PYTHON) $(PACKET)/tests/run_host.py --root $(ROOT) --build $(BUILD)/ordinary --cc $(CC)

controls:
	$(PYTHON) $(PACKET)/tests/negative_controls.py --root $(ROOT) --output $(BUILD)/controls --cc $(CC)

sanitize:
	$(PYTHON) $(PACKET)/tests/run_host.py --root $(ROOT) --build $(BUILD)/sanitized --cc $(CC) --sanitize
