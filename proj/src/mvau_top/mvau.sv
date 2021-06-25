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
 * aresetn  - Active low synchronous reset
 * aclk    - Main clock
 * rready - Input ready which tells that the successor logic is ready to receive data
 * [TI-1:0] in - Input stream, word length TI=TSrcI*SIMD
 * in_v - Input valid, indicates valid input
 * 
 * Outputs:
 * wready - Output ready which tells the predecessor logic to start providing data
 * out_v        - Output stream valid
 * [TO-1:0] out - Output stream, word length TO=TDstI*PE 
 * 
 * Parameters:
 * WMEM_ADDR_BW - Word length of the address for the weight memories (log2(WMEM_DEPTH))
 * */

`timescale 1ns/1ns
// Package file for parameters
//`include "mvau_defn.sv"

module mvau #(
	      parameter int KDim=2, // Kernel dimensions
	      parameter int IFMCh=2,// Input feature map channels
	      parameter int OFMCh=2,// Output feature map channels or the number of filter banks
	      parameter int IFMDim=2, // Input feature map dimensions
	      parameter int PAD=0, // Padding around the input feature map
	      parameter int STRIDE=1, // Number of pixels to move across when applying the filter
	      parameter int OFMDim=1, // Output feature map dimensions
	      parameter int MatrixW=8, // Width of the input matrix
	      parameter int MatrixH=2, // Heigth of the input matrix
	      parameter int SIMD=2, // Number of input columns computed in parallel
	      parameter int PE=2, // Number of output rows computed in parallel
	      parameter int WMEM_DEPTH=4, // Depth of each weight memory
	      parameter int MMV=1, // Number of output pixels computed in parallel
	      parameter int TSrcI=4, // DataType of the input activation (as used in the MAC)
	      parameter int TSrcI_BIN = 0, // Indicates whether the 1-bit TSrcI is to be interpreted as special +1/-1 or not
	      parameter int TI=8, // SIMD times the word length of input stream
	      parameter int TW=1, // Word length of individual weights
	      parameter int TW_BIN = 0, // Indicates whether the 1-bit TW is to be interpreted as special +1/-1 or not
	      parameter int TDstI=8, // DataType of the output activation (as generated by the activation) 
	      parameter int TO=16, // PE times the word length of output stream   
	      parameter int TA=16, // PE times the word length of the activation class (e.g thresholds)
	      parameter int USE_DSP=0, // Use DSP blocks or LUTs for MAC
	      parameter int INST_WMEM=1, // Instantiate weight memory, if needed
	      parameter int MVAU_STREAM=0, // Top module is not MVAU Stream
	      parameter int USE_ACT=0)     // Use activation after matrix-vector activation	      
   (    
	input logic 	      aresetn, // active low synchronous reset
	input logic 	      aclk, // main clock
	
	// Axis Stream interface
	input logic 	      rready,
	output logic 	      wready,
		 
	input logic [TI-1:0]  in, // input stream
	input logic 	      in_v, // input valid
	output logic 	      out_v, // Output valid
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
   // Signal: in_reg
   // Input activation stream synchronized to clock
   logic [TI-1:0] 		       in_reg;
   // Signal: wmem_addr
   // This signal holds the address of the weight memory
   logic [WMEM_ADDR_BW-1:0] 	       wmem_addr;
   // Signal: wmem_out
   // This holds the streaming weight tile
   logic [0:SIMD*TW-1] 		       wmem_out [0:PE-1];
   logic [0:PE*SIMD*TW-1] 	       wmem_out_packed;   
   // Signal: out_stream
   // This signal is connected to the output of streaming module (mvau_stream)
   logic [TO-1:0] 		       out_stream;
   // Signal: out_stream_valid
   // Signal showing when output from the MVAU Stream block is valid
   logic 			       out_stream_valid;
   // Signal: wmem_wready
   // Output ready signal for the weight stream
   logic 			       wmem_wready;
   // Signal: wmem_valid
   // Valid signal of weight stream
   logic 			       wmem_valid;
  
   
   // Always_FF: INP_REG
   // Register the input valid and activation
   // always_ff @(posedge aclk) begin
   //    if(!aresetn) begin
   // 	 in_v_reg <= 1'b0;
   // 	 in_reg   <= 'd0;
   //    end
   //    else begin
   // 	 in_v_reg <= in_v;// & wready;
   // 	 in_reg   <= in;//in_v & wready ? in: 'd0;
   //    end
   // end
   assign in_v_reg = in_v;
   assign in_reg = in;
   
   
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
			.WMEM_DEPTH(WMEM_DEPTH),
			.WMEM_ADDR_BW(WMEM_ADDR_BW)
			)
   mvau_cb_inst (.aresetn,
		 .aclk,
		 .wmem_wready,
		 .wmem_valid,
		 //.in_v(in_v_reg),
		 .wmem_addr);
   
   // Submodule: mvau_stream
   // Instantiation of the Multiply Vector Multiplication Unit   
   mvau_stream #(
		 .KDim       (KDim      ), 
		 .IFMCh	     (IFMCh     ), 
		 .OFMCh	     (OFMCh     ), 
		 .IFMDim     (IFMDim    ), 
		 .PAD	     (PAD       ), 
		 .STRIDE     (STRIDE    ), 
		 .OFMDim     (OFMDim    ), 
		 .MatrixW    (MatrixW   ), 
		 .MatrixH    (MatrixH   ), 
		 .SIMD	     (SIMD      ), 
		 .PE	     (PE        ), 
		 .WMEM_DEPTH (WMEM_DEPTH), 
		 .MMV	     (MMV       ), 
		 .TSrcI	     (TSrcI     ), 
		 .TSrcI_BIN  (TSrcI_BIN ), 
		 .TI	     (TI        ), 
		 .TW	     (TW        ), 
		 .TW_BIN     (TW_BIN    ), 
		 .TDstI	     (TDstI     ), 
		 .TO	     (TO        ), 
		 .TA	     (TA        ), 
		 .USE_DSP    (USE_DSP   ),
		 .MVAU_STREAM(MVAU_STREAM),
		 .USE_ACT    (USE_ACT   ))
     mvau_stream_inst(
		      .aresetn,
		      .aclk,
		      .rready,
		      .wready,
		      .wmem_wready,
		      .in_v(in_v_reg), // Input activation valid
		      .in_act(in_reg), // Input activation
		      .in_wgt_v(wmem_valid), // Weight stream valid
		      .in_wgt(wmem_out_packed), // A tile of weights
		      .out_v(out_stream_valid),
		      .out(out_stream)
		      );

   // Submodule: mvau_weight_mem
   // Instantiation of the Weight Memory Unit
   if(INST_WMEM==1) begin: WGT_MEM
      mvau_weight_mem_merged #(
			       .SIMD(SIMD),
			       .PE(PE),
			       .TW(TW),
			       .WMEM_DEPTH(WMEM_DEPTH),
			       .WMEM_ADDR_BW(WMEM_ADDR_BW))
      mvau_weigt_mem_inst(
      			  .aclk,
      			  .wmem_addr,
      			  .wmem_out(wmem_out)
      			  );
   end // block: WGT_MEM
  
   generate
      for(genvar p = 0; p<PE; p++) begin
	 assign wmem_out_packed[SIMD*TW*p:SIMD*TW*p+(SIMD*TW-1)] = wmem_out[p];
      end
   endgenerate
   
   // A place holder for the activation unit to be implemented later
   generate
      if(USE_ACT==1) begin: ACT
      end
      else begin: NO_ACT
	 logic out_v_int;
	 assign out_v_int = out_stream_valid;// & rready;

	 // Always_FF: OUT_REG
	 // Registering the output activation stream
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      out <= 'd0;
	    else if(rready)
	      out <= out_stream;	    
	    else if(out_v)
	      out <= out;	    
	    else
	      out <= out_stream;	    
	 end
	 // Always_FF: OUT_V_REG
	 // Registering the output activation stream valid signal
	 always_ff @(posedge aclk) begin
	    if(!aresetn) 
	      out_v <= 1'b0;	    	    
	    else if(out_v_int)
	      out_v <= 1'b1;
	    else if(rready)
	      out_v <= 1'b0;	    
	 end
	 // always_ff @(posedge aclk) begin
	 //    if(!aresetn) begin
	 //       out_v <= 1'b0;
	 //       out <= 'd0;
	 //       //wready <= 1'b0;
	 //    end	       
	 //    else begin
	 //       out_v <= out_v_int;
	 //       out   <= out_stream;
	 //       //wready <= rready;	       
	 //    end
	 // end // always_ff @ (posedge aclk)	 
      end
   endgenerate
   
endmodule // mvau
