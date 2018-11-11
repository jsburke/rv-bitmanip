PROJ_NAME = Bluespec Sources

#################################################
##                                             ##
##  Compiler Controls                          ##
##                                             ##
#################################################

XLEN        ?= 32
TEST_COUNT  ?= 16
#TEST_VERBOSE = on

BSC ?= bsc

BSC_DEFINES = -D RV$(XLEN)

BLUESIM_DEFINES = -D TEST_COUNT=$(TEST_COUNT)
ifdef TEST_VERBOSE
  BLUESIM_DEFINES += -D TEST_VERBOSE
  ifdef HW_DBG
    BLUESIM_DEFINES += -D HW_DBG
  endif
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

TB     = genericTb
BSV_TB = $(TB).bsv

INSNS  = clz ctz pcnt andc slo sro rol ror grev shfl unshfl bext bdep

TB_BINARIES = $(addsuffix Tb, $(INSNS))
TB_SHARED   = $(addsuffix .so, $(TB_BINARIES))
TB_RESIDUES = *.bo *.ba *.cxx *.h *.o

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: all

.PRECIOUS: $(TB_BINARIES) $(TB_SHARED)

%Tb:
	@echo "   ******* BSV : Building $@ *******"
	$(BSC) $(BSC_DEFINES) -D TEST_$* $(BLUESIM_DEFINES) $(BLUESIM_S1) $(BSV_TB)
	$(BSC) $(BLUESIM_S2) mkGenericTb -o $(TB) *.ba
	mv $(TB) $@
	mv $(TB).so $@.so

.PHONY: all
all: 
	@echo "   ******* BSV : Building all $(XLEN) bit Testbenches *******"
	make $(TB_BINARIES)
	make clean

.PHONY: rebuild
rebuild:
	@echo "   ******* BSV : Fresh Build ******* "
	make full-clean
	make all
	
.PHONY: clean
clean:
	@echo "   ******* BSV : cleaning dir ******* "
	rm -rf $(TB_RESIDUES)

.PHONY: full-clean
full-clean: clean
	@echo "   ******* BSV : complete cleanup ******* "
	rm -rf $(TB_BINARIES) $(TB_SHARED) *.so

.PHONY: help
help:
	@echo " "
	@echo "   ******* $(PROJ_NAME) HELP ******* "
	@echo " "
	@echo "     Targets"
	@echo " "
	@echo "     [INSN]Tb {XLEN=[32,64]} {TEST_COUNT=int}"
	@echo "              {TEST_VERBOSE=on} {HW_DBG=on}"
	@echo " "
	@echo "       Builds bluesim test bench and .so for INSN"
	@echo " "
	@echo "   ************ ALIASES ************* "
	@echo " "
	@echo "     all (default) --- build bluesim Tb for all insns"
	@echo " "
	@echo "     clean ----------- delete bsc generated files"
	@echo " "
	@echo "     full-clean ------ clean and delete binaries and .so"
	@echo " "
	@echo "     rebuild --------- full-clean then all"
	@echo " "
	@echo "     help ------------ print this message"
	@echo " "
