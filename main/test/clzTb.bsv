package CLZ_Tb;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

import BRAM :: *;

/////////////////////////////////////////////////
//                                             //
// Project Imports and Controls                //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta  :: *;
import BitManipCount :: *;

`ifndef BRAM_ENTRIES
`define BRAM_ENTRIES 0  // force bsc to get angry
`endif // BRAM_ENTRIES

/////////////////////////////////////////////////
//                                             //
// Test Bench                                  //
//                                             //
/////////////////////////////////////////////////

typedef Bit #(valueOf(TLog #(BRAM_ENTRIES))) bramEntry;
typedef enum {Init, Calc, Return} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkCLZ_Tb (Empty);

  Reg #(bramEntry) rg_bram_offset <- mkReg(0);
  Reg #(TbState)   rg_state       <- mkReg(Init);

  BitManip_IFC #(single_port, one_option) clz <- mkZeroCounterIter;

  //                                                         No. Tests      no reg  file     hex mode
  BRAM_PORT #(bramEntry, BitXL) rs1       <- mkBRAMCore1Load(`BRAM_ENTRIES, False, `RS1_HEX, `HEX_FILE);
  BRAM_PORT #(bramEntry, BitXL) rd_expect <- mkBRAMCore1Load(`BRAM_ENTRIES, False, `RS1_HEX, `HEX_FILE);

  /////////////////////
  //                 //
  //  Rules          //
  //                 //
  /////////////////////

  rule tb_init_test ((rg_state == Init) && (rg_bram_offset < `BRAM_ENTRIES));
    clz.args_put(/*do this after waking up...*/, 0);
  endrule: tb_init_test

endmodule: mkCLZ_Tb

endpackage: CLZ_Tb
