/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvu_pe_adders.sv
 *
 * This file lists an RTL implementation of an adder unit
 * which adds the output of the SIMD units
 * It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/

/**********************************************
 * Unit to add SIMD outputs
 * Starting off as a simple adder tree
 * ********************************************/

`timescale 1ns/1ns
`include "mvau_defn.sv"

/**
 * The interface is as follows:
 * *******
 * Inputs:
 * *******
 * [TDstI-1:0] in_simd [0:SIMD-1] : Input from the SIMD unit, word length TDstI
 * ********
 * Outputs:
 * ********
 * [TDstI-1:0] out_add            : Output from adder, word length TDstI
 * **/

module mvu_pe_adders 
  (input logic [TDstI-1:0] in_simd [0:SIMD-1],
   output logic [TDstI-1:0] out_add);

    /****************************
    * Internal Signals/Wires
    * *************************/
   always_comb
     begin: adders
	// Initializing the output with a value
	out_add = in_simd[0]; // Picking up the first element to initialize
	for(int i = 1; i < SIMD; i++) begin
	   out_add = out_add + in_simd[i]; // always_comb makes sure no latches are inferred
	end
     end
   
endmodule // mvu_pe_adders
