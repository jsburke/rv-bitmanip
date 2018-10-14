package CLZ_Tb;

import BitManipMeta  :: *;
import BitManipCount :: *;

(* synthesize *)
module mkCLZ_Tb (Empty);

  BitManip_IFC #(single_port, one_option) clz <- mkZeroCounterIter;

endmodule: mkCLZ_Tb

endpackage: CLZ_Tb
