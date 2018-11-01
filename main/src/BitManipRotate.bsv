package BitManipRotate;

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

Bit #(1) opt_left  = 1'b0;
Bit #(1) opt_right = 1'b1;

module mkRotateIter (BitManip_IFC #(double_port, one_option))
  provisos (SizedLiteral #(Bit #(one_option), 1));

  Reg #(BitXL)      rg_rs1     <- mkRegU;
  Reg #(BitXLog)    rg_rs2     <- mkRegU;
  // rg_rs1 acts as result register as well
  
  Reg #(Bool)       rg_dir     <- mkRegU;
  Reg #(IterState)  rg_state   <- mkReg(Idle);

  ///////////////////////////
  //                       //
  //  Rules                //
  //                       //
  ///////////////////////////

  BitXL minus_1  = '1;
  BitXL high_bit = (1 << (xlen - 1));
  BitXL low_bit  = 1;

  rule rl_calc (rg_state == Calc);
    if(rg_rs2 == 0) rg_state <= Idle;
    else begin
      rg_rs2 <= rg_rs2 - 1;
      if(rg_dir) rg_rs1 <= {rg_rs1[0], (rg_rs1)[(xlen - 1) : 1]};
      else       rg_rs1 <= {(rg_rs1)[(xlen - 2) : 0], rg_rs1[(xlen - 1)]};
    end
  endrule: rl_calc

  ///////////////////////////
  //                       //
  //  Interface            //
  //                       //
  ///////////////////////////  

  method Action args_put (Vector #(double_port, BitXL) arg, Bit #(one_option) option) if (rg_state == Idle);
    rg_rs1     <= arg[0];
    rg_rs2     <= arg[1][(log_xlen - 1):0];
    rg_dir     <= (unpack(option));
    rg_state   <= Calc;
  endmethod: args_put

  method Action kill;
    rg_state <= Idle;
  endmethod: kill

  method Bool valid_get;
    return (rg_rs2 == 0); 
  endmethod: valid_get

  method BitXL value_get;
    return rg_rs1;
  endmethod: value_get

endmodule: mkRotateIter

endpackage: BitManipRotate
