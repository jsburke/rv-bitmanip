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
//    NB: really should just be a r1&~r2 deal  //
//                                             //
/////////////////////////////////////////////////

interface BitManipAndC_IFC;
  (* always_ready *)
  method ActionValue #(BitXL) eval (BitXL op0, BitXL op1);
endinterface: BitManipAndC_IFC

module mkAndWithComplement (BitManipAndC_IFC);

  method ActionValue #(BitXL) eval (BitXL op0, BitXL op1);
    return op0 & ~op1;
  endmethod: eval

endmodule: mkAndWithComplement

endpackage: BitManipAndComp
