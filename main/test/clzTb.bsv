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

String res_file = bram_locate("clz");

/////////////////////////////////////////////////
//                                             //
// Test Bench                                  //
//                                             //
/////////////////////////////////////////////////

typedef enum {Init, Calc, Return, Complete} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkclzTb (Empty);

  Reg #(BramEntry) rg_bram_offset <- mkReg(0);
  Reg #(TbState)   rg_state       <- mkReg(Init);

  Reg #(BitXL)     rg_rs1         <- mkRegU;
  Reg #(BitXL)     rg_rd          <- mkRegU;

  BRAM_PORT #(BramEntry, BitXL) rs1       <- mkBRAMCore1Load(bram_entries, False, rs1_file, False);
  BRAM_PORT #(BramEntry, BitXL) rd_expect <- mkBRAMCore1Load(bram_entries, False, res_file, False);

  /////////////////////
  //                 //
  //  Rules          //
  //                 //
  /////////////////////

  rule tb_init (rg_state == Init);
    $display("Test %d of %d", rg_bram_offset, fromInteger(bram_limit));

    rs1.put(False, rg_bram_offset, 0);
    rd_expect.put(False, rg_bram_offset, 0);

    rg_state <= Calc;
  endrule: tb_init



  rule tb_calc (rg_state == Calc);
    rg_rs1 <= rs1.read;
    rg_rd  <= rd_expect.read;

    rg_state <= Return;
  endrule: tb_calc


  rule tb_return (rg_state == Return);
    $display("  RS1 -- %h || RD -- %h", rg_rs1, rg_rd);

    if (rg_bram_offset >= fromInteger(bram_limit)) rg_state <= Complete;
    else                                rg_state <= Init;

    rg_bram_offset <= rg_bram_offset + 1;
  endrule: tb_return


  rule tb_complete (rg_state == Complete);
    $display("Count Leading Zeroes Test Complete");
    $finish(0);
  endrule: tb_complete

endmodule: mkclzTb

endpackage: clzTb
