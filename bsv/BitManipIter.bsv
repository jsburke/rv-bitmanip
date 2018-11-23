package BitManipIter;

/////////////////////////////////////////////////
//                                             //
// Iterative Module Notes:                     //
//                                             //
// This Module implements 11 of the B spec     //
// operations (ANDC is forced into BBox).      //
//                                             //
// This one is intended as a simplest model.   //
// All of the operations will complete in      //
// an unfixed interval at most XLEN cycles     //
// in length.                                  //
//                                             //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//                                             //
// Project Imports                             //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
// Iterative Module                            //
//                                             //
/////////////////////////////////////////////////

module mkBitManipIter (BitManip_IFC);

  Reg #(BitXL)      rg_res       <- mkRegU;  // we'll accumulate a result here
  Reg #(BitXL)      rg_control   <- mkRegU;  // normly lsb says rg_res changes,  when to terminate 

  // Below registers are only used for bext and bdep
  //
  // rough correspondence with C impl in util
  //
  // rg_res         -- xlen_t r
  // rg_control     -- rs2 (causes things controlled by C Impl's j to left shift)
  // rg_seed        -- one << [i,j]  // remembers shifts rather than applying as needed like C
  // rg_setter      -- rs1

  Reg #(BitXL)      rg_seed      <- mkRegU;  // also manages shifts in grev
  Reg #(BitXL)      rg_setter    <- mkRegU;

  // module operative control registers
  Reg #(IterState)  rg_state     <- mkReg(S_Idle);
  Reg #(BitManipOp) rg_operation <- mkRegU;
  `ifdef RV64
  Reg #(Bool)       rg_32_bit    <- mkRegU;
  `endif

  `ifdef HW_DIAG
  Reg #(int)        rg_cycle     <- mkReg(0);
  `endif

  /////////////////////////
  //                     //
  // Rule Controls       //
  //                     //
  /////////////////////////

  BitXL   minus_1 = '1;
  BitXL   msb_set = (1 << (xlen - 1));
  BitXL   lsb_set = 1;
  `ifdef RV32
  BitXL   res_saturation = 32;
  `elsif RV64
  BitXL   lower_32 = 64'h0000_0000__FFFF_FFFF;
  BitXL   upper_32 = 64'hFFFF_FFFF__0000_0000;
  BitXL   res_saturation = (rg_32_bit) ? 32 : 64;
  BitXL   msb_set_32     = 64'h0000_0000__8000_0000;
  `endif

  Bool is_right_shift_op = (rg_operation == CLZ)  ||
                           (rg_operation == CTZ)  ||
                           (rg_operation == PCNT) ||
                           (rg_operation == SRO)  ||
                           (rg_operation == ROR);

  Bool is_left_shift_op  = (rg_operation == SLO)  ||
                           (rg_operation == ROL);
  

  Bool is_rule_right_shift =  (rg_state == S_Calc) &&  is_right_shift_op;
  Bool is_rule_left_shift  =  (rg_state == S_Calc) &&  is_left_shift_op;
  Bool is_rule_grev        = ((rg_state != S_Idle) && (rg_state != S_Calc)) &&
                              (rg_operation == GREV);
  Bool is_rule_shfl        = ((rg_state != S_Idle) && (rg_state != S_Calc)) && 
                             ((rg_operation == SHFL) || (rg_operation == UNSHFL));
  Bool is_rule_bext_bdep   =  (rg_state == S_Calc) && ((rg_operation == BEXT) || 
                                                      (rg_operation == BDEP));

  // NB: some exit conditions are honestly early exit (ie: grev, shuffles)
  //             exit          if bit we see is 1    OR  result saturates at XLEN
  Bool exit_zero_count     = ((unpack(rg_control[0])) || (rg_res == res_saturation)) && 
                             ((rg_operation == CLZ) || (rg_operation == CTZ));

  //             exit         if rs1 becomes 0 OR  result saturates
  Bool exit_ones_count     = ((rg_control == 0) || (rg_res == res_saturation)) &&
                              (rg_operation == PCNT);

  `ifdef RV32
  Bool res_is_minus_1      = (rg_res == minus_1);
  `elsif RV64
  Bool res_is_minus_1      = ((rg_32_bit)  && (rg_res == lower_32)) ||
                             ((!rg_32_bit) && (rg_res == minus_1));
  `endif

  //             exit         if res saturates   OR  control is depleted
  Bool exit_shift_ones     = (res_is_minus_1) || (rg_control == 0) &&
                             ((rg_operation == SRO) || (rg_operation == SLO));

  //             exit         when control depletes
  Bool exit_rot_grev       = (rg_control == 0) &&
                             ((rg_operation == ROR)  || (rg_operation == ROL)    ||
                              (rg_operation == GREV));  

  //             exit         when either reg assoc with rs1 or rs2 depletes
  Bool exit_bext_bdep      = (rg_control == 0) || (rg_setter == 0) &&
                             ((rg_operation == BEXT) || (rg_operation == BDEP)); 

  // andc not handled here

  Bool terminate_right_shift = is_right_shift_op  && (exit_zero_count || exit_ones_count ||
                                                      exit_shift_ones || exit_rot_grev);
  Bool terminate_left_shift  = is_left_shift_op   && (exit_shift_ones || exit_rot_grev);

  Bool terminate_grev        = exit_rot_grev      && (rg_operation == GREV);
  Bool terminate_shfl        = (rg_control == 0)  && ((rg_operation == SHFL) || 
                                                     (rg_operation == UNSHFL)); 
  Bool terminate_bext_bdep   = exit_bext_bdep     && ((rg_operation == BEXT) || 
                                                      (rg_operation == BDEP));

  Bool result_valid          = terminate_right_shift || terminate_left_shift || terminate_grev ||
                               terminate_shfl        || terminate_bext_bdep;
  /////////////////////////
  //                     //
  // Rules               //
  //                     //
  /////////////////////////

  // control sigs for rl_right_shifts
  Bool is_zero_count = (rg_operation == CLZ)  || (rg_operation == CTZ);
  Bool is_pcnt_inc   = (rg_operation == PCNT) && (unpack(rg_control[0]));
  Bool is_ror_sro    = (rg_operation == ROR)  || (rg_operation == SRO);

  // rule manages CLZ, CTZ, PCNT, SRO, ROR
  rule rl_right_shifts (is_rule_right_shift);
    `ifdef HW_DIAG
      $display("-------  RIGHT SHIFT RULE -------");
      $display("   Operation  -- ", fshow(rg_operation));
      $display("   State      -- ", fshow(rg_state));
      $display("   Cycles     -- %d", rg_cycle);
      $display(" ");
      $display("   res        -- %h", rg_res);
      $display("   control    -- %h", rg_control);
      $display("   seed       -- %h", rg_seed);
      $display("   setter     -- %h", rg_setter);
      $display("   terminating - %b", terminate_right_shift);
      rg_cycle <= rg_cycle + 1;
    `endif
    if (terminate_right_shift) rg_state <= S_Idle;
    else begin
      // for ROR, we steal the lsb, otherwise we only care for SRO
      `ifdef RV32
      let new_msb = (rg_operation == ROR) ? reverseBits(rg_res & lsb_set) : msb_set;
      `elsif RV64
      let ror_shamt = (rg_32_bit) ? 32 : 0;
      let sro_msb   = (rg_32_bit) ? msb_set_32 : msb_set;
      let new_msb   = (rg_operation == ROR) ? (reverseBits(rg_res & lsb_set) >> ror_shamt) : sro_msb;
      `endif

      // increment rg_res if zero counts are going or pcnt has a set bit
      // use earlier new_mb for sro and ror
      // leave it be if pcnt does not have a set bit
      rg_res <= (is_zero_count || is_pcnt_inc) ? rg_res + 1 :
                (is_ror_sro)                   ? ((rg_res >> 1) | new_msb) : 
                                                 rg_res;

      rg_control <= (is_ror_sro) ? (rg_control - 1) : (rg_control >> 1);
    end
  endrule: rl_right_shifts



  // rule manages SLO and ROL
  rule rl_left_shifts (is_rule_left_shift);
    `ifdef HW_DIAG
      $display("-------  LEFT SHIFT RULE -------");
      $display("   Operation  -- ", fshow(rg_operation));
      $display("   State      -- ", fshow(rg_state));
      $display("   Cycles     -- %d", rg_cycle);
      $display(" ");
      $display("   res        -- %h", rg_res);
      $display("   control    -- %h", rg_control);
      $display("   seed       -- %h", rg_seed);
      $display("   setter     -- %h", rg_setter);
      $display("   terminating - %b", terminate_left_shift);
      rg_cycle <= rg_cycle + 1;
    `endif
    if (terminate_left_shift) rg_state <= S_Idle;
    else begin
      // see note above for new_msb, and think backwards for new_lsb
      `ifdef RV32
      let new_lsb = (rg_operation == ROL) ? reverseBits(rg_res & msb_set) : lsb_set;
      `elsif RV64
      let rol_shamt = (rg_32_bit) ? 32 : 0;
      let new_lsb = (rg_operation == ROL) ? (reverseBits(rg_res & msb_set) >> rol_shamt) : lsb_set;
      `endif

      rg_res     <= ((rg_res << 1) | new_lsb);
      rg_control <= rg_control - 1;
    end
  endrule: rl_left_shifts



  // rule manages GREV
  rule rl_grev (is_rule_grev);
    `ifdef HW_DIAG
      $display("-------  GREV RULE -------");
      $display("   Operation  -- ", fshow(rg_operation));
      $display("   State      -- ", fshow(rg_state));
      $display("   Cycles     -- %d", rg_cycle);
      $display(" ");
      $display("   res        -- %h", rg_res);
      $display("   control    -- %h", rg_control);
      $display("   seed       -- %h", rg_seed);
      $display("   setter     -- %h", rg_setter);
      $display("   terminating - %b", terminate_grev);
      rg_cycle <= rg_cycle + 1;
    `endif
    if (terminate_grev) rg_state <= S_Idle;
    else begin
      rg_control <= rg_control >> 1;  // this way we can get the next lsb of rs2
      rg_state   <= fv_grevNextState (rg_state);
      rg_seed    <= rg_seed << 1;

      // next we apply shifts and masks per state we're in and if the lsb is set
      let left_mask  = (rg_state == S_Stage_1)  ? grev_left_s1 :
                       (rg_state == S_Stage_2)  ? grev_left_s2 :
                       (rg_state == S_Stage_4)  ? grev_left_s4 :
                       (rg_state == S_Stage_8)  ? grev_left_s8 :
                       (rg_state == S_Stage_16) ? grev_left_s16:
                       `ifdef RV64
                       (rg_state == S_Stage_32) ? grev_left_s32 :
                       `endif
                       0;

      let right_mask = (rg_state == S_Stage_1)  ? grev_right_s1 :
                       (rg_state == S_Stage_2)  ? grev_right_s2 :
                       (rg_state == S_Stage_4)  ? grev_right_s4 :
                       (rg_state == S_Stage_8)  ? grev_right_s8 :
                       (rg_state == S_Stage_16) ? grev_right_s16:
                       `ifdef RV64
                       (rg_state == S_Stage_32) ? grev_right_s32 :
                       `endif
                       0;

      let left  = (rg_res & left_mask)  << rg_seed;
      let right = (rg_res & right_mask) >> rg_seed;

      rg_res <= (unpack(rg_control[0])) ? (left | right) : rg_res;

   end
  endrule: rl_grev



  // rule manages SHFL and UNSHFL
  rule rl_shfl (is_rule_shfl);
    `ifdef HW_DIAG
      $display("-------  SHUFFLE RULE -------");
      $display("   Operation  -- ", fshow(rg_operation));
      $display("   State      -- ", fshow(rg_state));
      $display("   Cycles     -- %d", rg_cycle);
      $display(" ");
      $display("   res        -- %h", rg_res);
      $display("   control    -- %b", rg_control[4:0]); // get all germane bits regardless of xlen
      $display("   seed       -- %h", rg_seed);
      $display("   setter     -- %h", rg_setter);
      $display("   terminating - %b", terminate_shfl);
      rg_cycle <= rg_cycle + 1;
    `endif
    if (terminate_shfl) rg_state <= S_Idle;
    else begin
      rg_control <= rg_control >> 1;
      rg_state   <= fv_shflNextState(rg_state, (rg_operation == SHFL));

      let shuffle = (rg_state == S_Stage_1)  ? fv_shuffleStage(rg_res, shfl_left_s1,  shfl_right_s1,  1) :
                    (rg_state == S_Stage_2)  ? fv_shuffleStage(rg_res, shfl_left_s2,  shfl_right_s2,  2) :
                    (rg_state == S_Stage_4)  ? fv_shuffleStage(rg_res, shfl_left_s4,  shfl_right_s4,  4) :
                    (rg_state == S_Stage_8)  ? fv_shuffleStage(rg_res, shfl_left_s8,  shfl_right_s8,  8) :
                    `ifdef RV64
                    (rg_state == S_Stage_16) ? fv_shuffleStage(rg_res, shfl_left_s16, shfl_right_s16, 16) :
                    `endif
                    rg_res;  // safe defalut??
      rg_res     <= (unpack(rg_control[0])) ? shuffle : rg_res;
    end
  endrule: rl_shfl

  // control sigs to determine shifts in bext and bdep
  Bool seed_shift_bext_bdep   =  (rg_operation == BDEP) || 
                                ((rg_operation == BEXT) && (unpack(rg_control[0])));
  Bool setter_shift_bext_bdep =  (rg_operation == BEXT) || 
                                ((rg_operation == BDEP) && (unpack(rg_control[0])));
  Bool alter_res_bext_bdep    = unpack((rg_setter & rg_control)[0]);

  // rule manages BEXT and BDEP
  rule rl_bext_bdep (is_rule_bext_bdep);
    `ifdef HW_DIAG
      $display("-------  BEXT BDEP RULE -------");
      $display("   Operation  -- ", fshow(rg_operation));
      $display("   State      -- ", fshow(rg_state));
      $display("   Cycles     -- %d", rg_cycle);
      $display(" ");
      $display("   res        -- %h", rg_res);
      $display("   control    -- %h", rg_control);
      $display("   seed       -- %h", rg_seed);
      $display("   setter     -- %h", rg_setter);
      $display("   terminating - %b", terminate_bext_bdep);
      rg_cycle <= rg_cycle + 1;
    `endif
    if (terminate_bext_bdep) rg_state <= S_Idle;
    else begin
      rg_control <= rg_control >> 1;
      if (seed_shift_bext_bdep)   rg_seed   <= rg_seed << 1;
      if (setter_shift_bext_bdep) rg_setter <= rg_setter >> 1;
      if (alter_res_bext_bdep)    rg_res    <= rg_res | rg_seed;
    end
  endrule: rl_bext_bdep

  /////////////////////////
  //                     //
  // Interface           //
  //                     //
  /////////////////////////

  method Action args_put(BitXL arg0, BitXL arg1, BitManipOp op_sel
                         `ifdef RV64
                          ,Bool is_32bit
                         `endif
                          ) if (rg_state == S_Idle);

    let res_init     = fv_result_init  (op_sel, arg0);
    `ifdef RV32
    let control_init = fv_control_init (op_sel, arg0, arg1);
    `elsif RV64
    let control_init = fv_control_init (op_sel, arg0, arg1, is_32bit);
    `endif

    rg_res     <= res_init; 
    rg_control <= control_init;
 
    // assigning the below in a slightly sloppy fashion since
    // only the pack operations utilize them (grev uses seed)
    rg_seed     <= 1;
    rg_setter   <= arg0;

    rg_operation <= op_sel;
    rg_state     <= fv_state_init (op_sel); 

    `ifdef RV64
    rg_32_bit    <= is_32bit;
    `endif

    `ifdef HW_DIAG
    rg_cycle     <= 0;  // init for diagnostic build
    $display("--------------------------------------");
    $display("   BitManipIter Arg Put               ");
    $display("   Operation: ", fshow(op_sel));
    `ifdef RV64
    if(!is_32bit)
      $display("   64 bit mode ");
    else
      $display("   32 bit mode ");
    $display(" ");
    $display("     Res     init : %h", res_init);
    $display("     Control init : %h", control_init);
    $display("     Seed always inits to 1");
    $display("     Setter  init : %h", arg0);
    $display("--------------------------------------");
    `endif
    `endif

  endmethod: args_put

  method Action kill;
    rg_state <= S_Idle;
  endmethod: kill

  method Bool is_busy;
    return (rg_state != S_Idle);
  endmethod: is_busy

  method BitXL value_get;
    `ifdef RV32
    return rg_res;
    `elsif RV64
    return (rg_32_bit) ? (rg_res & lower_32) : rg_res;
    `endif
  endmethod: value_get

endmodule: mkBitManipIter

endpackage: BitManipIter
