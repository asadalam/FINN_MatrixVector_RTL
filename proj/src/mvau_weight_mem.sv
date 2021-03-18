/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvau_weight_mem.sv
 *
 * This file lists an RTL implementation of the 
 * weight memory
 * 
 * The depth of each weight memory is given by
 *              (KDim^2 * IFMCh * OFMCh)/(SIMD * PE)
 * 
 * The word length of each word is
 *                   SIMD*TW
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
 * WMEM_ID                     : The ID for the weight memory. Helps in reading the right file
 * WMEM_ADDR_BW                : The word length of the address for the weight memory
 * *******
 * Inputs:
 * *******
 * clk                         : Main clock
 * [WMEM_ADDR_BW-1:0] wmem_addr: Weight memory address
 * ********
 * Outputs:
 * ********
 * [SIMD*TW-1:0]               : Weight memory output, word lenght SIMDxTW
 * **/

module mvau_weight_mem #(parameter int WMEM_ID=0,
			 parameter int WMEM_ADDR_BW=2)
   (
    input logic 		   clk,
    input logic [WMEM_ADDR_BW-1:0] wmem_addr,
    output logic [(SIMD*TW)-1:0]   wmem_out);
   
   /**
    * Local Parameters
    * **/
   localparam FILE=$sformatf("weight_mem%0d.mem",WMEM_ID);
   
   /**
    * Internal Signals 
    * */

   // The memory itself
   logic [SIMD*TW-1:0] 		weight_mem [0:WMEM_DEPTH];

   // Reading the contents of the weight memor from hex file
   initial
     $readmemh(FILE, weight_mem);
   
   assign wmem_out = weight_mem[wmem_addr];

endmodule // mvau_weight_mem

   
