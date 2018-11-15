package BitManipIter;

/////////////////////////////////////////////////
//                                             //
// Iterative Module Notes:                     //
//                                             //
// This Module implements 11 of the B spec     //
// operations (ANDC is forced into BBox).      //
//                                             //
// This one is intended as a simplest model.   //
// All of the operations will complete in      //
// an unfixed interval at most XLEN cycles     //
// in length.                                  //
//                                             //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//                                             //
// Project Imports                             //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
// Iterative Module                            //
//                                             //
/////////////////////////////////////////////////

// should I move to meta per chance??
function IterState fv_state_init(BitManipOp op, Bool arg1_lsb);
  case(op) matches
    CLZ      : return S_Calc;
    CTZ      : return S_Calc;
    PCNT     : return S_Calc;
    SRO      : return S_Calc;
    SLO      : return S_Calc;
    ROR      : return S_Calc;
    ROL      : return S_Calc;
    GREV     : return S_State_1;
    `ifdef RV32  // this shuffle portion will likely get messy...
    SHFL     : return (arg1_lsb) ? S_Stage_1 : S_Stage_8;
    `elsif RV64
    SHFL     : return (arg1_lsb) ? S_Stage_1 : S_Stage_16;
    `endif
    BEXT     : return S_Calc;
    BDEP     : return S_Calc;
    ANDC     : return S_Idle;
    default  : return S_Idle;
  endcase
endfunction: fv_state_init

module mkBitManipIter (BitManip_IFC);

  Reg #(BitXL)      rg_res         <- mkRegU;  // we'll accumulate a result here
  Reg #(BitXL)      rg_control     <- mkRegU;  // determines modifications to rg_res, when to terminate 

  // Below registers are only used for bext and bdep
  //
  // rough correspondence with C impl in util
  //
  // rg_res         -- xlen_t r
  // rg_control     -- rs2 (causes things controlled by C Impl's j to left shift)
  // rg_pack_seed   -- one << [i,j]  // remembers shifts rather than applying as needed like C
  // rg_pack_setter -- rs1

  Reg #(BitXL)      rg_pack_seed   <- mkRegU;
  Reg #(BitXL)      rg_pack_setter <- mkRegU;

  // module operative control registers
  Reg #(IterState)  rg_state       <- mkReg(S_Idle);
  Reg #(BitManipOp) rg_operation   <- mkRegU;

  /////////////////////////
  //                     //
  // Rule Controls       //
  //                     //
  /////////////////////////

  Integer int_msb  = xlen - 1; // probably gets messy witgh RV64 coming in

  BitXL   minus_1  = '1;
  BitXL   high_set = (1 << (xlen - 1));
  BitXL   low_set  = 1;

  Bool is_right_shift_op = (rg_operation == CLZ)  ||
                           (rg_operation == CTZ)  ||
                           (rg_operation == PCNT) ||
                           (rg_operation == SRO)  ||
                           (rg_operation == ROR);

  Bool is_left_shift_op  = (rg_operation == SLO)  ||
                           (rg_operation == ROL);
  

  Bool is_rule_right_shift = (rg_state != S_IDLE) && is_right_shift_op;
  Bool is_rule_left_shift  = (rg_state != S_IDLE) && is_left_shift_op;

  // NB: some exit conditions are honestly early exit (ie: grev, shuffles)
  //             exit          if bit we see is 1    OR  result saturates at XLEN
  Bool exit_zero_count     = ((unpack(rg_control[0])) || (rg_res == fromInteger(xlen))) && 
                             ((rg_operation == CLZ) || (rg_operation == CTZ));

  //             exit         if rs1 becomes 0 OR  result saturates
  Bool exit_ones_count     = (rg_control == 0) || (rg_res == fromInteger(xlen)) &&
                             (rg_operation == PCNT);

  //             exit         if res saturates   OR  control is depleted
  Bool exit_shift_ones     = (rg_res == minus_1) || (rg_control == 0) &&
                             ((rg_operation == SRO) || (rg_operation == SLO));

  //             exit         when control depletes
  Bool exit_rot_shfl_grev  = (rg_control == 0) &&
                             ((rg_operation == SHFL) || (rg_operation == UNSHFL) || 
                              (rg_operation == ROR)  || (rg_operation == ROL)    ||
                              (rg_operation == GREV));  

  //             exit         when either reg assoc with rs1 or rs2 depletes
  Bool exit_bext_bdep      = (r_control == 0) || (rg_pack_setter == 0) &&
                             ((rg_operation == BEXT) || (rg_operation == BDEP)); 

  // andc not handled here

  Bool terminate_right_shift = is_right_shift_op  && (exit_zero_count || exit_ones_count ||
                                                     exit_shift_ones || exit_rot_shfl_grev);
  Bool terminate_left_shift  = is_left_shift_op   && (exit_shift_ones || exit_rot_shfl_grev);

  Bool terminate_grev        = exit_rot_shfl_grev && (rg_operation == GREV);
  Bool terminate_shfl        = exit_rot_shfl_grev && ((rg_operation == SHFL) || 
                                                      (rg_operation == UNSHFL));
  Bool terminate_bext_bdep   = exit_bext_bdep     && ((rg_operation == BEXT) || 
                                                      (rg_operation == BDEP));
  /////////////////////////
  //                     //
  // Rules               //
  //                     //
  /////////////////////////

  rule rl_right_shifts (is_right_shift_op);
  endrule: rl_right_shifts



  rule rl_left_shifts (is_left_shift_op);
  endrule: rl_left_shifts

  /////////////////////////
  //                     //
  // Interface           //
  //                     //
  /////////////////////////

  method Action args_put(BitXL arg0, BitXL arg1, BitManipOp op_sel
                         `ifdef RV64
                          ,Bool is_32bit
                         `endif
                          );

    rg_operation <= op_sel;
    rg_state     <= fv_state_init(op_sel, unpack(arg1[0])); 

  endmethod: args_put

  method Action kill;
    rg_state <= S_Idle;
  endmethod: kill

  method Bool valid_get;
    return False;
  endmethod: valid_get

  method BitXL value_get;
    return rg_val1;
  endmethod: value_get

endmodule: mkBitManipIter

endpackage: BitManipIter
