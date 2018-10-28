package genericTb;

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

/////////////////////////////////////////////////
//                                             //
// Preprocessor for Generalizing               //
//                                             //
/////////////////////////////////////////////////

`ifdef TEST_clz
  String res_file = bram_locate("clz");
  `define DUT_IFC BitManip_IFC #(1,1)
  `define DUT_MODULE mkZeroCountIter
  `define DUT_PORT_COUNT 1
  `define DUT_PORT_ASSIGN v_args[0] = op_0;
  `define DUT_SELECT 0
`elsif TEST_ctz
  String res_file = bram_locate("ctz");
  `define DUT_IFC BitManip_IFC #(1,1)
  `define DUT_MODULE mkZeroCountIter
  `define DUT_PORT_COUNT 1
  `define DUT_PORT_ASSIGN v_args[0] = op_0;
  `define DUT_SELECT 1
`endif

/////////////////////////////////////////////////
//                                             //
// Test Bench                                  //
//                                             //
/////////////////////////////////////////////////

typedef enum {MemInit, DutInit, Calc, Return, Complete, Fail} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkGenericTb (Empty);

  Reg #(BramEntry) rg_bram_offset <- mkReg(0);
  Reg #(TbState)   rg_state       <- mkReg(MemInit);

  Reg #(BitXL)     rg_rs1         <- mkRegU;
  Reg #(BitXL)     rg_rd          <- mkRegU;
  Reg #(BitXL)     rg_dut_res     <- mkRegU;

  BRAM_PORT #(BramEntry, BitXL) rs1 <- mkBRAMCore1Load(bram_entries, False, rs1_file, False);
  BRAM_PORT #(BramEntry, BitXL) rd  <- mkBRAMCore1Load(bram_entries, False, res_file, False);

  `DUT_IFC dut <- `DUT_MODULE;

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

    Vector #(`DUT_PORT_COUNT, BitXL) v_args = newVector();
    `DUT_PORT_ASSIGN

    dut.args_put(v_args, `DUT_SELECT);

    rg_state <= Calc;
  endrule: tb_dut_init

  rule tb_calc (rg_state == Calc);
    if(dut.valid_get) begin
      rg_dut_res <= dut.value_get;
      rg_state   <= Return;
    end
  endrule: tb_calc

  rule tb_return (rg_state == Return);
    let fail = rg_dut_res != rg_rd;

    if (fail) rg_state <= Fail;
    else begin
      $display("  -- PASS: rs1 = %h", rg_rs1);
      $display("           res = %h", rg_dut_res);

      if (rg_bram_offset >= fromInteger(bram_limit)) rg_state <= Complete;
      else                                           rg_state <= MemInit;
    end

    rg_bram_offset <= rg_bram_offset + 1;
  endrule: tb_return

  rule tb_complete (rg_state == Complete);
    $display(" *** All Tests Completed Correctly ***");
    $finish(0);
  endrule: tb_complete

  rule tb_fail (rg_state == Fail);
    $display(" *** FAILURE *** ");
    $display("    For input %h, result calculated was %h, but was expected as %h", rg_rs1, rg_dut_res, rg_rd);
    $finish(1);
  endrule: tb_fail

endmodule: mkGenericTb

endpackage: genericTb
