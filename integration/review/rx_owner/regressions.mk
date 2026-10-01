# Include AFTER native-submit.mk. Old assertions/core stay unchanged.
RO_DEPS ?= build/r04-deps
DIZZASS_NATIVE_CPP := -I$(RO_DEPS) $(DIZZASS_NATIVE_CPP)
ifeq ($(RO_ANTS2),1)
DIZZASS_JOBS_FLAGS += -include integration/review/rx_owner/host_compat.h
endif
$(DIZZASS_JOBS_DIR)/jobs.o: $(RO_DEPS)/integration/native_jobs.c $(RO_DEPS)/integration/native_jobs.h $(RO_DEPS)/integration/native_submit.h | $(DIZZASS_JOBS_DIR)
	$(CC) $(DIZZASS_NATIVE_CPP) $(DIZZASS_JOBS_FLAGS) $(DIZZASS_JOBS_WARNINGS) -c $(RO_DEPS)/integration/native_jobs.c -o $@
