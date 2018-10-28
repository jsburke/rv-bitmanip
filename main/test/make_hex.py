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
#  -e,  --entries    defines number of integers in each hex file
#                      must be at least 8 to cover defaulting corner cases 
#

#############################
##                         ##
##  Python Utilities       ##
##                         ##
#############################

from random import randint as randomint
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

def bin_inv(bin_str):
  return "".join(["1" if s == "0" else "0" for s in bin_str])

def stringReverse(string):
  return string[::-1]

def randHexDigit():
  return hex(randomint(0,15))[2:]

  # file writers

def writeBytes(file_name, entries, noDigits):
  file = open(file_name, "a") # open with append since writeCornerCases
  for i in range(entries):    # will be first for source "register" data
    for c in range(noDigits):
      file.write(randHexDigit())
    file.write("\n")
  file.close()

def writeCornerCases(file_name, noDigits): # admittedly coded quite lazily
  file = open(file_name, "w")              
  file.write("0" * noDigits + "\n")               # all zeros
  file.write("0" * (noDigits - 1) + "1" + "\n")   # int of value 1
  file.write("f" * noDigits + "\n")               # negative one
  file.write("f" * (noDigits - 1) + "e" + "\n")   # all bits set except LSB
  file.write("7" + "f" * (noDigits - 1) + "\n")   # most positive 2's c
  file.write("8" + "0" * (noDigits - 1) + "\n")   # most negative 2's c
  file.write("5" * noDigits + "\n")               # alternating 0101...
  file.write("a" * noDigits + "\n")               # alternating 1010...

noCornerCases = 8 # equal to number of writes invoked above

def writeBytesLambdaSingle(lam, sourceFile, destFile, noDigits):
  dest = open(destFile, "w")
  with open(sourceFile, "r") as source:
    for line in source:
      dest.write(lam(hexToBinStr(line.rstrip("\n")), noDigits))
      dest.write("\n")
  source.close
  dest.close

# assume sourceFileOne maps to rs1 values, sourceFileTwo to rs2
def writeBytesLambdaDouble(lam, sourceFileOne, sourceFileTwo, destFile, noDigits):
  dest = open(destFile, "w")
  with open(sourceFileOne) as src1, open(sourceFileTwo) as src2:
    for (rs1, rs2) in zip(src1, src2):
      dest.write(lam(hexToBinStr(rs1.rstrip("\n")), hexToBinStr(rs2.rstrip("\n")), noDigits))
      dest.write("\n")
  src1.close
  src2.close
  dest.close

#############################
##                         ##
##  Lambda Functions       ##
##                         ##
#############################

def countLeadingZeroes(bin_str, noDigits):
  bits    = len(bin_str)
  count   = 0
  while (count < bits) and (bin_str[count] == "0"):
    count = count + 1
  return hexStrFormat(count, noDigits)

def countTrailingZeroes(bin_str, noDigits):  # possible to collapse via lambdas or partial application
  return countLeadingZeroes(stringReverse(bin_str), noDigits)

def popCount(bin_str, noDigits):
  count   = 0
  for bit in bin_str:
    if(bit == "1"): count = count + 1
  return hexStrFormat(count, noDigits)
 
def andWithComplement(bin_str1, bin_str2, noDigits):
  bin_str2_inv = bin_inv(bin_str2)
  bin_result   = "".join(["1" if a == "1" and b == "1" else "0" for a, b in zip(bin_str1, bin_str2_inv)])
  return hexStrFormat(int(bin_result, 2), noDigits)

def shiftOnesLeft(bin_str1, bin_str2, noDigits):
  bin_str_res = bin_inv(bin(int(bin_inv(bin_str1), 2) << (int(bin_str2, 2)))[3::])
  return hexStrFormat(int(bin_str_res, 2), noDigits)

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

  if (entries <= noCornerCases): randEntries = 0
  else                         : randEntries = entries - noCornerCases

  # use an int to make controlling digits to write easy
  mode = 32
  if(options.rv64): mode = 64

  entry_len = mode // 4 

  # write digits to files

  path   = "./RV" + str(mode) + "/"
  os.mkdir(path)
  suffix = ".hex"

  # sources
  rs1_file = path + "rs1" + suffix
  rs2_file = path + "rs2" + suffix

  # result files, may only need rs1
  instructions = []

  instructions.append("clz")
  instructions.append("ctz")
  instructions.append("pcnt")
  instructions.append("andc")
  instructions.append("slo")

  dest_files = [path + insn + suffix for insn in instructions]

  writeCornerCases(rs1_file, entry_len)
  writeCornerCases(rs2_file, entry_len)

  writeBytes(rs1_file, randEntries, entry_len)
  writeBytes(rs2_file, randEntries, entry_len)

  # can I do a map below via some dictionary for dest_file <--> lambda ??
  writeBytesLambdaSingle(countLeadingZeroes,  rs1_file, dest_files[0], entry_len)
  writeBytesLambdaSingle(countTrailingZeroes, rs1_file, dest_files[1], entry_len)
  writeBytesLambdaSingle(popCount,            rs1_file, dest_files[2], entry_len)

  writeBytesLambdaDouble(andWithComplement,   rs1_file, rs2_file, dest_files[3], entry_len)
  writeBytesLambdaDouble(shiftOnesLeft,       rs1_file, rs2_file, dest_files[4], entry_len)
  
main()
