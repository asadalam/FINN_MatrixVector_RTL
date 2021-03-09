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

// Including the package definition file
`include "mvau_defn.pkg" // compile the package file

module #(
	 parameter int SF=8,
	 parameter int NF=2,
	 parameter int SF_T=3,
	 parameter int NF_T=1
	 )
   (input logic rst_n,
    input logic 	    clk,
    input logic [TW-1:0]    weights [0:NF-1][0:SF-1], // The weights matrix
    output logic 	    ib_wen,
    output logic 	    ib_ren,
    output logic [SF_T-1:0] sf_cnt
    );
   
   /*
    * Internal Signals
    * */
   logic 		    sf_clr; // To reset the sf_cnt
   logic 		    nf_clr; // To reset the nf_cnt
   logic [NF_T-1:0] 	    nf_cnt; // NF counter, keeping track of the NF
   logic [TW-1:0] 	    in_wgt[0:PE-1]; // The weight tile
   logic [-1:0] 	    tile_cnt; // Counter to keep track of weight tile
   
   
   in_wgt = weights[:][tile];
   

   // A one bit control signal to indicate when sf_cnt == SF
   assign sf_clr = sf_cnt==sf_cnt'(SF) ? 1'b1 : 1'b0;
   // A one bit control signal to indicate when nf_cnt == NF
   assign nf_clr = nf_cnt==nf_cnt'(NF) ? 1'b1 : 1'b0;

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
      if(!rst)
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
      if(!rst)
	nf_cnt <= 'd0;
      else if(nf_clr)
	nf_cnt <= 'd0;
      else if(sf_clr)
	nf_cnt <= nf_cnt + 1;
      end

endmodule
   
