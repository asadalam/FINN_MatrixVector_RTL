/*
 * Module: XNOR based SIMD (mvu_pe_simd_xnor.sv)
 *  
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of a SIMD unit based on standard
 * multiplication. It performs XNOR of input activation and weight where
 * word length of both inputs is 1-bit. 
 * It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * rst_n             - Active low, synchronous reset
 * clk               - Main clock
 * do_mvau_stream   - Controls how long the MVAU operation continues
 *                    Case 1: NF=1 => do_mvau_stream = in_v (input buffer not reused)
 *                    Case 2: NF>1 => do_mvau_stream = in_v | (~(nf_clr&sf_clr)) (input buffer reused)
 * [TSrc-1:0] in_act - Input activation stream, word length TSrcI
 * [TW-1:0]   in_wgt - Input weight, word length TW
 * 
 * Outputs:
 * [TDstI-1:0] out   - Output stream, word length TDstI
 * */


`timescale 1ns/1ns
`include "../../mvau_defn.sv"

module mvu_pe_simd_xnor 
  ( 
    input logic 	     rst_n,
    input logic 	     clk,
    input logic 	     do_mvau_stream,
    input logic unsigned [TSrcI-1:0]  in_act, //Input activation
    input logic unsigned [TW-1:0]     in_wgt, //Input weight
    output logic unsigned [TDstI-1:0] out); //Output   

   // Always_FF: XNOR based SIMD
   // Performs multiplication by XNOR
   // Both inputs are '1' bit
   // Output is also '1' bit with extra output bits forced to zero
   always_ff @(posedge clk) begin: SIMD_MUL
      if(!rst_n)
	out <= 'd0;
      else if(do_mvau_stream) begin
	 out[0] <= in_act^~in_wgt;
	 out[TDstI-1:1] <= 'd0;	 
      end
   end

endmodule // mvu_simd
