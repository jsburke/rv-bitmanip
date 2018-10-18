package CLZ_Tb;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

import BRAMCore :: *;

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

typedef Bit #(valueOf(TLog #(`BRAM_ENTRIES))) bramEntry;
typedef enum {Init, Calc, Return} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkCLZ_Tb (Empty);

  Reg #(bramEntry) rg_bram_offset <- mkReg(0);
  Reg #(TbState)   rg_state       <- mkReg(Init);

  Reg #(BitXL)     rg_rs1         <- mkRegU;
  Reg #(BitXL)     rg_rd          <- mkRegU;

//  BitManip_IFC #(single_port, one_option) clz <- mkZeroCounterIter;

  //                                                         No. Tests      no reg  file     hex mode
  BRAM_PORT #(bramEntry, BitXL) rs1       <- mkBRAMCore1Load(`BRAM_ENTRIES, False, `RS1_HEX, `HEX_FILE);
  BRAM_PORT #(bramEntry, BitXL) rd_expect <- mkBRAMCore1Load(`BRAM_ENTRIES, False, `RS1_HEX, `HEX_FILE);

  /////////////////////
  //                 //
  //  Rules          //
  //                 //
  /////////////////////

  rule tb_init ((rg_state == Init) && (rg_bram_offset < `BRAM_ENTRIES));
//    clz.args_put(/*do this after waking up...*/, 0);
    $display("Test Number : %d", rg_bram_offset);

    rs1.put(False, rg_bram_offset, 0);
    rd_expect.put(False, rg_bram_offset, 0);

    rg_state <= Calc;
  endrule: tb_init_test



  rule tb_calc ((rg_state == Calc) && (rg_bram_offset < `BRAM_ENTRIES));
    rg_rs1 <= rs1.read;
    rg_rd  <= rd_expect.read;

    $display("  RS1 -- %h || RD -- %h", rg_rs1, rg_rd);
    rg_state <= Return;
  endrule: tb_calc


  rule tb_return ((rg_state == Return) && (rg_bram_offset < `BRAM_ENTRIES));
    rg_bram_offset <= rg_bram_offset + 1;
    rg_state       <= Init;
  endrule: tb_return

  rule tb_complete (rg_bram_offset >= `BRAM_ENTRIES);
    $display("Count Leading Zeroes Test Complete");
    $finish(0);
  endrule: tb_complete

endmodule: mkCLZ_Tb

endpackage: CLZ_Tb
