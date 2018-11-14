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

  Reg #(BitXL)      rg_val1       <- mkRegU;
  Reg #(BitXL)      rg_val2       <- mkRegU;

  Reg #(IterState)  rg_state     <- mkReg(Idle);
  Reg #(BitManipOp) rg_operation <- mkRegU;

  /////////////////////////
  //                     //
  // Rules               //
  //                     //
  /////////////////////////

  Bool is_right_shift_op = (rg_state == S_Calc) && ((rg_operation == CTZ)  || 
                                                    (rg_operation == PCNT) || 
                                                    (rg_operation == SRO)  || 
                                                    (rg_operation == ROR)); 
 
  Bool is_left_shift_op  = (rg_state == S_Calc) && ((rg_operation == CLZ)  || 
                                                    (rg_operation == SLO)  || 
                                                    (rg_operation == ROL)); 
 
  rule rl_calc_right_shifts (is_right_shift_op);
  endrule: rl_calc_right_shifts

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

    rg_val1      <= arg0;
    rg_val2      <= arg1;
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
