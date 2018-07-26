package BitManip_fn;

////////////////////////////////
// BSV Libs

////////////////////////////////
// functions of interest

function Bit #(sz) fn_bit_reverse (Bit #(sz) x);

  Integer int_sz = valueOf(sz);
  Bit #(sz) x_rev;

  for(Integer i = 0; i < int_sz; i = i + 1) begin
    x_rev[i] = x[int_sz - i -1];
  end


  return x_rev;

endfunction: fn_bit_reverse

/////////////////////////////////////////////
// grev functions

let s0_left  = 64'h5555_5555__5555_5555;
let s0_right = 64'hAAAA_AAAA__AAAA_AAAA;

let s1_left  = 64'h3333_3333__3333_3333;
let s1_right = 64'hCCCC_CCCC__CCCC_CCCC;

let s2_left  = 64'h0F0F_0F0F__0F0F_0F0F;
let s2_right = 64'hF0F0_F0F0__F0F0_F0F0;

let s3_left  = 64'h00FF_00FF__00FF_00FF;
let s3_right = 64'h00FF_00FF__00FF_00FF;

let s4_left  = 64'h0000_FFFF__0000_FFFF;
let s4_right = 64'hFFFF_0000__FFFF_0000;

let s5_left  = 64'h0000_0000__FFFF_FFFF;
let s5_right = 64'hFFFF_FFFF__0000_0000;

function Bit #(sz) fn_grev_s0 (Bit #(sz) x);

endfunction: fn_grev_s0

/////////////////////////////////////////////
endpackage: BitManip_fn
