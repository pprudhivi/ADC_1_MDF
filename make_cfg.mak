###############################################################################
# Set CPU and MCU Options
###############################################################################
CPU_TYPE :=cortexr5f
MCU_ID   =

# Target Parameters
OUTPUT   =bb_ADC
BIN_EXT  =bin

OUTPUT_HEX = $(OUTPUT).hex
OUTPUT_BIN = $(OUTPUT).$(BIN_EXT)

#TBD GA to verify need
OUTPUT_MAP = $(OUTPUT).map
OUTPUT_DLA = $(OUTPUT).dla
OUTPUT_DNM = $(OUTPUT).dnm

###############################################################################
# Tool Paths
###############################################################################

# Compiler
ifeq ($(C_FLAVOR), host)
COMP_PATH_HOME_TEMP= 
endif

ifeq ($(C_FLAVOR), target_check)
COMP_PATH_HOME_TEMP:=/mnt/c/ghs/comp_201416/
endif

ifeq ($(C_FLAVOR), ghs_arm64)
COMP_PATH_HOME_TEMP:=/mnt/c/ghs/comp_201416/
endif

ifneq ( ,$(filter $(HOST_ARCH), win64 win32))
COMP_PATH_HOME:=$(subst mnt,cygdrive,$(COMP_PATH_HOME_TEMP))
else
COMP_PATH_HOME:=$(COMP_PATH_HOME_TEMP)
endif

###############################################################################
# C Run-Time Object
###############################################################################

###############################################################################
# Link First Object List
#
# The following are objects that must be linked before the user objects.
###############################################################################

###############################################################################
# User Object List
#
# The following are objects for files that are in the root directory.  This
# list may also contain objects for subprojects that do not have a makefile.
# The order of the objects is significant.  Objects will be linked in the
# order listed.  Objects that begin with cal_ or end with _cal are compiled
# as calibration files.
###############################################################################


###############################################################################
# VPATH for subprojects that do not have make files
#
# VPATH defines the search directory used to find source code during the buld.
# All subdirectories that contain source code must be added to VPATH.
###############################################################################

VPATH :=$(VPATH): 02_cfg
include $(MAKE_DIR)04_support/bb_common/bb_common.mak

###############################################################################
# Include Subproject Makefiles
###############################################################################
include $(MAKE_DIR)03_building_block/bb_ADC/bb_ADC.mak



