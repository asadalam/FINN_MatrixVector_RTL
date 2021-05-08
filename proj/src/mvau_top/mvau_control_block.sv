/*
 * Module: MVAU Control Block (mvau_control_block.sv)
 * 
 * Author(s): Syed Asad Alam
 * 
 * This file lists an RTL implementation of the control block
 * which generates address for weight memory
 * 
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Parameters:
 * WMEM_ADDR_BW - Word length of the address for the weight memories
 * 
 * Inputs:
 * aresetn                       - Active low synchronous reset
 * aclk                         - Main clock
 * in_v                        - Input valid to indicate valid input stream
 * 
 * Outputs:
 * [WMEM_ADDR_BW-1:0] wmem_addr- Address for the weight memories
 * */


`timescale 1ns/1ns
//`include "mvau_defn.sv"

module mvau_control_block #(parameter int SF=8,
			    parameter int NF=8,
			    parameter int WMEM_DEPTH=4,
			    parameter int WMEM_ADDR_BW=2			    
			    )
   (
    input logic 		    aresetn,
    input logic 		    aclk,
    input logic 		    in_v,
    output logic [WMEM_ADDR_BW-1:0] wmem_addr // Address for the weight memory
    );
   
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
   
   /*
    * Local Parameters
    * */
   // Parameter: NF_T
   // Word length of the NF counter to control reading and writing from the input buffer
   localparam int 		    NF_T=$clog2(NF); // For nf_cnt
   // Parameter: SF_T
   // Address word length of the buffer
   localparam int 		    SF_T=$clog2(SF); // Address word length for the input buffer
   
   // Signal: do_mvau
   // To allow reading of weight memory when computation taking place
   logic 			    do_mvau;   
   // Signal: wmem_en
   // To enable reading of weight memory when the input buffer is being re-used
   logic 			    wmem_en;
   
   generate
      if(NF==1) begin: ONE_FILTER_BANK
	 assign wmem_en = 1'b0; // Memory operation only controlled by in_v
	 assign do_mvau = in_v;	 
      end
      else begin: N_FILTER_BANKS
	 /*
	  * The following control logic is replicated in 
	  * mvau_stream_control_block.sv in order to maintain
	  * modularity so that mvau_stream can be used as a 
	  * top level module
	  * */
	 // Signal: sf_clr
	 // Control signal for resetting the accumulator and a one bit control signal to indicate when sf_cnt == SF-1
	 logic 	    sf_clr;
	 // Signal: sf_cnt
	 // Counter to check when a whole weight matrix row has been processed
	 logic [SF_T-1:0] sf_cnt;
	 
	 // Signal: nf_clr
	 // Signal to reset the nf_cnt counter
	 // Only used when multiple output channel
	 logic 		    nf_clr; // To reset the nf_cnt
	 // Signal: nf_cnt
	 // A counter to keep track how many weight channels have been processed
	 // Only used when multiple output channels
	 logic [NF_T-1:0]   nf_cnt; // NF counter, keeping track of the NF
	 
	 // After input stream inactive, allows for reading from weight memory
	 // as the input buffer is being re-used	 
	 assign wmem_en = (nf_cnt=='d0) ? 1'b0 : 1'b1;
	 assign do_mvau = in_v|wmem_en;

	 // Always_FF: NF_CLR
	 // A one bit control signal to indicate when nf_cnt == NF	 
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      nf_clr <= 1'b0;
	    else if(nf_cnt==NF_T'(NF-1)) //assign nf_clr = nf_cnt==NF_T'(NF-1) ? 1'b1 : 1'b0;
	      nf_clr <= 1'b1;
	    else
	      nf_clr <= 1'b0;
	 end
	 // Always_FF: NF_CNT
	 // A counter to keep track when we are done writing to the
	 // input buffer so that it can be reused again
	 // Similar to the variable nf in mvau.hpp
	 // Only used when multiple output channels
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      nf_cnt <= 'd0;
	    else if(nf_clr & sf_clr)
	      nf_cnt <= 'd0;
	    else if(sf_clr)
	      nf_cnt <= nf_cnt + 1;
	 end

	 // ALWAYS_FF: SF_CLR
	 // A one bit control signal to indicate when sf_cnt == SF-1   
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      sf_clr <= 1'b0;
	    else if(sf_cnt == SF_T'(SF-2)) //assign sf_clr = sf_cnt==SF_T'(SF-1) ? 1'b1 : 1'b0;
	      sf_clr <= 1'b1;
	    else
	      sf_clr <= 1'b0;
	 end
	 
	 // Always_FF: SF_CNT
	 // A sequential 'always' block for a counter
	 // which keeps track when one row of weight matrix is accessed
	 // Only runs when do_mvau is asserted
	 // A counter similar to sf in mvau.hpp
	 // Only used when multiple output channels
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      sf_cnt <= 'd0;
	    else if(do_mvau) begin
	       if(sf_clr)
		 sf_cnt <= 'd0;
	       else
		 sf_cnt <= sf_cnt + 1;
	    end
	 end
      end
   endgenerate
   
   // Always_FF: WMEM_ADDR
   // Control Logic for generating address
   // for the weight memory
   always_ff @(posedge aclk) begin
      if(!aresetn)
	wmem_addr <= 'd0;
      else if(do_mvau) begin
	 if(wmem_addr==WMEM_ADDR_BW'(WMEM_DEPTH-1))
	   wmem_addr <= 'd0;
	 else
	   wmem_addr <= wmem_addr + 1;
      end
   end   
endmodule

