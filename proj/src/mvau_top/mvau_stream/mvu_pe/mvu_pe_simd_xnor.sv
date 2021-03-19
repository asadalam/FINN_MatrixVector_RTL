/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvu_pe_simd_xnor.sv
 *
 * This file lists an RTL implementation of a SIMD unit based on standard
 * multiplication. It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/


/*************************************************
 * SIMD unit
 * Performs XNOR of input activation and weight
 * Word length == 1
 * **********************************************/

`timescale 1ns/1ns
`include "mvau_defn.sv"


/**
 * The interface is as follows:
 * *******
 * Inputs:
 * *******
 * rst_n             : Active low, synchronous reset
 * clk               : Main clock
 * [TSrc-1:0] in_act : Input activation stream, word length TSrcI
 * [TW-1:0]   in_wgt : Input weight, word length TW
 * ********
 * Outputs:
 * ********
 * [TDstI-1:0] out   : Output stream, word length TDstI
 * **/

module mvu_pe_simd_xnor 
  ( 
    input logic 	     rst_n,
    input logic 	     clk,
    input logic [TSrcI-1:0]  in_act, //Input activation
    input logic [TW-1:0]     in_wgt, //Input weight
    output logic [TDstI-1:0] out); //Output   

   /***************************************
    * SIMD only performs multiplication
    * ************************************/
   always_ff @(posedge clk) begin: SIMD_MUL
      if(!rst_n)
	out <= 'd0;
      else
	out <= in_act^~in_wgt;
   end

endmodule // mvu_simd