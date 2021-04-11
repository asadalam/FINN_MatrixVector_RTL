/*
 * Module: MVAU Top Level (mvau.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists an RTL implementation of the matrix-vector activation unit
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * rst_n  - Active low synchronous reset
 * clk    - Main clock
 * [TI-1:0] in - Input stream, word length TI=TSrcI*SIMD
 * in_v - Input valid, indicates valid input
 * 
 * Outputs:
 * out_v        - Output stream valid
 * [TO-1:0] out - Output stream, word length TO=TDstI*PE 
 * 
 * Parameters:
 * WMEM_ADDR_BW - Word length of the address for the weight memories (log2(WMEM_DEPTH))
 * */

`timescale 1ns/1ns
// Package file for parameters
`include "mvau_defn.sv"

module mvau (    
		 input logic 	       rst_n, // active low synchronous reset
		 input logic 	       clk, // main clock
		 input logic [TI-1:0]  in, // input stream
		 input logic 	       in_v, // input valid
		 output logic 	       out_v, // Output valid
		 output logic [TO-1:0] out); //output stream
   /*
    * Local parameters
    * */
   // Parameter: WMEM_ADDR_BW
   // Word length of the weight memory address
   localparam int 		       WMEM_ADDR_BW=$clog2(WMEM_DEPTH); // Address word length for the weight memory
   // Parameter: SF
   // Number of vertical matrix chunks to be processed in parallel by one PE
   localparam int 		       SF=MatrixW/SIMD; // Number of vertical matrix chunks
   // Parameter: NF
   // Number of horizontal matrix chunks to be processed by PEs in parallel
   localparam int 		       NF=MatrixH/PE; // Number of horizontal matrix chunks
   
   /*
    * Internal Signals/Wires 
    * */ 
   
   /* 
    * Internal signals for the weight memory
    * */
   // Signal: in_v_reg
   // Input valid synchronized to clock
   logic  			       in_v_reg;
   // Signal: in_v_reg_dly
   // Input valid delayed for one more clock cycle
   logic 			       in_v_reg_dly;
   // Signal: in_reg
   // Input activation stream synchronized to clock
   logic [TI-1:0] 		       in_reg;
   // Signal: in_reg_dly
   // Input activation stream delayed by one clock cycle to synchronize with weight stream
   logic [TI-1:0] 		       in_reg_dly;
   // Signal: wmem_addr
   // This signal holds the address of the weight memory
   logic [WMEM_ADDR_BW-1:0] 	       wmem_addr;
   // Signal: in_wgt
   // This holds the streaming weight tile
   logic [0:SIMD-1][TW-1:0] 	       in_wgt [0:PE-1];   
   
   // Signal: out_stream
   // This signal is connected to the output of streaming module (mvau_stream)
   logic [TO-1:0] 		       out_stream;
   // Signal: out_stream_valid
   // Signal showing when output from the MVAU Stream block is valid
   logic 			       out_stream_valid;
   
   // Always_FF: INP_REG
   // Register the input valid and activation
   always_ff @(posedge clk) begin
      if(!rst_n) begin
	 in_v_reg <= 1'b0;
	 in_reg   <= 'd0;
      end
      else begin
	 in_v_reg <= in_v;
	 in_reg   <= in;
      end
   end
   // Always_FF: IN_REG_DLY
   // Delays the input activation stream for one more clock cycle
   always_ff @(posedge clk) begin
      if(!rst_n) begin
	 in_v_reg_dly <= 1'b0;
	 in_reg_dly <= 'd0;
      end
      else begin
	 in_v_reg_dly <= in_v_reg;
	 in_reg_dly <= in_reg;
      end
   end

   /*
    * Control logic for reading and writing to input buffer
    * and for generating the correct weight tile for the
    * matrix vector computation/multiplication unit
    * */
   // Submodule: mvau_control_block
   // Instantiation of the control unit for generation
   // of address for the weight memory
   mvau_control_block #(.SF(SF),
			.NF(NF),
			.WMEM_ADDR_BW(WMEM_ADDR_BW)
			)
   mvau_cb_inst (.rst_n,
		 .clk,
		 .in_v(in_v_reg),
		 .wmem_addr);
   		 //.out_wgt(in_wgt));

   
   // Submodule: mvau_stream
   // Instantiation of the Multiply Vector Multiplication Unit   
   mvau_stream
     mvau_stream_inst(
		      .rst_n,
		      .clk,
		      .in_v(in_v_reg_dly), // Input activation valid
		      .in_act(in_reg_dly), // Input activation
		      .in_wgt, // A tile of weights
		      .out_v(out_stream_valid),
		      .out(out_stream)
		      );

   // Submodule: mvau_weight_mem
   // Instantiation of the Weight Memory Unit
   if(INST_WMEM==1) begin: WGT_MEM
      //for(genvar wmem = 0; wmem < PE; wmem=wmem+1)	 
      	 // mvau_weight_mem #(.WMEM_ID(wmem),
      	 // 		   .WMEM_ADDR_BW(WMEM_ADDR_BW))
      	 //   mvau_weight_mem_inst(
      	 // 			.clk,
      	 // 			.wmem_addr,
      	 // 			.wmem_out(in_wgt[wmem])
      	 // 			);
      mvau_weight_mem_merged #(.WMEM_ADDR_BW(WMEM_ADDR_BW))
      mvau_weigt_mem_inst(
      			  .clk,
      			  .wmem_addr,
      			  .wmem_out(in_wgt)
      			  );
   end // block: WGT_MEM
      
   // A place holder for the activation unit to be implemented later
   generate
      if(USE_ACT==1) begin: ACT
      end
      else begin: NO_ACT
	 assign out_v = out_stream_valid;	 
	 assign out = out_stream;
      end
   endgenerate
   
endmodule // mvau
