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
   mvau_weight_mem16 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem16_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[16])
      		       );   
   mvau_weight_mem17 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem17_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[17])
      		       );   
   mvau_weight_mem18 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem18_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[18])
      		       );   
   mvau_weight_mem19 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem19_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[19])
      		       );   
   mvau_weight_mem20 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem20_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[20])
      		       );   
   mvau_weight_mem21 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem21_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[21])
      		       );   
   mvau_weight_mem22 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem22_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[22])
      		       );   
   mvau_weight_mem23 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem23_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[23])
      		       );   
   mvau_weight_mem24 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem24_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[24])
      		       );   
   mvau_weight_mem25 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem25_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[25])
      		       );   
   mvau_weight_mem26 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem26_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[26])
      		       );   
   mvau_weight_mem27 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem27_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[27])
      		       );   
   mvau_weight_mem28 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem28_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[28])
      		       );   
   mvau_weight_mem29 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem29_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[29])
      		       );   
   mvau_weight_mem30 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem30_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[30])
      		       );   
   mvau_weight_mem31 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem31_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[31])
      		       );   
   mvau_weight_mem32 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem32_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[32])
      		       );   
   mvau_weight_mem33 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem33_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[33])
      		       );   
   mvau_weight_mem34 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem34_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[34])
      		       );   
   mvau_weight_mem35 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem35_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[35])
      		       );   
   mvau_weight_mem36 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem36_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[36])
      		       );   
   mvau_weight_mem37 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem37_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[37])
      		       );   
   mvau_weight_mem38 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem38_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[38])
      		       );   
   mvau_weight_mem39 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem39_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[39])
      		       );   
   mvau_weight_mem40 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem40_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[40])
      		       );   
   mvau_weight_mem41 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem41_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[41])
      		       );   
   mvau_weight_mem42 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem42_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[42])
      		       );   
   mvau_weight_mem43 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem43_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[43])
      		       );   
   mvau_weight_mem44 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem44_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[44])
      		       );   
   mvau_weight_mem45 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem45_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[45])
      		       );   
   mvau_weight_mem46 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem46_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[46])
      		       );   
   mvau_weight_mem47 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem47_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[47])
      		       );   
   mvau_weight_mem48 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem48_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[48])
      		       );   
   mvau_weight_mem49 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem49_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[49])
      		       );   
   mvau_weight_mem50 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem50_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[50])
      		       );   
   mvau_weight_mem51 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem51_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[51])
      		       );   
   mvau_weight_mem52 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem52_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[52])
      		       );   
   mvau_weight_mem53 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem53_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[53])
      		       );   
   mvau_weight_mem54 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem54_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[54])
      		       );   
   mvau_weight_mem55 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem55_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[55])
      		       );   
   mvau_weight_mem56 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem56_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[56])
      		       );   
   mvau_weight_mem57 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem57_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[57])
      		       );   
   mvau_weight_mem58 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem58_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[58])
      		       );   
   mvau_weight_mem59 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem59_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[59])
      		       );   
   mvau_weight_mem60 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem60_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[60])
      		       );   
   mvau_weight_mem61 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem61_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[61])
      		       );   
   mvau_weight_mem62 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem62_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[62])
      		       );   
   mvau_weight_mem63 #(
      .SIMD(SIMD),
      .TW(TW),
      .WMEM_DEPTH(WMEM_DEPTH),
      .WMEM_ADDR_BW(WMEM_ADDR_BW))
   mvau_weigt_mem63_inst(
      		       .aclk,
      		       .wmem_addr,
      		       .wmem_out(wmem_out[63])
      		       );   
endmodule // mvau_weight_mem_merged
