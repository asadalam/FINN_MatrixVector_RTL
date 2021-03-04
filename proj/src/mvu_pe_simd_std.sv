/*******************************************************************************
 *
 *  Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 *  \file mvu_pe_simd_std.sv
 *
 * This file lists an RTL implementation of a SIMD unit based on standard
 * multiplication. It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/


/*************************************************
 * SIMD unit
 * Performs multiplication of input activation and weight
 * Word length >= 2
 * **********************************************/

// Including the package definition file
`include "mvau_defn.pkg" // compile the package file

module mvu_pe_simd_std #(parameter int TI=1,
		  parameter int TW=1,
		  parameter int TO=1)
   ( input logic rst,
     input logic 	   clk,
     input logic [TI-1:0]  in_act, //Input activation
     input logic [TW-1:0]  in_wgt, //Input weight
     output logic [TO-1:0] out); //Output   

   /***************************************
    * SIMD only performs multiplication
    * ************************************/
   always_ff @(posedge clk) begin: SIMD_MUL
      if(!rst)
	out <= 'd0;
      else
	out <= in_act*in_wgt;      
   end

endmodule // mvu_simd

