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

function String bram_locate (String test);
  return "./" + bram_dir + "/" + test;
endfunction

//  Source operand value vectors
String rs1_file  = bram_locate("rs1.hex");
String rs2_file  = bram_locate("rs2.hex"); 

`ifndef TEST_COUNT
  `define TEST_COUNT 0
`endif

typedef `TEST_COUNT BRAM_ENTRIES;
typedef TLog #(BRAM_ENTRIES) LOG_BRAM_ENTRIES;

Integer bram_entries     = valueOf(BRAM_ENTRIES);
Integer log_bram_entries = valueOf(LOG_BRAM_ENTRIES);

typedef Bit #(LOG_BRAM_ENTRIES) BramEntry;
/////////////////////////////////////////////////
endpackage: metaTb
