/*
 * Module: MVAU Weight Memory (mvau_weight_mem.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of the 
 * weight memory. The depth of each weight memory is given by
 * (KDim^2 * IFMCh * OFMCh)/(SIMD * PE). The word length of each word is
 * SIMD*TW
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
 * WMEM_ADDR_BW                - The word length of the address for the weight memory
 * 
 * Inputs:
 * aclk - Main clock
 * [WMEM_ADDR_BW-1:0] wmem_addr - Weight memory address
 * 
 * Outputs:
 * [SIMD*TW-1:0]               - Weight memory output, word lenght SIMDxTW
 * */
 
`timescale 1ns/1ns
 
module mvau_weight_mem43 #(
    parameter int SIMD=2,
    parameter int TW=1,
    parameter int WMEM_DEPTH=4,
    parameter int WMEM_ADDR_BW=4)
   
   (
    input 			   aclk,
    input logic [WMEM_ADDR_BW-1:0] wmem_addr,
    output logic [(SIMD*TW)-1:0]   wmem_out);
   
   
   /**
    * Internal Signals 
    * */
   
   
   // Signal: weight_mem
   // This signal defines the memory itself
   (* ram_style = "auto" *) logic [SIMD*TW-1:0] 		weight_mem [0:WMEM_DEPTH-1];
   initial
     $readmemh("weight_mem43.mem", weight_mem);
   
   
   // Always_FF: WMEM_READ_OUT
   // Sequential 'always' block to read from
   // weight memory
   always_ff @(posedge aclk) begin: WMEM_READ_OUT
      wmem_out = weight_mem[wmem_addr];
   end
   
endmodule // mvau_weight_mem
