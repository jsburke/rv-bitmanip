package BitManip_IFC;

/////////////////////////////////////////////////
//                                             //
// General Interfaces                          //
//                                             //
/////////////////////////////////////////////////

interface BitSingle_IFC #(type bit_t);
  method Action args_put (bit_t arg0);
  method Action kill;
  method Bool   valid_get;
  method bit_t  value_get;
endinterface: BitSingle_IFC

interface BitDual_IFC #(type bit_t);
  method Action args_put (bit_t arg0, bit_t arg1);
  method Action kill;
  method Bool   valid_get;
  method bit_t  value_get;
endinterface: BitDual_IFC

endpackage: BitManip_IFC
