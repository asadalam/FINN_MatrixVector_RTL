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
 * SF - Number of vertical matrix chunks to be processed in parallel by one PE
 * NF - Number of vertical matrix chunks to be processed in parallel by one PE
 * WMEM_DEPTH - The depth of the weight memories
 * WMEM_ADDR_BW - Word length of the address for the weight memories
 * 
 * Inputs:
 * aresetn                      - Active low synchronous reset
 * aclk                         - Main clock
 * wmem_wready                  - Input ready for the weight memory
 * 
 * Outputs:
 * wmem_valid                   - Output valid signal to indicate when weights are available from the weight memory
 * [WMEM_ADDR_BW-1:0] wmem_addr - Address for the weight memories
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
    input logic 		    wmem_wready,
    output logic 		    wmem_valid,
    output logic [WMEM_ADDR_BW-1:0] wmem_addr // Address for the weight memory
    );
   
   // Signal: do_mvau
   // To allow reading of weight memory when computation taking place
   logic 			    do_mvau;   
   
   // After input stream inactive, allows for reading from weight memory
   // as the input buffer is being re-used	 
   // assign wmem_en = (nf_cnt=='d0) ? 1'b0 : 1'b1;
   assign do_mvau = wmem_wready;//(in_v & wmem_wready) |wmem_en;

   // Generate block to deal with two cases
   // Case 1: With one word weight memory, address forced to zero
   // Case 2: With multi word weight memory, address generated as required
   generate
      if(WMEM_DEPTH==1) begin: WMEM_ONEWORD
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      wmem_addr <= 'd0;
	    else if(do_mvau)
	      wmem_addr <= 'd0;
	 end
      end // block: WMEM_ONEWORD      
      else begin: WMEM_MULTIWORD
	 // Always_FF: WMEM_ADDR
	 // Control Logic for generating address
	 // for the weight memory
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      wmem_addr <= 'd0;
	    else if(do_mvau) begin
	       if(wmem_addr==WMEM_ADDR_BW'(WMEM_DEPTH-1))
		 wmem_addr <= 'd0;	 
	       else//if(do_mvau)
		 wmem_addr <= wmem_addr + 1;
	    end
	 end
      end // block: WMEM_MULTIWORD
   endgenerate  

   // Output valid of weights asserted
   // when ever computation is being done
   assign wmem_valid = do_mvau;

endmodule // mvau_control_block
