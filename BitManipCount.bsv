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

  ///////////////////////////
  //                       //
  //  Zero Counts          //
  //                       //
  //  Covers Both Leading  //
  //  and Trailing         //
  //                       //
  //  (clz and ctz)        //
  //                       //
  ///////////////////////////

Bit #(1) opt_leading  = 1'b0;
Bit #(1) opt_trailing = 1'b1;

module mkZeroCountIter (BitManip_IFC #(int_single_port, one_option))
  provisos (SizedLiteral #(Bit #(one_option), 1));

  Integer           int_msb     = xlen - 1;

  Reg #(BitXL)      rg_operand <- mkRegU;
  Reg #(BitXL)      rg_count   <- mkRegU;
  Reg #(IterState)  rg_state   <- mkReg(Idle);

  ///////////////////////////
  //                       //
  //  Rules                //
  //                       //
  ///////////////////////////

  rule rl_calc ((rg_state == Calc) && !unpack(rg_operand[int_msb]));
    rg_count   <= rg_count + 1;
    rg_operand <= rg_operand << 1;
  endrule: rl_calc

  ///////////////////////////
  //                       //
  //  Interface            //
  //                       //
  ///////////////////////////  

  method Action args_put (Vector #(int_single_port, BitXL) arg, Bit #(one_option) option) if (rg_state == Idle);
    rg_operand <= (option == opt_leading) ? arg[0] : reverseBits(arg[0]);
    rg_count   <= 0;
    rg_state   <= Calc;
  endmethod: args_put

  method Action kill;
    rg_state <= Idle;
  endmethod: kill

  method Bool valid_get;
    return ((rg_state == Calc) && unpack(rg_operand[int_msb]));
  endmethod: valid_get

  method BitXL value_get;
    return rg_count;
  endmethod: value_get

endmodule: mkZeroCountIter

  ///////////////////////////
  //                       //
  //  Pop Count            //
  //                       //
  ///////////////////////////

module mkPopCountIter (BitManip_IFC #(int_single_port, no_options));

  Reg #(BitXL) rg_operand   <- mkRegU;
  Reg #(BitXL) rg_count     <- mkRegU;
  Reg #(IterState) rg_state <- mkReg(Idle);

  ///////////////////////////
  //                       //
  //  Rules                //
  //                       //
  ///////////////////////////

  rule rl_calc ((rg_state == Calc) && (rg_operand != 0));
    rg_count   <= rg_count + 1;
    rg_operand <= rg_operand << 1;
  endrule: rl_calc

  ///////////////////////////
  //                       //
  //  Interface            //
  //                       //
  ///////////////////////////  

  method Action args_put (Vector #(int_single_port, BitXL) arg, Bit #(no_options) option) if (rg_state == Idle);
    rg_operand <= arg[0];
    rg_count   <= 0;
    rg_state   <= Calc;
  endmethod: args_put

  method Action kill;
    rg_state <= Idle;
  endmethod: kill

  method Bool valid_get;
    return ((rg_state == Calc) && (rg_operand == 0));
  endmethod: valid_get

  method BitXL value_get;
    return rg_count;
  endmethod: value_get

endmodule: mkPopCountIter

endpackage: BitManipCount
