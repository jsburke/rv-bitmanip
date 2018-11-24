# BitManip Overview

This project is a build up to implement the proposed RISC-V X-BitManip extension.  From a high level, the goal is to incorporate these into Piccolo and Flute with a RISCV_BBox similar to how the M extension is handled via the RISCV_MBox.  The modules contained herein may have varying degrees of optimization.  In addition to this, this repo will provide standalone tests to verify proper execution of each instruction in bluespec verilog by producing test BRAMs.

## Contents

Below is a listing of the suddirectories and files in this project with descriptions.

### archive

This directory contains standalone bluespec modules to implement the full host of bitmanip extensions in both 32 and 64 bit.  The modules themselves are not too useful for implementing the Bit Manip Extension though they could be used for that.  They should be valuable in a testing framework since they do provide another means of calculating the desired results.  This dir has its own Makefile for building to BlueSim (verilog might be nice to have, but is not a high priority at all), and can be built from the main project Makefile.

### bsv

This directory contains bluespec that can be utilized to implement the RV32 and RV64 Bit Manip extension in a better manner than `archive`.  It has its own makefile that can be directly called, but the main project Makefile is preferable for building the modules here.  Build Targets:

- RV32 Variable Latency BlueSim (**complete**)    Verilog (**coming soon**)
- RV64 Variable Latency BlueSim (**complete**)    Verilog (**coming soon**)
- RV32 BBox Wrapper     BlueSim (**coming soon**) Verilog (**coming soon**)
- RV64 BBox Wrapper     BlueSim (**comint soon**) Verilog (**coming soon**)

### util

Contains C sources for building programs that create hex files to be imported by bluespec as BRAMs for testing purposes.  It also contains sources to make a simple bitmanip repl for on the fly gut checks.  Makefile to compile everything.

### LICENSE

Apache-2.0: chosen to match the BlueSpec Piccolo and Flute

### Makefile

Main Makefile to build various targets in the project.  `make` will build everything in the utils directory, the BitManipIter Module Testbench in bsv, and leave you in a good state to test that module.  `make help` will enumerate more targets and instructions

### README.md

Presently reading.  Enjoy

## Building and Testing

If you want to make tests, the first thing you'll likely need to do is `make utils` to make the bramGen programs.  Then `make bram` will create a build directory and a bram subdirectory in it so that tests can launch.  **IMPORTANT:** your hex files must have at least as many entries as tests are built to expect or the test will fail.  It is best to have these numbers equal, and this is controlled by the `TEST_COUNT` variable in the Top level Makefile.  It is recommended to alter that value in the makefile itself.  `make ModuleTb` will generate a testbench with a module that can execute all the B extension operations except ANDC (will be relegated to RISCV_BBox).

Building individual instruction tests can be done with the `[INSN]Tb` target or `test-all` target.  **IMPORTANT:** This will build from the archive directory only.  Tests can be launched via the `launch-[INSN]` target.

_This section could use a bit of an update.  `make help` hopefully covers everything here, but better to be overly verbose here._

## Dependencies

- gcc [version differences should be minimal] _clang may work, untested_
- bsc from Bluespec to compile bsv sources [pregenerated tests and verilog will come]
- gnumake _other makes may work, untested_

## Checklist

1. Build the RISCV_BBox
2. Incorporate into Piccolo or Flute
3. Tabular test results (Issue exists)
4. Fixed Latency Modules
5. Fixed Latency Pipelined Modules
