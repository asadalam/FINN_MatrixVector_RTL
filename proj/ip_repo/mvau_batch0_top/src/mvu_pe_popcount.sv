/*
 * Module: PE Adder Tree based on popcount (mvu_pe_popcount.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of an adder unit
 * which adds the output of the SIMD units based on counting '1's.
 * The basic word lenght is '1' bit, so implemented as a popcount.
 * It is part of a processing element which is part of the 
 * Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * aclk - Main clock
 * aresetn - Synchronous and active low reset 
 * [TDstI-1:0] in_simd [0:SIMD-1] - Input from the SIMD unit, word length TDstI
 * 
 * Outputs:
 * [TDstI-1:0] out_add            - Output from adder, word length TDstI
 * 
 * Parameters:
 * SIMD - SIMD factor
 * TDstI - Output word length
 * */

`timescale 1ns/1ns

module mvu_pe_popcount #(
			 parameter int SIMD=2,
			 parameter int TDstI=4)
  (
   input 		    aclk,
   input 		    aresetn,
   input logic [TDstI-1:0]  in_simd [0:SIMD-1],
   output logic [TDstI-1:0] out_add);

   // Signal: out_add_int
   // Internal signal holding the combinatorial output of adder tree
   logic [TDstI-1:0] 	    out_add_int;
   
   // Always_COMB: Addition
   // Performs addition using popcount
   always_comb
     begin: adders
	// Initializing the output with a value
	out_add_int = in_simd[0]; // Initializing with the initial value
	for(int i = 1; i < SIMD; i++) begin
	   out_add_int = out_add_int + in_simd[i]; // always_comb ensures no latches are inferred
	end
     end

   // Always_FF: OUT_REG
   // Registered output
   always_ff @(posedge aclk) begin
      if(!aresetn)
	out_add <= 'd0;
      else
	out_add <= out_add_int;
   end
     
   
endmodule // mvu_pe_adders

