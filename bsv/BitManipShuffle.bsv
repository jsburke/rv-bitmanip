package BitManipShuffle;

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
  typedef enum {Idle, Calc_1, Calc_2, Calc_4, Calc_8}          ShuffleState deriving (Eq, Bits, FShow);
`elsif RV64
  typedef enum {Idle, Calc_1, Calc_2, Calc_4, Calc_8, Calc_16} ShuffleState deriving (Eq, Bits, FShow);
`endif

typedef enum {Shuffle, Unshuffle} ShuffleMode deriving (Eq, Bits);

function ShuffleState fv_state_inc(ShuffleState s, ShuffleMode m);

  if (m == Unshuffle) begin 
    case(s) matches
      Calc_1  : return Calc_2;
      Calc_2  : return Calc_4;
      Calc_4  : return Calc_8;
      `ifdef RV64
      Calc_8  : return Calc_16;
      `endif
      default : return    Idle;
    endcase
  end else begin// m == Shuffle
    case(s) matches
      `ifdef RV64
      Calc_16 : return Calc_8;
      `endif
      Calc_8  : return Calc_4;
      Calc_4  : return Calc_2;
      Calc_2  : return Calc_1;
      default : return   Idle;
    endcase
  end

endfunction: fv_state_inc

module mkShuffleIter (BitManip_IFC #(double_port, no_options));

  Reg #(BitXL)      rg_rs1     <- mkRegU;
  `ifdef RV32
  Reg #(Bit #(4))   rg_rs2     <- mkRegU;
  `elsif RV64
  Reg #(Bit #(5))   rg_rs2     <- mkRegU;
  `endif
  // rg_rs1 acts as result register as well
  // rg_rs2 effectively is our "shamt" or revving select  

  Reg #(ShuffleState)  rg_state   <- mkReg(Idle);  
  Reg #(ShuffleMode)   rg_mode    <- mkRegU;

  ///////////////////////////
  //                       //
  //  Rules                //
  //                       //
  ///////////////////////////

  `ifdef RV32
    BitXL mask_left_s1   = 32'h4444_4444;
    BitXL mask_right_s1  = 32'h2222_2222;

    BitXL mask_left_s2   = 32'h3030_3030;
    BitXL mask_right_s2  = 32'h0C0C_0C0C;

    BitXL mask_left_s4   = 32'h0F00_0F00;
    BitXL mask_right_s4  = 32'h00F0_00F0;

    BitXL mask_left_s8   = 32'h00FF_0000;
    BitXL mask_right_s8  = 32'h0000_FF00;
  `elsif RV64
    BitXL mask_left_s1   = 64'h44444444_44444444;
    BitXL mask_right_s1  = 64'h22222222_22222222;

    BitXL mask_left_s2   = 64'h30303030_30303030;
    BitXL mask_right_s2  = 64'h0C0C0C0C_0C0C0C0C;

    BitXL mask_left_s4   = 64'h0F000F00_0F000F00;
    BitXL mask_right_s4  = 64'h00F000F0_00F000F0;

    BitXL mask_left_s8   = 64'h00FF0000_00FF0000;
    BitXL mask_right_s8  = 64'h0000FF00_0000FF00;

    BitXL mask_left_s16  = 64'h0000FFFF_00000000;
    BitXL mask_right_s16 = 64'h00000000_FFFF0000;
  `endif

  function BitXL fv_shuffle_stage(BitXL src, BitXL mask_left, BitXL mask_right, BitXLog shamt);
    let x = src & ~(mask_left | mask_right);
    return x | (((src << shamt) & mask_left) | ((src >> shamt) & mask_right));
  endfunction: fv_shuffle_stage

  rule rl_calc (rg_state != Idle);

    `ifdef HW_DBG
    $display("  --  HW_DBG : (un)shuffle rs1 == %h || rs2 == %b", rg_rs1, rg_rs2);
    $display("  --  Stage ", fshow(rg_state));
    `endif

    if ((rg_state == Calc_1) && (unpack(rg_rs2[0]))) begin
      rg_rs1   <= fv_shuffle_stage(rg_rs1, mask_left_s1, mask_right_s1, 1);
    end

    if ((rg_state == Calc_2) && (unpack(rg_rs2[0]))) begin
      rg_rs1   <= fv_shuffle_stage(rg_rs1, mask_left_s2, mask_right_s2, 2);
    end

    if ((rg_state == Calc_4) && (unpack(rg_rs2[0]))) begin
      rg_rs1   <= fv_shuffle_stage(rg_rs1, mask_left_s4, mask_right_s4, 4);
    end

    if ((rg_state == Calc_8) && (unpack(rg_rs2[0]))) begin
      rg_rs1   <= fv_shuffle_stage(rg_rs1, mask_left_s8, mask_right_s8, 8);
    end

    `ifdef RV64
    if ((rg_state == Calc_16) && (unpack(rg_rs2[0]))) begin
      rg_rs1   <= fv_shuffle_stage(rg_rs1, mask_left_s16, mask_right_s16, 16);
    end
    `endif

    rg_rs2 <= rg_rs2 >> 1;  // shift rs2 rather than some bit select logic, then look at LSB
    if(rg_rs2 == 0) rg_state <= Idle;
    else begin
      rg_state <= fv_state_inc(rg_state, rg_mode);
    end
  endrule: rl_calc

  ///////////////////////////
  //                       //
  //  Interface            //
  //                       //
  ///////////////////////////  

  method Action args_put (Vector #(double_port, BitXL) arg, Bit #(no_options) option) if (rg_state == Idle);

    rg_rs1     <= arg[0];

    let is_unshfl = arg[0][0];
    let op_1      = arg[1][(log_xlen - 2):1];

    rg_rs2     <= (unpack(is_unshfl)) ? op_1 : reverseBits(op_1);
    rg_mode    <= (unpack(is_unshfl)) ? Unshuffle : Shuffle;

    `ifdef RV32
    rg_state   <= (unpack(is_unshfl)) ? Calc_1 : Calc_8;
    `elsif RV64
    rg_state   <= (unpack(is_unshfl)) ? Calc_1 : Calc_16;
    `endif
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

endmodule: mkShuffleIter

endpackage: BitManipShuffle
