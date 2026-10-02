.DEFAULT_GOAL := evidence
ROOT ?= $(abspath ../../../..)
PYTHON ?= python3
.PHONY: evidence
evidence:
	$(PYTHON) -B verify_evidence.py --cgminer $(ROOT)/reference/cgminer.vendor.elf
	$(PYTHON) -O -B verify_evidence.py --cgminer $(ROOT)/reference/cgminer.vendor.elf
	$(PYTHON) -B -m unittest discover -s tests -p test_evidence.py -v
	$(PYTHON) -O -B -m unittest discover -s tests -p test_evidence.py -v
