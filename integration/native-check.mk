# Read-only inspection of the configured upstream production source list.
# Usage: make -s -f Makefile -f integration/native-check.mk dizzass-core-sources
# Not included by upstream Makefile.am; adds no source, flags or dependency.
.PHONY: dizzass-core-sources
dizzass-core-sources:
	@printf '%s\n' $(cgminer_SOURCES)
