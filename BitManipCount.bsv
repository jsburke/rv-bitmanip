package BitManipCount;

import Vector :: *;

/////////////////////////////////////////////////
//                                             //
//  Project Imports                            //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
//  Iterative Modules                          //
//                                             //
/////////////////////////////////////////////////

typedef enum {Idle, Calc} IterState deriving (Eq, Bits, FShow);

module mkIterCLZ (BitManip_IFC #(int_single_port));

  Integer           int_msb     = xlen - 1;

  Reg #(BitXL)      rg_operand <- mkRegU;
  Reg #(BitXL)      rg_count   <- mkRegU;
  Reg #(IterState)  rg_state   <- mkReg(Idle);

  /////////////////////////
  //                     //
  //  Rules              //
  //                     //
  /////////////////////////

  rule rl_calc ((rg_state == Calc) && !unpack(rg_operand[int_msb]));
    rg_count   <= rg_count + 1;
    rg_operand <= rg_operand << 1;
  endrule: rl_calc

  /////////////////////////
  //                     //
  //  Interface          //
  //                     //
  /////////////////////////  

  method Action args_put (Vector #(int_single_port, BitXL) arg) if (rg_state == Idle);
    rg_operand <= arg[0];
    rg_count   <= 0;
    rg_state   <= Calc;
  endmethod: args_put

  method Action kill;  // consider conditioning kill on state being calc
    rg_state <= Idle;
  endmethod: kill

  method Bool valid_get;
    return ((rg_state == Calc) && !unpack(rg_operand[int_msb]));
  endmethod: valid_get

  method BitXL value_get;
    return rg_count;
  endmethod: value_get

endmodule: mkIterCLZ

endpackage: BitManipCount
