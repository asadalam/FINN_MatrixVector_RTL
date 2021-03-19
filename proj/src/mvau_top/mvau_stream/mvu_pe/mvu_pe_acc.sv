/*
 * Module: PE Accumulator (mvu_pe.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of the accumulator
 * This accumulator is used to accumulator as a row of weights
 * is multiplied by the input activation vector
 * It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * rst_n              - Active low synchronous reset
 * clk                - Main clock
 * sf_clr             - Control signal from the control block for resetting the accumulator
 * [TDstI-1:0] in_acc - Input to the accumulator from the adders, word length TDstI
 * 
 * Outputs:
 * [TDstI-1:0] out_add            - Output from adder, word length TDstI
 * */

`timescale 1ns/1ns
`include "mvau_defn.sv"

module mvu_pe_acc 
  ( input logic rst_n,
    input logic 	     clk,
    input logic 	     sf_clr,
    input logic [TDstI-1:0]  in_acc, // Input from the adders/popcount
    output logic [TDstI-1:0] out_acc); //Output

   /**
    * Internal signals
    * */
   // Signal: sf_clr_dly
   // A two bit signal to delay the sf_clr input by two clock cycles
   logic [1:0] 		      sf_clr_dly;
   
   /**
    * Delaying sf_clr for two clock cycles
    * to match the two pipelines
    * one after SIMD's and one after the adders
    * */
   always_ff @(posedge clk) begin
      if(!rst_n)
	sf_clr_dly <= 2'd0;
      else
	sf_clr_dly <= {sf_clr_dly[0],sf_clr};
   end
      
   /***************************************
    * Accmulation
    * ************************************/
   always_ff @(posedge clk) begin
      if(!rst_n)
	out_acc <= 'd0;
      else if(sf_clr_dly[1])
	out_acc <= in_acc; // resetting the accumulator
      else
	out_acc <= out_acc + in_acc;      
   end

endmodule // mvu_simd

