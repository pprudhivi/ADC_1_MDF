###############################################################################
# Get the Makefile running directory 
###############################################################################
MAKE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

###############################################################################
# Include External Makefile Options
###############################################################################
include make_flavor.mak
include make_cfg.mak

# START {
###############################################################################
# Standard Make Variables
###############################################################################
# Path to compiler ROOT
COMPILER_PATH=$(COMP_PATH_HOME)

# Path to linker ROOT
LINKER_PATH=$(COMP_PATH_HOME)

# Build Verbose Level
#   VERBOSE
# Note: 'VERBOSE' variable is defined on command-line, if enabled
ifdef VERBOSE
   $(warning VERBOSE is ON)
endif

#==============================================================================
# Additional  Variables:
#==============================================================================
#  API version string
API_VERSION = "1.0"

# List of  API targets supported in this makefile
API_TARGETS += show_api_version
API_TARGETS += show_api_targets
API_TARGETS += show_roster_ids
API_TARGETS += show_builds
API_TARGETS += clean
API_TARGETS += build_thru_link-all

###############################################################################
# Standard Make Variables
###############################################################################
# END  }

###############################################################################
# Compiler/Linker Tool Path
###############################################################################
ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))
COMP_PATH_BIN=$(COMPILER_PATH)
COMP_PATH_INC=$(COMPILER_PATH)/ansi
COMP_PATH_LIB=$(COMPILER_PATH)/lib/arm64
endif

ifeq ($(C_FLAVOR), host)
COMP_PATH_BIN=$(COMPILER_PATH)
COMP_PATH_INC=$(COMPILER_PATH)
COMP_PATH_LIB=$(COMPILER_PATH)
endif
#TODO: COMP_PATH_LIB=$(COMPILER_PATH)/lib/rh850_22
#TODO: COMP_PATH_LIB=$(COMPILER_PATH)/lib/rh850_22p
#TODO: COMP_PATH_LIB=$(COMPILER_PATH)/lib/intrh850
LINK_PATH_BIN=$(LINKER_PATH)




ifeq ($(C_FLAVOR), host)
MAP_DIR:=$(LINUX_PROG_DIR)_release/$(OUTPUT_MAP)

LINUX_PROG_DIR:=$(MAKE_DIR)
endif

ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))

MAP_DIR:=$(WIN_PROG_DIR)_release/$(OUTPUT_MAP)

WIN_PROG_DIR:=$(subst /mnt/c,C:,$(MAKE_DIR))

COMPILER = $(COMP_PATH_HOME)ccarm.exe
endif
 
PROJ_DIR:= $(LINUX_PROG_DIR)$(WIN_PROG_DIR)
 
###############################################################################
# Special Makefile defines to escape characters
###############################################################################
comma := ,
space := 
space += 
PRINT_LINE := @echo

###############################################################################
# Shell Commands
###############################################################################
MV=mv -f
CP=cp
RM=rm -f
CAT=cat

###############################################################################
# Object Lists
###############################################################################

#TBD GA To verify how the objets are required to be created
BUILD_OBJS  = $(USER_OBJS)
#TODO: BUILD_OBJS += rompcrt.obj
#TODO:PZB BUILD_OBJS += $(CRT_OBJ)
#/BUILD_OBJS

# Set INCFLAGS to VPATH, but substituting ':' for ' ' and adding '-I'
INCFLAGS:=
WIN_INCFLAGS:= 

###############################################################################
# Tool Options
###############################################################################
#--------------------------------------------------------------------------
# Compiler
COMPILER:=$(CC)
INCFLAGS:=$(patsubst %,-I%,$(subst :, ,$(VPATH)))

ifeq ($(C_FLAVOR), host)
LINUX_OUT_INCFLAGS:=$(INCFLAGS)
LINUX_C_INCFLAGS:=$(LINUX_OUT_INCFLAGS) -c
endif

ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))

VPATH :=$(subst /mnt/c,C:,$(VPATH))

WIN_INCFLAGS :=$(subst /mnt/c,C:,$(INCFLAGS)) 

COMPILER = $(COMP_PATH_HOME)ccarm.exe
endif

OUT_INCLUDES :=$(WIN_INCFLAGS)$(LINUX_OUT_INCFLAGS)
C_INCLUDES :=$(WIN_INCFLAGS)$(LINUX_C_INCFLAGS)

#--------------------------------------------------------------------------
# DEBUG options

# Debug flags that support CubeSuite+ or GHS MULTI debug projects
ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))
#TBD GA Verify if reserving the R2 for user is required 
DEBUG_FLAGS =
#-g
#DEBUG_FLAGS += -dual_debug
endif

#--------------------------------------------------------------------------
# Register mode options:
REGMODE_FLAGS =
#REGMODE_FLAGS += -registermode=22
#REGMODE_FLAGS += -r20has255   # R20=0xFF   (255)
#REGMODE_FLAGS += -r21has65535 # R21=0xFFFF (65535)
#TODO:SWCST:

#--------------------------------------------------------------------------
# Compile flags
BASE_CFLAGS = -nostartfiles

ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))
BASE_CFLAGS += $(DEBUG_FLAGS)
BASE_CFLAGS += -cpu=$(CPU_TYPE)

BASE_CFLAGS += -noobj
BASE_CFLAGS += -nofloatio

# Assembly options
#BASE_ASM_CFLAGS += -asm=-nofpu    # No FPU instructions: error if found
BASE_ASM_CFLAGS += -asm=-V
# Print version number of assembler
BASE_ASM_CFLAGS += -asm=-nomacro
# No macro expansion in assembly
BASE_CFLAGS += $(BASE_ASM_CFLAGS)

# Target options
BASE_CFLAGS += -nopic
# Position Independent Code (PIC) is OFF [default]
BASE_CFLAGS += -nopid
# Position Independent Data (PID) is OFF [default]

BASE_CFLAGS += -callgraph
# Generate call graph (*.graph) file

# Optimization settings
BASE_CFLAGS += -Onoipa
# Disables all interprocedural optimizations
BASE_CFLAGS += -Onoprintfuncs
# No printf optimization

# Link optimizations
BASE_CFLAGS += -Onolink
# Disables linker optimizations
#BASE_CFLAGS += -Olink
# Enables linker optimizations

# Inlining optimizations
BASE_CFLAGS += -Onoinline
# Disables intermodule (two-pass) inlining

BASE_CFLAGS += -Onomax
#BASE_CFLAGS += -Omax

# Memory optimizations
BASE_CFLAGS += --no_commons

# General optimization
BASE_CFLAGS += -Ogeneral

endif


CFLAGS      = $(BASE_CFLAGS)

CFLAGS     += -D__asm= 
CFLAGS     += -D__attribute= 
CFLAGS     += -D__interrupt= 

ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))
CFLAGS += 
endif

#--------------------------------------------------------------------------
# Linker flags
LDFLAGS =

ifneq ( , $(filter $(C_FLAVOR), $(GHS_REQ)))
LDFLAGS += -cpu=$(CPU_TYPE)
LDFLAGS += -map=$(MAP_DIR)
LDFLAGS += -Mn
LDFLAGS += -Mu
LDFLAGS += -MD
LDFLAGS += -gsize
LDFLAGS += -check=none

ifdef BB_TASK 
LDFLAGS += -e $(OUTPUT)_task.c
endif
endif

ifeq ($(C_FLAVOR), host)
LDFLAGS += 
endif

###############################################################################
# Environment arragements
###############################################################################



###############################################################################
# Build Rules
###############################################################################
.phony: clean release bench deps $(API_TARGETS)

$(OUTPUT_BIN) : $(BUILD_OBJS)
	$(PRINT_LINE)
	$(PRINT_LINE) ----------------------- COMPILE OUT--------------------------
#	$(PRINT_LINE)
	$(PRINT_LINE) VPATH:            $(VPATH)
	$(PRINT_LINE) MAKE_DIR:         $(MAKE_DIR)
	$(PRINT_LINE) INCLUDES:         $(OUT_INCLUDES)
	$(PRINT_LINE) Compiler flags:   $(CFLAGS)
	$(PRINT_LINE) Compiler info:    $(COMPILER)  
	$(PRINT_LINE) $(C_FLAVOR)
	$(PRINT_LINE)
	$(COMPILER) $(LDFLAGS) $(CFLAGS) $(BUILD_OBJS) $(OUT_INCLUDES) -o _release/$(OUTPUT_BIN)
	$(MV) $(MAKE_DIR)*.o $(MAKE_DIR)_release

#  Target to build only through link step (then stop)
build_thru_link-all: $(OUTPUT_BIN)

clean:
	-$(RM) $(OUTPUT_HEX)
	-$(RM) $(PROJ_DIR)_release/$(OUTPUT_BIN)
	-$(RM) $(PROJ_DIR)_release/$(OUTPUT_MAP)
	-$(RM) $(PROJ_DIR)_release/$(OUTPUT).cref
	-$(RM) $(PROJ_DIR)_release/$(OUTPUT).graph
	-$(RM) $(PROJ_DIR)_release/$(OUTPUT_DLA)
	-$(RM) $(PROJ_DIR)_release/$(OUTPUT_DNM)
	-$(RM) $(PROJ_DIR)_release/*.dep
	-$(RM) $(PROJ_DIR)_release/*.siz
	-$(RM) $(PROJ_DIR)_release/*.o
	-$(RM) $(PROJ_DIR)*.o ./_out
	-$(RM) $(PROJ_DIR)*.dbo ./_out

deps:
	gcc -MM $(INCFLAGS) $(XCFLAGS) $(wildcard *.c) \
	     $(wildcard $(patsubst %,%/*.c,$(subst :, ,$(VPATH)))) > $(DEPFILE)

###############################################################################
# swrlse targets
###############################################################################

# swrlse_ccm.pl to release (level control, with bundle)
release:
	$(shell cmd /c start "http://release.delcoelect.com/rlsein/index.html")

###############################################################################



###############################################################################
# Help and extras
###############################################################################
help:
	$(PRINT_LINE) Objects:   $(BUILD_OBJS)
	$(PRINT_LINE) Compiler:  $(CC)
	$(PRINT_LINE) C Flags:   $(CFLAGS)
	$(PRINT_LINE) Make Path: $(MAKE_DIR)
	$(PRINT_LINE) TARGETs available:   host, target_check, amber_i4l

###############################################################################
# Cal-DS dependencies }
###############################################################################

.SUFFIXES:
.SUFFIXES: .c .o .i .glint
.SUFFIXES: .s
.SUFFIXES: .850
.SUFFIXES: .800
.SUFFIXES: .lst

.c.o:
	@echo ------------------------------- objects -------------------------------
	$(PRINT_LINE) Linker flags:     $(HOST_ARCH)
	$(COMPILER) $(CFLAGS) $(OUT_INCLUDES) -c $< 

$(BUILD_OBJS): makefile make_cfg.mak

# dependency for C run-time object
$(CRT_OBJ): $(CRT_DEPS)

###############################################################################
# The make dependencies have been moved to the file $(DEPFILE).
# The following procedure will update the make dependencies.
# 1) check out $(DEPFILE)
# 2) make deps
###############################################################################
#include $(DEPFILE)


