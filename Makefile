#
# Basic makefile that compile the runtime and project files in src folder
# Author: Banshaku
# Version 0.9.5:
#  - 2018-09-18
#    + decided to add revision history 
#    + Jarhmander fixed issue with deps. now uses CL instead
#  - 2018-09-20
#    + for some reason cl65 fails for .s files. reverted AS to ca65 and now it works
#
# TODO: 
#  - Flag for add debug info or not?
# 
# Include neslib and famitone in a folder inside lib and crt0 in any folder inside src.
#
# [Example]
# libs/neslib
#  - neslib.s
#  - neslib.h
# libs/famitone
#  - famitone2.s
# src/crt
#  - crt0.s
#
# Note:
# - The files from data can be moved to src folder without issue
# - To compile runtime.lib (C runtime), you need to have a cloned version of cc65 which is available
#   at https://github.com/cc65/cc65. The version from your linux distribution or homebrew (for mac osx)
#   usually does not contain the libsrc/runtime folder.
# - If for some reason you cannot or do not want to get the version from github, the included
#   libsrc folder inside runtime contain all the V2.17 files from version libsrc/runtime and libsrc/common
# - Only the files from runtime/runtime.lst are added to runtime.lib. If you need a specific file,
#   you need to add it manually to this list
# - The path of all folders are added to the incluepath automatically. The advantage is that you do not need
#   to include the path of the file while including file either in c of assembler. There is one compromise: 
#   files cannot have the same name since the compiler will uses the first file it finds. If you do need to 
#   have the same name, you will have to write the relative/absolute path to the file (tested and working).
#
# About the libs folder:
# - For now, the libs folder is for libraries that requires to be included in another source file to work
#   properly. This is the case for famitune and neslib (to some degree). This mean no files are are
#   compiled from this folder: it is only used in include path so it can be included in the proper
#   module/bank etc.


##################
# Target related 
APP_NAME = example
TARGET = $(APP_NAME).nes

##################
# CC65 related
AS := ca65
CC := cl65
LD := ld65
AR := ar65

##################
# Folders related
BUILD_DIR = build
RUNTIME_DIR = runtime
# Use the files downloaded from github
#LIBSRC_DIR = /path_for_cc65_here/libsrc
# Use provided runtime files instead
LIBSRC_DIR = $(RUNTIME_DIR)/libsrc
LIB_DIR = libs
DATA_DIR = data
SRC_DIR = src
RUNTIME_BUILD_DIR = build_runtime

##################
# List of dir, mostly used for include path
SRC_DIR_LIST  := $(SRC_DIR) $(sort $(dir $(wildcard $(SRC_DIR)/**/*/)))
LIB_DIR_LIST  := $(LIB_DIR) $(sort $(dir $(wildcard $(LIB_DIR)/**/*/)))
DATA_DIR_LIST := $(DATA_DIR) $(sort $(dir $(wildcard $(DATA_DIR)/**/*/)))

##################
# Target files related 
C_FILES := $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/**/*.c)
S_FILES := $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/**/*.s)
C_OBJ_FILES := $(addprefix $(BUILD_DIR)/, $(C_FILES:.c=.o))
S_OBJ_FILES := $(addprefix $(BUILD_DIR)/, $(S_FILES:.s=.o))
OBJ_FILES := $(C_OBJ_FILES) $(S_OBJ_FILES)
DEPS := $(OBJ_FILES:.o=.d)
CONFIG_FILE := config/nrom_256_horz.cfg

###########################
# Runtime related
RUNTIME_FILES_LIST := $(shell cat ${RUNTIME_DIR}/runtime.lst)
RUNTIME_OBJ_FILES = $(patsubst %.s, $(RUNTIME_BUILD_DIR)/%.o, $(RUNTIME_FILES_LIST))
RUNTIME_LIB := $(RUNTIME_DIR)/runtime.lib

###################
# Specific compilation flags for famitracker
FT_DEFINES  = -D FT_DPCM_ENABLE=0    # with dpcm
FT_DEFINES += -D FT_SFX_ENABLE=1     # with sound fx
FT_DEFINES += -D FT_THREAD=1         # calls soundfx in a different thread
FT_DEFINES += -D FT_PAL_SUPPORT=1    # PAL support
FT_DEFINES += -D FT_NTSC_SUPPORT=1   # NTSC support
FT_DEFINES += -D FT_SFX_STREAMS=4    # Set all 4 channels for SFX

###################
# Compiler/linker flags
ASFLAGS = -g -I $(SRC_DIR) $(INCLUDE_LIBS_FLAGS) $(INCLUDE_DATA_FLAGS) $(FT_DEFINES)
CCFLAGS = -c -t none --add-source -Oi -Cl -g $(INCLUDE_LIBS_FLAGS)
LDFLAGS = -Ln $(BUILD_DIR)/$(APP_NAME)_labels.txt -m $(BUILD_DIR)/$(APP_NAME)_map.txt --dbgfile $(APP_NAME).dbg -vm
INCLUDE_DATA_FLAGS := $(addprefix -I ,$(DATA_DIR_LIST)) $(addprefix --bin-include-dir ,$(DATA_DIR_LIST)) $(addprefix --bin-include-dir ,$(SRC_DIR_LIST))
INCLUDE_LIBS_FLAGS := $(addprefix -I ,$(SRC_DIR_LIST)) $(addprefix -I ,$(LIB_DIR_LIST))

CREATE_DEP = --create-dep $(@:.o=.d)

###################
# other varibables (external programs etc)
EMULATOR = fceux
EMULATOR_DEBUG = ./scripts/nin.sh
EMULATOR_DEBUG2 = ./scripts/mesen.sh
EMULATOR_DEBUG3 = ./scripts/fceux_win.sh

.PHONY: all runtime run debug clean clean-both clean-runtime

#########################
### Build main target ###
all: $(TARGET)

$(TARGET): $(RUNTIME_LIB) $(OBJ_FILES) 
	$(LD) $(LDFLAGS) -C $(CONFIG_FILE) -o $@ $(OBJ_FILES) $(RUNTIME_LIB) 

#################################################################
### Prints content of variable                                ###
### usage make print-DEPS will show the value of the variable ###
print-%  : ; @echo $* = $($*)

####################################
### Main target files to compile ###
$(C_OBJ_FILES): $(BUILD_DIR)/%.o : %.c
	@mkdir -p $(@D)
	$(CC) $(CCFLAGS) $(CREATE_DEP) -l $(@:.o=)_listing.txt -o $@ $<

$(S_OBJ_FILES): $(BUILD_DIR)/%.o : %.s 
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) $(CREATE_DEP) -l $(@:.o=)_listing.txt -o $@ $<

##########################
### Build runtime only ###
runtime: $(RUNTIME_LIB)

##################################
### Files related to C runtime ###
$(RUNTIME_LIB): $(RUNTIME_OBJ_FILES)
	$(AR) a $@ $^

$(RUNTIME_OBJ_FILES):
	@mkdir -p $(@D)
	$(AS) $(patsubst $(RUNTIME_BUILD_DIR)/%.o, $(LIBSRC_DIR)/%.s, $@) -g -o $@

##################################
### Ways to execute the target ###
run: $(TARGET) 
	$(EMULATOR) ./$<

debug: $(TARGET)
	$(EMULATOR_DEBUG) ./$<

debug2: $(TARGET)
	$(EMULATOR_DEBUG2) ./$<

debug3: $(TARGET)
	$(EMULATOR_DEBUG3) ./$<

######################################
### Cleaning main build only files ###
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TARGET)
	rm -f $(APP_NAME).dbg

###############################################
### Remove current runtime.librelated files ###
clean-runtime:
	rm -f $(RUNTIME_LIB)
	rm -rf $(RUNTIME_BUILD_DIR)

###############################################
### Clean both main build and runtime files ###
clean-both: clean clean-runtime

-include $(DEPS)
