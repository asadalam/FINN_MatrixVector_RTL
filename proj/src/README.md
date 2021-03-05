This folder contains all the design source files written in System Verilog. The hierarchy is as follows:

Top level module -->
		     mvau.sv

                     --> mvu_comp.sv
		     
                         --> mvu_pe[0:PE-1]
			 
                         --> mvu_pe_simd[std,binary,xnor]
			 
                         --> mvu_pe_adders[tree,popcount]
			 
                     --> mvu_act_comp.sv

A package file defines constants used in various design files.
