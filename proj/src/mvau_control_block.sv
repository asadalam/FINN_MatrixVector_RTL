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

module mvau_control_block #(parameter int PE=2,
			    parameter int  TW=1,
			    parameter int  MatrixH=20,
			    parameter int  SF=8,
			    parameter int  NF=2,
			    parameter int  SF_T=3,
			    localparam int NF_T=$clog2(NF) // For nf_cnt
			    )
   (input logic rst_n,
    input logic 	    clk,
    input logic [TW-1:0]    weights [0:MatrixH-1][0:SF-1], // The weights matrix
    output logic 	    ib_wen, // Input buffer write enable
    output logic 	    ib_ren, // INput buffer read enable
    output logic [SF_T-1:0] sf_cnt, // Address for the input buffer
    output logic [TW-1:0]   out_wgt[0:PE-1] // The output weight tile
    );
   
   /*
    * Internal Signals
    * */
   logic 		    sf_clr; // To reset the sf_cnt
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
    * word length of each element is TSrcI bits. But we access 
    * TW bits at a given time which is also the width of the
    * tile. The height of the tile is equal to PE.
    * 
    * Based on the current value of sf_cnt and nf_cnt, we pick
    * the correct tile from within the weight matrix
    * */
   always_comb begin
      for(logic [NF_T-1:0] tile=0; tile < PE; tile=tile++)
	out_wgt[tile] = weights[tile+nf_cnt*PE][sf_cnt];
   end
   

   // A one bit control signal to indicate when sf_cnt == SF
   assign sf_clr = sf_cnt==SF_T'(SF) ? 1'b1 : 1'b0;
   // A one bit control signal to indicate when nf_cnt == NF
   assign nf_clr = nf_cnt==NF_T'(NF) ? 1'b1 : 1'b0;

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
      else if(nf_clr)
	nf_cnt <= 'd0;
      else if(sf_clr)
	nf_cnt <= nf_cnt + 1;
      end

endmodule
   
