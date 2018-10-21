package metaTb;

/////////////////////////////////////////////////
//                                             //
// BlueSpec Imports                            //
//                                             //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//                                             //
// Project Imports                             //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
// Test Controls                               //
//                                             //
/////////////////////////////////////////////////

`ifdef RV32
typedef "RV32" BRAM_DIR;
`elsif RV64
typedef "RV64" BRAM_DIR;
`else
typedef "RV32" BRAM_DIR;
`endif

//  Where the hex files are located
String bram_path = PROJ_HOME + BRAM_DIR;

//  should the below be put into a function??
//  Source operand value vectors
String rs1_file  = bram_path + "/rs1.hex";
String rs2_file  = bram_path + "/rs2.hex";

//  Caclulation result value vectors
String clz_file  = bram_path + "/clz.hex";
String ctz_file  = bram_path + "/cts.hex";
String pcnt_file = bram_path + "/pcnt.hex";
String andc_file = bram_path + "/andc.hex";

/////////////////////////////////////////////////
endpackage: metaTb
