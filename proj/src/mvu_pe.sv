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
		 parameter int SIMD=2,
		 parameter int PE=2,
		 parameter int TSrcI=1,
		 parameter int TDstI=1,
		 parameter int TWeightI=1,
		 parameter int TI=1,
		 parameter int TW=1		 
		)
   (input logic rst_n,
    input logic 	  clk,
    input logic [TI-1:0]  in_act, // Input activation (packed array): TSrcI*PE
    input logic [TW-1:0]  in_wgt, // Input weights (packed array): TWeightI*SIMD
    output logic [TDstI-1:0] out); // Output
   
   /****************************
    * Internal Signals/Wires
    * *************************/
   logic [TDstI-1:0] 	  out_simd [0:SIMD-1]; // SIMD output 
   logic [TDstI-1:0] 	  out_add; // Unregistered output from the adders   

   /*****************************
    * Component Instantiation
    * **************************/

   /****************************
    * A number of SIMD units using generate statement
    * For each SIMD, a part of input activation and weights connected.
    * Part selection controlled by the generae variable and
    * TSrcI for input activation and TWeightI for weights. 
    * These two parameters define the word length of input activation and weight
    * *************************/
   genvar 		  simd_ind;
   
   if(TSrcI==1) begin: TSrcI_1
     if(TWeightI==1) begin: TWeightI_1
       for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	 begin: SIMD_GEN
	    generate
	       mvu_pe_simd_xnor #(
				  .TI(TSrcI),
				  .TW(TWeightI),
				  .TO(TDstI)
				  )
	       mvu_simd_inst(
			     .rst,
			     .clk,
			     .in_act(in_act[simd_ind*TSrcI+TSrcI-1:simd_ind*TSrcI]), 
			     .in_wgt(in_wgt[simd_ind*TWeightI+TWeightI-1:simd_ind*TWeightI]),
			     .out(out_simd[simd_ind])
			     );
	    end // block: SIMD_GEN
     end // block: TWeightI_1		   
     else if(TWeight > 1) begin: TWeightI_gt1
       for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	 begin: SIMD_GEN
	    generate
	       mvu_pe_simd_binary #(
				    .TI(TSrcI),
				    .TW(TWeightI),
				    .TO(TDstI)
				    )
	       mvu_simd_inst(
			     .rst,
			     .clk,
			     .in_act(in_act[simd_ind*TSrcI+TSrcI-1:simd_ind*TSrcI]),
			     .in_wgt(in_wgt[simd_ind*TWeightI+TWeightI-1:simd_ind*TWeightI]),
			     .out(out_simd[simd_ind])
			     );
	    end // block: SIMD_GEN
     end // block: TWeightI_gt1
   end // block: TSrcI_1
   else if(TWeightI==1) begin: TWeightI_1_2
      if(TSrcI > 1) begin: TSrcI_gt1
	 for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	   begin: SIMD_GEN
	      generate
		 mvu_pe_simd_binary #(
				      .TI(TSrcI),
				      .TW(TWeightI),
				      .TO(TDstI)
				      )
		 mvu_simd_inst(
			       .rst,
			       .clk,
			       .in_act(in_act[simd_ind*TSrcI+TSrcI-1:simd_ind*TSrcI]),
			       .in_wgt(in_wgt[simd_ind*TWeightI+TWeightI-1:simd_ind*TWeightI]),
			       .out(out_simd[simd_ind])
			       );
	      end // block: SIMD_GEN
      end // block: TSrcI_gt1
   end // block: TWeightI_1_2
   else begin: TSrcI_TWeight_gt1
      for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	begin: SIMD_GEN
	      generate
		 mvu_simd #(
			    .TI(TSrcI),
			    .TW(TWeightI),
			    .TO(TDstI)
			    )
		 mvu_simd_inst(
			       .rst,
			       .clk,
			       .in_act(in_act[simd_ind*TSrcI+TSrcI-1:simd_ind*TSrcI]),
			       .in_wgt(in_wgt[simd_ind*TWeightI+TWeightI-1:simd_ind*TWeightI]),
			       .out(out_simd[simd_ind])
			       );
	      end // block: SIMD_GEN
   end // block: TSrcI_TWeight_gt1

   /************************************
    * Adders for summing SIMD output
    * *********************************/
   if(TSrcI==1) begin: TSrcI_1_Add
      if(TDstI==1) begin: TDestI_1_Add // Popcount based addition
	 mvu_pe_popcount #(
			   .TI(TDstI),
			   .TO(TDstI),
			   .SIMD(SIMD)
			   )
	 (
	  .in_simd(out_simd),
	  .out_add(out_add)
	  );
      end // block: TDestI_1_Add
   end // block: TSrcI_1_Add
      else begin: All_Add // Normal addition
	 mvu_pe_adders #(
			 .TI(TDstI),
			 .TO(TDstI),
			 .SIMD(SIMD)
			 )
	 (
	  .in_simd(out_simd),
	  .out_add(out_add)
	  );
      end // block: All_Add

   /**
    * Accumulator
    * */

   always_ff @(posedge clk) begin: ACC_OUT
      if(!rst_n)
	out <= 'd0;
      else
	out <= out+out_add;
   end
   
endmodule // mvu_pe

   
