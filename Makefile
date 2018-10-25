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
TESTS     = $(patsubst %Tb.bsv,%,$(notdir $(TESTS_RAW)))

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
	mv RV$(XLEN) $(TEST_BRAM) # mv feels hacky, should one line this recipe

test-%: $(TEST_BRAM)
	$(BSC) $(BSC_DEFINES) $(BSC_TEST_0) $(BSV_INC) $(TEST_DIR)/$*Tb.bsv
	mv $(SRC_DIR)/*.bo  $(TB_DIR)
	mv $(TEST_DIR)/*.ba $(TB_DIR)
	mv $(TEST_DIR)/*.bo $(TB_DIR)
	cd $(TB_DIR) && $(BSC) $(BSC_TEST_1) mk$*Tb -o $*Tb *.ba 

.PHONY: help
help:
	@echo "$(PROJ_NAME) Instructions"
	@echo " "
	@echo "  ********* Basic Targets **********"
	@echo " "
	@echo " "
	@echo "   help  -- show this message"
	@echo " "
	@echo "   clean -- remove generated files"
	@echo " "
	@echo "  ******* Individual Targets *******"
	@echo " "
	@echo " $(TESTS)"
	@echo " "

.PHONY: clean
clean:
	rm -rf $(TB_DIR)
	rm -rf $(VERI_DIR)
