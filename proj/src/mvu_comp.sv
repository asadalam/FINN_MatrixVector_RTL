/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvu.sv
 *
 * This file lists an RTL implementation of the matrix-vector multiplication unit
 * It is part of the Matrix-Vector-Activation Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/

/*****************************************************/
/*****************************************************/
/*** Top Level Multiply Vector Multiplication Unit ***/
/*****************************************************/
/*****************************************************/

`timescale 1ns/1ns

module mvu_comp #(
		  parameter int SIMD=2, // Number of input columns computed in parallel                       
		  parameter int PE=2, // Number of output rows computed in parallel                         
		  parameter int MMV=1, // Number of output pixels computed in parallel
		  parameter int TSrcI=1, // DataType (word length) of the input activation
		  parameter int TDstI=1, // DataType (word length) of the output activation
		  parameter int TWeightI=1, // DataType (word lenght) of each weight
		  parameter int TI=1, // DataType of the input activation (as used in the MAC)          
		  parameter int TW=1, // DataType of the weights and how to access them in the array
		  parameter int USE_DSP=0, // Use DSP blocks or LUTs for MAC
		  parameter int TO=2 //Output word length of the processing elements
	     )
   (    input logic 	 rst_n,
	input logic 	      clk,
	input logic [TI-1:0]  in_act ,
	input logic [TW-1:0]  in_wgt [0:PE-1],
	output logic [TO-1:0] out);

   /**
    * Generating instantiations of all processing elements
    * Each PE reads in different set of weights
    * Each PE reads in the same set of activation
    * Each PE outputs TDstI bits
    * Output of each PE packed into one array of size TO
    * */
   generate
      for(genvar pe_ind = 0; pe_ind < PE; pe_ind = pe_ind+1)
	begin: PE_GEN
	   mvu_pe #( // Mapping the parameters
		     .SIMD(SIMD),
		     .PE(PE),
		     .TSrcI(TSrcI),
		     .TDstI(TDstI),
		     .TWeightI(TWeightI),
		     .TI(TI),
		     .TW(TW)
		    )
	   mvu_pe_inst( // Mapping the I/O blocks
		       .rst_n,
		       .clk,
		       .in_act,
		       .in_wgt(in_wgt[pe_ind]),
		       .out(out[TDstI-1+pe_ind*TDstI:pe_ind*TDstI]) // Each PE contribution TDstI bits in the output
		       );
	end
      endgenerate
endmodule // mvu

   
