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
 * aresetn                     - Active low, synchronous reset
 * aclk                       - Main clock
 * sf_clr                    - Control signal to reset the accumulator
 * do_mvau_stream   - Controls how long the MVAU operation continues
 *                    Case 1: NF=1 => do_mvau_stream = in_v (input buffer not reused)
 *                    Case 2: NF>1 => do_mvau_stream = in_v | (~(nf_clr&sf_clr)) (input buffer reused)
 * [TI-1:0] in_act           - Input activation stream, word length TI=TSrcI*SIMD
 * [0:SIMD-1][TW-1:0] in_wgt - Input weight stream for each PE
 * 
 * Outputs:
 * out_v                     - Output valid
 * [TDstI-1:0] out           - Output stream, word length TDstI
 * 
 * Parameters:
 * SIMD - SIMD factor
 * PE - PE factor
 * TSrcI - Input word length
 * TSrcI_BIN - Indicates whether input is binary or not
 * TI - Input word length times SIMD
 * TW - Weight word length
 * TW_BIN - Indicates whether the weights are binary or not
 * TDstI - Output word length 
 * TO - Output word length times PE
 * 
 * */
 
`timescale 1ns/1ns

module mvu_pe #(
		parameter int SIMD=2,
		parameter int PE=2,
		parameter int TSrcI=4,
		parameter int TSrcI_BIN=0,
		parameter int TI=8,
		parameter int TW=1,
		parameter int TW_BIN=1,
		parameter int TDstI=4,
		parameter int TO=8)
   
   (input logic aresetn,
    input logic 		   aclk,
    input logic 		   sf_clr,
    input logic 		   do_mvau_stream,
    input logic [TI-1:0] 	   in_act, // Input activation (packed array): TSrcI*PE
    input logic [0:SIMD-1][TW-1:0] in_wgt , // Input weights (packed array): TW*SIMD
    output logic 		   out_v, // Output valid
    output logic [TDstI-1:0] 	   out); // Output
   
   /*
    * Internal Signals/Wires
    * */
   // Signal: out_simd
   // SIMD Output
   logic [TDstI-1:0] 	     out_simd [0:SIMD-1];
   // Signal: out_add
   // Unregistered output from the adders
   logic [TDstI-1:0] 	     out_add;
   // Signal: in_act_rev
   // Copy of input in_act for easy partitioning of input activation
   logic [0:TI-1] 	     in_act_rev;
   // Signal: in_act_packed
   // Packed input activation array, makes for easy access
   logic [0:SIMD-1][TSrcI-1:0] in_act_packed;
   // Signal: do_mvau_stream_reg
   // Registered version of do_mvau_stream
   logic 		       do_mvau_stream_reg;   
         
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

   assign do_mvau_stream_reg = do_mvau_stream;   
      
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

   if(TSrcI_BIN == 1) begin: TSrcI_BIN_1
      if(TSrcI==1) begin: TSrcI1_1
	 if(TW_BIN == 1) begin: TW_BIN_1
	    if(TW==1) begin: TW1_1
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
		    mvu_pe_simd_xnor #(
				       .TSrcI(TSrcI),
				       .TW(TW),
				       .TDstI(TDstI))
		    mvu_simd_inst(
				  .in_act(in_act_packed[simd_ind]), 
				  .in_wgt(in_wgt[simd_ind]),
				  .out(out_simd[simd_ind])
				  );
		 end // block: SIMD_GEN
	    end // block: TW1_1	    
	    else begin: TW_NBIN_1
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
		    mvu_pe_simd_binary #(
					 .TSrcI(TSrcI),
					 .TW(TW),
					 .TDstI(TDstI))
		    mvu_simd_inst(
				  .in_act(in_act_packed[simd_ind]),
				  .in_wgt(in_wgt[simd_ind]),
				  .out(out_simd[simd_ind])
				  );
		 end // block: SIMD_GEN
	    end // block: TW_NBIN_1	    
	 end // block: TW_BIN_1	 
	 else begin: TW_NBIN_2
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
		 mvu_pe_simd_binary #(
				       .TSrcI(TSrcI),
				       .TW(TW),
				       .TDstI(TDstI))
		 mvu_simd_inst(
			       .in_act(in_act_packed[simd_ind]),
			       .in_wgt(in_wgt[simd_ind]),
			       .out(out_simd[simd_ind])
			       );
	      end // block: SIMD_GEN
	 end // block: TW_NBIN_2	 
      end // block: TSrcI1_1      
      else begin: TSrcI_NBIN_1
	 if(TW_BIN == 1) begin: TW_BIN_2
	    if(TW==1) begin: TW1_2
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
		    mvu_pe_simd_binary #(
				       .TSrcI(TSrcI),
				       .TW(TW),
				       .TDstI(TDstI))
		    mvu_simd_inst(
				  .in_act(in_act_packed[simd_ind]),
				  .in_wgt(in_wgt[simd_ind]),
				  .out(out_simd[simd_ind])
				  );
		 end // block: SIMD_GEN
	    end // block: TW1_2	    
	    else begin: TSrcI_TW_NBIN_1
	       /**
		* Case 4: Multi-bit input activation and Multi-bit weight
		* 
		* Simple multiplication
		* **/
	       for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
		 begin: SIMD_GEN
		    mvu_pe_simd_std #(
				      .TSrcI(TSrcI),
				      .TW(TW),
				      .TDstI(TDstI))
		    mvu_pe_simd_inst(
				     .in_act(in_act_packed[simd_ind]),
				     .in_wgt(in_wgt[simd_ind]),
				     .out(out_simd[simd_ind])
				     );
		 end // block: SIMD_GEN
	    end // block: TSrcI_TW_NBIN_1	    
	 end // block: TW_BIN_2	 
	 else begin: TSrcI_TW_NBIN_2
	    /**
	     * Case 4: Multi-bit input activation and Multi-bit weight
	     * 
	     * Simple multiplication
	     * **/
	    for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	      begin: SIMD_GEN
		 mvu_pe_simd_std #(
				   .TSrcI(TSrcI),
				   .TW(TW),
				   .TDstI(TDstI))
		 mvu_pe_simd_inst(
				  .in_act(in_act_packed[simd_ind]),
				  .in_wgt(in_wgt[simd_ind]),
				  .out(out_simd[simd_ind])
				  );
	      end // block: SIMD_GEN
	 end // block: TSrcI_TW_NBIN_2	 
      end // block: TSrcI_NBIN_1      
   end // block: TSrcI_BIN_1   
   else if(TW_BIN==1) begin: TW_BIN_3
      if(TW==1) begin: TW_1_3
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
	      mvu_pe_simd_binary #(
				   .TSrcI(TSrcI),
				   .TW(TW),
				   .TDstI(TDstI))
	      mvu_simd_inst(
			    .in_act(in_act_packed[simd_ind]),
			    .in_wgt(in_wgt[simd_ind]),
			    .out(out_simd[simd_ind])
			    );
	   end // block: SIMD_GEN
      end // block: TW_1_3      
      else begin: TW_NBIN_3
	 /**
	  * Case 4: Multi-bit input activation and Multi-bit weight
	  * 
	  * Simple multiplication
	  * **/
	 for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	   begin: SIMD_GEN
	      mvu_pe_simd_std #(
				.TSrcI(TSrcI),
				.TW(TW),
				.TDstI(TDstI))
	      mvu_pe_simd_inst(
			       .in_act(in_act_packed[simd_ind]),
			       .in_wgt(in_wgt[simd_ind]),
			       .out(out_simd[simd_ind])
			       );
	   end // block: SIMD_GEN
      end // block: TW_NBIN_3
   end // block: TW_BIN_3      
   else begin: TSrcI_TW_NBIN_3
      /**
       * Case 4: Multi-bit input activation and Multi-bit weight
       * 
       * Simple multiplication
       * **/
      for(simd_ind = 0; simd_ind < SIMD; simd_ind = simd_ind+1)
	begin: SIMD_GEN
	   mvu_pe_simd_std #(
			     .TSrcI(TSrcI),
			     .TW(TW),
			     .TDstI(TDstI))
	   mvu_pe_simd_inst(
			    .in_act(in_act_packed[simd_ind]),
			    .in_wgt(in_wgt[simd_ind]),
			    .out(out_simd[simd_ind])
			    );
	end // block: SIMD_GEN
   end // block: TSrcI_TW_NBIN_3

   /************************************
    * Adders for summing SIMD output
    * 
    * One of two types of adders will be
    * implemented based on the input word
    * length of the activations and weights
    * 
    * Case 1: 1-bit input activation and 1-bit weight
    * Case 2: 1-bit input activation
    * Case 3: 1-bit weight
    * Case 4: All of case 2 to 3 for implementing SIMDs
    * *********************************/   
   if(TSrcI==1) begin: TSrcI_1_Add0
      if(TW==1) begin: TW_1_Add0 // Popcount based addition
	 /** 
	  * Case 1: 1-bit input activation and 1-bit weight
	  * Addition reduced to popcount: Count the number of 1's
	  * in the combined SIMD output
	  * **/	 
	 mvu_pe_popcount #(
			   .SIMD(SIMD),
			   .TDstI(TDstI))
	 mvu_pe_popcount_inst (
			       .aclk,
			       .aresetn,
			       .in_simd(out_simd),
			       .out_add(out_add)
			       );
	 
      end // block: TW_1_Add0      
      else begin: Bin_Add0 // Binary Addition which takes care of adding a carry in
	 /**
	  * Case 2: Binary input activations
	  * **/
	 mvu_pe_adders #(
			 .SIMD(SIMD),
			 .TDstI(TDstI))
	 mvu_pe_adders_ins (
			       .aclk,
			       .aresetn,
			       .in_simd(out_simd),
			       .out_add(out_add)
			    );
      end // block: Bin_Add0      
   end // block: TSrcI_1_Add0   
   else if(TW==1) begin: TW_1_Add1
      if(TSrcI==1) begin: TSrcI_1_Add1
	 /** 
	  * Case 1: 1-bit input activation and 1-bit weight
	  * Addition reduced to popcount: Count the number of 1's
	  * in the combined SIMD output
	  * **/	 
	 mvu_pe_popcount #(
			   .SIMD(SIMD),
			   .TDstI(TDstI))
	 mvu_pe_popcount_inst (
			       .aclk,
			       .aresetn,
			       .in_simd(out_simd),
			       .out_add(out_add)
			       );
      end // block: TSrcI_1_Add1
      else begin: Bin_Add1
	 /**
	  * Case 2: Binary weights
	  * **/
	 mvu_pe_adders #(
			    .SIMD(SIMD),
			    .TDstI(TDstI))
	 mvu_pe_adders_ins (
			    .aclk,
			    .aresetn,
			    .in_simd(out_simd),
			    .out_add(out_add)
			    );
	 
      end // block: Bin_Add1
   end // block: TW_1_Add1   
   else begin: All_Add // Normal addition
      /**
       * Case 2: Simple adder tree
       * **/
      mvu_pe_adders #(
		      .SIMD(SIMD),
		      .TDstI(TDstI))
      mvu_pe_adders_ins (
			 .aclk,
			 .aresetn,
			 .in_simd(out_simd),
			 .out_add(out_add)
			 );
   end // block: All_Add
   
   /**
    * Accumulator
    * */
   mvu_pe_acc #(.TDstI(TDstI))
   mvu_pe_acc_inst (
		    .aresetn,
		    .aclk,
		    .do_mvau_stream(do_mvau_stream_reg),
		    .sf_clr(sf_clr),
		    .in_acc(out_add),
		    .out_acc_v(out_v),
		    .out_acc(out));
   
endmodule // mvu_pe


