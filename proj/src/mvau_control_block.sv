/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvau_control_block.sv
 *
 * This file lists an RTL implementation of the control block
 * It is used to control the generation of address for the weight
 * memory
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

/**
 * Interface is as follows:
 * *****************
 * Extra parameters:
 * *****************
 * WMEM_ADDR_BW: Word length of the address for the weight memories
 * *******
 * Inputs:
 * *******
 * rst_n                       : Active low synchronous reset
 * clk                         : Main clock
 * ********
 * Outputs:
 * ********
 * [WMEM_ADDR_BW-1:0] wmem_addr: Address for the weight memories
 * **/

module mvau_control_block #(parameter int WMEM_ADDR_BW=2
			    )
   (
    input logic 		    rst_n,
    input logic 		    clk,
    output logic [WMEM_ADDR_BW-1:0]    wmem_addr // Address for the weight memory
    //output logic [0:SIMD-1][TW-1:0] out_wgt[0:PE-1] // The output weight tile (not used any more)
    );
   
   /*
    * Internal Signals
    * */
      
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
   // always_comb begin
   //    for(logic [MatrixH_BW-1:0] tile_row=0; tile_row < PE; tile_row++)
   // 	for(logic [MatrixW_BW-1:0] tile_col=0; tile_col < SIMD; tile_col++)
   // 	  out_wgt[tile_row][tile_col] = weights[nf_cnt*PE+tile_row][sf_cnt*SIMD+tile_col];
   // end

   /**
    * Control Logic for generating address
    * for the weight memory
    * **/

   always_ff @(posedge clk) begin
      if(!rst_n)
	wmem_addr <= 'd0;
      else if(wmem_addr==WMEM_ADDR_BW'(WMEM_DEPTH-1))
	wmem_addr <= 'd0;
      else
	wmem_addr <= wmem_addr + 1;
   end   
endmodule

