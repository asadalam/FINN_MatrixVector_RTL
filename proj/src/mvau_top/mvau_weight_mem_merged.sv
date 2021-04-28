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
 * clk    - Main clock
 * [WMEM_ADDR_BW-1:0] wmem_addr - Weight memory address
 * 
 * Outputs:
 * [SIMD*TW-1:0]               - Weight memory output, word lenght SIMDxTW
 
 * Parameters:
 * WMEM_ADDR_BW - Word length of the address for the weight memories (log2(WMEM_DEPTH))
 * */
 
`timescale 1ns/1ns
// Package file for parameters
`include "mvau_defn.sv"
 
module mvau_weight_mem_merged #(parameter int WMEM_ID=0,
        			parameter int WMEM_ADDR_BW=4)
   (    
        input logic 		       clk, // main clock
        input logic [WMEM_ADDR_BW-1:0] wmem_addr,
        output logic [(SIMD*TW)-1:0]   wmem_out [0:PE-1]);
   
   mvau_weight_mem0 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem0_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[0])
      		       );   
   mvau_weight_mem1 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem1_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[1])
      		       );   
   mvau_weight_mem2 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem2_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[2])
      		       );   
   mvau_weight_mem3 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem3_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[3])
      		       );   
   mvau_weight_mem4 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem4_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[4])
      		       );   
   mvau_weight_mem5 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem5_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[5])
      		       );   
   mvau_weight_mem6 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem6_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[6])
      		       );   
   mvau_weight_mem7 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem7_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[7])
      		       );   
   mvau_weight_mem8 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem8_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[8])
      		       );   
   mvau_weight_mem9 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem9_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[9])
      		       );   
   mvau_weight_mem10 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem10_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[10])
      		       );   
   mvau_weight_mem11 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem11_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[11])
      		       );   
   mvau_weight_mem12 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem12_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[12])
      		       );   
   mvau_weight_mem13 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem13_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[13])
      		       );   
   mvau_weight_mem14 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem14_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[14])
      		       );   
   mvau_weight_mem15 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem15_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[15])
      		       );   
   mvau_weight_mem16 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem16_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[16])
      		       );   
   mvau_weight_mem17 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem17_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[17])
      		       );   
   mvau_weight_mem18 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem18_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[18])
      		       );   
   mvau_weight_mem19 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem19_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[19])
      		       );   
   mvau_weight_mem20 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem20_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[20])
      		       );   
   mvau_weight_mem21 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem21_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[21])
      		       );   
   mvau_weight_mem22 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem22_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[22])
      		       );   
   mvau_weight_mem23 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem23_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[23])
      		       );   
   mvau_weight_mem24 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem24_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[24])
      		       );   
   mvau_weight_mem25 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem25_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[25])
      		       );   
   mvau_weight_mem26 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem26_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[26])
      		       );   
   mvau_weight_mem27 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem27_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[27])
      		       );   
   mvau_weight_mem28 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem28_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[28])
      		       );   
   mvau_weight_mem29 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem29_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[29])
      		       );   
   mvau_weight_mem30 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem30_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[30])
      		       );   
   mvau_weight_mem31 #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem31_inst(
      		       .clk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[31])
      		       );   
endmodule // mvau_weight_mem_merged
