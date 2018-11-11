PROJ_NAME = BlueSpec RISC-V Bitmanip
PROJ_HOME = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

#################################################
##                                             ##
##  Build Options                              ##
##                                             ##
#################################################

XLEN ?= 32# set default to 32 or 64 bit
#HW_DBG = on # enables nice debug prints in HW simulation
TEST_VERBOSE = on # enables info to come out of tests

#################################################
##                                             ##
##  Test Controls                              ##
##                                             ##
#################################################

TEST_COUNT ?= 16  # Number of tests to run

TB_DIR  = $(PROJ_HOME)/tb$(XLEN)

#################################################
##                                             ##
##  Verilog Generation Controls                ##
##                                             ##
#################################################

VERILOG = $(PROJ_HOME)/veri$(XLEN)

#################################################
##                                             ##
##  Bluespec Controls                          ##
##                                             ##
#################################################

BSC ?= bsc
BSC_DEFINES = -D RV$(XLEN) -D TEST_COUNT=$(TEST_COUNT)
ifdef TEST_VERBOSE
  BSC_DEFINES += -D TEST_VERBOSE
  ifdef HW_DBG
    BSC_DEFINES += -D HW_DBG
  endif
endif
BSV_INC = -p $(SRC_DIR):$(TEST_DIR):+

BSC_TEST_0 = -u -sim
BSC_TEST_1 = -sim -e

VERI_LIB = $(BLUESPECDIR)/Verilog
VERIMAIN = $(VERI_LIB)/main.v

#################################################
##                                             ##
##  Utility Build                              ##
##                                             ##
#################################################

UTIL     = $(PROJ_HOME)/util
BRAM_DIR = $(TB_DIR)/bram
#UTIL_DBG = on # enable if we want gdb to debug bram C stuff
BRAM_GEN = $(UTIL)/bramGen$(XLEN)

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: help

.PHONY: utils
utils:
	@echo "  ********* Building Utils *********"
	$(MAKE) -C $(UTIL) all UTIL_DBG=$(UTIL_DBG)

.PHONY: utils-rebuild
utils-rebuild:
	@echo "  ********* Rebuilding Utils *********"
	$(MAKE) -C $(UTIL) rebuild UTIL_DBG=$(UTIL_DBG)

$(TB_DIR):
	@echo " *************** $(PROJ_NAME) $(XLEN)bit Testbench Dir **************"
	mkdir -p $(TB_DIR)

bram: utils $(TB_DIR)
	@echo " *************** $(PROJ_NAME) $(XLEN)bit BRAM Generation ************"
	mkdir -p $(BRAM_DIR)
	cd $(BRAM_DIR) && $(BRAM_GEN) $(TEST_COUNT) 

.PHONY: clean
clean:
	rm -rf tb32 tb64 veri32 veri64

.PHONY: help
help:
	@echo "Make file path : $(PROJ_HOME)"
