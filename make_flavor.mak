###############################################################################
# Select flavor and set required configurations
###############################################################################
C_FLAVOR = host

ifeq (target_check, $(TARGET))
C_FLAVOR = target_check
endif

ifeq (amber_i4l, $(TARGET))
C_FLAVOR = ghs_arm64
endif

GHS_REQ = target_check ghs_arm64

###############################################################################

###############################################################################
# Detect Host Architecture
###############################################################################
# win64 = 64-bit Windows (i.e., uses WOW64 to emulate 32-bit on 64-bit OS)
# win32 = 32-bit Windows (i.e., supports 32-bit natively)
#
# Note: tested on:
# win64 = 64-bit Windows 7 Enterprise SP1
# win32 = 32-bit Windows XP Professional SP3

ifdef PROCESSOR_ARCHITEW6432
HOST_ARCH=win64
ifdef DEBUG_HOST_ARCH
$(warning HOST_ARCH=$(HOST_ARCH) as PROCESSOR_ARCHITEW6432 defined)
endif
else
ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
HOST_ARCH=win64
ifdef DEBUG_HOST_ARCH
$(warning HOST_ARCH=$(HOST_ARCH) as PROCESSOR_ARCHITECTURE=$(PROCESSOR_ARCHITECTURE))
endif
else
HOST_ARCH=win32
ifdef DEBUG_HOST_ARCH
$(warning HOST_ARCH=$(HOST_ARCH) as PROCESSOR_ARCHITECTURE=$(PROCESSOR_ARCHITECTURE))
endif
endif
endif

ifeq ($(HOSTTYPE),x86_64)
HOST_ARCH=linux
ifdef DEBUG_HOST_ARCH
$(warning HOST_ARCH=$(HOST_ARCH) as PROCESSOR_ARCHITECTURE=$(PROCESSOR_ARCHITECTURE))
endif
endif

ifdef DEBUG_HOST_ARCH
$(warning HOST_ARCH              = [$(HOST_ARCH)])
$(warning PROCESSOR_ARCHITECTURE = [$(PROCESSOR_ARCHITECTURE)])
$(warning PROCESSOR_ARCHITEW6432 = [$(PROCESSOR_ARCHITEW6432)])
endif

###############################################################################

###############################################################################
# Confirm if HOST_ARCH is a supported value
###############################################################################
ifeq (,$(filter $(HOST_ARCH),win32 win64 linux))

$(error HOST_ARCH not valid: [$(HOST_ARCH)])

else # $(HOST_ARCH) is supported

#---------------------------------------------------------------------------
# Settings for 64-bit Windows
#---------------------------------------------------------------------------
ifeq ($(HOST_ARCH),win64)
# 64-bit Cygwin ROOT
CYGWIN_PATH_ROOT=c:/cygwin64

# 64-bit path to perl 5.16.3 64-bit
# (install ActiveState perl to "c:/bin/release/perl5.16.3_64")
PERL_EXE=$(SWRLSE_PATH)/perl5.16.3_64/bin/perl.exe

# 64-bit Windows 32-bit ROOT
PROGRAMFILES32_PATH_ROOT='C:/Program Files (x86)'
endif
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Settings for 32-bit Windows
#---------------------------------------------------------------------------
ifeq ($(HOST_ARCH),win32)
# 32-bit Cygwin ROOT
CYGWIN_PATH_ROOT=c:/cygwin

# 32-bit path to perl 5.6.1
# (install ActiveState perl to "c:/bin/release/perl5.6.1")
PERL_EXE=$(SWRLSE_PATH)/perl5.6.1/bin/perl.exe

# 32-bit Windows 32-bit ROOT
PROGRAMFILES32_PATH_ROOT='C:/Program Files'
endif
#---------------------------------------------------------------------------
endif
###############################################################################