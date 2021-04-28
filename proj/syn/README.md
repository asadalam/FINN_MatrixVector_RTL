# Project Synthesis Folder
This folder contains all the synthesis scripts and constraint files

Details of the files are as follows:

## MVAU Batch Synthesis Script: mvau_synth.tcl
A TCL script for MVAU batch synthesis. To execute, say the following on a terminal:

- vivado -mode batch -source mvau_synth.tcl

This file is also called by the overall testing scripts located in XILINX_MVAU_ROOT/proj/RegressionTests


## MVAU Stream Synthesis Script: mvau_stream_synth.tcl
A TCL script for MVAU stream synthesis. To execute, say the following on a terminal:

- vivado -mode batch -source mvau_stream_synth.tcl

This file is also called by the overall testing scripts located in XILINX_MVAU_ROOT/proj/RegressionTests

## Constraints File: mvau.xdc/mvau_stream.xdc
A simple constraint file defining a clock constraint

