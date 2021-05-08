/*
 * Module: MVAU Weights Top Level file (mvau_weight_mem_merged.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists an RTL implementation of the matrix-vector activation unit
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * aclk    - Main clock
 * [WMEM_ADDR_BW-1:0] wmem_addr - Weight memory address
 * 
 * Outputs:
 * [SIMD*TW-1:0]               - Weight memory output, word lenght SIMDxTW
 
 * Parameters:
 * WMEM_ADDR_BW - Word length of the address for the weight memories (log2(WMEM_DEPTH))
 * */
 
`timescale 1ns/1ns
// Package file for parameters
 
module mvau_weight_mem_merged #(
    parameter int SIMD=2,
    parameter int PE=2,
    parameter int TW=1,
    parameter int WMEM_DEPTH=4,
    parameter int WMEM_ADDR_BW=4)
   (    
        input logic 		       aclk, // main clock
        input logic [WMEM_ADDR_BW-1:0] wmem_addr,
        output logic [(SIMD*TW)-1:0]   wmem_out [0:PE-1]);
   
   mvau_weight_mem0 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem0_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[0])
      		       );   
   mvau_weight_mem1 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem1_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[1])
      		       );   
   mvau_weight_mem2 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem2_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[2])
      		       );   
   mvau_weight_mem3 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem3_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[3])
      		       );   
   mvau_weight_mem4 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem4_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[4])
      		       );   
   mvau_weight_mem5 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem5_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[5])
      		       );   
   mvau_weight_mem6 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem6_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[6])
      		       );   
   mvau_weight_mem7 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem7_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[7])
      		       );   
   mvau_weight_mem8 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem8_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[8])
      		       );   
   mvau_weight_mem9 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem9_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[9])
      		       );   
   mvau_weight_mem10 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem10_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[10])
      		       );   
   mvau_weight_mem11 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem11_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[11])
      		       );   
   mvau_weight_mem12 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem12_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[12])
      		       );   
   mvau_weight_mem13 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem13_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[13])
      		       );   
   mvau_weight_mem14 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem14_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[14])
      		       );   
   mvau_weight_mem15 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem15_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[15])
      		       );   
endmodule // mvau_weight_mem_merged
