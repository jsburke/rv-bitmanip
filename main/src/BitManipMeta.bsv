package BitManipMeta;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

import Vector :: *;

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

typedef Bit #(XLEN) BitXL;

// solo or paired source inputs
Integer single_port = 1;
Integer double_port = 2;

// width for option selection
// in modules
Integer no_options  = 0;
Integer one_option  = 1;
Integer two_options = 2;

/////////////////////////////////////////////////
//                                             //
//  BitManip Interface                         //
//                                             //
/////////////////////////////////////////////////

typedef enum {Idle, Calc} IterState deriving (Eq, Bits, FShow);

interface BitManip_IFC #(numeric type no_args, numeric type opt_sz);

  (* always_ready *)
  method Action args_put (Vector #(no_args, BitXL) arg, Bit #(opt_sz) option);

  (* always_ready *)
  method Action kill;

  (* always_ready *)
  method Bool   valid_get;

  (* always_ready *)
  method BitXL  value_get;
endinterface: BitManip_IFC

endpackage: BitManipMeta
