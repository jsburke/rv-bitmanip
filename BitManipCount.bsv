package BitManipCount

/////////////////////////////////////////////////
//                                             //
//  Project Imports                            //
//                                             //
/////////////////////////////////////////////////

import BitManip_IFC :: *;

/////////////////////////////////////////////////
//                                             //
//  Iterative Modules                          //
//                                             //
/////////////////////////////////////////////////

typedef enum {Idle, Calc} IterState deriving (Eq, Bits, FShow);

module mkIterCLZ (BitSingle_IFC #(bit_t))
  provisos(Arith #(bit_t), Eq #(bit_t), Bitwise #(bit_t), Bits #(bit_t, bit_t_sz));

  Reg #(bit_t)      rg_operand <- mkRegU;
  Reg #(bit_t)      rg_result  <- mkRegU;
  Reg #(IterState)  rg_state   <- mkReg(Idle);

  rule rl_calc (rg_state == Calc);
    
  endrule: rl_calc

  method Action args_put (bit_t arg0);
    rg_operand <= arg0;
    rg_result  <= 0;
    rg_state   <= Calc;
  endmethod: args_put

  method Bool valid_get;
    return ((rg_state == Calc) && );
  endmethod: valid_get;

  method bit_t value_get;
    return rg_result;
  endmethod: value_get

endmodule: mkIterCLZ

endpackage: BitManipCount
