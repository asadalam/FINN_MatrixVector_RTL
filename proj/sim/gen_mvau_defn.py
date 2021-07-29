 #
 # Module: MVAU Parameter Generation file
 # 
 # Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 # 
 # This file generates a parameter file to be used by the test benches. It
 # contains a number of write commands to a file
 #
 # This material is based upon work supported, in part, by Science Foundation
 # Ireland, www.sfi.ie under Grant No. 13/RC/2094_P2 and, in part, by the 
 # European Union's Horizon 2020 research and innovation programme under the 
 # Marie Sklodowska-Curie grant agreement Grant No.754489.  # 

import numpy as np
import sys
import argparse

# Function: gen_mvau_defn 
# This function takes in a number of parameters and generates the parameter
# file based on them.
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
def gen_mvau_defn(kdim,iwl,iwb,ifmc,ofmc,ifmd,wwl,wwb,owl,simd,pe,mmv,stride=1):
    mvau_defn = open("mvau_defn.sv","wt")
    #stride=1
    pad=0
    #mmv=1    
    mvau_defn.write("/*\n")
    mvau_defn.write(" * Package: mvau_defn.sv\n")
    mvau_defn.write(" * \n")
    mvau_defn.write(" * Author(s): Syed Asad Alam (syed.asad.alam@tcd.ie)\n")
    mvau_defn.write(" * \n")
    mvau_defn.write(" * Package for definitions and constants\n")
    mvau_defn.write(" * for multiply-vector activation unit. Defines the following parameters\n")
    mvau_defn.write(" * that control the generation of the matrix vector activation unit\n")
    mvau_defn.write(" * \n")
    mvau_defn.write(" * Parameters:  \n")
    mvau_defn.write(" * VERION                                       - Version number\n")
    mvau_defn.write(" * KDim                                         - Kernel dimensions \n")
    mvau_defn.write(" * IFMCh                                        - Input feature map channels\n")
    mvau_defn.write(" * OFMCh                                        - Output feature map channels\n")
    mvau_defn.write(" * IFMDim		                             - Input feature map dimensions\n")
    mvau_defn.write(" * PAD                                          - Padding around the input feature map\n")
    mvau_defn.write(" * STRIDE		                             - Number of pixels to move across when applying the filter\n")
    mvau_defn.write(" * OFMDim=(IFMDim-KDim+2*PAD)/STRIDE+1          - Output feature map dimensions\n")
    mvau_defn.write(" * MatrixW=KDim*KDim*IFMCh                      - Width of the input matrix\n")
    mvau_defn.write(" * MatrixH=OFMCh                                - Heigth of the input matrix\n")
    mvau_defn.write(" * SIMD                                         - Number of input columns computed in parallel\n")
    mvau_defn.write(" * PE                                           - Number of output rows computed in parallel\n")
    mvau_defn.write(" * WMEM_DEPTH=(KDim*KDim*IFMCh*OFMCh)/(SIMD*PE) - Depth of each weight memory\n")
    mvau_defn.write(" * MMV                                          - Number of output pixels computed in parallel\n")
    mvau_defn.write(" * TSrcI                                        - DataType of the input activation (as used in the MAC)\n")
    mvau_defn.write(" * TSrcI_BIN = 0                                - Indicates whether the 1-bit TSrcI is to be interpreted as special +1/-1 or not\n")
    mvau_defn.write(" * TDstI                                        - DataType of the output activation (as generated by the activation)\n")
    mvau_defn.write(" * TI                                           - SIMD times the word length of input stream\n")
    mvau_defn.write(" * TO                                           - PE times the word length of output stream\n")
    mvau_defn.write(" * TW                                           - Word length of individual weights\n")
    mvau_defn.write(" * TW_BIN                                       - Indicates whether the 1-bit TW is to be interpreted as special +1/-1 or not\n")
    mvau_defn.write(" * TA                                           - PE times the word length of the activation class (e.g thresholds)\n")
    mvau_defn.write(" * USE_DSP                                      - Use DSP blocks or LUTs for MAC (future extension)\n")
    mvau_defn.write(" * INST_WMEM                                    - Instantiate weight memory; if needed\n")
    mvau_defn.write(" * USE_ACT                                      - Use activation after matrix-vector activation\n")
    mvau_defn.write(" * */\n")
    mvau_defn.write(" \n")
    mvau_defn.write("`ifndef MVAU_DEFN_PKG // if the already-compiled flag is not set\n")
    mvau_defn.write(" `define MVAU_DEFN_PKG //set the flag\n")
    mvau_defn.write("package mvau_defn;\n")
    mvau_defn.write("   parameter VERSION = \"0.1\";\n")
    mvau_defn.write("   parameter int KDim=%d; // Kernel dimensions\n" % kdim)
    mvau_defn.write("   parameter int IFMCh=%d;// Input feature map channels\n" % ifmc)
    mvau_defn.write("   parameter int OFMCh=%d;// Output feature map channels or the number of filter banks\n" % ofmc)
    mvau_defn.write("   parameter int IFMDim=%d; // Input feature map dimensions\n" % ifmd)
    mvau_defn.write("   parameter int PAD=%d;    // Padding around the input feature map\n" % pad)
    mvau_defn.write("   parameter int STRIDE=%d; // Number of pixels to move across when applying the filter\n" % stride)
    mvau_defn.write("   parameter int OFMDim=(IFMDim-KDim+2*PAD)/STRIDE+1; // Output feature map dimensions\n")
    mvau_defn.write("   parameter int MatrixW=KDim*KDim*IFMCh;   // Width of the input matrix\n")
    mvau_defn.write("   parameter int MatrixH=OFMCh; // Heigth of the input matrix\n")
    mvau_defn.write("   parameter int SIMD=%d; // Number of input columns computed in parallel\n" % simd)
    mvau_defn.write("   parameter int PE=%d; // Number of output rows computed in parallel\n" % pe)
    mvau_defn.write("   parameter int WMEM_DEPTH=(KDim*KDim*IFMCh*OFMCh)/(SIMD*PE); // Depth of each weight memory\n")
    mvau_defn.write("   parameter int MMV=%d; // Number of output pixels computed in parallel\n" % mmv)
    mvau_defn.write("   parameter int TSrcI=%d; // DataType of the input activation (as used in the MAC)\n" % iwl)
    mvau_defn.write("   parameter int TSrcI_BIN = %d; // Indicates whether the 1-bit TSrcI is to be interpreted as special +1/-1 or not\n" % iwb)
    mvau_defn.write("   parameter int TI=SIMD*TSrcI; // SIMD times the word length of input stream\n")
    mvau_defn.write("   parameter int TW=%d; // Word length of individual weights\n" % wwl)
    mvau_defn.write("   parameter int TW_BIN = %d; // Indicates whether the 1-bit TW is to be interpreted as special +1/-1 or not\n" % wwb)
    mvau_defn.write("   parameter int TDstI=%d; // DataType of the output activation (as generated by the activation) \n" % owl)
    mvau_defn.write("   parameter int TO=PE*TDstI; // PE times the word length of output stream   \n")
    mvau_defn.write("   parameter int TA=%d; // PE times the word length of the activation class (e.g thresholds)\n" % owl)
    mvau_defn.write("   parameter int USE_DSP=0; // Use DSP blocks or LUTs for MAC\n")
    mvau_defn.write("   parameter int INST_WMEM=1; // Instantiate weight memory; if needed\n")
    mvau_defn.write("   parameter int USE_ACT=0;     // Use activation after matrix-vector activation\n")
    mvau_defn.write("   \n")
    mvau_defn.write("endpackage\n")
    mvau_defn.write("   \n")
    mvau_defn.write("   import mvau_defn::*; // import package into $unit compilation space\n")
    mvau_defn.write("`endif\n")

    mvau_defn.close()

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
    parser.add_argument('-m', '--mmv', default=1,type=int,
			help="MMV")
    return parser

# Function: __main__
# Entry point of the file, retrieves the command line arguments and
# calls the gen_mvau_defn function with the required arguments
if __name__ == "__main__":

    ## Reading the argument list passed to this script
    args = parser().parse_args()

    ## Generating the definition file for RTL
    gen_mvau_defn(args.kdim,args.inp_wl,args.inp_bin,
                  args.ifm_ch,args.ofm_ch,args.ifm_dim,
                  args.wgt_wl,args.wgt_bin,args.out_wl,
                  args.simd,args.pe,args.mmv)
                            
    sys.exit(0)
