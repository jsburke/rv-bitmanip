PROJ_NAME = BRAM Generators

#################################################
##                                             ##
##  Compiler Controls                          ##
##                                             ##
#################################################

CC      = gcc
  # can do below since we lack FP in bramGen[32,64]
C_OPT   = -Ofast
CFLAGS  = -Wextra -Wall -Wshadow -Wcast-align
CFLAGS += -Wswitch-default -Wunreachable-code
ifdef UTIL_DBG
  # gdb and -O3 or -Ofast sounds like a nightmare...
C_OPT   = -O0
CFLAGS += -g
endif

  # compress everything for easy use in recie
CC_FULL = $(CC) $(C_OPT) $(CFLAGS)

#################################################
##                                             ##
##  Disassembling                              ##
##                                             ##
#################################################

DD = objdump
D_FLAGS = -D
ifdef UTIL_DBG
D_FLAGS += -g
endif

DD_FULL = $(DD) $(D_FLAGS)
#################################################
##                                             ##
##  Source Files                               ##
##                                             ##
#################################################

HEAD = bramGen.c
SOBJ = bitmanip.c
HDR  = bitmanip.h

OBJ_DEP = $(SOBJ) $(HDR)
OBJS    = bitmanip*.o bramGen32 repl32 bramGen64 repl64

#################################################
##                                             ##
##  Project Targets                            ##
##                                             ##
#################################################

.PHONY: default
default: all

bitmanip%.o: $(OBJ_DEP)
	$(CC_FULL) -DRV$* $(SOBJ) -c -o $@

bramGen%: bitmanip%.o
	$(CC_FULL) -DRV$* -o $@ $^ bramGen.c  

repl%: bitmanip%.o
	$(CC_FULL) -DRV$* -o $@ $^ repl.c

%.dump: %
	$(DD_FULL) $^ > $@


.PHONY: all
all: bramGen32 bramGen64 repl32 repl64 bramGen32.dump bramGen64.dump repl32.dump repl64.dump  

.PHONY: rebuild
rebuild:
	make clean
	make all
	
.PHONY: clean
clean:
	rm -rf $(OBJS) *.dump

.PHONY: help
help:
	@echo " "
	@echo "   ******* $(PROJ_NAME) HELP *******"
	@echo " "
	@echo "     Targets"
	@echo " "
	@echo "     bitmanip[32,64].o --- make [32,64] bit insn C funcs"
	@echo " "
	@echo "     bramGen[32,64]    --- make bram generation program"
	@echo " "
	@echo "     repl[32,64]       --- make repls for quick bitmanip calcs"
	@echo " "
	@echo "   ************ ALIASES ************"
	@echo " "
	@echo "     all (default) --- make bramGen32 and bramGen64"
	@echo " "
	@echo "     clean         --- delete binaries and .o files"
	@echo " "
	@echo "     rebuild       --- clean then all"
	@echo " "
	@echo "     help          --- print this message"
	@echo " "
