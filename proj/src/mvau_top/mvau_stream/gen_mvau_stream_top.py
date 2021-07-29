 #
 # Python: MVAU Stream Top Wrapper Generator (gen_mvau_stream_top.py)
 # 
 # Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 # 
 # This file generates the top level Verilog wrapper for the stream unit top
 # that instantiates the mvau_stream.sv module. Verilog wrapper is needed for IP generation.
 #
 # This material is based upon work supported, in part, by Science Foundation
 # Ireland, www.sfi.ie under Grant No. 13/RC/2094_P2 and, in part, by the 
 # European Union's Horizon 2020 research and innovation programme under the 
 # Marie Sklodowska-Curie grant agreement Grant No.754489.  # 

import numpy as np
import sys
import argparse



# Function: gen_mvau_stream_top
# This function takes in a number of parameters and generates the top level
# Verilog wrapper for the mvau_stream.sv module through the use of successive write
# commands. A python generator is needed so that the parameters can be handled
# programmatically
#
# Parameters:
#   kdim - Kernel dimension.
#   iwl - Input activation word length.
#   iwb - '1' if input word length '1' bit, else '0'.
#   ifmc - Number of input feature map channels.
#   ofmc - Number of output feature map channels.
#   wwl - Weight precision.
#   wwb - '1' if weights are '1' bit, else '0'
#   owl - Output activation word length
#   simd - Number of SIMD elements
#   pe - Number of processing elements (PE)
#   mmv - Number of images
#   stride - Convolution stride
#
# Returns:
#
# None
def gen_mvau_stream_top(kdim,iwl,iwb,ifmc,ofmc,ifmd,wwl,wwb,owl,simd,pe,stride=1,mmv=1):
    mvau_stream_top = open("mvau_stream_top.v","wt")
    stride=1
    pad=0
    mmv=1    
    mvau_stream_top.write("/*\n")
    mvau_stream_top.write(" * Module: MVAU Stream Top Level Verilog Wrapper (mvau_stream_top)\n")
    mvau_stream_top.write(" * \n")
    mvau_stream_top.write(" * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>\n")
    mvau_stream_top.write(" * \n")
    mvau_stream_top.write(" * This file lists an RTL implementation of the matrix-vector activation unit\n")
    mvau_stream_top.write(" * based on streaming weights. It can either be part of the Matrix-Vector-Activation Unit\n")
    mvau_stream_top.write(" * or run independently. It is part of the Xilinx FINN open source framework for implementing\n")
    mvau_stream_top.write(" * quantized neural networks on FPGAs\n")
    mvau_stream_top.write(" *\n")
    mvau_stream_top.write(" * This material is based upon work supported, in part, by Science Foundation\n")
    mvau_stream_top.write(" * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the \n")
    mvau_stream_top.write(" * European Union's Horizon 2020 research and innovation programme under the \n")
    mvau_stream_top.write(" * Marie Sklodowska-Curie grant agreement Grant No.754489. \n")
    mvau_stream_top.write(" * \n")
    mvau_stream_top.write(" * Inputs:\n")
    mvau_stream_top.write(" * aresetn  - Active low synchronous reset\n")
    mvau_stream_top.write(" * aclk    - Main clock\n")
    mvau_stream_top.write(" * s0_axis_tready - Input ready which tells that the MVAU unit is ready to receive data\n")
    mvau_stream_top.write(" * [TI-1:0] m0_axis_tdata - Input stream, word length TI=TSrcI*SIMD\n")
    mvau_stream_top.write(" * m0_axis_tvalid - Input valid, indicates valid input\n")
    mvau_stream_top.write(" * \n")
    mvau_stream_top.write(" * Outputs:\n")
    mvau_stream_top.write(" * m0_axis_tready - Output ready which tells the predecessor logic to start providing data\n")
    mvau_stream_top.write(" * s0_axis_tvalid        - Output stream valid\n")
    mvau_stream_top.write(" * [TO-1:0] s0_axis_tdata - Output stream, word length TO=TDstI*PE \n")
    mvau_stream_top.write(" * \n")
    mvau_stream_top.write(" * Parameters:\n")
    mvau_stream_top.write(" * KDim                                         - Kernel dimensions \n")
    mvau_stream_top.write(" * IFMCh                                        - Input feature map channels\n")
    mvau_stream_top.write(" * OFMCh                                        - Output feature map channels\n")
    mvau_stream_top.write(" * IFMDim		                            - Input feature map dimensions\n")
    mvau_stream_top.write(" * PAD                                          - Padding around the input feature map\n")
    mvau_stream_top.write(" * STRIDE		                            - Number of pixels to move across when applying the filter\n")
    mvau_stream_top.write(" * OFMDim=(IFMDim-KDim+2*PAD)/STRIDE+1          - Output feature map dimensions\n")
    mvau_stream_top.write(" * MatrixW=KDim*KDim*IFMCh                      - Width of the input matrix\n")
    mvau_stream_top.write(" * MatrixH=OFMCh                                - Heigth of the input matrix\n")
    mvau_stream_top.write(" * SIMD                                         - Number of input columns computed in parallel\n")
    mvau_stream_top.write(" * PE                                           - Number of output rows computed in parallel\n")
    mvau_stream_top.write(" * WMEM_DEPTH=(KDim*KDim*IFMCh*OFMCh)/(SIMD*PE) - Depth of each weight memory\n")
    mvau_stream_top.write(" * MMV                                          - Number of output pixels computed in parallel\n")
    mvau_stream_top.write(" * TSrcI                                        - DataType of the input activation (as used in the MAC)\n")
    mvau_stream_top.write(" * TSrcI_BIN = 0                                - Indicates whether the 1-bit TSrcI is to be interpreted as special +1/-1 or not\n")
    mvau_stream_top.write(" * TDstI                                        - DataType of the output activation (as generated by the activation)\n")
    mvau_stream_top.write(" * TI                                           - SIMD times the word length of input stream\n")
    mvau_stream_top.write(" * TO                                           - PE times the word length of output stream\n")
    mvau_stream_top.write(" * TW                                           - Word length of individual weights\n")
    mvau_stream_top.write(" * TW_BIN                                       - Indicates whether the 1-bit TW is to be interpreted as special +1/-1 or not\n")
    mvau_stream_top.write(" * TA                                           - PE times the word length of the activation class (e.g thresholds)\n")
    mvau_stream_top.write(" * USE_DSP                                      - Use DSP blocks or LUTs for MAC (future extension)\n")
    mvau_stream_top.write(" * USE_ACT                                      - Use activation after matrix-vector activation\n")
    mvau_stream_top.write(" * */\n")
    mvau_stream_top.write(" \n")
    mvau_stream_top.write("`timescale 1ns/1ns\n")
    mvau_stream_top.write(" \n")
    mvau_stream_top.write("module mvau_stream_top #(\n")
    mvau_stream_top.write("   parameter integer KDim=%d, // Kernel dimensions\n" % kdim)
    mvau_stream_top.write("   parameter integer IFMCh=%d,// Input feature map channels\n" % ifmc)
    mvau_stream_top.write("   parameter integer OFMCh=%d,// Output feature map channels or the number of filter banks\n" % ofmc)
    mvau_stream_top.write("   parameter integer IFMDim=%d, // Input feature map dimensions\n" % ifmd)
    mvau_stream_top.write("   parameter integer PAD=%d,    // Padding around the input feature map\n" % pad)
    mvau_stream_top.write("   parameter integer STRIDE=%d, // Number of pixels to move across when applying the filter\n" % stride)
    mvau_stream_top.write("   parameter integer OFMDim=(IFMDim-KDim+2*PAD)/STRIDE+1, // Output feature map dimensions\n")
    mvau_stream_top.write("   parameter integer MatrixW=KDim*KDim*IFMCh,   // Width of the input matrix\n")
    mvau_stream_top.write("   parameter integer MatrixH=OFMCh, // Heigth of the input matrix\n")
    mvau_stream_top.write("   parameter integer SIMD=%d, // Number of input columns computed in parallel\n" % simd)
    mvau_stream_top.write("   parameter integer PE=%d, // Number of output rows computed in parallel\n" % pe)
    mvau_stream_top.write("   parameter integer WMEM_DEPTH=(KDim*KDim*IFMCh*OFMCh)/(SIMD*PE), // Depth of each weight memory\n")
    mvau_stream_top.write("   parameter integer MMV=%d, // Number of output pixels computed in parallel\n" % mmv)
    mvau_stream_top.write("   parameter integer TSrcI=%d, // DataType of the input activation (as used in the MAC)\n" % iwl)
    mvau_stream_top.write("   parameter integer TSrcI_BIN = %d, // Indicates whether the 1-bit TSrcI is to be interpreted as special +1/-1 or not\n" % iwb)
    mvau_stream_top.write("   parameter integer TI=SIMD*TSrcI, // SIMD times the word length of input stream\n")
    mvau_stream_top.write("   parameter integer TW=%d, // Word length of individual weights\n" % wwl)
    mvau_stream_top.write("   parameter integer TW_BIN = %d, // Indicates whether the 1-bit TW is to be interpreted as special +1/-1 or not\n" % wwb)
    mvau_stream_top.write("   parameter integer TDstI=%d, // DataType of the output activation (as generated by the activation) \n" % owl)
    mvau_stream_top.write("   parameter integer TO=PE*TDstI, // PE times the word length of output stream   \n")
    mvau_stream_top.write("   parameter integer TA=%d, // PE times the word length of the activation class (e.g thresholds)\n" % owl)
    mvau_stream_top.write("   parameter integer USE_DSP=0, // Use DSP blocks or LUTs for MAC\n")
    mvau_stream_top.write("   parameter integer MVAU_STREAM=1, // Top module is MVAU Stream or not\n")
    mvau_stream_top.write("   parameter integer USE_ACT=0)     // Use activation after matrix-vector activation\n")
    mvau_stream_top.write("(    \n")
    mvau_stream_top.write(" 		 input  	       aresetn, // active low synchronous reset\n")
    mvau_stream_top.write(" 		 input  	       aclk, // main clock\n")
    mvau_stream_top.write(" \n")
    mvau_stream_top.write(" 		 // Axis Stream interface\n")
    mvau_stream_top.write(" 		 input  	         m0_axis_tready,\n")    
    mvau_stream_top.write(" 		 input  [TI-1:0]         s0_axis_tdata,  // input stream\n")
    mvau_stream_top.write(" 		 input  	         s0_axis_tvalid, // input valid\n")
    mvau_stream_top.write("              input  [0:PE*SIMD*TW-1] s1_axis_tdata,  // Streaming weight tile\n")
    mvau_stream_top.write("              input                   s1_axis_tvalid, // Streaming weight tile valid\n")
    mvau_stream_top.write(" 		 output  	         s0_axis_tready, // Ready for input stream\n")
    mvau_stream_top.write("              output                  s1_axis_tready, // Stream weight output ready\n")
    mvau_stream_top.write(" 		 output  	         m0_axis_tvalid, // Output valid\n")
    mvau_stream_top.write(" 		 output  [TO-1:0]        m0_axis_tdata); //output stream\n")
    mvau_stream_top.write(" \n")
    mvau_stream_top.write("   mvau_stream #(\n")
    mvau_stream_top.write("   .KDim        (KDim      ), \n") 
    mvau_stream_top.write("   .IFMCh	   (IFMCh     ), \n") 
    mvau_stream_top.write("   .OFMCh	   (OFMCh     ), \n") 
    mvau_stream_top.write("   .IFMDim      (IFMDim    ), \n") 
    mvau_stream_top.write("   .PAD	   (PAD       ), \n") 
    mvau_stream_top.write("   .STRIDE      (STRIDE    ), \n") 
    mvau_stream_top.write("   .OFMDim      (OFMDim    ), \n") 
    mvau_stream_top.write("   .MatrixW     (MatrixW   ), \n") 
    mvau_stream_top.write("   .MatrixH     (MatrixH   ), \n") 
    mvau_stream_top.write("   .SIMD	   (SIMD      ), \n") 
    mvau_stream_top.write("   .PE	   (PE        ), \n") 
    mvau_stream_top.write("   .WMEM_DEPTH  (WMEM_DEPTH), \n") 
    mvau_stream_top.write("   .MMV	   (MMV       ), \n") 
    mvau_stream_top.write("   .TSrcI	   (TSrcI     ), \n") 
    mvau_stream_top.write("   .TSrcI_BIN   (TSrcI_BIN ), \n") 
    mvau_stream_top.write("   .TI	   (TI        ), \n") 
    mvau_stream_top.write("   .TW	   (TW        ), \n") 
    mvau_stream_top.write("   .TW_BIN      (TW_BIN    ), \n") 
    mvau_stream_top.write("   .TDstI	   (TDstI     ), \n") 
    mvau_stream_top.write("   .TO	   (TO        ), \n") 
    mvau_stream_top.write("   .TA	   (TA        ), \n") 
    mvau_stream_top.write("   .USE_DSP     (USE_DSP   ), \n")
    mvau_stream_top.write("   .MVAU_STREAM (MVAU_STREAM), \n")
    mvau_stream_top.write("   .USE_ACT     (USE_ACT   )) \n") 
    mvau_stream_top.write("   mvau_stream_inst(\n")
    mvau_stream_top.write(" 		  .aresetn     (aresetn),\n")
    mvau_stream_top.write(" 		  .aclk        (aclk),\n")
    mvau_stream_top.write(" 		  .rready      (m0_axis_tready),\n")
    mvau_stream_top.write(" 		  .wready      (s0_axis_tready),\n")
    mvau_stream_top.write(" 		  .in_act      (s0_axis_tdata),\n")
    mvau_stream_top.write(" 		  .in_v        (s0_axis_tvalid),\n")
    mvau_stream_top.write("               .wmem_wready (s1_axis_tready),\n")
    mvau_stream_top.write("               .in_wgt      (s1_axis_tdata),\n")
    mvau_stream_top.write("               .in_wgt_v    (s1_axis_tvalid),\n")
    mvau_stream_top.write(" 		  .out_v       (m0_axis_tvalid),\n")
    mvau_stream_top.write(" 		  .out         (m0_axis_tdata)\n")
    mvau_stream_top.write(" 		  );\n")       
    mvau_stream_top.write("      \n")
    mvau_stream_top.write("endmodule // mvau_stream_top\n")

    mvau_stream_top.close()

    
# Function: parser
# This function defines an ArgumentParser object for command line arguments
#
# Returns:
# Parser object (parser)
def parser():
    parser = argparse.ArgumentParser(description='Python data script for generating MVAU Paramter file')
    parser.add_argument('-k','--kdim',default=2,type=int,
			help="Filter dimension")
    parser.add_argument('-i','--inp_wl',default=8,type=int,
			help="Input word length")
    parser.add_argument('--inp_bin',default=0,type=int,
                        help="Inputs binary or fixed point")
    parser.add_argument('--ifm_ch', default=4,type=int,
			help="Input feature map channels")
    parser.add_argument('--ofm_ch', default=4, type=int,
			help="Output feature map channels")
    parser.add_argument('--ifm_dim', default=4, type=int,
			help="Input feature map dimensions")
    parser.add_argument('-w','--wgt_wl',default=1,type=int,
                        help="Weight word length")
    parser.add_argument('--wgt_bin',default=1,type=int,
                        help="Weights binary or fixed point")
    parser.add_argument('-o','--out_wl', default=16, type=int,
			help="Output word length")
    parser.add_argument('-s','--simd',default=2,type=int,
			help="SIMD")
    parser.add_argument('-p', '--pe', default=2,type=int,
			help="PE")
    return parser

# Function: __main__
# Entry point of the file, retrieves the command line arguments and
# calls the gen_mvau_stream_top function with the required arguments
if __name__ == "__main__":

    ## Reading the argument list passed to this script
    args = parser().parse_args()

    ## Generating the definition file for RTL
    gen_mvau_stream_top(args.kdim,args.inp_wl,args.inp_bin,
                        args.ifm_ch,args.ofm_ch,args.ifm_dim,
                        args.wgt_wl,args.wgt_bin,args.out_wl,
                        args.simd,args.pe)
                            
    sys.exit(0)
