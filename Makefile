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
##  Utility Build                              ##
##                                             ##
#################################################

UTIL     = $(PROJ_HOME)/util
BRAM_DIR = $(TB_DIR)/bram
#UTIL_DBG = on # enable if we want gdb to debug bram C stuff
BRAM_GEN = $(UTIL)/bramGen$(XLEN)

#################################################
##                                             ##
##  Bluespec Build                             ##
##                                             ##
#################################################

BSV = $(PROJ_HOME)/bsv
BSC_FLAGS = XLEN=$(XLEN) TEST_COUNT=$(TEST_COUNT)
ifdef TEST_VERBOSE
BSC_FLAGS += TEST_VERBOSE=on
ifdef HW_DBG
BSC_FLAGS += HW_DBG=on
endif
endif

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: all

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

%Tb: $(TB_DIR)
	@echo " ********* $(PROJ_NAME): Building $(XLEN) bit $* Testbench **********"
	$(MAKE) -C $(BSV) $@ $(BSC_FLAGS)
	mv $(BSV)/$** $(TB_DIR)

PHONY: test-all
test-all: $(TB_DIR)
	@echo " ********** $(PROJ_NAME): Building all $(XLEN) bit Testbenches *********"
	$(MAKE) -C $(BSV) all $(BSC_FLAGS)
	mv $(BSV)/*Tb  $(TB_DIR)
	mv $(BSV)/*.so $(TB_DIR)

.PHONY: all
all:
	make utils
	make bram
	make bram XLEN=64
	make test-all
	make test-all XLEN=64

.PHONY: clean
clean:
	rm -rf tb32 tb64 veri32 veri64

.PHONY: full-clean
full-clean: clean
	$(MAKE) -C $(UTIL) clean
	$(MAKE) -C $(BSV)  full-clean

.PHONY: help
help:
	@echo "Make file path : $(PROJ_HOME)"
