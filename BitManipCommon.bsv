package BitManip_IFC;

/////////////////////////////////////////////////
//                                             //
// Universal BitManip Interface                //
//                                             //
/////////////////////////////////////////////////

interface BitCommon_IFC #(type bit_t);
  method Action kill;
  method Bool   valid_get;
  method bit_t  value_get;
endinterface: BitCommon_IFC

/////////////////////////////////////////////////
//                                             //
// Interfaces Extended For Argument Inputs     //
//                                             //
/////////////////////////////////////////////////

interface BitSingle_IFC #(type bit_t);
  method    Action                 args_put (bit_t arg0);
  interface BitCommon_IFC #(bit_t) common;
endinterface: BitSingle_IFC

interface BitDouble_IFC #(type bit_t);
  method    Action                 args_put (bit_t arg0, bit_t arg1);
  interface BitCommon_IFC #(bit_t) common;
endinterface: BitDouble_IFC

endpackage: BitManip_IFC
