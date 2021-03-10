/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvu.sv
 *
 * This file lists an RTL implementation of the matrix-vector activation unit
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/

/*************************************************/
/*************************************************/
/*** Top Level Multiply Vector Activation Unit ***/
/*************************************************/
/*************************************************/
`timescale 1ns/1ns
// Including the package definition file
`include "mvau_defn.sv" // compile the package file

module mvau (    input logic       rst_n, // active low synchronous reset
	input logic 	      clk, // main clock
	input logic [TI-1:0]  in, // input stream
	input logic [TW-1:0]  weights [0:MatrixH-1][0:SF-1], // The weights matrix   
	output logic [TO-1:0] out); //output stream

   /******************************/
   /*** Internal Signals/Wires ***/
   /******************************/
   // Internal signals for the input buffer
   logic 		      ib_wen; // Write enable for the input buffer
   logic 		      ib_ren; // Read enable for the input buffer
   logic [SF_T-1:0] 	      sf_cnt; // Counter keeping track of SF and also address to input buffer
   logic [TI-1:0] 	      in_act; // Output of the input buffer
   


   // Internal signals for the MVU
   logic [TW-1:0] 	      in_wgt [0:PE-1];   
   
   /*
    * Control logic for reading and writing to input buffer
    * and for generating the correct weight tile for the
    * matrix vector computation/multiplication unit
    * */
   mvau_control_block #(
			.PE(PE),
			.TW(TW),
			.MatrixH(MatrixH),
			.SF(SF),
			.NF(NF),
			.SF_T(SF_T)
			)
   mvau_cb_inst (.rst_n,
    .clk,
    .weights,
    .ib_wen,
    .ib_ren,
    .sf_cnt,
    .out_wgt(in_wgt));

   //Insantiating the input buffer
   mvau_inp_buffer #(
		     .TI(TI),
		     .MatrixW(MatrixW),
		     .SIMD(SIMD),
		     .BUF_LEN(SF),
		     .BUF_ADDR(SF_T))
   mvau_inb_inst (
    .clk,
    .in,
    .wr_en(ib_wen),
    .rd_en(ib_ren),
    .addr(sf_cnt),
    .out(in_act));

   
   // Instantiation of the Multiply Vector Multiplication Unit
   mvu_comp #(
	      .SIMD(SIMD),
	      .PE(PE),
	      .MMV(MMV),
	      .TI(TI),
	      .TW(TW),
	      .USE_DSP(USE_DSP),
	      .TO(TO)
	      )
   mvu_comp_inst(
		 .rst_n,
		 .clk,
		 .in_act, // Input activation
		 .in_wgt, // A tile of weights
		 .out
	    );

   generate
      if(INST_WMEM==1) begin: WGT_MEM
	 // Instantiation of the Weights Memory Unit
	 weights_mem #(
		       .SIMD(SIMD),
		       .PE(PE),
		       .MMV(MMV),
		       .TI(TI),
		       .TO(TO)
		       
		       )
	 weights_mem_inst(
			  .*
			  );
      end // block: WGT_MEM
   endgenerate
      
   // A place holder for the activation unit to be implemented later
   generate
      if(USE_ACT==1) begin: ACT
      end
   endgenerate
   
endmodule // mvau
