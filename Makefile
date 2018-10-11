PROJ_NAME = RISC V X-Bitmanip

#################################################
##                                             ##
##  Build options                              ##
##                                             ##
#################################################

XLEN ?= 32

#################################################
##                                             ##
##  Source Files                               ##
##                                             ##
#################################################

BSV_ALL = $(wildcard *.bsv)
BSV_TB  = $(wildcard *Tb.bsv)

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
	@echo " $(BSV_ALL)"
	@echo " $(BSV_TB)"

.PHONY: clean
clean:
	rm -rf *.bo *.ba *.bi *.log
