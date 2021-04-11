/*
 * Module: PE Adder Tree based on popcount (mvu_pe_popcount.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of an adder unit
 * which adds the output of the SIMD units based on counting '1's.
 * The basic word lenght is '1' bit, so implemented as a popcount.
 * A completely combinatorial circuit. It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * clk - Main clock
 * rst_n - Synchronous and active low reset 
 * [TDstI-1:0] in_simd [0:SIMD-1] - Input from the SIMD unit, word length TDstI
 * 
 * Outputs:
 * [TDstI-1:0] out_add            - Output from adder, word length TDstI
 * */

`timescale 1ns/1ns
`include "../../mvau_defn.sv"

module mvu_pe_popcount 
  (
   input 		    clk,
   input 		    rst_n,
   input logic [TDstI-1:0]  in_simd [0:SIMD-1],
   output logic [TDstI-1:0] out_add);

   // Signal: out_add_int
   // Internal signal holding the combinatorial output of adder tree
   logic [TDstI-1:0] 	    out_add_int;

   // Signal: in_simd_reg
   // Internal signal for holding the registered version of input data
   logic [TDstI-1:0] 	    in_simd_reg [0:SIMD-1];

   // Always_FF: IN_SIMD_REG
   // Registering in_simd
   always_ff @(posedge clk) begin
      if(!rst_n) begin
	 for(int i = 0; i<SIMD; i++)
	   in_simd_reg[i] <= 'd0;
      end
      else begin
	 for(int i = 0; i<SIMD; i++)
	   in_simd_reg[i] <= in_simd[i];
      end
   end

   
   // Always_COMB: Addition
   // Performs addition using popcount
   always_comb
     begin: adders
	// Initializing the output with a value
	out_add_int = in_simd_reg[0]; // Initializing with the initial value
	for(int i = 1; i < SIMD; i++) begin
	   out_add_int = out_add_int + in_simd_reg[i]; // always_comb ensures no latches are inferred
	end
     end

   // Always_FF: OUT_REG
   // Registered output
   always_ff @(posedge clk) begin
      if(!rst_n)
	out_add <= 'd0;
      else
	out_add <= out_add_int;
   end
     
   
endmodule // mvu_pe_adders

