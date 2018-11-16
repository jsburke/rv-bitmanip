package ModuleTb;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

import BRAMCore     :: *;
import Vector       :: *;

/////////////////////////////////////////////////
//                                             //
// Project Imports                             //
//                                             //
/////////////////////////////////////////////////

import TbMeta       :: *;
import BitManipIter :: *;  // likely to be ifdeffed as other modules are made

/////////////////////////////////////////////////
//                                             //
// Test Bench                                  //
//                                             //
/////////////////////////////////////////////////

// fn mainly to neaten rules
function BitManipOp fv_nextOp(BitManipOp op);
  case (op) matches
    CLZ     : return CTZ;
    CTZ     : return PCNT;
    PCNT    : return SRO;
    SRO     : return SLO;
    SLO     : return ROR;
    ROR     : return ROL;
    ROL     : return GREV;
    GREV    : return SHFL;
    SHFL    : return UNSHFL;
    UNSHFL  : return BEXT;
    BEXT    : return BDEP;
    BDEP    : return ANDC;
    ANDC    : return CLZ;
    default : return CLZ; // ensures we kickoff in CLZ
  endcase
endfunction: fv_nextOp

typedef enum {Op_Init,
              Mem_Init,
              Dut_Init,
              Dut_Wait,
              Dut_Return,
              Tb_Exit} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkModuleTb (Empty);

  Reg #(BramEntry)  rg_bram_offset <- mkReg(0);
  Reg #(TbState)    rg_state       <- mkReg(Op_Init);
  Reg #(BitManipOp) rg_operation   <- mkReg(ANDC); // init to dummy state for fn ease
  Reg #(Bool)       rg_was_failure <- mkReg(False);

  Reg #(BitXL)      rg_rs1         <- mkRegU;
  Reg #(BitXL)      rg_rs2         <- mkRegU;
  Reg #(BitXL)      rg_rd          <- mkRegU;
  Reg #(BitXL)      rg_dut_res     <- mkRegU;

  BRAM_PORT #(Bramentry, BitXL) rs1    <- mkBRAMCore1Load(bram_entries, False, rs1_file   , False);
  BRAM_PORT #(Bramentry, BitXL) rs2    <- mkBRAMCore1Load(bram_entries, False, rs2_file   , False);

  BRAM_PORT #(Bramentry, BitXL) clz    <- mkBRAMCore1Load(bram_entries, False, clz_file   , False);
  BRAM_PORT #(Bramentry, BitXL) ctz    <- mkBRAMCore1Load(bram_entries, False, ctz_file   , False);
  BRAM_PORT #(Bramentry, BitXL) pcnt   <- mkBRAMCore1Load(bram_entries, False, pcnt_file  , False);
  BRAM_PORT #(Bramentry, BitXL) sro    <- mkBRAMCore1Load(bram_entries, False, sro_file   , False);
  BRAM_PORT #(Bramentry, BitXL) slo    <- mkBRAMCore1Load(bram_entries, False, slo_file   , False);
  BRAM_PORT #(Bramentry, BitXL) ror    <- mkBRAMCore1Load(bram_entries, False, ror_file   , False);
  BRAM_PORT #(Bramentry, BitXL) rol    <- mkBRAMCore1Load(bram_entries, False, rol_file   , False);
  BRAM_PORT #(Bramentry, BitXL) grev   <- mkBRAMCore1Load(bram_entries, False, grev_file  , False);
  BRAM_PORT #(Bramentry, BitXL) shfl   <- mkBRAMCore1Load(bram_entries, False, shfl_file  , False);
  BRAM_PORT #(Bramentry, BitXL) unshfl <- mkBRAMCore1Load(bram_entries, False, unshfl_file, False);
  BRAM_PORT #(Bramentry, BitXL) bext   <- mkBRAMCore1Load(bram_entries, False, bext_file  , False);
  BRAM_PORT #(Bramentry, BitXL) bdep   <- mkBRAMCore1Load(bram_entries, False, bdep_file  , False);

  BitManip_IFC dut <- mkBitManipIter;

  ///////////////////////////
  //                       //
  //  Test Guts            //
  //                       //
  ///////////////////////////

  rule tb_op_init (rg_state == Op_Init);
    `ifdef TEST_VERBOSE
    $display("----- Begin Tests for ", fshow(rg_operation));
    `endif 

    rg_operation <= fv_nextOp(rg_operation);
    rg_state     <= Mem_Init;
  endrule: tb_op_init



  rule tb_mem_init (rg_state == Mem_Init);
    `ifdef TEST_VERBOSE
    $display("Test %d of %d", rg_bram_offset, fromInteger(bram_limit));
    `endif

    rs1.put   (False, rg_bram_offset, 0);
    rs2.put   (False, rg_bram_offset, 0);

    case (rg_operation) matches
      CLZ    : clz.put   (False, rg_bram_offset, 0);
      CTZ    : ctz.put   (False, rg_bram_offset, 0);
      PCNT   : pcnt.put  (False, rg_bram_offset, 0);
      SRO    : sro.put   (False, rg_bram_offset, 0);
      SLO    : slo.put   (False, rg_bram_offset, 0);
      ROR    : ror.put   (False, rg_bram_offset, 0);
      ROL    : rol.put   (False, rg_bram_offset, 0);
      GREV   : grev.put  (False, rg_bram_offset, 0);
      SHFL   : shfl.put  (False, rg_bram_offset, 0);
      UNSHFL : unshfl.put(False, rg_bram_offset, 0);
      BEXT   : bext.put  (False, rg_bram_offset, 0);
      BDEP   : bdep.put  (False, rg_bram_offset, 0);
    endcase

    rg_state <= Dut_Init;
  endrule: tb_mem_init



  rule tb_dut_init (rg_state == Dut_Init);

    let arg0 = rs1.read;
    let arg1 = rs2.read;

    rg_rs1 <= arg0;
    rg_rs2 <= arg1;

    case (rg_operation) matches
      CLZ    : let res = clz.read;
      CTZ    : let res = ctz.read;
      PCNT   : let res = pcnt.read;
      SRO    : let res = sro.read;
      SLO    : let res = slo.read;
      ROR    : let res = ror.read;
      ROL    : let res = rol.read;
      GREV   : let res = grev.read;
      SHFL   : let res = shfl.read;
      UNSHFL : let res = unshfl.read;
      BEXT   : let res = bext.read;
      BDEP   : let res = bdep.read;
    endcase

    rg_rd <= res;

    dut.args_put(arg0, arg1, rg_operation);

    rg_state <= Dut_Wait;
  endrule: tb_dut_init



  rule tb_dut_wait (rg_state == Dut_Wait);
    if (dut.valid_get) begin
      rg_state   <= Dut_Return;
      rg_dut_res <= dut.value_get;
    end
  endrule: tb_dut_wait



  rule tb_dut_return (rg_state == Dut_Return);
    let fail = rg_dut_res != rg_rd;
    if (fail)  rg_was_failure <= True;
    
    `ifdef TEST_VERBOSE
    if (fail) $display("  --- FAILURE ---");
    else      $display("  --- PASS ------");

              $display("   rs1     : %h", rg_rs1);
    if (!((rg_operation == CLZ) || (rg_operation == CTZ) || (rg_operation == PCNT))) begin //rs1 only
              $display("   rs2     : %h", rg_rs2);
    end

    if (fail) $display("expected   : %h", rg_rd); 
              $display("calculated : %h", rg_dut_res);
    `endif
    
    rg_bram_offset <= rg_bram_offset + 1;

    if (rg_bram_offset != fromInteger(bram_limit)) rg_state <= Mem_Init;
    else if (rg_operation != BDEP)                 rg_state <= Op_Init;
    else                                           rg_state <= Tb_Exit;
  endrule: tb_dut_return



  rule tb_exit (rg_state == Tb_Exit);
    if (rg_was_failure) $display("A failure was encountered during this run");
    else                $display("All tests completed correctly");

    $finish(0);
  endrule: tb_exit



endmodule: mkModuleTb

endpackage: ModuleTb
