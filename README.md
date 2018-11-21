# BitManip Overview

This project is a build up to implement the proposed RISC-V X-BitManip extension.  From a high level, the goal is to incorporate these into Piccolo and Flute with a RISCV_BBox similar to how the M extension is handled via the RISCV_MBox.  The modules contained herein may have varying degrees of optimization.  In addition to this, this repo will provide standalone tests to verify proper execution of each instruction in bluespec verilog by producing test BRAMs.

## Contents

- `archive/` -- Contains Bluespec sources where modules are dedicated in a loosely related operational fashion (bit counts, rotation, etc).  While these will work properly, they will not be used to implement the Bitmanip extension.  The modules may be interesting for verification of other possibly more optimized modules.
- `bsv/` -- Contains the Bluespec sources for the Bitmanip Modules and Testbenches. Contains a Makefile to build Bluespec to bluesim testbenches (_complete_) and verilog (_coming soon_).  Will contain the RISCV_BBox module (_coming soon_)
- `util/` -- Contains C source files to create a program to generate hex files for testing brams and simple bitmanip repls for quick gut checks.  Also contains a Makefile to build said programs (_complete_)
- `LICENSE` -- This repo is licensed under Apache-2.0, mainly to match with Piccolo and Flute
- `Makefile` -- Makefile to build bitmanip tools.  For options, invoke `make help`
- `README.md` -- You're reading me

## Building and Testing

If you want to make tests, the first thing you'll likely need to do is `make utils` to make the bramGen programs.  Then `make bram` will create a build directory and a bram subdirectory in it so that tests can launch.  **IMPORTANT:** your hex files must have at least as many entries as tests are built to expect or the test will fail.  It is best to have these numbers equal, and this is controlled by the `TEST_COUNT` variable in the Top level Makefile.  It is recommended to alter that value in the makefile itself.  `make ModuleTb` will generate a testbench with a module that can execute all the B extension operations except ANDC (will be relegated to RISCV_BBox).

Building individual instruction tests can be done with the `[INSN]Tb` target or `test-all` target.  **IMPORTANT:** This will build from the archive directory only.  Tests can be launched via the `launch-[INSN]` target.

## Dependencies

- gcc [version differences should be minimal] _clang may work, untested_
- bsc from Bluespec to compile bsv sources [pregenerated tests and verilog will come]
- gnumake _other makes may work, untested_

## Checklist

1. Make a 64 bit compliant BitManipIter Module
2. Build the RISCV_BBox
3. Incorporate into Piccolo or Flute
4. Tabular test results (Issue exists)
5. Fixed Latency Modules
