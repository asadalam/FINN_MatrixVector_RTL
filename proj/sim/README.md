# Project Simulation Folder
This folder contains all the simulation files, for e.g., test benches,
scripts and wave files

Details of the files are as follows:

### Package File Generator: gen_mvau_defn.sv
A package file generator that defines all parameters used by all the test benches. It is called by saying:

```
python gen_mvau_top.py --kdim <k> --inp_wl <i> --inp_bin <ib> --ifm_ch <ifm> --ofm_ch <ofm> --ifm_dim <ifmd> --wgt_wl <w> --wgt_bin <wb> --out_wl <o> --simd <s> --pe <p>
```
where
* `kdim`: Kernel dimension
* `inp_wl`: Input word length
* `inp_bin`: '1' if input is binary, '0' if not
* `ifm_ch`: Number of input feature map channels
* `ofm_ch`: Number of output feature map channels
* `ifm_dim`: Input feature map dimension
* `wgt_wl`: Weight precision
* `wgt_bin`: '1' if weights are binary, '0' if not
* `out_wl`: Output word length
* `simd`: SIMD factor
* `pe`: PE factor
The file generated is named `mvau_defn.sv`.


## MVAU Batch Simulation Files

### MVAU Batch Testbench (v1): mvau_tb_v1.sv
In this version of test bench, the input activation activation matrix is
being generated using SystemVerilog's $random function. The weight memory
file is generated by a python script in $FINN_HLS_ROOT

The test bench performs a behavorial implementation of the matrix-matrix
multiplication using for-loops. The inputs generated are sent to the 
DUT (mvau.sv). Only slices of the input activation vector is sent over at a time

Finally, the output of the DUT and behavorial model are compared for error
checking

To run the sumulation, we use a shell script and we say the following on a Linux terminal 
(make sure the shell script is executable by saying `chmod a+x mvau_test_v1.sh):
```
./mvau_test_v1.sh
```
The bash script `mvau_test_v1.sh` is a standalone simulation script that generates all necessary
design files, weights and executes the simulation. It accepts the following inputs:
* `gui/ng`: To run a graphical or terminal only simulation
* `ifm_ch`: Number of input feature map channels
* `ifm_dim`: Input feature map dimension
* `ofm_ch`: Number of output feature map channels
* `kdim`: Kernel dimension
* `inp_wl`: Input word length
* `inp_bin`: '1' if input is binary, '0' if not
* `wgt_wl`: Weight precision
* `wgt_bin`: '1' if weights are binary, '0' if not
* `out_wl`: Output word length
* `simd`: SIMD factor
* `pe`: PE factor
* `mmv`: Number of images

To run a graphical simulation, the first argument must be `gui`. Any other argument will run a non-graphical simulation
in the Linux terminal.

Each input argument has a default value.

### MVAU Batch Testbench (v3): mvau_tb_v3.sv

This version of test bech is used together with the HLS flow and uses data
dumped by HLS as golden data. To run it independently, say the following on a Linux terminal
(make sure the shell script is executable):
```
./mvau_test_v3.sh
```
Typically, this test bench is run as part of the regression suite but can be run independently 
after an initial execution of the test suite to debug design issues. An optional argument of `gui` can
be given to run a graphical simulation.

### MVAU Batch Testbench (v4): mvau_tb_v4.sv

This test bench is similar to v3 in terms of using HLS data as golden input and output. It differs
in the way input is generated. Instead of generating one set of inputs in a continuous manner, it
randomly stops generating input for a few cycles and also between consecutive inputs. This is to test
a real world scenario where the preceding logic may not produce an output at all times.

This test bench is executed using the script `mvau_test_v4.sh` and can be given an optional input argument 
`gui` to run a graphical simulation. The number of cycles for which the simulation stops is random and a number
of simulations can be run to verify for different delay cycles by saying:
```
for i in {0..10}
  do
    ./mvau_test_v4.sh
   done
```

### MVAU Batch Testbench (v5): mvau_tb_v5.sv

This test bench is similar to v3 in terms of using HLS data as golden input and output. It differs
in the way the test bench responds with its ready signal (as part of the AXI stream protocol). Random delays
are inserted to test for different scenarios.

This test bench is executed using the script `mvau_test_v5.sh` and can be given an optional input argment `gui`
to run a graphical simulation which helps in debugging.

### Simulation files generator: gen_mvau_files.prj
This python script generates a file that contains all files needed for simulation. 
This file is used by the Xilinx's Vivado's 'xelab' command which creates a
simulation snapshot for 'xsim' to use

### XSIM script: mvau_xsim.tcl
This script can be used to set instructions to control the behavior of xsim.
Currently only has one command which directs xsim to run simulation till end and then exit

### XSIM Gui script: mvau_xsim_gui.tcl
Essentially the same script as `mvau_xsim.tcl`. The only difference is that it does not have any
exit command at the end. This script is called during graphical simulation for debugging

## MVAU Stream Simulation Files

### MVAU Stream Testbench (v1): mvau_stream_tb_v1.sv

In this version of test bench, all input data are being generated using
SystemVerilog's $random function. This includes the weight matrix and
the input activation matrix.

The test bench performs a behavorial implementation of the matrix-matrix
multiplication using for-loops. The parameters for the tests and design are
defined in ../src/mvau_defn.sv. The test has been successfull for various values
of IFMCh, OFMCh, KDim, IFMDim, OFMDim, SIMD, PE, TSrcI, TDstI and TW such that
all types of SIMDs and adder units are utilized.

The inputs generated are sent to the DUT (mvau_stream.sv). The weight matrix and
the input activation matrix is sent as tiles and slices. The weight tile
measures PExSIMD where word length of each element is TW. The input activation
slice measures SIMD where the word length of each element is TSrcI

Finally, the output of the DUT and behavorial model are compared for error
checking. The testbench is running successfully.

To run the sumulation, we use a shell script and we say the following on a Linux terminal
(make sure the shell script is executable):

- ./mvau_stream_test_v1.sh

### MVAU Stream Testbench (v3): mvau_stream_tb_v3.sv

This version of test bech is used together with the HLS flow and uses data
dumped by HLS as golden data. To run it independently, say the following on a Linux terminal
(make sure the shell script is executable):

- ./mvau_stream_test_v3.sh

### MVAU Stream Simulation files: mvau_stream_files.prj
This file contains all files needed for simulation. Can be edited in future
for adding/removing more files (for e.g., other versions of test benches).
This file is used by the Xilinx's Vivado's 'xelab' command which creates a
simulation snapshot for 'xsim' to use

### MVAU Stream Simulation script: mvau_stream_test_v<1/2/3>.sh
This file performs simulation using two commands. The 'xelab' command creates
a simulation snapshot while 'xsim' performs the simulation using the Vivado
graphical simulator. It also performs error checking and exits from the script
