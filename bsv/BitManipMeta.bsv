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

  (* always_ready *) method Bool   valid_get;
  (* always_ready *) method BitXL  value_get;
endinterface: BitManip_IFC

// functions to set registers in the modules on args_put
// question: put these in BitManipIter.bsv???
function BitXL fv_result_init (BitManipOp op, BitXL arg0);
  let is_zero_init = (op == CLZ) || (op == CTZ) || (op == PCNT) || (op == BEXT) || (op == BDEP);
  return (is_zero_init) ? 0 : arg0; // not super worried about how andc behaves here...
endfunction: fv_result_init

function BitXL fv_control_init (BitManipOp op, BitXL arg0, BitXL arg1);
  case (op) matches
    CLZ     : return reverseBits(arg0);
    CTZ     : return arg0;
    PCNT    : return arg0;
    SRO     : return arg1[(log_xlen - 1) : 0];
    SLO     : return arg1[(log_xlen - 1) : 0];
    ROR     : return arg1[(log_xlen - 1) : 0];
    ROL     : return arg1[(log_xlen - 1) : 0];
    GREV    : return arg1[(log_xlen - 1) : 0];
    SHFL    : return arg1[(log_xlen - 2) : 0];
    UNSHFL  : return arg1[(log_xlen - 2) : 0];
    BEXT    : return arg1;
    BDEP    : return arg1;
    default : return 0; // expecting andc, want this to be poor behaving
  endcase
endfunction

endpackage: BitManipMeta
