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

interface ZeroCount_IFC #(numeric type sz);
  method Action                   args_put (Bit #(sz) a, Bool rev_bits);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: ZeroCount_IFC

interface PopCount_IFC #(numeric type sz);
  method Action                   args_put(Bit #(sz) a);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: PopCount_IFC

/////////////////////////////////////////////////
// Generalized Modules

////////////////////////////////////////////
//
//  Zero Counter for clz and ctz based on
//  a bit shifter
//
////////////////////////////////////////////
module mkZeroCountShift (ZeroCount_IFC #(sz));

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

  method Action args_put (Bit #(sz) a, Bool rev_bits) if (!rg_busy);
    rg_z_count <= 0;
    rg_val     <= (rev_bits)? fn_bit_reverse(a) : a;
    rg_busy    <= True;
  endmethod: args_put 

  method ActionValue #(Bit #(sz)) res_get if (rg_busy && unpack(rg_val[int_msb]));
    rg_busy <= False;
    return rg_z_count;
  endmethod: res_get
  
endmodule: mkZeroCountShift

//////////////////////////////////////////
//
//  Popcount for pcnt based on a shifter
//
//////////////////////////////////////////

module mkPopCountShift (PopCount_IFC #(sz));

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

  method Action args_put (Bit #(sz) a) if (!rg_busy);
    rg_pop_count <= 0;
    rg_val       <= a;
    rg_busy      <= True;
  endmethod: args_put

  method ActionValue #(Bit #(sz)) res_get if (rg_busy && rg_val == 0);
    rg_busy <= False;
    return rg_pop_count;
  endmethod: res_get

endmodule: mkPopCountShift

//////////////////////////////////
endpackage : BitManip
