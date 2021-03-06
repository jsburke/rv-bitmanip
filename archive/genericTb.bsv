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
import metaTb        :: *;

/////////////////////////////////////////////////
//                                             //
// Preprocessor for Generalizing               //
//                                             //
/////////////////////////////////////////////////

`ifdef TEST_clz
  import BitManipCount :: *;
  String res_file = bram_locate("clz");
  `define DUT_IFC BitManip_IFC #(1,1)
  `define DUT_MODULE mkZeroCountIter
  `define DUT_PORT_COUNT 1
  `define DUT_PORT_ASSIGN v_args[0] = op_0;
  `define DUT_SELECT 0 
`elsif TEST_ctz
  import BitManipCount :: *;
  String res_file = bram_locate("ctz");
  `define DUT_IFC BitManip_IFC #(1,1)
  `define DUT_MODULE mkZeroCountIter
  `define DUT_PORT_COUNT 1
  `define DUT_PORT_ASSIGN v_args[0] = op_0;
  `define DUT_SELECT 1 
`elsif TEST_pcnt
  import BitManipCount :: *;
  String res_file = bram_locate("pcnt");
  `define DUT_IFC BitManip_IFC #(1,0)
  `define DUT_MODULE mkPopCountIter
  `define DUT_PORT_COUNT 1
  `define DUT_PORT_ASSIGN v_args[0] = op_0;
  `define DUT_SELECT 0 
`elsif TEST_andc
  import BitManipAndComp :: *;
  String res_file = bram_locate("andc");
  `define RS2_PRESENT
  `define DUT_IFC BitManipAndC_IFC
  `define DUT_MODULE mkAndWithComplement
`elsif TEST_slo
  import BitManipShiftOnes :: *;
  String res_file = bram_locate("slo");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkShiftOnesIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 0 
`elsif TEST_sro
  import BitManipShiftOnes :: *;
  String res_file = bram_locate("sro");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkShiftOnesIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 1 
`elsif TEST_rol
  import BitManipRotate :: *;
  String res_file = bram_locate("rol");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkRotateIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 0 
`elsif TEST_ror
  import BitManipRotate :: *;
  String res_file = bram_locate("ror");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkRotateIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 1 
`elsif TEST_grev
  import BitManipGrev :: *;
  String res_file = bram_locate("grev");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,0)
  `define DUT_MODULE mkGrevIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 0
`elsif TEST_shfl
  import BitManipShuffle :: *;
  String res_file = bram_locate("shfl");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkShuffleIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 0 
`elsif TEST_unshfl
  import BitManipShuffle :: *;
  String res_file = bram_locate("unshfl");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkShuffleIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 1 
`elsif TEST_bext
  import BitManipPack :: *;
  String res_file = bram_locate("bext");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkPackIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 1 
`elsif TEST_bdep
  import BitManipPack :: *;
  String res_file = bram_locate("bdep");
  `define RS2_PRESENT
  `define DUT_IFC BitManip_IFC #(2,1)
  `define DUT_MODULE mkPackIter
  `define DUT_PORT_COUNT 2
  `define DUT_PORT_ASSIGN v_args[0] = op_0; v_args[1] = op_1;
  `define DUT_SELECT 0 
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
  `ifdef RS2_PRESENT
  BRAM_PORT #(BramEntry, BitXL) rs2 <- mkBRAMCore1Load(bram_entries, False, rs2_file, False);
  Reg #(BitXL)     rg_rs2           <- mkRegU;
  `endif
  BRAM_PORT #(BramEntry, BitXL) rd  <- mkBRAMCore1Load(bram_entries, False, res_file, False);

  `DUT_IFC dut <- `DUT_MODULE;

  /////////////////////
  //                 //
  //  Rules          //
  //                 //
  /////////////////////

  rule tb_mem_init (rg_state == MemInit);
    `ifdef TEST_VERBOSE
    $display("Test %d of %d", rg_bram_offset, fromInteger(bram_limit));
    `endif

    rs1.put(False, rg_bram_offset, 0);
    `ifdef RS2_PRESENT
    rs2.put(False, rg_bram_offset, 0);
    `endif
    rd.put(False,  rg_bram_offset, 0);

    rg_state <= DutInit;
  endrule: tb_mem_init

  rule tb_dut_init (rg_state == DutInit);
    `ifdef HW_DBG
    $display("   -- initialize DUT --");
    `endif

    let op_0 = rs1.read;
    let res  = rd.read;

    rg_rs1 <= op_0;
    rg_rd  <= res;

    `ifdef RS2_PRESENT
    let op_1 = rs2.read;
    rg_rs2  <= op_1;
    `endif

    `ifndef TEST_andc
    Vector #(`DUT_PORT_COUNT, BitXL) v_args = newVector();
    `DUT_PORT_ASSIGN
    dut.args_put(v_args, `DUT_SELECT);
    rg_state <= Calc;
    `else // AndC test
    let dut_res = dut.eval(op_0,op_1);
    rg_dut_res <= dut_res;
    rg_state   <= Return;  // jump right to return because combinational
    `endif
  endrule: tb_dut_init

  `ifndef TEST_andc  // not used for andc
  rule tb_calc (rg_state == Calc);
  `ifdef HW_DBG
    $display("   -- dut processing --");
  `endif
    if(dut.valid_get) begin
      rg_dut_res <= dut.value_get;
      rg_state   <= Return;
    end
  endrule: tb_calc
  `endif // TEST_andc

  rule tb_return (rg_state == Return);
    `ifdef HW_DBG
    $display("   -- dut resolution --");
    `endif
    let fail = rg_dut_res != rg_rd;

    if (fail) rg_state <= Fail;
    else begin
      `ifdef TEST_VERBOSE
      $display("  -- PASS: rs1 = %h", rg_rs1);
      `ifdef RS2_PRESENT
      $display("           rs2 = %h", rg_rs2);
      `endif
      $display("           res = %h", rg_dut_res);
      `endif

      if (rg_bram_offset >= fromInteger(bram_limit)) rg_state <= Complete;
      else                                           rg_state <= MemInit;
    end

    rg_bram_offset <= rg_bram_offset + 1;
  endrule: tb_return

  rule tb_complete (rg_state == Complete);
    `ifdef TEST_VERBOSE
    $display(" *** All Tests Completed Correctly ***");
    `endif
    $finish(0);
  endrule: tb_complete

  rule tb_fail (rg_state == Fail);
    `ifdef TEST_VERBOSE
    $display(" *** FAILURE *** ");
    `ifndef RS2_PRESENT
    $display("    For input %h, result calculated was %h, but was expected as %h", rg_rs1, rg_dut_res, rg_rd);
    `else
    $display("    For rs1 = %h and rs2 = %h, calculated %h but expected %h", rg_rs1, rg_rs2, rg_dut_res, rg_rd);
    `endif // RS2_PRESENT
    `endif // TEST_VERBOSE
    $finish(1);
  endrule: tb_fail

endmodule: mkGenericTb

endpackage: genericTb
