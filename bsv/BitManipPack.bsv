package BitManipPack;

import Vector :: *;

/////////////////////////////////////////////////
//                                             //
//  Project Imports                            //
//                                             //
/////////////////////////////////////////////////

import BitManipMeta :: *;

/////////////////////////////////////////////////
//                                             //
//  Iterative Modules                          //
//                                             //
/////////////////////////////////////////////////

  //////////////////////////////
  //                          //
  // Bit Extract and Deposit  //
  //                          //
  //////////////////////////////

module mkPackIter (BitManip_IFC #(double_port, one_option))
  provisos (SizedLiteral #(Bit #(one_option), 1));

  Reg #(BitXL)      rg_rs1   <- mkRegU;
  Reg #(BitXL)      rg_rs2   <- mkRegU;
  Reg #(BitXL)      rg_res   <- mkRegU;
  Reg #(BitXL)      rg_seed  <- mkRegU;  // the one << [i,j] in local C impl

  Reg #(IterState)  rg_state <- mkReg(Idle);

  // False -- Extract || True -- Reposit
  Reg #(Bool)       rg_mode  <- mkRegU;

  ///////////////////////////
  //                       //
  //  Rules                //
  //                       //
  ///////////////////////////

  rule rl_calc (rg_state == Calc);
    if((rg_rs1 == 0) || (rg_rs2 == 0)) rg_state <= Idle; // exit conditions
    else begin  // deposit and extract section

      rg_rs2 <= rg_rs2 >> 1;

      if(rg_mode) begin // extract

        rg_rs1 <= rg_rs1 >> 1;
        if(unpack(rg_rs2[0])) begin
          rg_seed <= rg_seed << 1;
          if(unpack(rg_rs1[0])) begin
            rg_res <= rg_res | rg_seed;
          end
        end

      end else begin // deposit

        rg_seed <= rg_seed << 1;
        if(unpack(rg_rs2[0])) begin
          rg_rs1 <= rg_rs1 << 1;
          if(unpack(rg_rs1[0])) begin
            rg_res <= rg_res | rg_seed;
          end
        end

      end

    end    
  endrule: rl_calc

  ///////////////////////////
  //                       //
  //  Interface            //
  //                       //
  ///////////////////////////  

  method Action args_put (Vector #(double_port, BitXL) arg, Bit #(one_option) option) if (rg_state == Idle);
   rg_rs1     <= arg[0];
   rg_rs2     <= arg[1];

   rg_res     <= 0;
   rg_seed   <= 1;

   rg_state   <= Calc;
   rg_mode    <= unpack(option); // set -- extract, unset -- deposit
  endmethod: args_put

  method Action kill;
    rg_state <= Idle;
  endmethod: kill

  method Bool valid_get;
    return ((rg_rs1 == 0) || (rg_rs2 == 0));
  endmethod: valid_get

  method BitXL value_get;
    return rg_res;
  endmethod: value_get

endmodule: mkPackIter
endpackage: BitManipPack
