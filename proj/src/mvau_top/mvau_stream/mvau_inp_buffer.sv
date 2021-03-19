/*
 * Module: MVAU Stream Input Buffer (mvau_inp_buffer.sv)
 * 
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of an input buffer
 * Input buffer is needed to store the input activation 
 * in order for it to be processed with multiple rows of the 
 * lowered weight matrix.
 * Buffer length: MatrixW/SIMD = (Kernel^2*IFMCh)/SIMD
 * Word length of each cell: PE*TSrcI = TI
 * This module is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 

 * Parameters:
 * BUF_LEN  - Depth of the input buffer
 * BUF_ADDR - Input buffer address word length
 * 
 * Inputs:
 * clk         - Main clock
 * [TI-1:0] in - Input activation stream, word length TI=TSrcI*SIMD
 * 
 * Outputs:
 * wr_en               - Write enable for the input buffer
 * rd_en               - Read enable for the input buffer
 * [BUF_ADDR-1:0] addr - Address to the input buffer
 * [TI-1:0] out        - Output from the input buffer, word length TI=TSrcI*SIMD
 * */

`timescale 1ns/1ns
`include "mvau_defn.sv"

module mvau_inp_buffer #(
			 parameter int BUF_LEN=16,
			 parameter int BUF_ADDR=16)
   (    input logic 	  clk,
	input logic [TI-1:0] 	   in, // Input stream
	input logic 		   wr_en, // Write enable signal to write to buffer
	input logic 		   rd_en, // Read enable signal to read from buffer
	input logic [BUF_ADDR-1:0] addr, // Address for reading from the buffer
	output logic [TI-1:0] 	   out);

   /*
    * Internal Signals
    * */
   // Signal: inp_buffer [0:BUF_LEN-1]
   // The input buffer   
   logic [TI-1:0] 	  inp_buffer [0:BUF_LEN-1];

   /*
    * Implementing the memory operations
    * */
   assign out = rd_en? inp_buffer[addr] : in;
   
   always_ff @(posedge clk) begin
      if (wr_en)
	inp_buffer[addr] <= in;
   end

endmodule // mvau_inp_buffer

     
   
