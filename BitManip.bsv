package BitManip;

/////////////////////////////////////////////////
// Exports

/////////////////////////////////////////////////
// BSV libs

/////////////////////////////////////////////////
// Functions
//
// NB: maybe move elsewhere??

function Bit #(sz) fn_bit_reverse (Bit #(sz) x);
  Integer int_sz = valueOf(sz);
  Bit #(sz) x_rev;

  for(Integer i = 0; i < int_sz; i = i + 1) begin
    x_rev[i] = x[int_sz - i - 1];
  end

  return x_rev;
endfunction: fn_bit_reverse

/////////////////////////////////////////////////
// Interfaces

// rev_bits --> Bit #(opt_sz) opt ??
interface BitSingleOpt_IFC #(numeric type sz, numeric type opt_sz);
  method Action                   args_put (Bit #(sz) rs1, Bit #(opt_sz) opt);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: BitSingleOpt_IFC

interface BitSingle_IFC #(numeric type sz);
  method Action                   args_put(Bit #(sz) rs1);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: BitSingle_IFC

interface BitDoubleOpt_IFC #(numeric type sz, numeric type opt_sz);
  method Action                   args_put(Bit #(sz) rs1, Bit #(sz) rs2, Bit #(opt_sz) opt);
  method ActionValue #(Bit #(sz)) reg_get;
endinterface: BitDoubleOpt_IFC

interface BitDouble_IFC #(numeric type sz);
  method Action                   args_put(Bit #(sz) rs1, Bit #(sz) rs2);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: BitDouble_IFC
/////////////////////////////////////////////////
// Generalized Modules

////////////////////////////////////////////
//
//  Zero Counter for clz and ctz based on
//  a bit shifter
//
////////////////////////////////////////////
module mkBitZeroCountSerial (BitSingleOpt_IFC #(sz, opt_sz));

  Integer           int_msb    =  valueOf(sz) - 1;
  Reg #(Bool)       rg_busy    <- mkReg(False);
  Reg #(Bit #(sz))  rg_val     <- mkRegU;
  Reg #(Bit #(sz))  rg_z_count <- mkRegU;

  /////////////////////////
  // Rules

  rule rl_zero_count (rg_busy && !unpack(rg_val[int_msb]));
    rg_z_count <= rg_z_count + 1;
    rg_val     <= rg_val << 1;
  endrule: rl_zero_count

  /////////////////////////
  // Interface

  method Action args_put (Bit #(sz) rs1, Bit #(opt_sz) opt) if (!rg_busy);
    rg_z_count <= 0;
    rg_val     <= (opt == 1)? fn_bit_reverse(rs1) : rs1;
    rg_busy    <= True;
  endmethod: args_put 

  method ActionValue #(Bit #(sz)) res_get if (rg_busy && unpack(rg_val[int_msb]));
    rg_busy <= False;
    return rg_z_count;
  endmethod: res_get
  
endmodule: mkBitZeroCountSerial

//////////////////////////////////////////
//
//  Popcount for pcnt based on a shifter
//
//////////////////////////////////////////

module mkBitPopCountSerial (BitSingle_IFC #(sz));

  Integer          int_msb      =  valueOf(sz) - 1;
  Reg #(Bool)      rg_busy      <- mkReg(False);
  Reg #(Bit #(sz)) rg_val       <- mkRegU;
  Reg #(Bit #(sz)) rg_pop_count <- mkRegU;

  ////////////////////////
  // Rules

  rule rl_pop_count (rg_busy && rg_val != 0);
    rg_pop_count <= (unpack(rg_val[int_msb]))? rg_pop_count + 1: rg_pop_count;
    rg_val       <= rg_val << 1;
  endrule: rl_pop_count

  ///////////////////////
  // Interface

  method Action args_put (Bit #(sz) rs1) if (!rg_busy);
    rg_pop_count <= 0;
    rg_val       <= rs1;
    rg_busy      <= True;
  endmethod: args_put

  method ActionValue #(Bit #(sz)) res_get if (rg_busy && rg_val == 0);
    rg_busy <= False;
    return rg_pop_count;
  endmethod: res_get

endmodule: mkBitPopCountSerial

////////////////////////////////////
//
// And Complement
//
////////////////////////////////////
interface BitAndC_IFC #(numeric type sz);
  method ActionValue #(Bit #(sz)) eval (Bit #(sz) rs1, Bit #(sz) rs2);
endinterface: BitAndC_IFC

module mkBitAndC (BitAndC_IFC #(sz));
  
  method ActionValue #(Bit #(sz)) eval (Bit #(sz) rs1, Bit #(sz) rs2);
    return rs1 & ~rs2;
  endmethod: eval

endmodule: mkBitAndC
//////////////////////////////////
endpackage : BitManip
