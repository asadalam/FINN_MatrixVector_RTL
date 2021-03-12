/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvau_control_block.sv
 *
 * This file lists an RTL implementation of the control block
 * It is used to control the input buffer
 * and generation of the correct weight tile from the weight matrix
 * 
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/

/*
 * MVAU Control Block
 * Generates address, write and read enable for the input buffer
 * Free running counters to track as each input activation vector
 * is processed
 * */

`timescale 1ns/1ns
`include "mvau_defn.sv"
module mvau_control_block #(
			    parameter int SF=8,
			    parameter int NF=2,
			    parameter int SF_T=3			    
			    )
   (
    input logic 		    rst_n,
    input logic 		    clk,
    input logic [TW-1:0] 	    weights [0:MatrixH-1][0:MatrixW-1], // The weights matrix
    output logic 		    ib_wen, // Input buffer write enable
    output logic 		    ib_ren, // INput buffer read enable
    output logic 		    sf_clr, // To reset the sf_cnt
    output logic [SF_T-1:0] 	    sf_cnt, // Address for the input buffer
    output logic [0:SIMD-1][TW-1:0] out_wgt[0:PE-1] // The output weight tile
    );
   
   localparam int 	    NF_T=$clog2(NF); // For nf_cnt
   localparam int 	    MatrixH_BW=$clog2(MatrixH);
   localparam int 	    MatrixW_BW=$clog2(MatrixW);
   
   /*
    * Internal Signals
    * */   
   logic 		    nf_clr; // To reset the nf_cnt
   logic [NF_T-1:0] 	    nf_cnt; // NF counter, keeping track of the NF
   
   /* 
    * Always block for accessing a weight tile
    * We need to access the weight tile that corresponds
    * to the current value of the sf_cnt which tracks
    * the input activation vector as it is read-in
    * If more than one PE, we need more than one set of 
    * weights.
    * 
    * The weight tile is declared as a 2D matrix where the 
    * word length of each element is TW bits. The height
    * of the tile is PE and width is SIMD
    * */
   always_comb begin
      for(logic [MatrixH_BW-1:0] tile_row=0; tile_row < PE; tile_row++)
	for(logic [MatrixW_BW-1:0] tile_col=0; tile_col < SIMD; tile_col++)
	  out_wgt[tile_row][tile_col] = weights[nf_cnt*PE+tile_row][sf_cnt*SIMD+tile_col];
   end

   // A one bit control signal to indicate when sf_cnt == SF
   assign sf_clr = sf_cnt==SF_T'(SF-1) ? 1'b1 : 1'b0;
   // A one bit control signal to indicate when nf_cnt == NF
   assign nf_clr = nf_cnt==NF_T'(NF-1) ? 1'b1 : 1'b0;

   // Write enable for the input buffer
   // Remains one when the input buffer is being filled
   // Resets to Zero the input buffer is filled and ready
   // to be reused
   assign ib_wen = (nf_cnt=='d0) ? 1'b1 : 1'b0;
   // Read enable is just the inverse of write enable
   assign ib_ren = ~ib_wen;
   
   // We need to keep track when the input buffer is full
   // A counter similar to sf in mvau.hpp
   always_ff @(posedge clk) begin
      if(!rst_n)
	sf_cnt <= 'd0;
      else if(sf_clr)
	sf_cnt <= 'd0;
      else
	sf_cnt <= sf_cnt + 1;
   end

   // A counter to keep track when we are done writing to the
   // input buffer so that it can be reused again
   // Similar to the variable nf in mvau.hpp
   always_ff @(posedge clk) begin
      if(!rst_n)
	nf_cnt <= 'd0;
      else if(nf_clr & sf_clr)
	nf_cnt <= 'd0;
      else if(sf_clr)
	nf_cnt <= nf_cnt + 1;
   end

endmodule

