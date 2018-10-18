PROJ_NAME = RISC V X-Bitmanip

#################################################
##                                             ##
##  Build Options                              ##
##                                             ##
#################################################

XLEN ?= 32
#XLEN ?= 64

#################################################
##                                             ##
##  Build Tools                                ##
##                                             ##
#################################################

BSC ?= bsc

VERI_LIB = $(BLUESPECDIR)/Verilog
VERIMAIN = $(VERI_LIB)/main.v

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

SRC_DIR  = main/src
TEST_DIR = main/test
DATA_DIR = main/data/RV$(XLEN)

TESTS    = $(wildcard $(TEST_DIR)/*.bsv)

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: help

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

.PHONY: clean
clean:
	rm -rf *.bo *.ba *.bi *.log
