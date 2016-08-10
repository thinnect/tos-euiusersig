COMPONENT=UsigTestC

$(info --------------------------------------------------------------------------------)
ifndef WORKSPACE_ROOT
    $(error Please define WORKSPACE_ROOT)
endif
$(info WORKSPACE_ROOT      $(WORKSPACE_ROOT))
$(info --------------------------------------------------------------------------------)

# Avoid strange TinyOS issues
PFLAGS += -DTASKLET_IS_TASK

CFLAGS += -I$(PWD)

#CFLAGS += -I$(DIR_TOSGROUNDLIB)/tos/toslogging/boot_info

$(info --------------------------------------------------------------------------------)

PLATFORM_BAUDRATE ?= 500000UL
BASE_LOG_LEVEL ?= 0xFFFF

AVR_FUSE_H ?= 0x88
AVR_FUSE_E ?= 0xF8

TOSH_DATA_LENGTH ?= 110

#CFLAGS += -I$(DIR_SHARED_TOS)/lib/watchdog

# External watchdog
# EXTERNAL_WATCHDOG_TOGGLE_PERIOD ?= 15360

LOW_POWER_LISTENING ?= 1

# Radio conf
RADIO_CHANNEL ?= 25

# ------------------------------------------------------------------------------

include $(TINYOS_ROOT_DIR)/Makefile.include
$(call TOSMake_include,extras/groundlib.extra)
$(call TOSMake_include,extras/watchdogs.extra)
$(call TOSMake_include,extras/euiusersig.extra)
$(info --------------------------------------------------------------------------------)
