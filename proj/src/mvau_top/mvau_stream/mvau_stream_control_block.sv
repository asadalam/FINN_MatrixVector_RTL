/*
 * Module: MVAU Streaming Block Control Unit (mvau_stream_control_block.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists an RTL implementation of the control block
 * It is used to control the input buffer
 * and generation of the correct control signals to control
 * the multiplication operation and generate address, write 
 * and read enable for the input buffer. It also contains 
 * free running counters to track as each input activation vector
 * is processed
 * 
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * rst_n                                      - Active low synchronous reset
 * clk                                        - Main clock
 * 
 * Outputs:
 * ib_wen                             - Write enable for the input buffer
 * ib_red                             - Read enable for the input buffer
 * sf_clr                             - Control signal for resetting the accumulator
 * [SF_T:0] sf_cnt                    - Address for the input buffer
 * 
 * Parameters:
 * SF=MatrixW/SIMD - Number of vertical weight matrix chunks and depth of the input buffer
 * NF=MatrixH/PE   - Number of horizontal weight matrix chunks
 * SF_T            - log_2(SF), determines the number of address bits for the input buffer * SF_T
 * */

`timescale 1ns/1ns
`include "mvau_defn.sv"

module mvau_stream_control_block #(
			    parameter int SF=8,
			    parameter int NF=2,
			    parameter int SF_T=3,
			    parameter int WMEM_ADDR_BW=2
			    )
   (
    input logic 	    rst_n,
    input logic 	    clk,
    output logic 	    ib_wen, // Input buffer write enable
    output logic 	    ib_ren, // INput buffer read enable
    output logic 	    sf_clr, // To reset the sf_cnt
    output logic [SF_T-1:0] sf_cnt // Address for the input buffer
    );
   
   /*
    * Local Parameters
    * */
   // Parameter: NF_T
   // Word length of the NF counter to control reading and writing from the input buffer
   localparam int 	    NF_T=$clog2(NF); // For nf_cnt
   // Parameter: MatrixH_BW
   // Word length to represent the weight matrix height
   localparam int 	    MatrixH_BW=$clog2(MatrixH);
   // Parameter: MatrixW_BW
   // Word length to represent the weight matrix width
   localparam int 	    MatrixW_BW=$clog2(MatrixW);

   /*
    * Controlling for when MatrixH is '1' and PE is also '1'
    * Meaning only one output channel
    * */
   
   generate
      if(NF==1) begin: ONE_FILTER_BANK
	 assign ib_wen = 1'b1;
	 assign ib_ren = 1'b0;
      end
      else begin: N_FILTER_BANKS
	 logic 		    nf_clr; // To reset the nf_cnt
	 logic [NF_T-1:0]   nf_cnt; // NF counter, keeping track of the NF
	 // A one bit control signal to indicate when nf_cnt == NF
	 assign nf_clr = nf_cnt==NF_T'(NF-1) ? 1'b1 : 1'b0;
	 
	 // Write enable for the input buffer
	 // Remains one when the input buffer is being filled
	 // Resets to Zero the input buffer is filled and ready
	 // to be reused
	 assign ib_wen = (nf_cnt=='d0) ? 1'b1 : 1'b0;
	 // Read enable is just the inverse of write enable
	 assign ib_ren = ~ib_wen;
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
      end // block: N_FILTER_BANKS
   endgenerate

   // Signal: sf_clr
   // A one bit control signal to indicate when sf_cnt == SF
   assign sf_clr = sf_cnt==SF_T'(SF-1) ? 1'b1 : 1'b0;
   
      
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


endmodule

