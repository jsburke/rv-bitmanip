package BitManipGrev;

import Vector :: *;

/////////////////////////////////////////////////
//                                             //
//  Project Imports                            //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
//  Reference Module                           //
//    This is a vanilla translation of the     //
//    C code in the prov. B spec as an         //
//    iterative but fixed latency module       //
//                                             //
/////////////////////////////////////////////////

`ifdef RV32
  typedef enum {Idle, Calc_1, Calc_2, Calc_4, Calc_8, Calc_16}          GrevState deriving (Eq, Bits);
`elsif RV64
  typedef enum {Idle, Calc_1, Calc_2, Calc_4, Calc_8, Calc_16, Calc_32} GrevState deriving (Eq, Bits);
`endif

module mkGrevIter (BitManip_IFC #(double_port, no_options));

  Reg #(BitXL)      rg_rs1     <- mkRegU;
  Reg #(BitXLog)    rg_rs2     <- mkRegU;
  // rg_rs1 acts as result register as well
  // rg_rs2 effectively is our "shamt" or revving select  

  Reg #(GrevState)  rg_state   <- mkReg(Idle);  

  ///////////////////////////
  //                       //
  //  Rules                //
  //                       //
  ///////////////////////////

  `ifdef RV32
    BitXL mask_left_s1   = 32'h5555_5555;
    BitXL mask_right_s1  = 32'hAAAA_AAAA;

    BitXL mask_left_s2   = 32'h3333_3333;
    BitXL mask_right_s2  = 32'hCCCC_CCCC;

    BitXL mask_left_s4   = 32'h0F0F_0F0F;
    BitXL mask_right_s4  = 32'hF0F0_F0F0;

    BitXL mask_left_s8   = 32'h00FF_00FF;
    BitXL mask_right_s8  = 32'hFF00_FF00;

    BitXL mask_left_s16  = 32'h0000_FFFF;
    BitXL mask_right_s16 = 32'hFFFF_0000;
  `elsif RV64
    BitXL mask_left_s1   = 32'h55555555_55555555;
    BitXL mask_right_s1  = 32'hAAAAAAAA_AAAAAAAA;

    BitXL mask_left_s2   = 32'h33333333_33333333;
    BitXL mask_right_s2  = 32'hCCCCCCCC_CCCCCCCC;

    BitXL mask_left_s4   = 32'h0F0F0F0F_0F0F0F0F;
    BitXL mask_right_s4  = 32'hF0F0F0F0_F0F0F0F0;

    BitXL mask_left_s8   = 32'h00FF00FF_00FF00FF;
    BitXL mask_right_s8  = 32'hFF00FF00_FF00FF00;

    BitXL mask_left_s16  = 32'h0000FFFF_0000FFFF;
    BitXL mask_right_s16 = 32'hFFFF0000_FFFF0000;

    BitXL mask_left_s32  = 32'h00000000_FFFFFFFF;
    BitXL mask_right_s32 = 32'hFFFFFFFF_00000000;
  `endif

  rule rl_calc (rg_state != Idle);

    if ((rg_state == Calc_1) && (unpack(rg_rs2[0]))) begin
      let left  = (rg_rs1 & mask_left_s1)   << 1;  // arithmetic to the left and right
      let right = (rg_rs1 & mask_right_s1)  >> 1;  // of the OR in B spec's C impl
      rg_rs1   <= left | right;
    end

    if ((rg_state == Calc_2) && (unpack(rg_rs2[0]))) begin
      let left  = (rg_rs1 & mask_left_s2)   << 2;  // arithmetic to the left and right
      let right = (rg_rs1 & mask_right_s2)  >> 2;  // of the OR in B spec's C impl
      rg_rs1   <= left | right;
    end

    if ((rg_state == Calc_4) && (unpack(rg_rs2[0]))) begin
      let left  = (rg_rs1 & mask_left_s4)   << 4;  // arithmetic to the left and right
      let right = (rg_rs1 & mask_right_s4)  >> 4;  // of the OR in B spec's C impl
      rg_rs1   <= left | right;
    end

    if ((rg_state == Calc_8) && (unpack(rg_rs2[0]))) begin
      let left  = (rg_rs1 & mask_left_s8)   << 8;  // arithmetic to the left and right
      let right = (rg_rs1 & mask_right_s8)  >> 8;  // of the OR in B spec's C impl
      rg_rs1   <= left | right;
    end

    if ((rg_state == Calc_16) && (unpack(rg_rs2[0]))) begin
      let left  = (rg_rs1 & mask_left_s16)  << 16;  // arithmetic to the left and right
      let right = (rg_rs1 & mask_right_s16) >> 16;  // of the OR in B spec's C impl
      rg_rs1   <= left | right;
    end

    `ifdef RV64
    if ((rg_state == Calc_32) && (unpack(rg_rs2[0]))) begin
      let left  = (rg_rs1 & mask_left_s32)  << 32;  // arithmetic to the left and right
      let right = (rg_rs1 & mask_right_s32) >> 32;  // of the OR in B spec's C impl
      rg_rs1   <= left | right;
    end
    `endif

    rg_rs2 <= rg_rs2 >> 1;  // shift rs2 rather than some bit select logic, then look at LSB
  endrule: rl_calc

  ///////////////////////////
  //                       //
  //  Interface            //
  //                       //
  ///////////////////////////  

  method Action args_put (Vector #(double_port, BitXL) arg, Bit #(no_options) option) if (rg_state == Idle);
    rg_rs1     <= arg[0];
    rg_rs2     <= arg[1][(log_xlen - 1):0];
    rg_state   <= Calc_1;
  endmethod: args_put

  method Action kill;
    rg_state <= Idle;
  endmethod: kill

  method Bool valid_get;
    return ((rg_rs2 >> 1) == 0); 
  endmethod: valid_get

  method BitXL value_get;
    return rg_rs1;
  endmethod: value_get

endmodule: mkGrevIter

endpackage: BitManipGrev
