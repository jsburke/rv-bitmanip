PROJ_NAME = BlueSpec RISC-V Bitmanip

#################################################
##                                             ##
##  Build Options                              ##
##                                             ##
#################################################

XLEN ?= 32  # set default to 32 or 64 bit
#HW_DBG = on # enables nice debug prints in HW simulation

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
TB_DIR    = ./tb
VERI_DIR  = ./verilog

TEST_BRAM = $(TB_DIR)/RV$(XLEN)
#TESTS_RAW = $(wildcard $(TEST_DIR)/*.bsv)
#TESTS     = $(filter-out meta,$(patsubst %Tb.bsv,%,$(notdir $(TESTS_RAW))))

BRAM_SCRIPT = bramGen$(XLEN)
TEST_NAME   = genericTb

#################################################
##                                             ##
##  Bluespec Controls                          ##
##                                             ##
#################################################

BSC ?= bsc
BSC_DEFINES = -D RV$(XLEN) -D TEST_COUNT=$(TEST_COUNT)
ifdef HW_DBG
  BSC_DEFINES += -D HW_DBG
endif
BSV_INC = -p $(SRC_DIR):$(TEST_DIR):+

BSC_TEST_0 = -u -sim
BSC_TEST_1 = -sim -e

VERI_LIB = $(BLUESPECDIR)/Verilog
VERIMAIN = $(VERI_LIB)/main.v

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: help

$(TB_DIR):
	@echo "***** Creating Test Bench Dir *****"
	mkdir -p $(TB_DIR)

bramGen%: $(TB_DIR)
	cd $(TEST_DIR) && gcc -DRV$* -c bitmanip.c -o bitmanip$*.o
	cd $(TEST_DIR) && gcc -DRV$* -o $@ bramGen.c bitmanip$*.o
	mv $(TEST_DIR)/$@ $(TB_DIR)
	rm $(TEST_DIR)/*.o

$(TEST_BRAM): $(TB_DIR) bramGen$(XLEN)
	@echo "****** Creating Test Vectors ******"
	rm -rf $(TEST_BRAM) && mkdir -p $(TEST_BRAM) 
	cd $(TB_DIR) && ./$(BRAM_SCRIPT) $(TEST_COUNT)
	mv $(TB_DIR)/*.hex $(TEST_BRAM)

%Tb: $(TEST_BRAM)
	@echo "******* Creating Test Bench *******"
	$(BSC) $(BSC_DEFINES) -D TEST_$* $(BSC_TEST_0) $(BSV_INC) $(TEST_DIR)/genericTb.bsv
	mv $(SRC_DIR)/*.bo  $(TB_DIR)
	mv $(TEST_DIR)/*.ba $(TB_DIR)
	mv $(TEST_DIR)/*.bo $(TB_DIR)
	cd $(TB_DIR) && $(BSC) $(BSC_TEST_1) mkGenericTb -o genericTb *.ba
	cd $(TB_DIR) && mv genericTb $*Tb && mv genericTb.so $*Tb.so 

launch-%: $(TEST_BRAM) %Tb
	@echo "******* Launching Test Bench ******"
	cd $(TB_DIR) && ./$*Tb

retest-%:
	make clean
	make test-$*

relaunch-%:
	make clean
	make launch-$*

.PHONY: help
help:
	@echo "$(PROJ_NAME) Instructions"
	@echo " "
	@echo "************ Targets ************"
	@echo " "
	@echo "  <INSN>Tb [XLEN={32|64}] [TEST_COUNT=<int>]"
	@echo "    - generate testbench for instruction INSN"
	@echo "    - default 32 bit, 16 test inputs"
	@echo " "
	@echo "  launch-<INSN> [XLEN={32|64}] [TEST_COUNT=<int>]"
	@echo "    - generate testbench for instruction INSN"
	@echo "    - default 32 bit, 16 test inputs"
	@echo "    - launch the test automatically"
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
#	@echo "************ Testbenches **********"
#	@echo " "
#	@echo "  Instructions that can be tested"
#	@echo "   $(TESTS)"
#	@echo " "

.PHONY: clean
clean:
	rm -rf $(TB_DIR)
	rm -rf $(VERI_DIR)
