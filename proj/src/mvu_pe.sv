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

`timescale 1ns/1ns
`include "mvau_defn.sv"
module mvu_pe #( // Parameters aka generics in VHDL
		 parameter int SF_T=2,
		 parameter int SF=4
		 )
   (input logic rst_n,
    input logic 		   clk,
    input logic 		   sf_clr,
    input logic [TI-1:0] 	   in_act, // Input activation (packed array): TSrcI*PE
    input logic [0:SIMD-1][TW-1:0] in_wgt , // Input weights (packed array): TWeightI*SIMD
    output logic [TDstI-1:0] 	   out); // Output
   
   /****************************
    * Internal Signals/Wires
    * *************************/
   logic [TDstI-1:0] 	     out_simd [0:SIMD-1]; // SIMD output 
   logic [TDstI-1:0] 	     out_add; // Unregistered output from the adders
   logic [0:TI-1] 	     in_act_rev;
   logic [0:SIMD-1][TSrcI-1:0] in_act_packed;
   
   /**
    * Re-assigning in_act to in_act_temp
    * and then to a packed array where
    * TI is factored into TSrcI and SIMD
    * */
   assign in_act_rev = in_act;
   generate
      for(genvar act_ind=0;act_ind<SIMD;act_ind=act_ind+1)
	begin: ACT_PARTITIONING
	   assign in_act_packed[act_ind] = in_act_rev[act_ind*TSrcI:act_ind*TSrcI+TSrcI-1];
	end
   endgenerate
      
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
   genvar 		     simd_ind;
   
   if(TSrcI==1) begin: TSrcI_1
      if(TWeightI==1) begin: TWeightI_1
	 for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	   begin: SIMD_GEN
	      mvu_pe_simd_xnor 
			mvu_simd_inst(
				      .rst_n,
				      .clk,
				      .in_act(in_act_packed[simd_ind]), 
				      .in_wgt(in_wgt[simd_ind]),
				      .out(out_simd[simd_ind])
				      );
	   end // block: SIMD_GEN
      end // block: TWeightI_1		   
      else if(TWeightI > 1) begin: TWeightI_gt1
	 for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	   begin: SIMD_GEN
	      mvu_pe_simd_binary 
			mvu_simd_inst(
				      .rst_n,
				      .clk,
				      .in_act(in_act_packed[simd_ind]),
				      .in_wgt(in_wgt[simd_ind]),
				      .out(out_simd[simd_ind])
				      );
	   end // block: SIMD_GEN
      end // block: TWeightI_gt1
   end // block: TSrcI_1
   else if(TWeightI==1) begin: TWeightI_1_2
      if(TSrcI > 1) begin: TSrcI_gt1
	 for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	   begin: SIMD_GEN
	      mvu_pe_simd_binary 
			mvu_simd_inst(
				      .rst_n,
				      .clk,
				      .in_act(in_act_packed[simd_ind]),
				      .in_wgt(in_wgt[simd_ind]),
				      .out(out_simd[simd_ind])
				      );
	   end // block: SIMD_GEN
      end // block: TSrcI_gt1
   end // block: TWeightI_1_2
   else begin: TSrcI_TWeight_gt1
      for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	begin: SIMD_GEN
	   mvu_pe_simd_std 
		     mvu_pe_simd_inst(
				      .rst_n,
				      .clk,
				      .in_act(in_act_packed[simd_ind]),
				      .in_wgt(in_wgt[simd_ind]),
				      .out(out_simd[simd_ind])
				      );
	end // block: SIMD_GEN
   end // block: TSrcI_TWeight_gt1

   /************************************
    * Adders for summing SIMD output
    * *********************************/
   if(TSrcI==1) begin: TSrcI_1_Add
      if(TDstI==1) begin: TDestI_1_Add // Popcount based addition
	 mvu_pe_popcount
	   mvu_pe_popcount_inst (
				 .in_simd(out_simd),
				 .out_add(out_add)
				 );
      end // block: TDestI_1_Add
   end // block: TSrcI_1_Add
   else begin: All_Add // Normal addition
      mvu_pe_adders 
	mvu_pe_adders_ins (
			   .in_simd(out_simd),
			   .out_add(out_add)
			   );
   end // block: All_Add
   
   /**
    * Accumulator
    * */
   mvu_pe_acc #(.SF_T(SF_T),
		.SF(SF))
   mvu_pe_acc_inst (
		    .rst_n,
		    .clk,
		    .sf_clr,
		    .in_acc(out_add),
		    .out_acc(out));
   
endmodule // mvu_pe


