/*
 * Module: mvau_stream_tb_v2.sv (testbench)
 *
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * v2.0: 
 * Reads input data from a file and reads weights from a file
 * Compares output of DUT with outputs from a file.This file lists
 * a test bench for the matrix-vector activation streaming unit.
 * 
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 * 
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Parameters:
 * 
 * CLK_PER - Clock cycle period
 * INIT_DLY=(CLK_PER*2)+1 - Initial delay
 * RAND_DLY=21 - Random delay to be used when needed
 * NO_IN_VEC = 100 - Number of input vectors
 * ACT_MatrixW = OFMDim*OFMDim; - Input activation matrix height
 * ACT_MatrixH = (KDim*KDim*IFMCh) - Input activation matrix weight
 * TOTAL_OUTPUTS = MatrixH*ACT_MatrixW - Total number of elements in the output matrix
 * */

`timescale 1ns/1ns

`include "../src/mvau_top/mvau_defn.sv" // compile the package file

module mvau_stream_tb_v2;

   // parameters for controlling the simulation and inserting some delays
   parameter int CLK_PER=20;
   parameter int INIT_DLY=(CLK_PER*2)+1;
   parameter int RAND_DLY=21;
   parameter int NO_IN_VEC = 100;
   parameter int ACT_MatrixW = OFMDim*OFMDim; // input activation matrix height
   parameter int ACT_MatrixH = (KDim*KDim*IFMCh); // input activation matrix weight
   parameter int TOTAL_OUTPUTS = MatrixH*ACT_MatrixW;
   
   // Signals Declarations
   // Signal: clk
   // Main clock
   logic 	 clk;
   // Signal: rst_n
   // Asynchronous active low reset
   logic 	 rst_n;
   // Signal: in_v
   // Input valid
   logic 		     in_v;
   // Signal: weights
   // The weight matrix of dimensions (MatrixW/SIMD)*(MatrixH/PE) x MatrixH of word length TW x SIMD
   logic [PE-1:0][0:SIMD-1][TW-1:0] weights [0:MatrixH/PE-1][0:MatrixW/SIMD-1];
   // Signal: in_wgt
   // Input weight stream to DUT
   // Dimension: PE, word length: TW*SIMD
   logic [0:SIMD*TW-1] in_wgt[0:PE-1];
   // Signal: in_wgt_um
   // Input weight stream extracting weights from weight matrix
   // Dimension: PExSIMD, word length: TW
   logic [0:SIMD-1][TW-1:0] in_wgt_um[0:PE-1];   
   // Signal: in_mat
   // Input activation matrix
   // Dimension: ACT_MatrixH x ACT_MatrixW, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] in_mat [0:ACT_MatrixW-1][0:ACT_MatrixH/SIMD-1];
   // Signal: in_act
   // Input activation stream to DUT
   // Dimension: SIMD, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] in_act;
   // Signal: mvau_beh
   // Output matrix holding output of behavioral simulation
   // Dimension: MatrixH x ACT_MatrixW
   logic [PE-1:0][TDstI-1:0]     mvau_beh [0:ACT_MatrixW-1][0:MatrixH/PE-1];
   // Signal: out_v
   // Output valid signal
   logic 		    out_v;
   // Signal: out
   // Output from DUT, word length: TO = PExTDstI
   logic [TO-1:0] 	    out;
   // Signal: out_packed
   // Output signal from DUT where each element is divided into multiple elements   
   // as DUT produces a packed output of size PE x TDstI.
   // Dimension: PE, word length: TDstI
   logic [0:PE-1][TDstI-1:0] out_packed;
   // Signal: test_count
   // An integer to count for successful output matching
   integer 		       test_count;
   
   // Events for synchronizing the simulation
   event 		       gen_inp;    // generate input activation matrix
   event 		       gen_weights;// generate weight matrix
   event 		       do_mvau_beh;// perform behavioral mvau
   event 		       test_event; // to start testing
   
   
   //Generating Clock and Reset
   initial
     begin
	$display($time, " << Starting Simulation >>");	
	clk 		      = 0;
	rst_n 		      = 0;
	test_count 	      = 0;
	
	// Generating events to generate input vector and coefficients for test	
	#1 		      -> gen_inp; // To populate the input data vector
	#1 		      -> gen_weights; // To generate coefficients
	#1 		      -> do_mvau_beh; // To perform behavioral matrix vector convolution

	#(INIT_DLY-CLK_PER/2) -> test_event; // Test event to start generating input
	#(CLK_PER/2);
	
	rst_n 		      = 1; // Coming out of reset
	$display($time, " << Coming out of reset >>");
	$display($time, " << Starting simulation with System Verilog based data >>");

	// Checking DUT output with golden output generated by HLS
	#(CLK_PER*6);// Delaying to synchronize the DUT output
	// We need to delay more until the final output comes
	for(int i = 0; i < ACT_MatrixW; i++) begin
	   for(int j = 0; j < MatrixH/PE; j++) begin
	      #(CLK_PER*MatrixW/SIMD);	      
	      @(posedge clk) begin: TEST_DATA
		 if(out_v) begin		    
		    out_packed = out;
		    for(int k = 0; k < PE; k++) begin
		       if(out_packed[k] == mvau_beh[i][j][k]) begin
			  $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",k,out_packed[k],j*PE+k,i,mvau_beh[i][j][k]);
			  test_count++;
		       end
		       else begin
			  $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",k,out_packed[k],j*PE+k,i,mvau_beh[i][j][k]);
			  assert (out_packed[k] == mvau_beh[i][j][k])
			    else
			      $fatal(1,"Data MisMatch");
		       end
		    end
		 end // if (out_v)
	      end // block: TEST_DATA
	   end // for (int j = 0; j < MatrixH/PE; j++)
	end // for (int i = 0; i < ACT_MatrixW; i++)
	
	#RAND_DLY;
	if(test_count == TOTAL_OUTPUTS) begin
	  $display($time, " << Simulation Complete. Total successul outputs: %d >>", test_count);
	   $stop;
	end
	else begin
	  $display($time, " << Simulation complete, failed >>");
	   $stop;
	end
     end // initial begin

   
   // Always: CLK_GEN
   // Generating clock using the CLK_PER as clock period
   always
     #(CLK_PER/2) clk = ~clk;

   // Always: WGT_MAT_GEN
   // Always block for populating the weight matrix from
   // a memory file
   always @(gen_weights) begin: WGT_MAT_GEN
      $readmemh("inp_wgt.memh",weights);      
     end
   
   // Always: INP_ACT_MAT_GEN
   // Always block for populating the input activation matrix
   // from a memory file
   always @(gen_inp)
     begin: INP_ACT_MAT_GEN
	$readmemh("inp_act.memh",in_mat);
     end

   // Always: OUT_ACT_MAT_GEN
   // Always block for populating the output activation matrix
   // from a memory file
   always @(do_mvau_beh)
     begin: OUT_ACT_MAT_GEN
	$readmemh("out_act.memh",mvau_beh);
     end
   
   
   /*
    * Generating data from DUT
    * */
   always @(test_event)   
     begin
	for(int i = 0; i < ACT_MatrixW; i++) begin
	   for(int j = 0; j < ACT_MatrixH/SIMD; j++) begin
	      #(CLK_PER/2);
	      in_v = 1'b1;
	      for(int k = 0; k < SIMD; k++) begin
		 in_act[k] = in_mat[i][j][k];//[j*SIMD+k][i];		 
	      end
	      //$display($time, " << Row: %d, Col%d => Data In: 0x%0h >>", j,i,in_act);
	      #(CLK_PER/2);	   
	   end
	   in_v = 1'b0;
	   #(CLK_PER*((MatrixW/SIMD)*(MatrixH/PE-1)));
	end
     end // always @ (test_event)
   always @(test_event)
     begin
	for(int x = 0; x < ACT_MatrixW; x++) begin
	   for(int i = 0; i < MatrixH/PE; i++) begin
	      for(int j = 0; j < MatrixW/SIMD; j++) begin
		 #(CLK_PER/2);
		 for(int k = PE-1; k >= 0; k--) begin
		    in_wgt_um[k] = weights[i][j][k];
		 end		 
		 #(CLK_PER/2);
	      end
	   end // for (int i = 0; i < MatrixH/PE; i++)
	end // for (int x = 0; x < ACT_MatrixW; x++)
     end // always @ (test_event)
   assign in_wgt = in_wgt_um;
   
   /*
    * DUT Instantiation
    * */
   mvau_stream mvau_stream_inst(
   				.rst_n,
   				.clk,
				.in_v,
   				.in_act,
   				.in_wgt,
				.out_v,
   				.out);
   
endmodule // mvau_stream_tb

