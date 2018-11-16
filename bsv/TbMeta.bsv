package TbMeta;

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

function String bram_locate (String test);
  return "./bram/" + test + ".hex";
endfunction

//  Source operand value vectors
String rs1_file  = bram_locate("rs1");
String rs2_file  = bram_locate("rs2"); 

String rs2_file  = bram_locate("clz"); 
String rs2_file  = bram_locate("ctz"); 
String rs2_file  = bram_locate("pcnt"); 
String rs2_file  = bram_locate("sro"); 
String rs2_file  = bram_locate("slo"); 
String rs2_file  = bram_locate("ror"); 
String rs2_file  = bram_locate("rol"); 
String rs2_file  = bram_locate("grev"); 
String rs2_file  = bram_locate("shfl"); 
String rs2_file  = bram_locate("unshfl"); 
String rs2_file  = bram_locate("bext"); 
String rs2_file  = bram_locate("bdep"); 


typedef `TEST_COUNT BRAM_ENTRIES;
typedef TLog #(BRAM_ENTRIES) LOG_BRAM_ENTRIES;

Integer bram_entries     = valueOf(BRAM_ENTRIES);
Integer bram_limit       = bram_entries - 1;
Integer log_bram_entries = valueOf(LOG_BRAM_ENTRIES);

typedef Bit #(LOG_BRAM_ENTRIES) BramEntry;

/////////////////////////////////////////////////
endpackage: TbMeta
