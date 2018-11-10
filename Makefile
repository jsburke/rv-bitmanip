PROJ_NAME = BlueSpec RISC-V Bitmanip

#################################################
##                                             ##
##  Build Options                              ##
##                                             ##
#################################################

XLEN ?= 32  # set default to 32 or 64 bit
#HW_DBG = on # enables nice debug prints in HW simulation
TEST_VERBOSE = on # enables info to come out of tests

#################################################
##                                             ##
##  Test Options                               ##
##                                             ##
#################################################

TEST_COUNT ?= 16  # Number of tests to run

#################################################
##                                             ##
##  Project Management                         ##
##                                             ##
#################################################

SRC_DIR   = main/src
TEST_DIR  = main/test

  # directories for local testbench and generated
  # verilog
UTIL      = ./util
TB_DIR    = ./tb
VERI_DIR  = ./verilog

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

#UTIL_DBG = on # enable if we want gdb to debug bram C stuff

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


.PHONY: help
help:
	@echo "$(PROJ_NAME) Instructions"
	@echo " "
	@echo "************ Targets ************"
	@echo " "
	@echo "  <INSN>Tb [XLEN={32|64}] [TEST_COUNT=<int>] [TEST_VERBOSITY=on] [HW_DBG=on]"
	@echo "    - generate testbench for instruction INSN"
	@echo "    - default 32 bit, 16 test inputs"
	@echo " "
	@echo "  launch-<INSN> [XLEN={32|64}] [TEST_COUNT=<int>] [TEST_VERBOSITY=on] [HW_DBG=on]"
	@echo "    - generate testbench for instruction INSN"
	@echo "    - default 32 bit, 16 test inputs"
	@echo "    - launch the test automatically"
	@echo " "
	@echo "  full-test [TEST_COUNT=<int>] [TEST_VERBOSITY=on] [HW_DBG=on]"
	@echo "    - launches all tests, 32 bit then 64 bit"
	@echo "    - default 16 tests, non-verbose"
	@echo " "
	@echo "  clean"
	@echo "    - deletes build directories"
	@echo " "
	@echo "  help  (defualt option)"
	@echo "    - print this message "
	@echo " "
	@echo "************ Aliases ************"
	@echo " "
	@echo "  retest-<INSN> [...]"
	@echo "    - make clean then make <INSN>Tb ..."
	@echo " "
	@echo "  relaunch-<INSN> [...]"
	@echo "     - make clean then make launch-INSN ..."
	@echo " "

.PHONY: clean
clean:
	rm -rf $(TB_DIR)
	rm -rf $(VERI_DIR)

# really borked something?  This should put you even with the home repo
.PHONY: full-clean
full-clean: clean
	rm -rf $(UTIL_DIR)
