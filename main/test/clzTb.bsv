package clzTb;

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
import metaTb        :: *;

String clz_file = bram_locate("clz.hex");

/////////////////////////////////////////////////
//                                             //
// Test Bench                                  //
//                                             //
/////////////////////////////////////////////////

typedef enum {Init, Calc, Return} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkclzTb (Empty);

  Reg #(BramEntry) rg_bram_offset <- mkReg(0);
  Reg #(TbState)   rg_state       <- mkReg(Init);

  Reg #(BitXL)     rg_rs1         <- mkRegU;
  Reg #(BitXL)     rg_rd          <- mkRegU;

  BRAM_PORT #(BramEntry, BitXL) rs1       <- mkBRAMCore1Load(bram_entries, False, rs1_file, False);
  BRAM_PORT #(BramEntry, BitXL) rd_expect <- mkBRAMCore1Load(bram_entries, False, clz_file, False);

  /////////////////////
  //                 //
  //  Rules          //
  //                 //
  /////////////////////

  rule tb_init ((rg_state == Init) && (rg_bram_offset < bram_entries));
//    clz.args_put(/*do this after waking up...*/, 0);
    $display("Test Number : %d", rg_bram_offset);

    rs1.put(False, rg_bram_offset, 0);
    rd_expect.put(False, rg_bram_offset, 0);

    rg_state <= Calc;
  endrule: tb_init



  rule tb_calc ((rg_state == Calc) && (rg_bram_offset < bram_entries));
    rg_rs1 <= rs1.read;
    rg_rd  <= rd_expect.read;

    $display("  RS1 -- %h || RD -- %h", rg_rs1, rg_rd);
    rg_state <= Return;
  endrule: tb_calc


  rule tb_return ((rg_state == Return) && (rg_bram_offset < bram_entries));
    rg_bram_offset <= rg_bram_offset + 1;
    rg_state       <= Init;
  endrule: tb_return

  rule tb_complete (rg_bram_offset >= bram_entries);
    $display("Count Leading Zeroes Test Complete");
    $finish(0);
  endrule: tb_complete

endmodule: mkclzTb

endpackage: clzTb
