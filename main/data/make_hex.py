#!/usr/bin/python3

#############################
##                         ##
##  Python Utilities       ##
##                         ##
#############################

import random as rd
import sys, argparse

#############################
##                         ##
##  Utility Functions      ##
##                         ##
#############################

def randHexDigit():
  return hex(rd.randint(0,15))[2:]

#############################
##                         ##
##  Command Line Controls  ##
##                         ##
#############################

class parserDefinedError(argparse.ArgumentParser):
  def error(self, msg = ""):                        # use a block comment at top as
    if (msg): print("\n  ERROR: %s\n" % msg)        # info to print to command line
    source = open(sys.argv[0])
    for (lineNo, line) in enumerate(file):
      if(line[0] != "#"): sys.exit(msg != "")       # exit on printing first non comment line
      if(lineNo > 0): print(line[1:].rstrip("\n"))  # print all info lines not the shebang

def parseCMD():
  parser = parserDefinedError(add_help = False)

  parser.add_argument("-h", "--help", action = "store_true")

  # 32 or 64 bit values

  bitness = parser.add_mutually_exclusive_group()

  bitness.add_argument("-32", "--rv32", action = "store_true")
  bitness.add_argument("-64", "--rv64", action = "store_true")

  # file entries

  parser.add_argument("-e", "--entries", type = int)

  # processing to retrun this

  options = parser.parse_args()
  if options.help:
    parser.error()
    sys.exit()
  else:
    return options

#############################
##                         ##
##  Main                   ##
##                         ##
#############################

def main():
  options = parseCMD()

main()
