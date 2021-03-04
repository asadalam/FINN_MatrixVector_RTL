/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvu_simd.sv
 *
 *  This file lists an RTL implementation of a processing element. 
 * It is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/


/*************************************************
 * Top Level for the processing element unit 
 * Instantiates a number of SIMD units
 * and an adder unit which takes in the SIMD
 * outputs
/*************************************************/

// Including the package definition file
`include "mvau_defn.pkg" // compile the package file
//Nest modules
`include mvu_simd.sv
`include mvu_pe_adders.sv

module mvu_pe #( // Parameters aka generics in VHDL
		parameter int INT SIMD=2,
		parameter int PE=2,
		parameter int TI=1,
		parameter int TW=1,
		parameter int TO=2,
		)
   (input logic rst_n,
    input logic 		   clk,
    input logic [TI-1:0] 	   in_act, // Input activation (packed array)
    input logic [TW-1:0][0:SIMD-1] in_wgt, // Input weights (packed array)
    output logic [TO-1:0] 	   out); // Output twice the word length
   
   /****************************
    * Internal Signals/Wires
    * *************************/
   logic [TO-1:-0][0:SIMD-1] 	    out_simd; // SIMD output twice the word length
   logic [TO-1:0] 		    out_add; // Unregistered output from the adders   

   /*****************************
    * Component Instantiation
    * **************************/

   /****************************
    * A number of SIMD units
    * using generate statement
    * *************************/

   generate
      for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	begin: SIMD_GEN
	   mvu_simd #(
		      .TI(TI),
		      .TW(TW),
		      .TO(TO)
		      )
	   mvu_simd_inst(
			 .rst,
			 .clk,
			 .in_act,
			 .in_wgt(in_wgt[simd_ind]),
			 .out(out_simd[simd_ind])
			 );
	end
      endgenerate

   /************************************
    * Adders for summing SIMD output
    * *********************************/

   mvu_pe_adders #(
		   .TI(TO),
		   .TO(TO),
		   .SIMD(SI
		   )
   (
    .in_simd(out_simd),
    .out_add(out_add)
    );

   always_ff @(posedge clk) begin: REG_OUT
      if(!rst_n)
	out <= 'd0;
      else
	out <= out_add;
   end
   
endmodule // mvu_pe

   
