package BitManipMeta;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//                                             //
// Types and Aliases                           //
//                                             //
/////////////////////////////////////////////////

`ifdef RV32
 typedef 32 XLEN;
`elsif RV64
 typedef 64 XLEN;
`else  // don't know why it was missed...
 typedef 32 XLEN;
`endif

typedef TLog #(XLEN) LOG_XLEN;

Integer xlen     = valueOf(XLEN);
Integer log_xlen = valueOf(LOG_XLEN);

typedef Bit #(XLEN)     BitXL;
typedef Bit #(LOG_XLEN) BitXLog;

BitXL bitxl_zero = 0;

/////////////////////////////////////////////////
//                                             //
//  Grev and Shuffle Masks and Functions       //
//                                             //
/////////////////////////////////////////////////

`ifdef RV32
BitXL grev_left_s1   = 32'h5555_5555;
BitXL grev_right_s1  = 32'hAAAA_AAAA;

BitXL grev_left_s2   = 32'h3333_3333;
BitXL grev_right_s2  = 32'hCCCC_CCCC;

BitXL grev_left_s4   = 32'h0F0F_0F0F;
BitXL grev_right_s4  = 32'hF0F0_F0F0;

BitXL grev_left_s8   = 32'h00FF_00FF;
BitXL grev_right_s8  = 32'hFF00_FF00;

BitXL grev_left_s16  = 32'h0000_FFFF;
BitXL grev_right_s16 = 32'hFFFF_0000;
`elsif RV64
BitXL grev_left_s1   = 64'h55555555_55555555;
BitXL grev_right_s1  = 64'hAAAAAAAA_AAAAAAAA;

BitXL grev_left_s2   = 64'h33333333_33333333;
BitXL grev_right_s2  = 64'hCCCCCCCC_CCCCCCCC;

BitXL grev_left_s4   = 64'h0F0F0F0F_0F0F0F0F;
BitXL grev_right_s4  = 64'hF0F0F0F0_F0F0F0F0;

BitXL grev_left_s8   = 64'h00FF00FF_00FF00FF;
BitXL grev_right_s8  = 64'hFF00FF00_FF00FF00;

BitXL grev_left_s16  = 64'h0000FFFF_0000FFFF;
BitXL grev_right_s16 = 64'hFFFF0000_FFFF0000;

BitXL grev_left_s32  = 64'h00000000_FFFFFFFF;
BitXL grev_right_s32 = 64'hFFFFFFFF_00000000;
`endif


`ifdef RV32
BitXL shfl_left_s1   = 32'h4444_4444;
BitXL shfl_right_s1  = 32'h2222_2222;

BitXL shfl_left_s2   = 32'h3030_3030;
BitXL shfl_right_s2  = 32'h0C0C_0C0C;

BitXL shfl_left_s4   = 32'h0F00_0F00;
BitXL shfl_right_s4  = 32'h00F0_00F0;

BitXL shfl_left_s8   = 32'h00FF_0000;
BitXL shfl_right_s8  = 32'h0000_FF00;
`elsif RV64
BitXL shfl_left_s1   = 64'h44444444_44444444;
BitXL shfl_right_s1  = 64'h22222222_22222222;

BitXL shfl_left_s2   = 64'h30303030_30303030;
BitXL shfl_right_s2  = 64'h0C0C0C0C_0C0C0C0C;

BitXL shfl_left_s4   = 64'h0F000F00_0F000F00;
BitXL shfl_right_s4  = 64'h00F000F0_00F000F0;

BitXL shfl_left_s8   = 64'h00FF0000_00FF0000;
BitXL shfl_right_s8  = 64'h0000FF00_0000FF00;

BitXL shfl_left_s16  = 64'h0000FFFF_00000000;
BitXL shfl_right_s16 = 64'h00000000_FFFF0000;
`endif

// pretty much calque the C code in spec
function BitXL fv_shuffleStage(BitXL src, BitXL mask_left, BitXL mask_right, BitXLog shamt);
  let x = src & ~(mask_left | mask_right);
  return x | (((src << shamt) & mask_left) | ((src >> shamt) & mask_right));
endfunction: fv_shuffleStage

/////////////////////////////////////////////////
//                                             //
//  BitManip Enums and Aux Functions           //
//                                             //
/////////////////////////////////////////////////

// below enum describes state for the unfixed latency iterative design
typedef enum {S_Idle,      // awaiting args
              S_Calc,      // indeterminate state for counts, shifts, etc
              S_Stage_1,   // preset stages for grev and shfl
              S_Stage_2,
              S_Stage_4,
              S_Stage_8,
              S_Stage_16   // only grev will use final stage
`ifdef RV64                // shfl needs one less
             ,S_Stage_32
`endif
                        }  IterState deriving (Eq, Bits, FShow);

function IterState fv_grevNextState (IterState s);
  case (s) matches
    S_Stage_1  : return  S_Stage_2;
    S_Stage_2  : return  S_Stage_4;
    S_Stage_4  : return  S_Stage_8;
    S_Stage_8  : return S_Stage_16;
    `ifdef RV64
    S_Stage_16 : return S_Stage_32;
    `endif
    default    : return S_Idle;
  endcase
endfunction: fv_grevNextState

function IterState fv_shflNextState (IterState s, Bool is_shfl);
  if(is_shfl) begin // shuffle state progression
    case (s) matches
      `ifdef RV64
      S_Stage_16 : return  S_Stage_8;
      `endif
      S_Stage_8  : return  S_Stage_4;
      S_Stage_4  : return  S_Stage_2;
      S_Stage_2  : return  S_Stage_1;
      default    : return     S_Idle;
    endcase
  end else begin // Unshuffle state progression 
    case (s) matches
      S_Stage_1  : return  S_Stage_2;
      S_Stage_2  : return  S_Stage_4;
      S_Stage_4  : return  S_Stage_8;
      `ifdef RV64
      S_Stage_8  : return S_Stage_16;
      `endif
      default    : return     S_Idle;
    endcase
  end
endfunction: fv_shflNextState

typedef enum {CLZ,
              CTZ,
              PCNT,
              SRO,
              SLO,
              ROR,
              ROL,
              GREV,
              SHFL,
              UNSHFL,
              BEXT,
              BDEP,
              `ifdef RV64
              CLZW,
              CTZW,
              PCNTW,
              SROW,
              SLOW,
              RORW,
              ROLW,
              BEXTW,
              BDEPW,
              `endif
              ANDC} BitManipOp deriving (Eq, Bits, FShow);

/////////////////////////////////////////////////
//                                             //
//  BitManip Interfaces and Funcitons          //
//                                             //
/////////////////////////////////////////////////

interface BitManip_IFC; 
  (* always_ready *)
  method Action args_put (BitXL      arg0, 
                          BitXL      arg1,
                          BitManipOp op_sel // 11 possible ops, so 4 bits for coverage
                          `ifdef RV64
                          ,Bool  is_32bit //64 bit have the W instructions
                          `endif
                          );

  (* always_ready *)
  method Action kill;

  (* always_ready *) method Bool   is_busy;
  (* always_ready *) method BitXL  value_get;
endinterface: BitManip_IFC

// functions to set registers in the modules on args_put
// question: put these in BitManipIter.bsv???
function BitXL fv_result_init (BitManipOp op, BitXL arg0);
  `ifdef RV32
  let is_zero_init = (op == CLZ)  || (op == CTZ)  || (op == PCNT)  || (op == BEXT)  || (op == BDEP);  
  `elsif RV64
  let is_zero_init = (op == CLZ)  || (op == CTZ)  || (op == PCNT)  || (op == BEXT)  || (op == BDEP) ||
                      (op == CLZW) || (op == CTZW) || (op == PCNTW) || (op == BEXTW) || (op == BDEPW) ;  
  `endif
  return (is_zero_init) ? 0 : arg0; // not super worried about how andc behaves here...
endfunction: fv_result_init

`ifdef RV64
BitXL lower_32 = 64'h0000_0000__FFFF_FFFF;
`endif

function BitXL fv_control_init (BitManipOp op, 
                                BitXL      arg0,
                                BitXL      arg1
                                `ifdef RV64
                               ,Bool       is_32_bit
                                `endif
                                );
  `ifdef RV64
  if(is_32_bit) begin
    case (op) matches
      CLZ     : return reverseBits(arg0) >> 32;
      CTZ     : return arg0 & lower_32;
      PCNT    : return arg0 & lower_32;
      SRO     : return arg1[(log_xlen - 2) : 0];
      SLO     : return arg1[(log_xlen - 2) : 0];
      ROR     : return arg1[(log_xlen - 2) : 0];
      ROL     : return arg1[(log_xlen - 2) : 0];
      GREV    : return arg1[(log_xlen - 2) : 0];
      SHFL    : return reverseBits(arg1) >> (xlen - 4);
      UNSHFL  : return arg1[(log_xlen - 2) : 0];       
      BEXT    : return arg1 & lower_32;
      BDEP    : return arg1 & lower_32;
      default : return 0;
    endcase
  end
  else begin
  `endif
    case (op) matches
      CLZ     : return reverseBits(arg0);
      CTZ     : return arg0;
      PCNT    : return arg0;
      SRO     : return arg1[(log_xlen - 1) : 0];
      SLO     : return arg1[(log_xlen - 1) : 0];
      ROR     : return arg1[(log_xlen - 1) : 0];
      ROL     : return arg1[(log_xlen - 1) : 0];
      GREV    : return arg1[(log_xlen - 1) : 0];
      SHFL    : return reverseBits(arg1) >> (xlen - (log_xlen - 1));
      UNSHFL  : return arg1[(log_xlen - 2) : 0];
      BEXT    : return arg1;
      BDEP    : return arg1;
      default : return 0; // expecting andc, want this to be poor behaving
    endcase
  `ifdef RV64
  end
  `endif
endfunction

function IterState fv_state_init(BitManipOp op);
  case(op) matches
    CLZ      : return S_Calc;
    CTZ      : return S_Calc;
    PCNT     : return S_Calc;
    SRO      : return S_Calc;
    SLO      : return S_Calc;
    ROR      : return S_Calc;
    ROL      : return S_Calc;
    GREV     : return S_Stage_1;
    `ifdef RV32  // this shuffle portion will likely get messy...
    SHFL     : return S_Stage_8;
    `elsif RV64
    SHFL     : return S_Stage_16;
    `endif
    UNSHFL   : return S_Stage_1;
    BEXT     : return S_Calc;
    BDEP     : return S_Calc;
    ANDC     : return S_Idle; // andc not managed here
    default  : return S_Idle;
  endcase
endfunction: fv_state_init

endpackage: BitManipMeta
