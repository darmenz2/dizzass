# C-01 opt-in test override. Include AFTER one original stage Makefile.
# Positive composition tests compile tracked CURRENT sources, not old staged C.
ifneq ($(strip $(TC135_DEPS)),)
TC135_SRC := $(patsubst $(TC135_DEPS)/%,%,$(TC135_SRC))
TC135_FLAGS := -I. $(filter-out -I$(TC135_DEPS),$(TC135_FLAGS))
endif
ifneq ($(strip $(RT135_DEPS)),)
RT135_SRC := $(patsubst $(RT135_DEPS)/%,%,$(RT135_SRC))
RT135_FLAGS := -I. $(filter-out -I$(RT135_DEPS),$(RT135_FLAGS))
endif
ifneq ($(strip $(UP_DEPS)),)
UP_INPUT := $(patsubst $(UP_DEPS)/%,%,$(UP_INPUT))
UP_FLAGS := -I. $(filter-out -I$(UP_DEPS),$(UP_FLAGS))
endif
ifneq ($(strip $(UC_DEPS)),)
UC_INPUT := $(patsubst $(UC_DEPS)/%,%,$(UC_INPUT))
UC_FLAGS := -I. $(filter-out -I$(UC_DEPS),$(UC_FLAGS))
endif
ifneq ($(strip $(PT_DEPS)),)
PT_INPUT := $(patsubst $(PT_DEPS)/%,%,$(PT_INPUT))
PT_FLAGS := -I. $(filter-out -I$(PT_DEPS),$(PT_FLAGS))
endif
ifneq ($(strip $(NJ_DIR)),)
NJ_FLAGS := -I. $(filter-out -I$(NJ_DEPS),$(NJ_FLAGS))
define C01_NJ_RULE
$(NJ_DIR)/$(1).o: integration/native/$(1).c integration/native/$(1).h integration/consolidation/current-tree.mk | native-job-check $(NJ_DIR)
	$$(CC) $$(NJ_FLAGS) $$(NJ_WARN) -c integration/native/$(1).c -o $$@
endef
$(foreach s,$(NJ_DEP_INPUTS),$(eval $(call C01_NJ_RULE,$(s))))
endif
