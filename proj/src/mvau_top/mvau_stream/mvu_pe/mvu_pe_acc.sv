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
 * out_acc_v           - Output valid
 * [TDstI-1:0] out_acc - Output of the accumulator, word length TDstI
 * */

`timescale 1ns/1ns
`include "../../mvau_defn.sv"

module mvu_pe_acc 
  ( input logic rst_n,
    input logic 	     clk,
    input logic 	     do_mvau_stream,
    input logic 	     sf_clr,
    input logic [TDstI-1:0]  in_acc, // Input from the adders/popcount
    output logic 	     out_acc_v, // Output valid
    output logic [TDstI-1:0] out_acc); //Output

      
   /**
    * Internal signals
    * */
   // Signal: sf_clr_dly
   // A two bit signal to delay the sf_clr input by two clock cycles
   logic [2:0] 		      sf_clr_dly;
   // Signal: do_mvau_stream_reg
   // One bit signal to delay a control input by one clock cycle
   logic 		      do_mvau_stream_reg;
      
   // out_acc_v is a copy of the sf_clr_dly[1]
   // because that is the time we reach the last cycle
   // of accumulation
   assign out_acc_v = sf_clr_dly[2];

   always_ff @(posedge clk) begin
      if(!rst_n)
	do_mvau_stream_reg <= 1'b0;
      else
	do_mvau_stream_reg <= do_mvau_stream;
   end   
   
   // Always_FF: SF_CLR_DLY
   // Sequential 'always' block to delay sf_clr for two clock cycles
   // to match the two pipelines one after SIMD's and one after the adders
   always_ff @(posedge clk) begin
      if(!rst_n)
   	sf_clr_dly <= 'd0;
      else
   	sf_clr_dly <= {sf_clr_dly[1:0],sf_clr};
   end
      
   // Always_FF: Accumulator
   // Sequential 'always' block to perform accumulation
   // The accumulator is cleared the sf_clr_dly[1] is asserted
   always_ff @(posedge clk) begin
      if(!rst_n)
	out_acc <= 'd0;
      else if(do_mvau_stream_reg) begin
	 if(sf_clr_dly[2])
	   out_acc <= in_acc; // resetting the accumulator
	 else
	   out_acc <= out_acc + in_acc;
      end      
   end

endmodule // mvu_simd

