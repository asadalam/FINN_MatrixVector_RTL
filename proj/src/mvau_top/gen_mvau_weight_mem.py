 #
 # Python Script: MVAU Weight Memory Generator File (gen_mvau_weight_mem.py)
 # 
 # Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 # 
 # This file generates a single memory for weight storage. The depth of memory
 # equals (KDim^2 * IFMCh * OFMCh) / (SIMD*PE) and the word length of each data
 # equals SIMD * Weights Precision.
 #
 # This material is based upon work supported, in part, by Science Foundation
 # Ireland, www.sfi.ie under Grant No. 13/RC/2094_P2 and, in part, by the 
 # European Union's Horizon 2020 research and innovation programme under the 
 # Marie Sklodowska-Curie grant agreement Grant No.754489.

import numpy as np
import sys
import argparse

# Function: gen_mvau_weight_mem
# This function takes does the actual generation using a series
# of write commands. The use of Python generator was necessary
# so that file and module names of each memory are unique
#
# Parameters:
#   wmem_id - Unique ID for each memory, passed on from command line when generating memories. All other parameters are part of the SystemVerilog design space
#
# Returns:
#
# None
def gen_mvau_weight_mem(wmem_id):
    fname = "mvau_weight_mem"+str(wmem_id)+".sv"
    mvau_wmem = open(fname,"wt")

    mvau_wmem.write("/*\n")
    mvau_wmem.write(" * Module: MVAU Weight Memory (mvau_weight_mem.sv)\n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>\n")
    mvau_wmem.write(" *\n")
    mvau_wmem.write(" * This file lists an RTL implementation of the \n")
    mvau_wmem.write(" * weight memory. The depth of each weight memory is given by\n")
    mvau_wmem.write(" * (KDim^2 * IFMCh * OFMCh)/(SIMD * PE). The word length of each word is\n")
    mvau_wmem.write(" * SIMD*TW\n")
    mvau_wmem.write(" *  \n")
    mvau_wmem.write(" * It is part of the Xilinx FINN open source framework for implementing\n")
    mvau_wmem.write(" * quantized neural networks on FPGAs\n")
    mvau_wmem.write(" *\n")
    mvau_wmem.write(" * This material is based upon work supported, in part, by Science Foundation\n")
    mvau_wmem.write(" * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the \n")
    mvau_wmem.write(" * European Union's Horizon 2020 research and innovation programme under the \n")
    mvau_wmem.write(" * Marie Sklodowska-Curie grant agreement Grant No.754489. \n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Parameters:\n")
    mvau_wmem.write(" * WMEM_ADDR_BW                - The word length of the address for the weight memory\n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Inputs:\n")
    mvau_wmem.write(" * aclk - Main clock\n")
    mvau_wmem.write(" * [WMEM_ADDR_BW-1:0] wmem_addr - Weight memory address\n")
    mvau_wmem.write(" * \n")
    mvau_wmem.write(" * Outputs:\n")
    mvau_wmem.write(" * [SIMD*TW-1:0]               - Weight memory output, word lenght SIMDxTW\n")
    mvau_wmem.write(" * */\n")
    mvau_wmem.write(" \n")
    mvau_wmem.write("`timescale 1ns/1ns\n")
    mvau_wmem.write(" \n")
    mvau_wmem.write("module mvau_weight_mem%d #(\n" % wmem_id)
    mvau_wmem.write("    parameter int SIMD=2,\n")
    mvau_wmem.write("    parameter int TW=1,\n")
    mvau_wmem.write("    parameter int WMEM_DEPTH=4,\n")
    mvau_wmem.write("    parameter int WMEM_ADDR_BW=4)\n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("   (\n")
    mvau_wmem.write("    input 			   aclk,\n")
    mvau_wmem.write("    input logic [WMEM_ADDR_BW-1:0] wmem_addr,\n")
    mvau_wmem.write("    output logic [(SIMD*TW)-1:0]   wmem_out);\n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("   /**\n")
    mvau_wmem.write("    * Internal Signals \n")
    mvau_wmem.write("    * */\n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("   // Signal: weight_mem\n")
    mvau_wmem.write("   // This signal defines the memory itself\n")
    mvau_wmem.write("   (* ram_style = \"auto\" *) logic [SIMD*TW-1:0] 		weight_mem [0:WMEM_DEPTH-1];\n")
    mvau_wmem.write("   initial\n")
    mvau_wmem.write("     $readmemh(\"weight_mem%d.mem\", weight_mem);\n" % wmem_id)
    mvau_wmem.write("   \n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("   // Always_FF: WMEM_READ_OUT\n")
    mvau_wmem.write("   // Sequential 'always' block to read from\n")
    mvau_wmem.write("   // weight memory\n")
    mvau_wmem.write("   always_ff @(posedge aclk) begin: WMEM_READ_OUT\n")
    mvau_wmem.write("      wmem_out = weight_mem[wmem_addr];\n")
    mvau_wmem.write("   end\n")
    mvau_wmem.write("   \n")
    mvau_wmem.write("endmodule // mvau_weight_mem\n")

    mvau_wmem.close()

# Function: parser
# This function defines an ArgumentParser object for command line arguments
#
# Returns:
# Parser object (parser)
def parser():
    parser = argparse.ArgumentParser(description='Python data script for generating MVAU Weight memory SV file')
    parser.add_argument('-w','--wmem_id',default=0,type=int,
			help="Filter dimension")
    return parser

# Function: __main__
# Entry point of the file, retrieves the command line arguments and
# calls the gen_mvau_weight_mem function with the required arguments
if __name__ == "__main__":

    ### REading the argument list
    args = parser().parse_args()

    ### Generating the weight file
    gen_mvau_weight_mem(args.wmem_id)
    sys.exit(0)
   
