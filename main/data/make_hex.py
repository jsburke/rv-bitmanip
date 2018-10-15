#!/usr/bin/python3
#  make_hex.py usage
#
#    make_hex is a script meant to generate hex files for use in
#    hardware unit testing
#
#  command line options
#
#  -h,  --help       display this message (default option)
#
#  -32, --rv32       generate hex files with 32 bit hex numbers [default]
#  -64, --rv64       generate hex files with 64 bit hex numbers
#
#  -e,  --entries    defines number of integers in each hex file [default 16]
#

#############################
##                         ##
##  Python Utilities       ##
##                         ##
#############################

import random as rd
import os, sys, argparse

#############################
##                         ##
##  Utility Functions      ##
##                         ##
#############################

def randHexDigit():
  return hex(rd.randint(0,15))[2:]

def writeBytes(file_name, entries, chars):
  file = open(file_name, "w")

  for i in range(entries):
    for c in range(chars):
      file.write(randHexDigit())
    file.write("\n")
  file.close()

#############################
##                         ##
##  Command Line Controls  ##
##                         ##
#############################

class parserDefinedError(argparse.ArgumentParser):
  def error(self, msg = ""):                        # use a block comment at top as
    if (msg): print("\n  ERROR: %s\n" % msg)        # info to print to command line
    source = open(sys.argv[0], "r")
    for (lineNo, line) in enumerate(source):
      if(line[0] != "#"): sys.exit(msg != "")       # exit on printing first non comment line
      if(lineNo > 0): print(line[1:].rstrip("\n"))  # print all info lines not the shebang, start 2

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

  entries = options.entries

  # use an int to make controlling digits to write easy
  mode = 32
  if(options.rv64): mode = 64

  entry_len = mode // 4 

  # write digits to files
  suffix   = "_rv" + str(mode) + ".hex"

  # sources
  rs1_file = "rs1" + suffix
  rs2_file = "rs2" + suffix

  # result files, may only need rs1
  dst_files = []

  dst_files.append("clz")
  dst_files.append("ctz")
  dst_files.append("pcnt")

  writeBytes(rs1_file, entries, entry_len)
  writeBytes(rs2_file, entries, entry_len)

main()
