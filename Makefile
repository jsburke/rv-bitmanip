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

BRAM_ENTRIES ?= 32  # Number of tests to run

#################################################
##                                             ##
##  Project Management                         ##
##                                             ##
#################################################

SRC_DIR   = main/src
TEST_DIR  = main/test
DATA_DIR  = main/data

TEST_BRAM = $(DATA_DIR)/RV$(XLEN)
TESTS_RAW = $(wildcard $(TEST_DIR)/*.bsv)
TESTS     = $(patsubst %Tb.bsv,%,$(notdir $(TESTS_RAW)))

BRAM_SCRIPT = make_hex.py

#################################################
##                                             ##
##  Bluespec Controls                          ##
##                                             ##
#################################################

BSC ?= bsc
BSC_FLAGS   = -aggressive-conditions -no-warn-action-shadowing -show-range-conflict
BSC_DEFINES = -D RV$(XLEN)

BSV_INC = -p $(SRC_DIR):$(TEST_DIR):+

VERI_LIB = $(BLUESPECDIR)/Verilog
VERIMAIN = $(VERI_LIB)/main.v

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: help

$(TEST_BRAM):
	cd $(DATA_DIR) && ./$(BRAM_SCRIPT) -e $(BRAM_ENTRIES) --rv$(XLEN)

%Tb_sim: $(TEST_BRAM)
	$(BSC) 


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
	rm -rf *.bo *.ba *.bi *.log
	rm -rf $(DATA_DIR)/RV*
