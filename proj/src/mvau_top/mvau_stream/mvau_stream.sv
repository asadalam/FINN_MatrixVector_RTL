/*
 * Module: MVAU Streaming Block (mvau_stream.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists an RTL implementation of the matrix-vector multiplication unit
 * based on streaming weights. It can either be part of the Matrix-Vector-Activation Unit
 * or run independently
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * rst_n - Active low, synchronous reset
 * clk - Main clock
 * in_v - Input valid when input activation is valid
 * sf_clr - Control signal to reset the accumulator
 * [TI-1:0] in_act - Input activation stream, word length TI=TSrcI*SIMD
 * [0:SIMD*TW-1:0] in_wgt [0:PE-1] - Input weight stream
 * 
 * Outputs:			       
 * out_v        - Output stream valid
 * [TO-1:0] out - Output stream, word length TO=TDstI*PE
 * 
 * Parameters:
 * SF=MatrixW/SIMD - Number of vertical weight matrix chunks and depth of the input buffer
 * NF=MatrixH/PE   - Number of horizontal weight matrix chunks
 * SF_T            - log_2(SF), determines the number of address bits for the input buffer
 * */

`timescale 1ns/1ns
`include "../mvau_defn.sv"

module mvau_stream (
		    input logic 	      rst_n,
		    input logic 	      clk,
		    input logic 	      in_v,
		    input logic [TI-1:0]      in_act ,
		    input logic [0:SIMD*TW-1] in_wgt [0:PE-1], // Streaming weight tile
		    output logic 	      out_v, // Ouptut valid
		    output logic [TO-1:0]     out);

   /*
    * Local parameters
    * */
   // Parameter: SF
   // Number of vertical matrix chunks to be processed in parallel by one PE
   localparam int SF=MatrixW/SIMD; // Number of vertical matrix chunks
   // Parameter: NF
   // Number of horizontal matrix chunks to be processed by PEs in parallel
   localparam int NF=MatrixH/PE; // Number of horizontal matrix chunks
   // Parameter: SF_T
   // Address word length of the buffer
   localparam int SF_T=$clog2(SF); // Address word length for the input buffer
   //logic [0:PE-1][0:SIMD*TW-1] in_wgt_um = in_wgt;
   
   /**
    * Internal Signals
    * **/
   // Signal: in_v_reg
   // Input valid synchronized to clock
   logic 			       in_v_reg;
   // Signal: in_act_reg
   // Input activation stream synchronized to clock
   logic [TI-1:0] 		       in_act_reg;
   // Signal: in_wgt_reg
   // Streaming weight tile synchronized to clock
   logic [0:SIMD-1][TW-1:0] 	       in_wgt_reg [0:PE-1];
   // Internal signals for the input buffer and the control block
   // Signal: ib_wen
   // Write enable for the input buffer
   logic 		      ib_wen;
   // Signal: ib_ren
   // Read enable for the input buffer
   logic 		      ib_ren;
   // Signal: sf_clr
   // Resets the accumulator as well the sf_cnt
   logic 		      sf_clr;
   // Signal: sf_cnt
   // Counter keeping track of SF and also address to input buffer
   logic [SF_T-1:0] 	      sf_cnt;
   // Signal out_act
   // Output of the input buffer
   logic [TI-1:0] 	      out_act;    
   // Signal: out_pe
   // Holds the output from parallel PEs
   logic [0:PE-1][TDstI-1:0]  out_pe;
   // Signal: out_pe_v
   // Output valid signal from each PE
   logic [0:PE-1] 	      out_pe_v;
   // Signal: do_mvau_stream   
   // Controls how long the MVAU operation continues
   // Case 1: NF=1 => do_mvau_stream = in_v (input buffer not reused)
   // Case 2: NF>1 => do_mvau_stream = in_v | (~(nf_clr&sf_clr)) (input buffer reused)
   logic 		      do_mvau_stream;
   
   // Always_FF: INP_REG
   // Register the input valid and activation
   always_ff @(posedge clk) begin
      if(!rst_n) begin
	 in_v_reg <= 1'b0;
	 in_act_reg   <= 'd0;
      end
      else if(in_v) begin
	 in_v_reg   <= 1'b1;
	 in_act_reg <= in_act;
      end
      else
	in_v_reg <= 1'b0;
   end // always_ff @ (posedge clk)

   // Always_FF: WGT_REG
   // Register the input weight stream
   always_ff @(posedge clk) begin
      if(!rst_n) begin
	 for(int i = 0; i < PE; i++)
	   in_wgt_reg[i] <= 'd0;
      end
      else begin
	 for(int i = 0; i < PE; i++)
	   in_wgt_reg[i] <= in_wgt[i];
      end
   end
   
   /*
    * Control logic for reading and writing to input buffer
    * and for generating the correct weight tile for the
    * matrix vector computation/multiplication unit
    * */
   mvau_stream_control_block #(
			.SF(SF),
			.NF(NF),
			.SF_T(SF_T)
			)
   mvau_stream_cb_inst (.rst_n,
			.clk,
			.in_v(in_v_reg),
			.ib_wen,
			.ib_ren,
			.do_mvau_stream,
			.sf_clr,
			.sf_cnt);

   //Insantiating the input buffer
   mvau_inp_buffer #(
		     .BUF_LEN(SF),
		     .BUF_ADDR(SF_T))
   mvau_inb_inst (
		  .clk,
		  .rst_n,
		  .in(in_act_reg),
		  .wr_en(ib_wen),
		  .rd_en(ib_ren),
		  .addr(sf_cnt),
		  .out(out_act));
   
   /**
    * Generating instantiations of all processing elements
    * Each PE reads in different set of weights
    * Each PE reads in the same set of activation
    * Each PE outputs TDstI bits
    * Output of each PE packed into one array of size TO
    * */
   generate
      for(genvar pe_ind = 0; pe_ind < PE; pe_ind = pe_ind+1)
	begin: PE_GEN
	   mvu_pe mvu_pe_inst( // Mapping the I/O blocks
			       .rst_n,
			       .clk,
			       .sf_clr,
			       .do_mvau_stream,
			       .in_act(out_act),
			       .in_wgt(in_wgt_reg[pe_ind]),
			       .out_v(out_pe_v[pe_ind]),
			       .out(out_pe[pe_ind]) // Each PE contribution TDstI bits in the output
			       );
	end
   endgenerate

   // A place holder for the activation unit to be implemented later
   generate
      if(USE_ACT==1) begin: ACT
      end
      else begin: NO_ACT
	 // Always_FF: OUT_PE_REG
	 // Registering the output activation stream
	 always_ff @(posedge clk) begin
	    if(!rst_n)
	      out <= 'd0;
	    else
	      out <= out_pe;
	 end
	 // Always_FF: OUT_V_REG
	 // Registering the output activation stream valid signal
	 always_ff @(posedge clk) begin
	   if(!rst_n)
	     out_v <= 1'b0;
	    else
	      out_v = |out_pe_v;
	 end
      end      
   endgenerate

endmodule // mvau_stream
