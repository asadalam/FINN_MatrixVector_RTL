/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvau_stream.sv
 *
 * This file lists an RTL implementation of the matrix-vector multiplication unit
 * based on streaming weights. It can either be part of the Matrix-Vector-Activation Unit
 * or run independently
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
`include "mvau_defn.sv"

module mvau_stream  #(
		      parameter int SF_T=2,
		      parameter int SF=4)
		      (    
			   input logic 			  rst_n,
			   input logic 			  clk,
			   input logic 			  sf_clr,
			   input logic [TI-1:0] 	  in_act ,
			   input logic [0:SIMD-1][TW-1:0] in_wgt [0:PE-1], // Streaming weight tile
			   output logic [TO-1:0] 	  out);

   /**
    * Internal Signals
    * **/
   logic [0:PE-1][TDstI-1:0] 				  out_pe;
   
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
		     .SF_T(SF_T),
		     .SF(SF)
		     )
	   mvu_pe_inst( // Mapping the I/O blocks
			.rst_n,
			.clk,
			.sf_clr,
			.in_act,
			.in_wgt(in_wgt[pe_ind]),
			.out(out_pe[pe_ind]) // Each PE contribution TDstI bits in the output
		       );
	end
      endgenerate

   // A place holder for the activation unit to be implemented later
   generate
      if(USE_ACT==1) begin: ACT
      end
      else begin: NO_ACT
	 assign out = out_pe;
      end      
   endgenerate

endmodule // mvu

   
