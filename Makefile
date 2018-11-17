PROJ_NAME = BlueSpec RISC-V Bitmanip
PROJ_HOME = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

#################################################
##                                             ##
##  Build Options                              ##
##                                             ##
#################################################

XLEN ?= 32# set default to 32 or 64 bit

#################################################
##                                             ##
##  General Test Controls                      ##
##                                             ##
#################################################

TEST_COUNT ?= 16    # Number of tests to run

TB_DIR  = $(PROJ_HOME)/tb$(XLEN)
BSC_FLAGS = XLEN=$(XLEN) TEST_COUNT=$(TEST_COUNT)

#HW_DBG = on # enables nice debug prints in HW simulation (archive dir only)
TEST_VERBOSE = on # enables info to come out of tests
HW_DIAG      = on # enables stat prints, cycle reg in bit manip modules

ifdef TEST_VERBOSE
BSC_FLAGS += TEST_VERBOSE=on
endif

#################################################
##                                             ##
##  Normal Module Test Specific                ##
##                                             ##
#################################################

BSV = $(PROJ_HOME)/bsv
ifdef HW_DIAG
BSC_FLAGS += HW_DIAG=on
endif

#################################################
##                                             ##
##  Archive Test Specific                      ##
##                                             ##
#################################################

ARCH_DIR  = $(PROJ_HOME)/archive

INSNS     = clz ctz pcnt andc slo sro rol ror grev shfl unshfl bext bdep
LAUNCHERS = $(addprefix launch-, $(INSNS))

ifdef TEST_VERBOSE
ifdef HW_DBG
BSC_FLAGS += HW_DBG=on
endif
endif

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
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: all

.PHONY: utils
utils:
	$(MAKE) -C $(UTIL) all UTIL_DBG=$(UTIL_DBG)

.PHONY: utils-rebuild
utils-rebuild:
	$(MAKE) -C $(UTIL) rebuild UTIL_DBG=$(UTIL_DBG)

$(TB_DIR):
	mkdir -p $(TB_DIR)

bram: utils $(TB_DIR)
	mkdir -p $(BRAM_DIR)
	cd $(BRAM_DIR) && $(BRAM_GEN) $(TEST_COUNT) 

ModuleTb: $(TB_DIR)
	$(MAKE) -C $(BSV) $@ $(BSC_FLAGS)
	mv $(BSV)/$@ $(TB_DIR)
	mv $(BSV)/$@.so $(TB_DIR)

# archival targets
%Tb: $(TB_DIR)
	@echo "********* ARCHIVED CODE USAGE **********"
	$(MAKE) -C $(ARCH_DIR) full-clean
	$(MAKE) -C $(ARCH_DIR) $@ $(BSC_FLAGS)
	mv $(ARCH_DIR)/$** $(TB_DIR)

.PHONY: launch-%
launch-%: %Tb bram
	@echo "********* ARCHIVED CODE USAGE **********"
	cd $(TB_DIR) && ./$*Tb

.PHONY: launch-all
launch-all: all
	@echo "********* ARCHIVED CODE USAGE **********"
	make $(LAUNCHERS)
	make $(LAUNCHERS) XLEN=64

.PHONY: test-all
test-all: $(TB_DIR)
	@echo "********* ARCHIVED CODE USAGE **********"
	$(MAKE) -C $(ARCH_DIR) all $(BSC_FLAGS)
	mv $(ARCH_DIR)/*Tb  $(TB_DIR)
	mv $(ARCH_DIR)/*.so $(TB_DIR)
# end archival targets

.PHONY: all
all:
	make utils
	make bram
	make bram XLEN=64
	make ModuleTb
	$(MAKE) -C $(BSV) clean
	make ModuleTb XLEN=64

.PHONY: clean
clean:
	rm -rf tb32 tb64 veri32 veri64

.PHONY: full-clean
full-clean: clean
	$(MAKE) -C $(UTIL) clean
	$(MAKE) -C $(BSV)  clean
	$(MAKE) -C $(ARCH_DIR) full-clean

.PHONY: help
help:
	@echo " ******* $(PROJ_NAME) ******* "
	@echo " "
	@echo "  Targets"
	@echo " "
	@echo "  utils ------------------------------------- Build the bramGen Programs"
	@echo " "
	@echo "  utils-rebuild ----------------------------- clean then" 
	@echo "                            rebuild the bramGen Programs"
	@echo " "
	@echo "  bram [XLEN=[32,64]] [TEST_COUNT=int] ------ generate brams"
	@echo " "
	@echo "  [INSN]Tb [XLEN=[32,64]] [TEST_COUNT=int] -- make Test for INSN"
	@echo " "
	@echo "  test-all [XLEN=[32,64]] [TEST_COUNT=int] -- make all tests"
	@echo " "
	@echo "  all (default) ----------------------------- make everything"
	@echo " "
	@echo "  clean ------------------------------------- delete build dirs"
	@echo " "
	@echo "  full-clean -------------------------------- set repo back to clone state"
	@echo " "
	@echo "  help -------------------------------------- print this"
	@echo " "
