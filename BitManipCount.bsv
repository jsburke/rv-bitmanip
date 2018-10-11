package BitManipCount;

/////////////////////////////////////////////////
//                                             //
//  Project Imports                            //
//                                             //
/////////////////////////////////////////////////

import BitManipCommon :: *;

/////////////////////////////////////////////////
//                                             //
//  Iterative Modules                          //
//                                             //
/////////////////////////////////////////////////

typedef enum {Idle, Calc} IterState deriving (Eq, Bits, FShow);

module mkIterCLZ (BitSingle_IFC #(bit_t))
  provisos(Arith #(bit_t), Eq #(bit_t), Bitwise #(bit_t), Bits #(bit_t, bit_t_sz));

  Integer           int_msb     = valueOf(bit_t_sz) - 1;

  Reg #(bit_t)      rg_operand <- mkRegU;
  Reg #(bit_t)      rg_count   <- mkRegU;
  Reg #(IterState)  rg_state   <- mkReg(Idle);

  rule rl_calc ((rg_state == Calc) && !unpack(rg_operand[int_msb]));
    rg_count   <= rg_count + 1;
    rg_operand <= rg_operand << 1;
  endrule: rl_calc

  method Action args_put (bit_t arg0) if (rg_state == Idle);
    rg_operand <= arg0;
    rg_count   <= 0;
    rg_state   <= Calc;
  endmethod: args_put


  interface BitCommon_IFC common;

    method Action kill;
      rg_state <= Idle;
    endmethod: kill

    method Bool valid_get;
      return ((rg_state == Calc) && !unpack(rg_operand[int_msb]));
    endmethod: valid_get

    method bit_t value_get;
      return rg_count;
    endmethod: value_get

  endinterface: BitCommon_IFC

endmodule: mkIterCLZ

endpackage: BitManipCount
