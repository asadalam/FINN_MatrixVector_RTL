/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvu_pe_popcount.sv
 *
 * This file lists an RTL implementation of an adder unit
 * which adds the output of the SIMD units based on counting '1's
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
 * The basic word lenght is '1' bit
 * So implemented as a popcount
 * ********************************************/

// Including the package definition file
`include "mvau_defn.pkg" // compile the package file

module mvu_pe_popcount #(parameter int TI=2,
		       parameter int TO=2,
		       parameter int SIMD=2)   
   (input logic [TI-1:0] in_simd [0:SIMD-1],
    output logic [TO-1:0] out_add);

    /****************************
    * Internal Signals/Wires
    * *************************/
   always_comb
     begin: adders
	// Initializing the output with a value
	out_add = TO'(in_simd[0]); // Range casting in_simd to word length of out_add
	for(int i = 1; i < SIMD; i++) begin
	   out_add = out_add + TO'(in_simd[i]); // Range casting in_simd to word length of out_add
	end
     end
   
endmodule // mvu_pe_adders

