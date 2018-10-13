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

`endif

typedef TLog #(XLEN) LOG_XLEN;

Integer xlen     = valueOf(XLEN);
Integer log_xlen = valueOf(LOG_XLEN);

typedef Bit #(XLEN) BitXL;

Integer int_single_port = 1;
Integer int_double_port = 2;

/////////////////////////////////////////////////
//                                             //
//  BitManip Interface                         //
//                                             //
/////////////////////////////////////////////////

interface BitManip_IFC #(numeric type no_args);
  method Action args_put (Vector #(no_args, BitXL) arg);
  method Action kill;
  method Bool   valid_get;
  method BitXL  value_get;
endinterface: BitManip_IFC

endpackage: BitManipMeta
