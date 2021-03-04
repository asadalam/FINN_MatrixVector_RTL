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

// Including the package definition file
`include "mvau_defn.pkg" // compile the package file
//Nest modules
`include mvu_pe.sv

module mvu #(
	     parameter int SIMD=2, // Number of input columns computed in parallel                       
	     parameter int PE=2, // Number of output rows computed in parallel                         
	     parameter int MMV=1, // Number of output pixels computed in parallel                       
	     parameter int TI=1, // DataType of the input activation (as used in the MAC)          
	     parameter int TW=1, // DataType of the weights and how to access them in the array
	     parameter int USE_DSP=0,  // Use DSP blocks or LUTs for MAC
	     localparam int TO=TI+TW //Output word length of the processing elements
	     )
   (    input logic 	 rst,
	input logic 		       clk,
	input logic [TI-1:0][SIMD-1:0] in_act ,
	input logic [TW-1:0][SIMD-1:0] in_wgt [0:PE-1]
	output logic [TO-1:0] 	       out [0:PE-1]);

   // Generating instantiations of all processing elements
   generate
      for(pe_ind = 0; pe_ind < PE; pe = pe+1)
	begin: PE_GEN
	   mvu_pe #(
		    .SIMD(SIMD),
		    .PE(PE),
		    .TI(TI),
		    .TW(TW),
		    .TO(TO)
		    )
	   mvu_pe_inst(
		       .rst_n,
		       .clk,
		       .in_act,
		       .in_wgt(in_wgt[pe_ind]),
		       .out(out[pe_ind])
		       );
	end
      endgenerate
endmodule // mvu

   
