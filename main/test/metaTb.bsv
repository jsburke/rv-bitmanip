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
String bram_dir = "RV32";
`elsif RV64
String bram_dir = "RV64"
`else
String bram_dir = "RV32";
`endif

String proj_home = "./";

function String bram_locate (String test);
  return proj_home + bram_dir + "/" + test;
endfunction

//  Where the hex files are located
String bram_path = "./" + bram_dir;

//  should the below be put into a function??
//  Source operand value vectors
String rs1_file  = bram_locate("rs1.hex");
String rs2_file  = bram_locate("rs2.hex"); 

//  Caclulation result value vectors
String clz_file  = bram_locate("clz.hex"); 
String ctz_file  = bram_locate("ctz.hex"); 
String pcnt_file = bram_locate("pcnt.hex"); 
String andc_file = bram_locate("andc.hex"); 

/////////////////////////////////////////////////
endpackage: metaTb
