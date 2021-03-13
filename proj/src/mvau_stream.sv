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

/**
 * The interface is as follows:
 * *******
 * Inputs:
 * *******
 * rst_n                              : Active low, synchronous reset
 * clk                                : Main clock
 * sf_clr                             : Control signal to reset the accumulator
 * [TI-1:0] in_act                    : Input activation stream, word length TI=TSrcI*SIMD
 * [0:SIMD-1][TW-1:0] in_wgt [0:PE-1] : Input weight stream
 * ********			       
 * Outputs:			       
 * ********			       
 * [TO-1:0] out                       : Output stream, word length TO=TDstI*PE
 * *****************
 * Local parameters:
 * *****************
 * SF=MatrixW/SIMD                            : Number of vertical weight matrix chunks and depth of the input buffer
 * NF=MatrixH/PE                              : Number of horizontal weight matrix chunks
 * SF_T                                       : log_2(SF), determines the number of address bits for the input buffer
 * **/

module mvau_stream (
		    input logic 		   rst_n,
		    input logic 		   clk,
		    input logic [TI-1:0] 	   in_act ,
		    input logic [0:SIMD-1][TW-1:0] in_wgt [0:PE-1], // Streaming weight tile
		    output logic [TO-1:0] 	   out);

   /*
    * Local parameters
    * */   
   localparam int SF=MatrixW/SIMD; // Number of vertical matrix chunks
   localparam int NF=MatrixH/PE; // Number of horizontal matrix chunks
   localparam int SF_T=$clog2(SF); // Address word length for the input buffer
   
   /**
    * Internal Signals
    * **/
   // Internal signals for the input buffer and the control block
   logic 		      ib_wen; // Write enable for the input buffer
   logic 		      ib_ren; // Read enable for the input buffer
   logic 		      sf_clr;
   logic [SF_T-1:0] 	      sf_cnt; // Counter keeping track of SF and also address to input buffer
   logic [TI-1:0] 	      out_act; // Output of the input buffer
   
   // Internal signals for the PEs
   logic [0:PE-1][TDstI-1:0]  out_pe;

   /*
    * Control logic for reading and writing to input buffer
    * and for generating the correct weight tile for the
    * matrix vector computation/multiplication unit
    * */
   mvau_stream_control_block #(
			.SF(SF),
			.NF(NF),
			.SF_T(SF_T)
			)
   mvau_stream_cb_inst (.rst_n,
			.clk,
			.ib_wen,
			.ib_ren,
			.sf_clr,
			.sf_cnt);
   
   //Insantiating the input buffer
   mvau_inp_buffer #(
		     .BUF_LEN(SF),
		     .BUF_ADDR(SF_T))
   mvau_inb_inst (
		  .clk,
		  .in(in_act),
		  .wr_en(ib_wen),
		  .rd_en(ib_ren),
		  .addr(sf_cnt),
		  .out(out_act));
   
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
	   mvu_pe mvu_pe_inst( // Mapping the I/O blocks
			       .rst_n,
			       .clk,
			       .sf_clr,
			       .in_act(out_act),
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

   
