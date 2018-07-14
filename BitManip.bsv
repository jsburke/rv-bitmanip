package BitManip;

/////////////////////////////////////////////////
// Exports

/////////////////////////////////////////////////
// BSV libs

/////////////////////////////////////////////////
// Local imports

import BitManip_fn :: *;

/////////////////////////////////////////////////
// Interfaces

// rev_bits --> Bit #(opt_sz) opt ??
interface BitSingleOpt_IFC #(numeric type sz);
  method Action                   args_put (Bit #(sz) rs1, Bit #(1) opt);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: BitSingleOpt_IFC

interface BitSingle_IFC #(numeric type sz);
  method Action                   args_put(Bit #(sz) rs1);
  method ActionValue #(Bit #(sz)) res_get;
endinterface: BitSingle_IFC

interface BitDoubleOpt_IFC #(numeric type sz);
  method Action                   args_put(Bit #(sz) rs1, Bit #(sz) rs2, Bit #(2) opt);
  method ActionValue #(Bit #(sz)) res_get;
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
module mkBitZeroCountSerial (BitSingleOpt_IFC #(sz));

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

  method Action args_put (Bit #(sz) rs1, Bit #(1) opt) if (!rg_busy);
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
// Shift and rotate
//
////////////////////////////////////

module mkShiftRotSerial (BitDoubleOpt_IFC #(sz))
  provisos (SizedLiteral #(Bit #(sz), 1));

  Integer                  int_msb       =  valueOf(sz) - 1;
  Integer                  int_shamt_msb =  valueOf(TLog #(sz));
  Reg #(Bit #(sz))         rg_val        <- mkRegU;
  Reg #(Bit #(TLog #(sz))) rg_shamt      <- mkRegU;
  Reg #(Bool)              rg_right      <- mkRegU;
  Reg #(Bool)              rg_rot        <- mkRegU;
  Reg #(Bool)              rg_busy       <- mkReg(False);

  //////////////////////////////////
  // Rules

  rule rl_shift_ones_left (rg_busy && !rg_rot && !rg_right && (rg_shamt != 0));
    rg_val   <= {rg_val[int_msb - 1: 0], 1'b1};
    rg_shamt <= rg_shamt - 1;
  endrule: rl_shift_ones_left

  rule rl_shift_ones_right (rg_busy && !rg_rot && rg_right && (rg_shamt != 0));
    rg_val   <= {1'b1, rg_val[int_msb : 1]};
    rg_shamt <= rg_shamt - 1;
  endrule: rl_shift_ones_right

  rule rl_rotate_ones_left (rg_busy && rg_rot && !rg_right && (rg_shamt != 0));
    rg_val   <= {rg_val[int_msb - 1 : 0], rg_val[int_msb]};
    rg_shamt <= rg_shamt - 1;
  endrule: rl_rotate_ones_left

  rule rl_rotate_ones_right (rg_busy && rg_rot && rg_right && (rg_shamt != 1));
    rg_val   <= {rg_val[0], rg_val[int_msb : 1]};
    rg_shamt <= rg_shamt - 1;
  endrule: rl_rotate_ones_right
  
  //////////////////////////////////
  // Interface

  method Action args_put (Bit #(sz) rs1, Bit #(sz) rs2, Bit #(2) opt) if (!rg_busy);
    rg_val   <= rs1;
    rg_shamt <= rs2[int_shamt_msb : 0];
    rg_right <= unpack(opt[0]);
    rg_rot   <= unpack(opt[1]);
    rg_busy  <= True;
  endmethod: args_put

  method ActionValue #(Bit #(sz)) res_get if (rg_busy && (rg_shamt == 0));
    rg_busy <= False;
    return rg_val;
  endmethod: res_get

endmodule: mkShiftRotSerial

////////////////////////////////////
//
//  Generalized Reverse
//  
////////////////////////////////////

module mkBitGrevSerial (BitDouble_IFC #(sz));

  Integer                  int_msb       =  valueOf(sz) - 1;
  Integer                  int_shamt_msb =  valueOf(TLog #(sz));
  Reg #(Bit #(sz))         rg_val        <- mkRegU;
  Reg #(Bit #(TLog #(sz))) rg_shamt      <- mkRegU;
  Reg #(Bool)              rg_busy       <- mkReg(False);       
  Reg #(Bit #(TLog #(sz))) rg_chunk      <- mkReg(1);

  /////////////////////////////////
  // Rules

  rule rl_grev (rg_busy && (rg_shamt != 0));
    if (unpack(rg_shamt[int_shamt_msb])) begin 
      
    end
    rg_shamt <= rg_shamt << 1;
    rg_chunk <= rg_chunk << 1;
  endrule: rl_grev

  /////////////////////////////////
  // Interface

  method Action args_put (Bit #(sz) rs1, Bit #(sz) rs2) if (!rg_busy);
    rg_val   <= rs1;
    rg_shamt <= rs2[int_shamt_msb : 0];
    rg_busy  <= True;
  endmethod: args_put

  method ActionValue #(Bit #(sz)) res_get if (rg_busy && (rg_shamt == 0));
    rg_busy <= False;
    return rg_val;
  endmethod: res_get

endmodule: mkBitGrevSerial

////////////////////////////////////
//
// Generalized Zip
//
////////////////////////////////////

module mkBitGenZip (BitDouble_IFC #(sz));

endmodule: mkBitGenZip

////////////////////////////////////
//
// Byte Swap
//
////////////////////////////////////

module mkBitSwaps (BitSingleOpt_IFC #(sz));

endmodule: mkBitSwaps

////////////////////////////////////
//
// Bit Extract and Deposit
//
////////////////////////////////////

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
