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
	      parameter int  MatrixH=20, // Heigth of the input matrix                                         
	      parameter int  SIMD=2, // Number of input columns computed in parallel                       
	      parameter int  PE=2, // Number of output rows computed in parallel                         
	      parameter int  MMV=1, // Number of output pixels computed in parallel                       
	      parameter int  TSrcI=1, // DataType of the input activation (as used in the MAC)              
	      parameter int  TDstI=1, // DataType of the output activation (as generated by the activation) 
	      parameter int  TWeightI=1, // DataType of the weights and how to access them in the array
	      localparam int TI=TSrcI, // DataType of the input stream
	      localparam int TO=TDstI, // DataType of the output stream
	      localparam int TW=TWeightI, // DataType of the weights matrix
	      localparam int TA=TSrcI, // DataType of the activation class (e.g thresholds)
	      parameter int  USE_DSP=0, // Use DSP blocks or LUTs for MAC
	      parameter int  USE_ACT=0     // Use activation after matrix-vector activation
	      )
   (    input logic       rst,
	input logic 	      clk,
	input logic [TI-1:0]  in,
   
	output logic [TO-1:0] out);
   

   /******************************/
   /*** Internal Signals/Wires ***/
   /******************************/
   logic [TWeightI-1:0]       weights,

			      // Instantiation of the Multiply Vector Multiplication Unit
			      mvu #(
				    )
   mvu_inst(
	    .*, // .* connects ports with wires of the same name
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


	    // A place holder for the activation unit to be implemented later
	    generate
	    if(USE_ACT==1) begin: ACT
	    end      
	    endgenerate
	    

	    endmodule // mvau
