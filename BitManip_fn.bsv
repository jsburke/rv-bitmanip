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
endpackage: BitManip_fn
