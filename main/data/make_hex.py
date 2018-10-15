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
##  Support Functions      ##
##                         ##
#############################

def hexToBinStr(hex_str):
  return bin(int("1" + hex_str, 16))[3:]

def hexStrFormat(int_val, noDigits):
  hexShort = hex(int_val)[2::]
  return "0" * (noDigits - len(hexShort)) + hexShort

def stringReverse(string):
  return string[::-1]

def randHexDigit():
  return hex(rd.randint(0,15))[2:]

def writeBytes(file_name, entries, chars):
  file = open(file_name, "w")

  for i in range(entries):
    for c in range(chars):
      file.write(randHexDigit())
    file.write("\n")
  file.close()

def writeBytesLambdaSingle(lam, sourceFile, destFile, noDigits):
  dest = open(destFile, "w")
  with open(sourceFile, "r") as source:
    for line in source:
      dest.write(lam(line.rstrip("\n"), noDigits))
      dest.write("\n")
  source.close
  dest.close

#############################
##                         ##
##  Lambda Functions       ##
##                         ##
#############################

def countLeadingZeroes(hex_str, noDigits):
  bin_str = hexToBinStr(hex_str)
  bits    = len(bin_str)
  count   = 0
  while (bin_str[count] == "0") and (count < bits):
    count = count + 1
  return hexStrFormat(count, noDigits)

def countTrailingZeroes(hex_str, noDigits):  # possible to collapse via lambdas or partial application
  return countLeadingZeroes(stringReverse(hex_str), noDigits)

def popCount(hex_str, noDigits):
  bin_str = hexToBinStr(hex_str)
  count   = 0
  for bit in bin_str:
    if(bit == "1"): count = count + 1
  return hexStrFormat(count, noDigits)
 

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
  instructions = []

  instructions.append("clz")
  instructions.append("ctz")
  instructions.append("pcnt")

  dest_files = [insn + suffix for insn in instructions]

  writeBytes(rs1_file, entries, entry_len)
  writeBytes(rs2_file, entries, entry_len)

  # can I do a map below via some dictionary for dest_file <--> lambda ??
  writeBytesLambdaSingle(countLeadingZeroes,  rs1_file, dest_files[0], entry_len)
  writeBytesLambdaSingle(countTrailingZeroes, rs1_file, dest_files[1], entry_len)
  writeBytesLambdaSingle(popCount,            rs1_file, dest_files[2], entry_len)

main()
