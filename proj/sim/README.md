# Project Simulation Folder
This folder contains all the simulation files, for e.g., test benches,
scripts and wave files

Details of the files are as follows:

## Test bench (v1): mvau_tb.sv
In this version of test bench, all input data are being generated using
SystemVerilog's $random function. This includes the weight matrix and
the input activation matrix.

The test bench performs a behavorial implementation of the matrix-matrix
multiplication using for-loops

The inputs generated are sent to the DUT (mvau.sv). The whole weight matrix
is sent at once while only slices of the input activation vector is sent over.

Finally, the output of the DUT and behavorial model are compared for error
checking

To run the sumulation, say the following on a Linux terminal:

- vivado -mode batch -source mvau_vivado.tcl

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