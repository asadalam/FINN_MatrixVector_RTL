/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvau_inp_buffer.sv
 *
 * This file lists an RTL implementation of an input buffer
 * Input buffer is needed to store the input activation 
 * in order for it to be processed with multiple rows of the 
 * lowered weight matrix.
 * This module is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/

/**********************************************
 * Input buffer
 * Memory to hold the input activation
 * Buffer length: MatrixW/SIMD = (Kernel^2*IFMCh)/SIMD
 * Word length of each cell: PE*TSrcI = TI
 * ********************************************/
// Including the package definition file
`include "mvau_defn.pkg" // compile the package file

module mvau_inp_buffer #(parameter int TI=1,
			 parameter int 	MatrixW=20,
			 parameter int 	SIMD,
			 localparam int BUF_LEN=MatrixW/SIMD,
			 localparam int BUF_ADDR=$clog2(BUF_LEN))
   (input logic rst_n,
    input logic 	  clk,
    input logic [TI-1:0]  in, // Input stream
    input logic 	  write_en, // Write enable signal to write to buffer
    input logic read_en, // Read enable signal to read from buffer
    input logic [BUF_ADDR-1:0] 	  addr, // Address for reading from the buffer
    output logic [TI-1:0] out);

   /*
    * Internal Signals
    * */
   // The buffer
   logic [TI-1:0] 	  inp_buffer [0:BUF_LEN-1];

   /*
    * Implementing the memory operations
    * */
   assign out = read_en? inp_buffer[addr] : in;
   
   always_ff @(posedge clk) begin
      if (wr_en)
	inp_buffer[addr] <= in;
   end

endmodule // mvau_inp_buffer

     
   
