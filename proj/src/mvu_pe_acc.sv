/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvu_pe_acc.sv
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
 *******************************************************************************/


/*************************************************
 * Accmulator
 * Performs accmulation
 * **********************************************/

`timescale 1ns/1ns

module mvu_pe_acc #(parameter int TDstI=1)
   ( input logic rst_n,
     input logic 	      clk,
     input logic [TDstI-1:0]  in_acc, // Input from the adders/popcount
     output logic [TDstI-1:0] out_acc); //Output   

   /***************************************
    * Accmulation
    * ************************************/
   always_ff @(posedge clk) begin: 
      if(!rst_n)
	out_acc <= 'd0;
      else if() // fill in tomorrow
	out_acc <= 'd0;
      else
	out_acc <= out_acc + in_acc;      
   end

endmodule // mvu_simd

