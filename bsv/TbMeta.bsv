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
String rs1_file     = bram_locate("rs1");
String rs2_file     = bram_locate("rs2"); 

String clz_file     = bram_locate("clz"); 
String ctz_file     = bram_locate("ctz"); 
String pcnt_file    = bram_locate("pcnt"); 
String sro_file     = bram_locate("sro"); 
String slo_file     = bram_locate("slo"); 
String ror_file     = bram_locate("ror"); 
String rol_file     = bram_locate("rol"); 
String grev_file    = bram_locate("grev"); 
String shfl_file    = bram_locate("shfl"); 
String unshfl_file  = bram_locate("unshfl"); 
String bext_file    = bram_locate("bext"); 
String bdep_file    = bram_locate("bdep"); 


typedef `TEST_COUNT BRAM_ENTRIES;
typedef TLog #(BRAM_ENTRIES) LOG_BRAM_ENTRIES;

Integer bram_entries     = valueOf(BRAM_ENTRIES);
Integer bram_limit       = bram_entries - 1;
Integer log_bram_entries = valueOf(LOG_BRAM_ENTRIES);

typedef Bit #(LOG_BRAM_ENTRIES) BramEntry;

/////////////////////////////////////////////////
endpackage: TbMeta
