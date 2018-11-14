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

function String bram_locate (String test);
  return "./bram/" + test + ".hex";
endfunction

//  Source operand value vectors
String rs1_file  = bram_locate("rs1");
String rs2_file  = bram_locate("rs2"); 

typedef `TEST_COUNT BRAM_ENTRIES;
typedef TLog #(BRAM_ENTRIES) LOG_BRAM_ENTRIES;

Integer bram_entries     = valueOf(BRAM_ENTRIES);
Integer bram_limit       = bram_entries - 1;
Integer log_bram_entries = valueOf(LOG_BRAM_ENTRIES);

typedef Bit #(LOG_BRAM_ENTRIES) BramEntry;

/////////////////////////////////////////////////
endpackage: metaTb
