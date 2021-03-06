# Project Source Folder
This folder contains all the design source files written in System Verilog. The hierarchy is as follows:

## Top level module: mvau.sv
This is the top level design unit which instantiates a number of blocks. The main block is the matrix vector computation unit which multiplies
the input activation and weight matrix. The multiplication is carried out in steps, with each step multiplying a weight tile of dimension SIMDxPE, where each tile has a word length of TWeightI, with a slice of input activation vector of length SIMD. The top level file generates the required control signals to generate the weight tile and input activation vector slice.

It also instantiates the threshold based activation unit.
### Matrix vector computation unit: mvu_comp.sv  
  This unit is the main computation unit performing multiply accumulate of a tile of weight and a slice of input activation unit. It uses PE numbers of processing elements. Each processing element implements the dot product of its corresponding row of the weight tile with the input activation vector slice
#### Processing element design unit: mvu_pe.sv
The processing elements consists of a number of SIMD blocks which perform multiplication between a single weight and input activation. There are three types of SIMD blocks based on the input word length of weights and input activations but only one is implemented using generate statements. 

The output of SIMD is connected to an adder tree which if both the inputs are 1-bit reduces to a popcount (counting number of '1's in the SIMD's output
##### SIMD design unit: mvu_pe_simd_\<type\>.sv
The three different SIMD blocks are
- mvu_pe_simd_std.sv: Implements a 2's complement multiplication
- mvu_pe_simd_binary.sv: If one of the two inputs is 1-bit, a '0' is interpreted as -1 and '1' is interpreted as +1, meaning the output will either be a copy of the other input or a 2's complement of it
- mvu_pe_simd_xnor.sv: If both inputs are 1-bit, the output is an XNOR of the two inputs. This implements an XNOR network

##### Adder Tree: mvu_pe_\<adders/popcount\>.sv
The output of the SIMD blocks are added together either using an adder tree or a popcount (when both weights and input activation are 1-bit). A simple for-loop based implementation is selection (at the moment) for simplicity, so both design files are identical

##### Accumulator: mvu_pe_acc.sv
A simple accumulator
		 
### Threshold based Activation Unit: mvau_act_comp.sv

A package file defines constants used in various design files (mvau_defn.pkg).
