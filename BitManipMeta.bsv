package BitManipMeta;

/////////////////////////////////////////////////
//                                             //
// Types and Aliases                           //
//                                             //
/////////////////////////////////////////////////

`ifdef BIT32 

typedef 32 XLEN;

`elsif BIT64

typedef 64 XLEN;

`endif

typedef TLog #(XLEN) LOG_XLEN;

Integer xlen     = valueOf(XLEN);
Integer log_xlen = valueOf(LOG_XLEN);

typedef Bit #(XLEN) BitXL;

/////////////////////////////////////////////////
//                                             //
// Universal BitManip Interface                //
//                                             //
/////////////////////////////////////////////////

interface BitCommon_IFC;
  method Action kill;
  method Bool   valid_get;
  method BitXL  value_get;
endinterface: BitCommon_IFC

/////////////////////////////////////////////////
//                                             //
// Interfaces Extended For Argument Inputs     //
//                                             //
/////////////////////////////////////////////////

interface BitSingle_IFC;
  method    Action        args_put (BitXL arg0);
  interface BitCommon_IFC common;
endinterface: BitSingle_IFC

interface BitDouble_IFC;
  method    Action        args_put (BitXL arg0, BitXL arg1);
  interface BitCommon_IFC common;
endinterface: BitDouble_IFC

endpackage: BitManipMeta
