PROJ_NAME = BlueSpec RISC-V Bitmanip

#################################################
##                                             ##
##  Build Options                              ##
##                                             ##
#################################################

XLEN ?= 32
#XLEN ?= 64

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
TESTS_RAW = $(wildcard $(TEST_DIR)/*.bsv)
TESTS     = $(filter-out meta,$(patsubst %Tb.bsv,%,$(notdir $(TESTS_RAW))))

BRAM_SCRIPT = $(TEST_DIR)/make_hex.py
TB_NAME    ?= mkclzTb

#################################################
##                                             ##
##  Bluespec Controls                          ##
##                                             ##
#################################################

BSC ?= bsc
BSC_DEFINES = -D RV$(XLEN) -D TEST_COUNT=$(TEST_COUNT) -D MK_TB=$(TB_NAME)
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
	mkdir -p $(TB_DIR)

$(TEST_BRAM): $(TB_DIR)
	$(BRAM_SCRIPT) --entries $(TEST_COUNT) --rv$(XLEN)
	mv RV$(XLEN) $(TEST_BRAM)

test-%: $(TEST_BRAM)
	$(BSC) $(BSC_DEFINES) $(BSC_TEST_0) $(BSV_INC) $(TEST_DIR)/$*Tb.bsv
	mv $(SRC_DIR)/*.bo  $(TB_DIR)
	mv $(TEST_DIR)/*.ba $(TB_DIR)
	mv $(TEST_DIR)/*.bo $(TB_DIR)
	cd $(TB_DIR) && $(BSC) $(BSC_TEST_1) mk$*Tb -o $*Tb *.ba 

launch-%: test-%
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
	@echo "  test-<INSN> [XLEN={32|64}] [TEST_COUNT=<int>]"
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
	@echo "    - make clean then make test-INSN ..."
	@echo " "
	@echo "  relaunch-<INSN> [...]"
	@echo "     - make clean then make launch-INSN ..."
	@echo " "
	@echo "************ Testbenches **********"
	@echo " "
	@echo "  Instructions that can be tested"
	@echo "   $(TESTS)"
	@echo " "

.PHONY: clean
clean:
	rm -rf $(TB_DIR)
	rm -rf $(VERI_DIR)
