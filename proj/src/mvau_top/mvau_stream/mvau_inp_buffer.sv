/*
 * Module: MVAU Stream Input Buffer (mvau_inp_buffer.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
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
 *  
 * Inputs:
 * aclk         - Main clock
 * aresetn       - Synchronous and active low reset
 * [TI-1:0] in - Input activation stream, word length TI=TSrcI*SIMD
 * wr_en               - Write enable for the input buffer
 * rd_en               - Read enable for the input buffer
 * [BUF_ADDR-1:0] addr - Address to the input buffer
 * 
 * Outputs:
 * [TI-1:0] out        - Output from the input buffer, word length TI=TSrcI*SIMD
 * 
 * Parameters:
 * TI       - Input word length
 * BUF_LEN  - Depth of the input buffer
 * BUF_ADDR - Input buffer address word length * 
 * */

`timescale 1ns/1ns
//`include "../mvau_defn.sv"

module mvau_inp_buffer #(
			 parameter int TI=4,
			 parameter int BUF_LEN=16,
			 parameter int BUF_ADDR=4)
   (    
	input logic 		   aclk,
	input logic 		   aresetn,
	input logic [TI-1:0] 	   in, // Input stream
	input logic 		   wr_en, // Write enable signal to write to buffer
	input logic 		   rd_en, // Read enable signal to read from buffer
	input logic [BUF_ADDR-1:0] addr, // Address for reading from the buffer
	output logic [TI-1:0] 	   out);

   /*
    * Internal Signals
    * */
   // Signal: inp_buffer
   // The input buffer   
   //(* ram_style = "distributed" *) 
   logic [TI-1:0] 	  inp_buffer [0:BUF_LEN-1];
        

   /*
    * Implementing the memory operations
    * */         
   
   // Always_FF: Write_Input_Buffer in write through mode
   // Sequential 'always' block to write to the input buffer
   always_ff @(posedge aclk) begin
      if (wr_en) begin
	 inp_buffer[addr] <= in;
	 out <= in;
      end
      else begin
	 out <= inp_buffer[addr];
      end      
   end   

endmodule // mvau_inp_buffer

     
   
