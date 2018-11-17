PROJ_NAME = Bluespec Sources

#################################################
##                                             ##
##  Compiler Controls                          ##
##                                             ##
#################################################

XLEN        ?= 32
TEST_COUNT  ?= 16
#TEST_VERBOSE = on
#HW_DIAG      = on

BSC ?= bsc

BSC_DEFINES = -D RV$(XLEN)

BLUESIM_DEFINES  = -D TEST_COUNT=$(TEST_COUNT)

ifdef TEST_VERBOSE
BLUESIM_DEFINES += -D TEST_VERBOSE
endif
ifdef HW_DIAG
BLUESIM_DEFINES += -D HW_DIAG
endif

BLUESIM_S1 = -u -sim
BLUESIM_S2 = -sim -e

# BLUESPEC_DIR should be set up as bluespec describes
VERILOG_LIB = $(BLEUSPEC_DIR)/Verilog
VERIMAN     = $(VERILOG_LIB)/main.v

#################################################
##                                             ##
##  Files and Results                          ##
##                                             ##
#################################################

TB     = ModuleTb
BSV_TB = $(TB).bsv

TB_RESIDUES = *.bo *.ba *.cxx *.h *.o

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: ModuleTb

ModuleTb:
	$(BSC) $(BSC_DEFINES) $(BLUESIM_DEFINES) $(BLUESIM_S1) $(BSV_TB)
	$(BSC) $(BLUESIM_S2) mk$(TB) -o $(TB) *.ba

.PHONY: rebuild
rebuild:
	make clean
	make ModuleTb 
	
.PHONY: clean
clean:
	rm -rf $(TB_RESIDUES)

.PHONY: help
help:
	@echo " "
	@echo "   ******* $(PROJ_NAME) HELP ******* "
	@echo " "
	@echo "     Targets"
	@echo " "
	@echo "     (default) "
	@echo "     ModuleTb {XLEN=[32,64]} {TEST_COUNT=int}"
	@echo "              {TEST_VERBOSE=on} {HW_DIAG=on}"
	@echo " "
	@echo "       Builds bluesim test bench and .so"
	@echo " "
	@echo "   ************ ALIASES ************* "
	@echo " "
	@echo "     clean ----------- delete bsc generated files"
	@echo " "
	@echo "     rebuild --------- full-clean then all"
	@echo " "
	@echo "     help ------------ print this message"
	@echo " "
