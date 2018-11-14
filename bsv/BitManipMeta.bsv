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
//  BitManip Interface                         //
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

function IterState fv_grevNextState(IterState s);
  case(s) matches
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

function IterState fv_shflNextState(IterState s, Bool is_shfl);
  if(is_shfl) begin // shuffle state progression
    case(s) matches
      `ifdef RV64
      S_Stage_16 : return  S_Stage_8;
      `endif
      S_Stage_8  : return  S_Stage_4;
      S_Stage_4  : return  S_Stage_2;
      S_Stage_2  : return  S_Stage_1;
      default    : return     S_Idle;
    endcase
  end else begin // Unshuffle state progression 
    case(s) matches
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


interface BitManip_IFC; 

  (* always_ready *)
  method Action args_put (BitXL arg0, 
                          BitXL arg1
                          `ifdef RV64
                          ,Bool  is_OP32 //64 bit have the W instructions
                          `endif
                          );

  (* always_ready *)
  method Action kill;

  (* always_ready *) method Bool   valid_get;
  (* always_ready *) method BitXL  value_get;
endinterface: BitManip_IFC

endpackage: BitManipMeta
