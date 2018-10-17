package BitManipAndComp;

import Vector :: *;

/////////////////////////////////////////////////
//                                             //
//  Project Imports                            //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
//  The Only Module in Here                    //
//                                             //
/////////////////////////////////////////////////

module mkAndWithComplement (BitManip_IFC #(double_port, no_options));

  Wire #(BitXL) result <- mkWire;

  method Action args_put (Vector #(double_port, BitXL) arg, Bit #(no_options) option);
    let rs1 = arg[0];
    let rs2 = arg[1];

    result <= rs1 & ~rs2;
  endmethod: args_put

  method Action kill;
    // what do?  maybe custom IFC??
  endmethod: kill

  method Bool valid_get;
    return True;
  endmethod: valid_get

  method BitXL value_get;
    return result;
  endmethod: value_get
 
endmodule: mkAndWithComplement

endpackage: BitManipAndComp
