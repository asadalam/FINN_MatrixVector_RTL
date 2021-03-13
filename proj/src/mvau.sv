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
/**
 * Including the package definition file
 * The package definition file contains all global parameters
 * that control the generation of the design
 * **/
`include "mvau_defn.sv"

/**
 * The Interface is as follows:
 * *******
 * Inputs:
 * *******
 * rst_n                                      : Active low synchronous reset
 * clk                                        : Main clock
 * [TI-1:0] in                                : Input stream, word length TI=TSrcI*SIMD
 * ********
 * Outputs:
 * ********
 * [TO-1:0] out                               : Output stream, word length TO=TDstI*PE 
 * *****************
 * Local parameters:
 * *****************
 * WMEM_ADDR_BW: Word length of the address for the weight memories (log2(WMEM_DEPTH))
 * **/

module mvau (    
		 input logic 	       rst_n, // active low synchronous reset
		 input logic 	       clk, // main clock
		 input logic [TI-1:0]  in, // input stream
		 //input logic [TW-1:0]  weights [0:MatrixH-1][0:MatrixW-1], // The weights matrix   
		 output logic [TO-1:0] out); //output stream
   /*
    * Local parameters
    * */   
   localparam int 		       WMEM_ADDR_BW=$clog2(WMEM_DEPTH); // Address word length for the weight memory

   /*
    * Internal Signals/Wires 
    * */ 
   
   // Internal signals for the weight memory
   logic [WMEM_ADDR_BW-1:0]   wmem_addr;
   logic [0:SIMD-1][TW-1:0]   in_wgt [0:PE-1];   
   
   // Internal signals for the MVAU_STREAM   
   logic [TO-1:0] 	      out_stream;
   logic [TI-1:0] 	      in_act;
   
   /*
    * Control logic for reading and writing to input buffer
    * and for generating the correct weight tile for the
    * matrix vector computation/multiplication unit
    * */
   mvau_control_block #(.WMEM_ADDR_BW(WMEM_ADDR_BW)
			)
   mvau_cb_inst (.rst_n,
		 .clk,
		 .wmem_addr);
   		 //.out_wgt(in_wgt));

   
   
   // Instantiation of the Multiply Vector Multiplication Unit   
   alias in_act = in;   // alias does not create a new signal
   mvau_stream
     mvau_stream_inst(
		      .rst_n,
		      .clk,
		      .in_act, // Input activation
		      .in_wgt, // A tile of weights
		      .out(out_stream)
		      );

   // Instantiation of the Weights Memory Unit
   if(INST_WMEM==1) begin: WGT_MEM
      for(genvar wmem = 0; wmem < PE; wmem=wmem+1)	 
	 weights_mem #(.WMEM_ID(wmem),
		       .WMEM_ADDR_BW(WMEM_ADDR_BW))
	   weights_mem_inst(
			    .clk,
			    .wmem_addr,
			    .wmem_out(in_wgt[wmem])
			    );
      end // block: WGT_MEM
      
   // A place holder for the activation unit to be implemented later
   generate
      if(USE_ACT==1) begin: ACT
      end
      else begin: NO_ACT
	 assign out = out_stream;
      end
   endgenerate
   
endmodule // mvau
