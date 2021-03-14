# Project Simulation Folder
This folder contains all the simulation files, for e.g., test benches,
scripts and wave files

Details of the files are as follows:

## MVAU Stream Testbench (v1): mvau_stream_tb_v1.sv

In this version of test bench, all input data are being generated using
SystemVerilog's $random function. This includes the weight matrix and
the input activation matrix.

The test bench performs a behavorial implementation of the matrix-matrix
multiplication using for-loops. The parameters for the tests and design are
defined in ../src/mvau_defn.sv. The test has been successfull for various values
of IFMCh, OFMCh, KDim, IFMDim, OFMDim, SIMD, PE, TSrcI, TDstI and TW such that
all types of SIMDs and adder units are utilized.

The inputs generated are sent to the DUT (mvau.sv). The weight matrix and
the input activation matrix is sent as tiles and slices. The weight tile
measures PExSIMD where word length of each element is TW. The input activation
slice measures SIMD where the word length of each element is TSrcI

Finally, the output of the DUT and behavorial model are compared for error
checking. The testbench is running successfully.

To run the sumulation, say the following on a Linux terminal:

- vivado -mode batch -source mvau_stream_vivado.tcl

### MVAU Stream Simulation files: mvau_stream_files.prj
This file contains all files needed for simulation. Can be edited in future
for adding/removing more files (for e.g., other versions of test benches).
This file is used by the Xilinx's Vivado's 'xelab' command which creates a
simulation snapshot for 'xsim' to use

### MVAU Stream Simulation script: mvau_stream_vivado.tcl
This file performs simulation using two commands. The 'xelab' command creates
a simulation snapshot while 'xsim' performs the simulation using the Vivado
graphical simulator.

### XSIM script: mvau_xsim.tcl
This script can be used to set instructions to control the behavior of xsim.
Currently only has one command which directs xsim to run simulation till end

## MVAU Batch Testbench (v1): mvau_tb_v1.sv
In this version of test bench, the input activation activation matrix is
being generated using SystemVerilog's $random function.

The test bench performs a behavorial implementation of the matrix-matrix
multiplication using for-loops

The inputs generated are sent to the DUT (mvau.sv). Only slices of the input 
activation vector is sent over at a time

Finally, the output of the DUT and behavorial model are compared for error
checking

To run the sumulation, say the following on a Linux terminal:

- vivado -mode batch -source mvau_vivado.tcl

However, this test bench is not functional at the moment.

### Simulation files: mvau_files.prj
This file contains all files needed for simulation. Can be edited in future
for adding/removing more files (for e.g., other versions of test benches).
This file is used by the Xilinx's Vivado's 'xelab' command which creates a
simulation snapshot for 'xsim' to use

### Simulation script: mvau_vivado.tcl
This file performs simulation using two commands. The 'xelab' command creates
a simulation snapshot while 'xsim' performs the simulation using the Vivado
graphical simulator.

### XSIM script: mvau_xsim.tcl
This script can be used to set instructions to control the behavior of xsim.
Currently only has one command which directs xsim to run simulation till end
