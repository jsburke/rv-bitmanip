package clzTb;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

import BRAMCore :: *;
import Vector   :: *;

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

typedef enum {MemInit, DutInit, Calc, Return, Complete} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module `MK_TB (Empty);

  Reg #(BramEntry) rg_bram_offset <- mkReg(0);
  Reg #(TbState)   rg_state       <- mkReg(MemInit);

  Reg #(BitXL)     rg_rs1         <- mkRegU;
  Reg #(BitXL)     rg_rd          <- mkRegU;
  Reg #(BitXL)     rg_dut_res     <- mkRegU;

  BRAM_PORT #(BramEntry, BitXL) rs1 <- mkBRAMCore1Load(bram_entries, False, rs1_file, False);
  BRAM_PORT #(BramEntry, BitXL) rd  <- mkBRAMCore1Load(bram_entries, False, res_file, False);

  BitManip_IFC #(1,1) dut <- mkZeroCountIter;

  /////////////////////
  //                 //
  //  Rules          //
  //                 //
  /////////////////////

  rule tb_mem_init (rg_state == MemInit);
    $display("Test %d of %d", rg_bram_offset, fromInteger(bram_limit));

    rs1.put(False, rg_bram_offset, 0);
    rd.put(False,  rg_bram_offset, 0);

    rg_state <= DutInit;
  endrule: tb_mem_init

  rule tb_dut_init (rg_state == DutInit);
    let op_0 = rs1.read;
    let res  = rd.read;

    rg_rs1 <= op_0;
    rg_rd  <= res;

    Vector #(1, BitXL) v_args        = newVector();
    v_args[0] = op_0;

    dut.args_put(v_args, 0);

    rg_state <= Calc;
  endrule: tb_dut_init

  rule tb_calc (rg_state == Calc);
    if(dut.valid_get) begin
      rg_dut_res <= dut.value_get;
      rg_state   <= Return;
    end
  endrule: tb_calc

  rule tb_return (rg_state == Return);
    $display("  RS1 -- %h || DUT -- %h || EXPECTED -- %h", rg_rs1, rg_dut_res, rg_rd);

    if (rg_bram_offset >= fromInteger(bram_limit)) rg_state <= Complete;
    else                                           rg_state <= MemInit;

    rg_bram_offset <= rg_bram_offset + 1;
  endrule: tb_return

  rule tb_complete (rg_state == Complete);
    $display("Count Leading Zeroes Test Complete");
    $finish(0);
  endrule: tb_complete

endmodule: `MK_TB

endpackage: clzTb
