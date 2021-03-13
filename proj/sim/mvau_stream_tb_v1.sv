/*******************************************************************************
 *
 * Authors: Syed Asad Alam <syed.asad.alam@tcd.ie>
 * \file mvu.sv
 *
 * This file lists a test bench for the matrix-vector activation streaming
 * unit
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 *******************************************************************************/

`timescale 1ns/1ns

`include "../src/mvau_defn.sv" // compile the package file

module mvau_stream_tb;

   // parameters for controlling the simulation and inserting some delays
   parameter int CLK_PER=20;
   parameter int INIT_DLY=(CLK_PER*2)+1;
   parameter int RAND_DLY=21;
   parameter int NO_IN_VEC = 100;
   parameter int ACT_MatrixW = OFMDim*OFMDim; // input activation matrix height
   parameter int ACT_MatrixH = (KDim*KDim*IFMCh); // input activation matrix weight
   
   // Signals Declarations
   logic 	 clk;
   logic 	 rst_n;
   logic [TW-1:0] weights [0:MatrixH-1][0:MatrixW-1];
   logic [TO-1:0] out;
   logic [0:PE-1][TDstI-1:0] out_packed;
   logic [0:SIMD-1][TSrcI-1:0] in_act;
   logic [0:SIMD-1][TW-1:0]    in_wgt[0:PE-1];
   logic [TSrcI-1:0] 	       in_mat [0:ACT_MatrixH-1][0:ACT_MatrixW-1];
   logic [TDstI-1:0] 	       mvau_beh [0:MatrixH-1][0:ACT_MatrixW-1];
   
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

	// Generating events to generate input vector and coefficients for test	
	#1 		      -> gen_inp; // To populate the input data vector
	#1 		      -> gen_weights; // To generate coefficients
	#1 		      -> do_mvau_beh; // To perform behavioral matrix vector convolution

	#(INIT_DLY-CLK_PER/2) -> test_event; // Test event to start generating input
	#(CLK_PER/2);
	
	rst_n 		      = 1; // Coming out of reset
	$display($time, " << Coming out of reset >>");
	$display($time, " << Starting simulation with System Verilog based data >>");

	// Checking DUT output with golden output generated in the test bench
	#(CLK_PER) // Delaying to synchronize the DUT output
	// We need to delay more until the final output comes
	// To-do for tomorrow
	for(int i = 0; i < ACT_MatrixW; i++) begin
	   for(int j = 0; j < MatrixH/PE; j++)
	     begin
		#(CLK_PER*MatrixW/SIMD)
		out_packed = out;
		@(posedge clk) begin		  
		   for(int k = 0; k < PE; k++) begin
		      if(out_packed[k] == mvau_beh[j*PE+k][i])
			$display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",k,out_packed[k],j*PE+k,i,mvau_beh[j*PE+k][i]);
		      else begin
			 $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",k,out_packed[k],j*PE+k,i,mvau_beh[j*PE+k][i]);
			 assert (out_packed[k] == mvau_beh[j*PE+k][i])
			   else
			     $fatal(1,"Data MisMatch");
		      end			
		   end
		end
	     end // for (int j = 0; j < MatrixH/PE-1; j++)
	end // for (int i = 0; i < ACT_MatrixW-1; i++)	

	#RAND_DLY;
	$display($time, "<< Simulation Complete >>");
	$stop;		
     end // initial begin

   
   /*
    * Clock generation
    * */
   always
     #(CLK_PER/2) clk = ~clk;

   /*
    * Weight Matrix Generation
    * */
   always @(gen_weights)
     begin
	for(int row = 0; row < MatrixH; row=row+1)
	  for(int col = 0; col < MatrixW; col = col+1)
	    weights[row][col] = TW'($random);
     end
   
   /*
    * Input activation matrix generation
    * */
   always @(gen_inp)
     begin
	for(int row = 0; row < ACT_MatrixH; row=row+1)
	  for(int col = 0; col < ACT_MatrixW; col = col+1)
	    in_mat[row][col] = TSrcI'($random);
     end

   /*
    * Performing behavioral MVAU
    * Caters for all the following four cases
    * Case 1: 1-bit input activation and 1-bit weight
    * Case 2: 1-bit input activation and multi-bit weight
    * Case 3: Multi-bit weight and 1-bit input activation
    * Case 4: Multi-bit weight and input activation
    * */
   if(TSrcI==1) begin: NONGEN_MVAU1
      if(TW==1) begin: XNOR_MVAU1
	 // Case 1
	 always @(do_mvau_beh)
	   begin: MVAU_BEH1
	      for(int i = 0; i < MatrixH; i++)
		for(int j = 0; j < ACT_MatrixW; j++) begin
		   mvau_beh[i][j] = '0;
		   for(int k = 0; k < ACT_MatrixH; k++) 
		     mvau_beh[i][j] += weights[i][k]^~in_mat[k][j]; // XNOR
		end
	   end
end
      else begin: BIN_MVAU1
	 // Case 2
	 always @(do_mvau_beh)
	   begin: MVAU_BEH2
	      for(int i = 0; i < MatrixH; i++)
		for(int j = 0; j < ACT_MatrixW; j++) begin
		   mvau_beh[i][j]   = '0;
		   for(int k = 0; k < ACT_MatrixH; k++) begin
		      if(in_mat[k][j] == 1'b1) // in_act = +1
			mvau_beh[i][j] += weights[i][k];		      
		      else // in_act = -1
			mvau_beh[i][j] += ~weights[i][k]+1'b1;
		   end
		end
	   end
end
   end // block: NONGEN_MVAU1   
   else if(TW==1) begin: NONGEN_MVAU2
      if(TSrcI==1) begin: XNOR_MVAU1
	 // Case 1
	 always @(do_mvau_beh)
	   begin: MVAU_BEH3
	      for(int i = 0; i < MatrixH; i++)
		for(int j = 0; j < ACT_MatrixW; j++) begin
		   mvau_beh[i][j] = '0;
		   for(int k = 0; k < ACT_MatrixH; k++) 
		     mvau_beh[i][j] += weights[i][k]^~in_mat[k][j]; //XNOR
		end
	   end
end
      else begin: BIN_MVAU2
	 // Case 3
	 always @(do_mvau_beh)
	   begin: MVAU_BEH4
	      for(int i = 0; i < MatrixH; i++)
		for(int j = 0; j < ACT_MatrixW; j++) begin
		   mvau_beh[i][j] = '0;
		   for(int k = 0; k < ACT_MatrixH; k++) begin
		      if(weights[i][k] == 1'b1) // in_wgt = +1
			mvau_beh[i][j] += in_mat[k][j];
		      else // in_wgt = -1
			mvau_beh[i][j] += ~in_mat[k][j]+1'b1;
		   end
		end
	   end
end      
   end // block: NONGEN_MVAU2   
   else begin: GEN_MVAU
      // Case 4
      always @(do_mvau_beh)
	begin: MVAU_BEH
	   for(int i = 0; i < MatrixH; i++)
	     for(int j = 0; j < ACT_MatrixW; j++) begin
		mvau_beh[i][j] = '0;
		for(int k = 0; k < ACT_MatrixH; k++) 
		  mvau_beh[i][j] += weights[i][k]*in_mat[k][j];
	     end
	end
end
   
   /*
    * Generating data from DUT
    * */
   always @(test_event)   
     begin
	for(int i = 0; i < ACT_MatrixW; i++) begin
	   for(int j = 0; j < ACT_MatrixH/SIMD; j++) begin
	      #(CLK_PER/2);
	      for(int k = 0; k < SIMD; k++) begin
		 in_act[k] = in_mat[j*SIMD+k][i];		 
	      end
	      $display($time, " << Row: %d, Col%d => Data In: 0x%0h >>", j,i,in_act);
	      #(CLK_PER/2);	   
	   end
	   #(CLK_PER*((MatrixW/SIMD)*(MatrixH/PE-1)));
	end
     end // always @ (test_event)
   always @(test_event)
     begin
	for(int x = 0; x < ACT_MatrixW; x++) begin
	   for(int i = 0; i < MatrixH/PE; i++) begin
	      for(int j = 0; j < MatrixW/SIMD; j++) begin
		 #(CLK_PER/2);
		 for(int k = 0; k < SIMD; k++) begin
		    for(int l = 0; l < PE; l++) begin
		       in_wgt[l][k] = weights[i*PE+l][j*SIMD+k];
		    end		 
		 end
		 #(CLK_PER/2);
	      end
	   end // for (int i = 0; i < MatrixH/PE; i++)
	end // for (int x = 0; x < ACT_MatrixW; x++)
     end // always @ (test_event)
   
   /*
    * DUT Instantiation
    * */
   mvau_stream mvau_stream_inst(
				.rst_n,
				.clk,
				.in_act,
				.in_wgt,
				.out);
   
endmodule // mvau_stream_tb

