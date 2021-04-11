/*
 * Module: Binary input based SIMD (mvu_pe_simd_binary.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of a SIMD unit 
 * when one of the inputs is 1-bit and the other is more than 1 bits
 * It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 * 
 * SIMD unit
 * Performs multiplication of input activation and weight
 * Two cases
 * Activation = 1 bit, Weight > 1 bit
 * Weight = 1 bit, Activation > 1 bit
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


module mvu_pe_simd_binary 
  ( 
    input logic 	     rst_n,
    input logic 	     clk,
    input logic 	     do_mvau_stream,
    input logic [TSrcI-1:0]  in_act, //Input activation
    input logic [TW-1:0]     in_wgt, //Input weight
    output logic [TDstI-1:0] out); //Output   

   /***************************************
    * SIMD only performs multiplication
    * ************************************/
   generate
      if(TW==1) begin: WGT_1 // if weight is 1-bit
	 // Always_FF: Binary SIMD
	 // SIMD when one of the inputs is '1' bit
	 always_ff @(posedge clk) begin: SIMD_MUL
	    if(!rst_n)
	      out <= 'd0;
	    else if(do_mvau_stream)
	      out <= in_wgt==1'b1 ? in_act : ~in_act+1'b1;//'d0; //temporary change ~in_act+1'b1; // C-like ternary operator
	 end
      end
   endgenerate
   
   
   generate
      if(TSrcI==1) begin: ACT_1 // if activation is 1-bit
	 always_ff @(posedge clk) begin: SIMD_MUL
	    if(!rst_n)
	      out <= 'd0;
	    else if(do_mvau_stream)
	      out <= in_act==1'b1 ? in_wgt : ~in_wgt+1'b1;//'d0; //temporary change ~in_wgt+1'b1; // C-like ternary operator
	 end
      end
   endgenerate
   
endmodule // mvu_pe_simd_binary


