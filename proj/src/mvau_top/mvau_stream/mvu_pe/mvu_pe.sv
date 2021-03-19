/*
 * Module: MVU Processing Element (mvu_pe.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists an RTL implementation of the processing element unit. 
 * It instantiates a number of SIMD units and an adder unit which takes in the SIMD
 * outputs. It is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * rst_n                     - Active low, synchronous reset
 * clk                       - Main clock
 * sf_clr                    - Control signal to reset the accumulator
 * [TI-1:0] in_act           - Input activation stream, word length TI=TSrcI*SIMD
 * [0:SIMD-1][TW-1:0] in_wgt - Input weight stream for each PE
 * 
 * Outputs:
 * [TDstI-1:0] out           - Output stream, word length TDstI
 * */

 
`timescale 1ns/1ns
`include "mvau_defn.sv"


module mvu_pe 
  (input logic rst_n,
   input logic 			  clk,
   input logic 			  sf_clr,
   input logic [TI-1:0] 	  in_act, // Input activation (packed array): TSrcI*PE
   input logic [0:SIMD-1][TW-1:0] in_wgt , // Input weights (packed array): TW*SIMD
   output logic [TDstI-1:0] 	  out); // Output
   
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
    * Makes for easy connection to each
    * SIMD unit
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
    * TSrcI for input activation and TW for weights. 
    * These two parameters define the word length of input activation and weight
    * 
    * One of three different SIMD units will be used based on one of the 
    * following cases:
    * 
    * Case 1: 1-bit input activation and 1-bit weight
    * Case 2: 1-bit input activation and multi-bit weight
    * Case 3: Multi-bit weight and 1-bit input activation
    * Case 4: Multi-bit weight and input activation
    * *************************/
   genvar 		     simd_ind;
   
   if(TSrcI==1) begin: TSrcI_1
      if(TW==1) begin: TW_1
	 /**
	  * Case 1: 1-bit input activation and 1-bit weight
	  * Interpretation of values are:
	  * 1'b0 => -1
	  * 1'b1 => +1
	  * 
	  * SIMD implemented as xnor operation because
	  * 
	  * -1 x -1 = +1 maps to 0 xnor 0 = 1
	  * -1 x +1 = -1 maps to 0 xnor 1 = 0
	  * +1 x -1 = -1 maps to 1 xnor 0 = 0
	  * +1 x +1 = +1 maps to 1 xnor 1 = 1
	  * **/
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
      end // block: TW_1		   
      else if(TW > 1) begin: TW_gt1
	 /**
	  * Case 2: 1-bit activation and multi-bit weight
	  * Interpretation of the 1-bit activation is:
	  * 1'b0 => -1
	  * 1'b1 => +1
	  * 
	  * Implementation is simple
	  * output = input weight if in_act == +1 (1'b1)
	  * output = 2's complement of input weight if in_act == -1 (1'b0)
	  * **/
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
      end // block: TW_gt1
   end // block: TSrcI_1
   else if(TW==1) begin: TW_1_2
      if(TSrcI > 1) begin: TSrcI_gt1
	 /**
	  * Case 3: Multi-bit activation and 1-bit weight
	  * Interpretation of the 1-bit weight is:
	  * 1'b0 => -1
	  * 1'b1 => +1
	  * 
	  * Implementation is simple
	  * output = input activation if in_act == +1 (1'b1)
	  * output = 2's complement of input activation if in_act == -1 (1'b0)
	  * **/
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
   end // block: TW_1_2
   else begin: TSrcI_TWeight_gt1
      /**
       * Case 4: Multi-bit input activation and Multi-bit weight
       * 
       * Simple multiplication
       * **/
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
    * 
    * One of two types of adders will be
    * implemented based on the input word
    * length of the activations and weights
    * 
    * Case 1: 1-bit input activation and 1-bit weight
    * Case 2: All of case 2 to 3 for implementing SIMDs
    * *********************************/   
   if(TSrcI==1) begin: TSrcI_1_Add
      /** 
       * Case 1: 1-bit input activation and 1-bit weight
       * Addition reduced to popcount: Count the number of 1's
       * in the combined SIMD output
       * **/
      if(TW==1) begin: TW_1_Add // Popcount based addition
	 mvu_pe_popcount
	   mvu_pe_popcount_inst (
				 .in_simd(out_simd),
				 .out_add(out_add)
				 );	
      end // block: TDestI_1_Add
      else begin: All_Add // Normal addition
	 /**
	  * Case 2: Simple adder tree
	  * **/
	 mvu_pe_adders 
	   mvu_pe_adders_ins (
			      .in_simd(out_simd),
			      .out_add(out_add)
			      );
      end      
   end // block: TSrcI_1_Add
   else begin: All_Add // Normal addition
      /**
       * Case 2: Simple adder tree
       * **/
      mvu_pe_adders 
	mvu_pe_adders_ins (
			   .in_simd(out_simd),
			   .out_add(out_add)
			   );
   end // block: All_Add
   
   /**
    * Accumulator
    * */
   mvu_pe_acc 
     mvu_pe_acc_inst (
		      .rst_n,
		      .clk,
		      .sf_clr,
		      .in_acc(out_add),
		      .out_acc(out));
   
endmodule // mvu_pe


