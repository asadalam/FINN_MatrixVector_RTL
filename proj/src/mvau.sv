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

// Including the package definition file
`include "mvau_defn.pkg" // compile the package file
`include mvu.sv // mvu is a nested module of mvau

module mvau #(parameter int MatrixW=20,   // Width of the input matrix                                          
	      parameter int MatrixH=20, // Heigth of the input matrix                                         
	      parameter int SIMD=2, // Number of input columns computed in parallel                       
	      parameter int PE=2, // Number of output rows computed in parallel                         
	      parameter int MMV=1, // Number of output pixels computed in parallel                       
	      parameter int TSrcI=1, // DataType of the input activation (as used in the MAC)              
	      parameter int TDstI=1, // DataType of the output activation (as generated by the activation) 
	      parameter int TWeightI=1, // DataType of the weights and how to access them in the array
	      parameter int TI=1, // SIMD times the word length of input stream
	      parameter int TO=1, // PE times the word length of output stream
	      parameter int TW=1, // SIMD times the word length of weight stream
	      parameter int TA=1, // PE times the word length of the activation class (e.g thresholds)
	      parameter int USE_DSP=0, // Use DSP blocks or LUTs for MAC
	      parameter int INST_WMEM=0, // Instantiate weight memory, if needed
	      parameter int USE_ACT=0,     // Use activation after matrix-vector activation
	      localparam int SF=MatrixW/SIMD, // Number of vertical matrix chunks
	      localparam int NF=MatrixH/PE // Number of horizontal matrix chunks
	      )
   (    input logic       rst_n, // active low synchronous reset
	input logic 	      clk, // main clock
	input logic [TI-1:0]  in, // input stream
	input logic [TW-1:0]  weights [0:NF-1][0:SF-1], // The weights matrix   
	output logic [TO-1:0] out); //output stream
   

   /******************************/
   /*** Internal Signals/Wires ***/
   /******************************/
   logic 		      ib_wen;
   logic 		      ib_ren;
   logic [-1:0] 	      ib_addr;
   logic [TI-1:0] 	      in_act;
   
   //Insantiating the input buffer
   mvau_inp_buffer #(
		     .TI(TI),
		     .MatrixW(MatrixW),
		     .SIMD(SIMD));
   (
    .clk,
    .in,
    .write_en(ib_wen),
    .read_en(ib_ren),
    .addr(ib_addr),
    .out(ip_act));

   /*
    * Control logic for reading and writing to input buffer
    * */

   /*
    * Control logic for access to a weight tile
    * */
   
   // Instantiation of the Multiply Vector Multiplication Unit
   mvu_comp #(
	      .SIMD(SIMD)
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
		 .in_wgt(), // A tile of weights
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
