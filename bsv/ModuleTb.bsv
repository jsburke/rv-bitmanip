package ModuleTb;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

import BRAMCore     :: *;

/////////////////////////////////////////////////
//                                             //
// Project Imports                             //
//                                             //
/////////////////////////////////////////////////

import TbMeta       :: *;
import BitManipMeta :: *;
import BitManipIter :: *;  // likely to be ifdeffed as other modules are made

/////////////////////////////////////////////////
//                                             //
// Test Bench                                  //
//                                             //
/////////////////////////////////////////////////

// fn mainly to neaten rules
function BitManipOp fv_nextOp(BitManipOp op);
  case (op) matches
    ANDC    : return CLZ;
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
    `ifdef RV32
    BDEP    : return ANDC;
    `else 
    BDEP    : return CLZ;//W;
    `endif
    default : return CLZ; // ensures we kickoff in CLZ
  endcase
endfunction: fv_nextOp

typedef enum {Op_Init,
              Mem_Init,
              Dut_Init,
              Dut_Wait,
              Dut_Return,
              `ifdef TB_HARD_FAIL
              Tb_Hard_Fail,
              `endif
              Tb_Exit} TbState deriving (Eq, Bits, FShow);

(* synthesize *)
module mkModuleTb (Empty);

  Reg #(BramEntry)  rg_bram_offset <- mkReg(0);
  Reg #(TbState)    rg_state       <- mkReg(Op_Init);
  Reg #(BitManipOp) rg_operation   <- mkReg(ANDC); // init to dummy state for fn ease
  Reg #(Bool)       rg_was_failure <- mkReg(False);
  `ifdef RV64
  Reg #(Bool)       rg_32_bit      <- mkReg(False);
  `endif

  Reg #(BitXL)      rg_rs1         <- mkRegU;
  Reg #(BitXL)      rg_rs2         <- mkRegU;
  Reg #(BitXL)      rg_rd          <- mkRegU;
  Reg #(BitXL)      rg_dut_res     <- mkRegU;

  BRAM_PORT #(BramEntry, BitXL) rs1    <- mkBRAMCore1Load(bram_entries, False, rs1_file   , False);
  BRAM_PORT #(BramEntry, BitXL) rs2    <- mkBRAMCore1Load(bram_entries, False, rs2_file   , False);

  BRAM_PORT #(BramEntry, BitXL) clz    <- mkBRAMCore1Load(bram_entries, False, clz_file   , False);
  BRAM_PORT #(BramEntry, BitXL) ctz    <- mkBRAMCore1Load(bram_entries, False, ctz_file   , False);
  BRAM_PORT #(BramEntry, BitXL) pcnt   <- mkBRAMCore1Load(bram_entries, False, pcnt_file  , False);
  BRAM_PORT #(BramEntry, BitXL) sro    <- mkBRAMCore1Load(bram_entries, False, sro_file   , False);
  BRAM_PORT #(BramEntry, BitXL) slo    <- mkBRAMCore1Load(bram_entries, False, slo_file   , False);
  BRAM_PORT #(BramEntry, BitXL) ror    <- mkBRAMCore1Load(bram_entries, False, ror_file   , False);
  BRAM_PORT #(BramEntry, BitXL) rol    <- mkBRAMCore1Load(bram_entries, False, rol_file   , False);
  BRAM_PORT #(BramEntry, BitXL) grev   <- mkBRAMCore1Load(bram_entries, False, grev_file  , False);
  BRAM_PORT #(BramEntry, BitXL) shfl   <- mkBRAMCore1Load(bram_entries, False, shfl_file  , False);
  BRAM_PORT #(BramEntry, BitXL) unshfl <- mkBRAMCore1Load(bram_entries, False, unshfl_file, False);
  BRAM_PORT #(BramEntry, BitXL) bext   <- mkBRAMCore1Load(bram_entries, False, bext_file  , False);
  BRAM_PORT #(BramEntry, BitXL) bdep   <- mkBRAMCore1Load(bram_entries, False, bdep_file  , False);

  `ifdef RV64
  BRAM_PORT #(BramEntry, BitXL) clz32    <- mkBRAMCore1Load(bram_entries, False, clz32_file   , False);
  BRAM_PORT #(BramEntry, BitXL) ctz32    <- mkBRAMCore1Load(bram_entries, False, ctz32_file   , False);
  BRAM_PORT #(BramEntry, BitXL) pcnt32   <- mkBRAMCore1Load(bram_entries, False, pcnt32_file  , False);
  BRAM_PORT #(BramEntry, BitXL) sro32    <- mkBRAMCore1Load(bram_entries, False, sro32_file   , False);
  BRAM_PORT #(BramEntry, BitXL) slo32    <- mkBRAMCore1Load(bram_entries, False, slo32_file   , False);
  BRAM_PORT #(BramEntry, BitXL) ror32    <- mkBRAMCore1Load(bram_entries, False, ror32_file   , False);
  BRAM_PORT #(BramEntry, BitXL) rol32    <- mkBRAMCore1Load(bram_entries, False, rol32_file   , False);
  BRAM_PORT #(BramEntry, BitXL) grev32   <- mkBRAMCore1Load(bram_entries, False, grev32_file  , False);
  BRAM_PORT #(BramEntry, BitXL) shfl32   <- mkBRAMCore1Load(bram_entries, False, shfl32_file  , False);
  BRAM_PORT #(BramEntry, BitXL) unshfl32 <- mkBRAMCore1Load(bram_entries, False, unshfl32_file, False);
  BRAM_PORT #(BramEntry, BitXL) bext32   <- mkBRAMCore1Load(bram_entries, False, bext32_file  , False);
  BRAM_PORT #(BramEntry, BitXL) bdep32   <- mkBRAMCore1Load(bram_entries, False, bdep32_file  , False);
  `endif

  BitManip_IFC dut <- mkBitManipIter;

  ///////////////////////////
  //                       //
  //  Test Guts            //
  //                       //
  ///////////////////////////

  rule tb_op_init (rg_state == Op_Init);
    `ifdef TEST_VERBOSE
    $display("----- Begin Tests for ", fshow(fv_nextOp(rg_operation)));
    `endif 

    rg_operation <= fv_nextOp(rg_operation);
    `ifdef RV64
    rg_32_bit    <= (rg_operation == BDEP) ? True : rg_32_bit;
    `endif
    rg_state     <= Mem_Init;
  endrule: tb_op_init



  rule tb_mem_init (rg_state == Mem_Init);
    `ifdef TEST_VERBOSE
    $display("Test %d of %d", rg_bram_offset, fromInteger(bram_limit));
    `ifdef RV64
    if(rg_32_bit) $display("32 bit");
    else          $display("64 bit");
    `endif
    `endif

    rs1.put   (False, rg_bram_offset, 0);
    rs2.put   (False, rg_bram_offset, 0);

    `ifdef RV64
    if(!rg_32_bit) begin
    `endif
      case (rg_operation) matches
        CLZ    : clz.put    (False, rg_bram_offset, 0);
        CTZ    : ctz.put    (False, rg_bram_offset, 0);
        PCNT   : pcnt.put   (False, rg_bram_offset, 0);
        SRO    : sro.put    (False, rg_bram_offset, 0);
        SLO    : slo.put    (False, rg_bram_offset, 0);
        ROR    : ror.put    (False, rg_bram_offset, 0);
        ROL    : rol.put    (False, rg_bram_offset, 0);
        GREV   : grev.put   (False, rg_bram_offset, 0);
        SHFL   : shfl.put   (False, rg_bram_offset, 0);
        UNSHFL : unshfl.put (False, rg_bram_offset, 0);
        BEXT   : bext.put   (False, rg_bram_offset, 0);
        BDEP   : bdep.put   (False, rg_bram_offset, 0);
      endcase
    `ifdef RV64
    end
    else begin
      case (rg_operation) matches
        CLZ    : clz32.put    (False, rg_bram_offset, 0);
        CTZ    : ctz32.put    (False, rg_bram_offset, 0);
        PCNT   : pcnt32.put   (False, rg_bram_offset, 0);
        SRO    : sro32.put    (False, rg_bram_offset, 0);
        SLO    : slo32.put    (False, rg_bram_offset, 0);
        ROR    : ror32.put    (False, rg_bram_offset, 0);
        ROL    : rol32.put    (False, rg_bram_offset, 0);
        GREV   : grev32.put   (False, rg_bram_offset, 0);  // no W insn, but should still test
        SHFL   : shfl32.put   (False, rg_bram_offset, 0);  // in case we can run a 32 bit mode
        UNSHFL : unshfl32.put (False, rg_bram_offset, 0);  // in a RV64 proc??
        BEXT   : bext32.put   (False, rg_bram_offset, 0);
        BDEP   : bdep32.put   (False, rg_bram_offset, 0);
      endcase
    end
    `endif

    rg_state <= Dut_Init;
  endrule: tb_mem_init



  rule tb_dut_init (rg_state == Dut_Init);

    let arg0 = rs1.read;
    let arg1 = rs2.read;

    rg_rs1 <= arg0;
    rg_rs2 <= arg1;

    `ifdef RV32
    let res = (rg_operation == CLZ)    ? clz.read    :
              (rg_operation == CTZ)    ? ctz.read    :
              (rg_operation == PCNT)   ? pcnt.read   :
              (rg_operation == SRO)    ? sro.read    :
              (rg_operation == SLO)    ? slo.read    :
              (rg_operation == ROR)    ? ror.read    :
              (rg_operation == ROL)    ? rol.read    :
              (rg_operation == GREV)   ? grev.read   :
              (rg_operation == SHFL)   ? shfl.read   :
              (rg_operation == UNSHFL) ? unshfl.read :
              (rg_operation == BEXT)   ? bext.read   :
              (rg_operation == BDEP)   ? bdep.read   :
              0;
    `elsif RV64
    let res = ((rg_operation == CLZ)    && (!rg_32_bit)) ? clz.read      :
              ((rg_operation == CTZ)    && (!rg_32_bit)) ? ctz.read      :
              ((rg_operation == PCNT)   && (!rg_32_bit)) ? pcnt.read     :
              ((rg_operation == SRO)    && (!rg_32_bit)) ? sro.read      :
              ((rg_operation == SLO)    && (!rg_32_bit)) ? slo.read      :
              ((rg_operation == ROR)    && (!rg_32_bit)) ? ror.read      :
              ((rg_operation == ROL)    && (!rg_32_bit)) ? rol.read      :
              ((rg_operation == GREV)   && (!rg_32_bit)) ? grev.read     :
              ((rg_operation == SHFL)   && (!rg_32_bit)) ? shfl.read     :
              ((rg_operation == UNSHFL) && (!rg_32_bit)) ? unshfl.read   :
              ((rg_operation == BEXT)   && (!rg_32_bit)) ? bext.read     :
              ((rg_operation == BDEP)   && (!rg_32_bit)) ? bdep.read     :
              //  64 bit above              32 bit below
              ((rg_operation == CLZ)    &&  (rg_32_bit)) ? clz32.read    :
              ((rg_operation == CTZ)    &&  (rg_32_bit)) ? ctz32.read    :
              ((rg_operation == PCNT)   &&  (rg_32_bit)) ? pcnt32.read   :
              ((rg_operation == SRO)    &&  (rg_32_bit)) ? sro32.read    :
              ((rg_operation == SLO)    &&  (rg_32_bit)) ? slo32.read    :
              ((rg_operation == ROR)    &&  (rg_32_bit)) ? ror32.read    :
              ((rg_operation == ROL)    &&  (rg_32_bit)) ? rol32.read    :
              ((rg_operation == GREV)   &&  (rg_32_bit)) ? grev32.read   :
              ((rg_operation == SHFL)   &&  (rg_32_bit)) ? shfl32.read   :
              ((rg_operation == UNSHFL) &&  (rg_32_bit)) ? unshfl32.read :
              ((rg_operation == BEXT)   &&  (rg_32_bit)) ? bext32.read   :
              ((rg_operation == BDEP)   &&  (rg_32_bit)) ? bdep32.read   :
              0;
    `endif

    rg_rd <= res;

    dut.args_put(arg0,
                 arg1,
                 rg_operation
                 `ifdef RV64
                 ,rg_32_bit
                 `endif
                 );

    rg_state <= Dut_Wait;
  endrule: tb_dut_init



  rule tb_dut_wait (rg_state == Dut_Wait);
    if (!dut.is_busy) begin
      rg_state   <= Dut_Return;
      rg_dut_res <= dut.value_get;
    end
  endrule: tb_dut_wait

  Bool rs2_useful = !((rg_operation == CLZ)  || (rg_operation == CTZ)  || (rg_operation == PCNT));

  `ifdef RV32
  Bool inc_op = rg_operation != BDEP;
  `else
  Bool inc_op = (rg_operation != BDEP) || (!rg_32_bit);
  `endif

  rule tb_dut_return (rg_state == Dut_Return);
    let fail = rg_dut_res != rg_rd;
    if (fail)  rg_was_failure <= True;
    
    `ifdef TEST_VERBOSE
    if (fail) $display("  --- FAILURE ---");
    else      $display("  --- PASS ------");

              $display("   rs1     : %h", rg_rs1);
    if (rs2_useful) 
              $display("   rs2     : %h", rg_rs2);

    if (fail) $display("expected   : %h", rg_rd); 
              $display("calculated : %h", rg_dut_res);
    `endif
    
    rg_bram_offset <= rg_bram_offset + 1;

    `ifdef TB_HARD_FAIL
    if(fail) rg_state <= Tb_Hard_Fail;
    else
    `endif
    if (rg_bram_offset != fromInteger(bram_limit)) rg_state <= Mem_Init;
    else if (inc_op)                               rg_state <= Op_Init;
    else                                           rg_state <= Tb_Exit;
  endrule: tb_dut_return



  rule tb_exit (rg_state == Tb_Exit);
    if (rg_was_failure) $display("A failure was encountered during this run");
    else                $display("All tests completed correctly");

    $finish(0);
  endrule: tb_exit


  `ifdef TB_HARD_FAIL
  rule tb_hard_fail (rg_state == Tb_Hard_Fail);
    $display("--- Exiting on Failure ---");
    $finish(0);
  endrule: tb_hard_fail
  `endif


endmodule: mkModuleTb

endpackage: ModuleTb
