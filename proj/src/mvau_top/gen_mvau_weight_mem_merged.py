 #
 # Python Script: MVAU Weight Top Generator File (gen_mvau_weight_mem_merged.py)
 # 
 # Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 # 
 # This file generates a top level weight memory file which instantiates all
 # weight memories. The number of weight memories is equal to the number of PEs
 #
 # This material is based upon work supported, in part, by Science Foundation
 # Ireland, www.sfi.ie under Grant No. 13/RC/2094_P2 and, in part, by the 
 # European Union's Horizon 2020 research and innovation programme under the 
 # Marie Sklodowska-Curie grant agreement Grant No.754489.  # 

import numpy as np
import sys
import argparse

# Function: gen_mvau_weight_mem_merged
# This function takes does the actual generation using a series
# of write commands. The use of Python generator was necessary
# so that the number of memories instantiated can be programmable
# and based on the number of PEs
#
# Parameters:
#   pe - Number of processing elements as the number of memories equals PE
#
# Returns:
#
# None
def gen_mvau_weight_mem_merged(pe):
    fname = "mvau_weight_mem_merged.sv"
    mvau_wmem = open(fname,"wt")
    mvau_wmem.write("/*\n")
    mvau_wmem.write(" * Module: MVAU Weights Top Level file (mvau_weight_mem_merged.sv)\n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>\n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * This file lists an RTL implementation of the matrix-vector activation unit\n")
    mvau_wmem.write(" * It is part of the Xilinx FINN open source framework for implementing\n")
    mvau_wmem.write(" * quantized neural networks on FPGAs\n")
    mvau_wmem.write(" *\n")
    mvau_wmem.write(" * This material is based upon work supported, in part, by Science Foundation\n")
    mvau_wmem.write(" * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the \n")
    mvau_wmem.write(" * European Union's Horizon 2020 research and innovation programme under the \n")
    mvau_wmem.write(" * Marie Sklodowska-Curie grant agreement Grant No.754489. \n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Inputs:\n")
    mvau_wmem.write(" * aclk    - Main clock\n")
    mvau_wmem.write(" * [WMEM_ADDR_BW-1:0] wmem_addr - Weight memory address\n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Outputs:\n")
    mvau_wmem.write(" * [SIMD*TW-1:0]               - Weight memory output, word lenght SIMDxTW\n")
    mvau_wmem.write(" \n")
    mvau_wmem.write(" * Parameters:\n")
    mvau_wmem.write(" * WMEM_ADDR_BW - Word length of the address for the weight memories (log2(WMEM_DEPTH))\n")
    mvau_wmem.write(" * */\n")
    mvau_wmem.write(" \n")
    mvau_wmem.write("`timescale 1ns/1ns\n")
    mvau_wmem.write(" \n")
    mvau_wmem.write("module mvau_weight_mem_merged #(\n")
    mvau_wmem.write("    parameter int SIMD=2,\n")
    mvau_wmem.write("    parameter int PE=2,\n")
    mvau_wmem.write("    parameter int TW=1,\n")
    mvau_wmem.write("    parameter int WMEM_DEPTH=4,\n")
    mvau_wmem.write("    parameter int WMEM_ADDR_BW=4)\n")
    mvau_wmem.write("   (    \n")
    mvau_wmem.write("        input logic 		       aclk, // main clock\n")
    mvau_wmem.write("        input logic [WMEM_ADDR_BW-1:0] wmem_addr,\n")
    mvau_wmem.write("        output logic [(SIMD*TW)-1:0]   wmem_out [0:PE-1]);\n")
    mvau_wmem.write("   \n")
    for p in np.arange(pe):
        mvau_wmem.write("   mvau_weight_mem%d #(\n" % p)
        mvau_wmem.write("      .SIMD(SIMD),\n")
        mvau_wmem.write("      .TW(TW),\n")
        mvau_wmem.write("      .WMEM_DEPTH(WMEM_DEPTH),\n")
        mvau_wmem.write("      .WMEM_ADDR_BW(WMEM_ADDR_BW))\n")
        mvau_wmem.write("   mvau_weigt_mem%d_inst(\n" % p)
        mvau_wmem.write("      		       .aclk,\n")
        mvau_wmem.write("      		       .wmem_addr,\n")
        mvau_wmem.write("      		       .wmem_out(wmem_out[%d])\n" % p)
        mvau_wmem.write("      		       );   \n")
    mvau_wmem.write("endmodule // mvau_weight_mem_merged\n")
        
    mvau_wmem.close()

# Function: parser
# This function defines an ArgumentParser object for command line arguments
#
# Returns:
# Parser object (parser)
def parser():
    parser = argparse.ArgumentParser(description='Python data script for generating MVAU Weight memory top level SV file')
    parser.add_argument('-p','--pe',default=2,type=int,
			help="Filter dimension")
    return parser

# Function: __main__
# Entry point of the file, retrieves the command line arguments and
# calls the gen_mvau_weight_mem_merged function with the required arguments
if __name__ == "__main__":

    ### REading the argument list
    args = parser().parse_args()

    ### Generating the weight file
    gen_mvau_weight_mem_merged(args.pe)
    sys.exit(0)
        

