/*
 * Module: MVAU Merged Weight Memory (mvau_weight_mem_merged.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of the 
 * weight memory. The depth of each weight memory is given by
 * (KDim^2 * IFMCh * OFMCh)/(SIMD * PE) x PE. The word length of each word is
 * SIMD*TW. This memory is a merged memory for all PEs which is internally 
 * partitioned
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
 * WMEM_ID                     - The ID for the weight memory. Helps in reading the right file
 * WMEM_ADDR_BW                - The word length of the address for the weight memory
 * 
 * Inputs:
 * clk - Main clock
 * [WMEM_ADDR_BW-1:0] wmem_addr - Weight memory address
 * 
 * Outputs:
 * [SIMD*TW-1:0]               - Weight memory output, word lenght SIMDxTW
 * */

`timescale 1ns/1ns
`include "mvau_defn.sv"

module mvau_weight_mem_merged #(parameter int WMEM_ID=0,
			 parameter int WMEM_ADDR_BW=4)
   
   (
    input 			   clk,
    input logic [WMEM_ADDR_BW-1:0] wmem_addr,
    output logic [(SIMD*TW)-1:0]   wmem_out [0:PE-1]);
   
   /**
    * Local Parameters
    * **/
   // Parameter: FILE_WEIGHT_MEM
   // Defines the file to read weight memory contents
   //localparam FILE=$sformatf("weight_mem%0d.memh",WMEM_ID);
   
   /**
    * Internal Signals 
    * */

   // Signal: weight_mem_merged
   // This signal defines the merged memory itself   
   (* ram_style = "distributed" *) logic [SIMD*TW-1:0] 		weight_mem_merged [0:PE*WMEM_DEPTH-1];
   // Signal: weight_mem
   // The partitioned memory
   (* ram_style = "distributed" *) logic [SIMD*TW-1:0] weight_mem [0:PE-1][0:WMEM_DEPTH-1];

   initial
     $readmemh("weights_mem_full_src.mem", weight_mem);
   

   // Reading the contents of the weight memor from hex file
   generate
      for(genvar i = 0; i < PE; i=i+1) begin
	 assign weight_mem[i] = weight_mem_merged[i*WMEM_DEPTH:i*WMEM_DEPTH+WMEM_DEPTH-1];	 
      end
   endgenerate

   generate
      for(genvar i = 0; i < PE; i++) begin: WEIGHT_MEM
	 // Always_FF: WMEM_READ_OUT
	 // Reading weight from weight memory through a register
	 always_ff @(posedge clk) begin: WMEM_READ_OUT
	    wmem_out[i] = weight_mem[i][wmem_addr];
	 end
      end
   endgenerate
   
   
endmodule // mvau_weight_mem

   
