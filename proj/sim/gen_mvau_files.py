 #
 # Module: MVAU Project File Generator (gen_mvau_files.py)
 # 
 # Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 # 
 # This file generates a .prj file which lists all verilog files to be compiled
 # when running simulation. A .prj file is generated because the number of memories
 # change depending on the number of PEs. The .prj file is used by 'xelab' command
 # which elaborates the design
 #
 # This material is based upon work supported, in part, by Science Foundation
 # Ireland, www.sfi.ie under Grant No. 13/RC/2094_P2 and, in part, by the 
 # European Union's Horizon 2020 research and innovation programme under the 
 # Marie Sklodowska-Curie grant agreement Grant No.754489.
 
import numpy as np
import sys
import argparse

# Function: gen_mvau_files
# This function generates the file by using a series of write commands
#
# Parameter:
# pe - Number of processing elements
def gen_mvau_files(pe):
    fname = "mvau_files.prj"
    mvau_files = open(fname,"wt")

    mvau_files.write("sv work mvau_tb_v1.sv\n")
    mvau_files.write("sv work mvau_tb_v3.sv\n")
    mvau_files.write("sv work mvau_tb_v4.sv\n")
    mvau_files.write("sv work mvau_tb_v5.sv\n")
    mvau_files.write("verilog work ../src/mvau_top/mvau_top.v\n")
    mvau_files.write("sv work ../src/mvau_top/mvau.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_control_block.sv\n")
    for p in np.arange(pe):
        mvau_files.write("sv work ../src/mvau_top/mvau_weight_mem%d.sv\n" % p)
    mvau_files.write("sv work ../src/mvau_top/mvau_weight_mem_merged.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvau_stream.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvau_inp_buffer.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvau_stream_control_block.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_simd_std.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_simd_binary.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_simd_xnor.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_adders.sv\n")
    #mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_binadders.sv\n")    
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_popcount.sv\n")
    mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_acc.sv\n")
    #mvau_files.write("sv work ../src/mvau_top/mvau_stream/mvu_pe/mvu_pe_binacc.sv\n")

    mvau_files.close()

# Function: parser
# This function defines an ArgumentParser object for command line arguments
#
# Returns:
# Parser object (parser)
def parser():
    parser = argparse.ArgumentParser(description='Python data script for generating MVAU project file')
    parser.add_argument('-p','--pe',default=2,type=int,
			help="Filter dimension")
    return parser

# Function: __main__
# Entry point of the file, retrieves the command line arguments and
# calls the gen_mvau_files function with the required arguments
if __name__ == "__main__":

    ### REading the argument list
    args = parser().parse_args()

    ### Generating the weight file
    gen_mvau_files(args.pe)
    sys.exit(0)

