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
 * [TSrc-1:0] in_act - Input activation stream, word length TSrcI
 * [TW-1:0]   in_wgt - Input weight, word length TW
 * 
 * Outputs:
 * [TDstI-1:0] out   - Output stream, word length TDstI
 * */

`timescale 1ns/1ns
//`include "../../mvau_defn.sv"

module mvu_pe_simd_binary #(
			    parameter int TSrcI=4,
			    parameter int TW=1,
			    parameter int TDstI=4)
  ( 
    input logic [TSrcI-1:0]  in_act, //Input activation
    input logic [TW-1:0]     in_wgt, //Input weight
    output logic [TDstI-1:0] out); //Output   

   logic [TW-1:0] 	     in_wgt_int;
   assign in_wgt_int = ~in_wgt;
   
   /***************************************
    * SIMD only performs multiplication
    * ************************************/
   generate
      if(TW==1) begin: WGT_1 // if weight is 1-bit
	 // Always_COMB: Binary SIMD
	 // SIMD when one of the inputs is '1' bit
	 always_comb
	   out = in_wgt==1'b1 ? in_act : ~in_act+1'b1;
	   //out = { {TDstI-TSrcI{in_wgt_int[TW-1]}}, { {TSrcI-1{in_wgt_int[TW-1]}}, in_wgt_int } ^ in_act};
//{ {TDstI-TSrcI{in_act[TSrcI-1]}}, in_act};//
	 // end
      end
   endgenerate
   
   
   generate
      if(TSrcI==1) begin: ACT_1 // if activation is 1-bit
	 always_comb
	   out = in_act==1'b1 ? in_wgt : ~in_wgt+1'b1;	 
	   //out = { {TW-1{in_act[TSrcI-1]}}, in_act } ^ in_wgt;//
      end
   endgenerate
   
endmodule // mvu_pe_simd_binary


