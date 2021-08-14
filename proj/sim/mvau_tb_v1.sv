/*
 * Module: mvau_tb_v1.sv (testbench)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists a test bench for the matrix-vector activation batch unit.
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

`include "mvau_defn.sv" // compile the package file

module mvau_tb_v1;

   // parameters for controlling the simulation and inserting some delays
   parameter int CLK_PER=20;
   parameter int INIT_DLY=(CLK_PER*2)+1;
   parameter int RAND_DLY=21;
   parameter int NO_IN_VEC = 100;
   parameter int ACT_MatrixW = OFMDim*OFMDim; // input activation matrix height
   parameter int ACT_MatrixH = (KDim*KDim*IFMCh); // input activation matrix weight
   parameter int TOTAL_OUTPUTS = MMV*MatrixH*ACT_MatrixW;
   
   // Signals Declarations
   // Signal: aclk
   // Main clock
   logic 	 aclk;
   // Signal: aresetn
   // Asynchronous active low reset
   logic 	 aresetn;
   // Signal: out_v
   // Output valid signal
   logic 	  out_v;
   // Signal: out
   // Output from DUT
   logic [TO-1:0] out;
   // Signal: out_packed
   // Output signal from DUT where each element is divided into multiple elements
   // as DUT produces a packed output of size PE x TDstI
   // Dimension: PE, word length: TDstI
   logic [0:PE-1][TDstI-1:0] out_packed;
   // Signal: in_v
   // Input valid
   logic 		     in_v;
   // Signal: weights
   // The weight matrix of dimensions (MatrixW/SIMD)*(MatrixH) x MatrixH of word length TW x SIMD
   logic [0:SIMD-1][TW-1:0] weights [0:MatrixH-1][0:MatrixW/SIMD-1];
   // Signal: in_mat
   // Input activation matrix
   // Dimension: ACT_MatrixH x ACT_MatrixW, word length: TSrcI
   logic [TSrcI-1:0] 	     in_mat [0:MMV-1][0:ACT_MatrixH-1][0:ACT_MatrixW-1];
   // Signal: in
   // Input activation stream to DUT
   // Dimension: SIMD, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] in;
   // Signal: mvau_beh
   // Output matrix holding output of behavioral simulation
   // Dimension: MatrixH x ACT_MatrixW
   logic [TDstI-1:0] 	       mvau_beh [0:MMV-1][0:MatrixH-1][0:ACT_MatrixW-1];
   // Signal: test_count
   // An integer to count for successful output matching
   integer 		       test_count;
   // Signal: do_comp
   // A signal which indicates the comparison is done, helps in debugging
   logic 		       do_comp;
   // Signal: latency
   // An integer to count the total number of cycles taken to get all outputs
   integer 		       latency;
   // Signal: sim_start
   // A signal which indicates when simulation starts
   logic 		       sim_start;
   // Signal: rready
   // Input ready to the DUT
   logic 		       rready;
   // Signal: wready
   // Output ready from the DUT
   logic 		       wready;
   

   // Events for synchronizing the simulation
   event 		       gen_inp;    // generate input activation matrix
   event 		       gen_weights;// generate weight matrix
   event 		       do_mvau_beh;// perform behavioral mvau
   
   
   // Initial: CLK_RST_GEN
   // Initialization of Clock and Reset and performing validation
   // between output of DUT and behavioral model
   initial
     begin
	$display($time, " << Starting Simulation >>");	
	aclk 		      = 0;
	aresetn 		      = 0;
	sim_start = 0;
	test_count = 0;
	rready = 0;	

	// Generating events to generate input vector and coefficients for test	
	#1 		      -> gen_inp; // To populate the input data vector
	#1 		      -> gen_weights; // To generate coefficients
	#1 		      -> do_mvau_beh; // To perform behavioral matrix vector convolution

	#(INIT_DLY);//-CLK_PER/2) -> test_event; // Test event to start generating input
	//#(CLK_PER/2);
	
	aresetn 		      = 1; // Coming out of reset
	//rready = 1; // Fixing rready to '1' as this is just test bench
	sim_start = 1; // Simulation starts
	do_comp = 0;
	
	$display($time, " << Coming out of reset >>");
	$display($time, " << Starting simulation with System Verilog based data >>");

	// Checking DUT output with golden output generated in the test bench
	//#(CLK_PER*5) // Delaying to synchronize the DUT output
	for(int m = 0; m < MMV; m++) begin
	   for(int i = 0; i < ACT_MatrixW; i++) begin
	      for(int j = 0; j < MatrixH/PE; j++) begin
		 //#(CLK_PER*MatrixW/SIMD)
		 do_comp = 1; // Indicating when actual comparison is done, helps in debugging
		 #1;		 
		 wait(out_v==1'b1);		 
		 @(posedge aclk) begin: DUT_BEH_MATCH
		    if(out_v) begin		    
		       out_packed = out;
		       for(int k = 0; k < PE; k++) begin
			  if(out_packed[PE-k-1] == mvau_beh[m][j*PE+k][i]) begin
			     $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",
				      k,out_packed[PE-k-1],i,j*PE+k,mvau_beh[m][j*PE+k][i]);
			     test_count++;
			  end
			  else begin
			     $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",
				      k,out_packed[PE-k-1],i,j*PE+k,mvau_beh[m][j*PE+k][i]);
			     assert (out_packed[PE-k-1] == mvau_beh[m][j*PE+k][i])
			       else
				 $fatal(1,"Data MisMatch");
			  end
		       end // for (int k = 0; k < PE; k++)
		    end // if (out_v)
		 end // block: DUT_BEH_MATCH
		 do_comp = 0;
		 wait(out_v==1'b0 || rready==1'b1);		 
	      end // for (int j = 0; j < MatrixH/PE; j++)
	   end // for (int i = 0; i < ACT_MatrixW; i++)
	end // for (int m = 0; m < MMV; m++)
	
	sim_start = 0;
		
	#RAND_DLY;
	if(test_count == TOTAL_OUTPUTS) begin
	   integer f;
	   $display($time, " << Simulation Complete. Total successul outputs: %d >>", test_count);
	   $display($time, " << Latency: %d >>", latency/MMV);
	   f = $fopen("latency.txt","w");
	   $fwrite(f,"%d",latency);
	   $fclose(f);	   
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
     #(CLK_PER/2) aclk = ~aclk;

   // Always: WGT_MAT_GEN
   // Generates a weight matrix using memory files
   always @(gen_weights) begin: WGT_MAT_GEN
      $readmemh("weights_mem_full.mem", weights);
   end
   
   // Always: INP_MAT_GEN
   // Input matrix generation using random data
   always @(gen_inp)
     begin
	for(int m = 0; m < MMV; m=m+1)
	  for(int row = 0; row < ACT_MatrixH; row=row+1)
	    for(int col = 0; col < ACT_MatrixW; col = col+1)
	      in_mat[m][row][col] = TSrcI'($random);
     end

   /*
    * Performing behavioral MVAU
    * Caters for all the following four cases
    * Case 1: 1-bit input activation and 1-bit weight
    * Case 2: 1-bit input activation and multi-bit weight
    * Case 3: Multi-bit weight and 1-bit input activation
    * Case 4: Multi-bit weight and input activation
    * */
   // Always: OUT_GEN_BEH
   // Generating the golden output data
   if(TSrcI==1) begin: NONGEN_MVAU1
      if(TW==1) begin: XNOR_MVAU1
	 // Case 1
	 always @(do_mvau_beh)
	   begin: MVAU_BEH1
	      logic simd_xnor;	      
	      for(int m = 0; m < MMV; m++) begin
		for(int i = 0; i < MatrixH; i++) begin
		  for(int j = 0; j < ACT_MatrixW; j++) begin
		     mvau_beh[m][i][j]   = '0;
		     for(int k = 0; k < ACT_MatrixH/SIMD; k++) begin
			for(int l = 0; l < SIMD; l++) begin
			   simd_xnor = weights[i][k][l]^~in_mat[m][k*SIMD+l][j]; // XNOR
			   mvau_beh[m][i][j] += simd_xnor;//weights[i][k][l]^~in_mat[m][k*SIMD+l][j]; // XNOR
			end
		     end
		  end
		end
	      end // for (int m = 0; m < MMV; m++)
	   end // block: MVAU_BEH1
end // block: XNOR_MVAU1      
      else begin: BIN_MVAU1
	 // Case 2
	 always @(do_mvau_beh)
	   begin: MVAU_BEH2
	      for(int m = 0; m < MMV; m++) begin
		 for(int i = 0; i < MatrixH; i++) begin
		    for(int j = 0; j < ACT_MatrixW; j++) begin
		       mvau_beh[m][i][j] = '0;
		       for(int k = 0; k < ACT_MatrixH/SIMD; k++) begin
			  for(int l = 0; l < SIMD; l++) begin
			     if(in_mat[m][k*SIMD+l][j] == 1'b1) // in = +1
			       mvau_beh[m][i][j] += weights[i][k][l];		      
			     else // in = -1
			       mvau_beh[m][i][j] += ~weights[i][k][l]+1'b1;
			  end
		       end
		    end // for (int j = 0; j < ACT_MatrixW; j++)
		 end // for (int i = 0; i < MatrixH; i++)
	      end // for (int m = 0; m < MMV; m++)
	   end // block: MVAU_BEH2
end // block: BIN_MVAU1      
   end // block: NONGEN_MVAU1   
   else if(TW==1) begin: NONGEN_MVAU2
      if(TSrcI==1) begin: XNOR_MVAU2
	 // Case 1
	 always @(do_mvau_beh)
	   begin: MVAU_BEH3
	      logic simd_xnor;
	      for(int m = 0; m < MMV; m++) begin
		 for(int i = 0; i < MatrixH; i++) begin
		    for(int j = 0; j < ACT_MatrixW; j++) begin
		       mvau_beh[m][i][j]   = '0;
		       for(int k = 0; k < ACT_MatrixH/SIMD; k++) begin
			  for(int l = 0; l < SIMD; l++) begin
			     simd_xnor = weights[i][k][l]^~in_mat[m][k*SIMD+l][j]; // XNOR
			     mvau_beh[m][i][j] += simd_xnor;//weights[i][k][l]^~in_mat[m][k*SIMD+l][j]; // XNOR
			  end
		       end
		    end
		 end		 
	      end // for (int m = 0; m < MMV; m++)	      
	   end // block: MVAU_BEH3
end // block: XNOR_MVAU2      
      else begin: BIN_MVAU2
	 // Case 3
	 always @(do_mvau_beh)
	   begin: MVAU_BEH4
	      for(int m = 0; m < MMV; m++) begin
		 for(int i = 0; i < MatrixH; i++) begin
		    for(int j = 0; j < ACT_MatrixW; j++) begin
		       mvau_beh[m][i][j] = '0;
		       for(int k = 0; k < ACT_MatrixH/SIMD; k++) begin
			  for(int l = 0; l < SIMD; l++) begin
			     if(weights[i][k][l] == 1'b1) // in_wgt = +1
			       mvau_beh[m][i][j] += in_mat[m][k*SIMD+l][j];
			     else // in_wgt = -1
			       mvau_beh[m][i][j] += ~in_mat[m][k*SIMD+l][j]+1'b1;
			  end
		       end
		    end // for (int j = 0; j < ACT_MatrixW; j++)
		 end // for (int i = 0; i < MatrixH; i++)
	      end // for (int m = 0; m < MMV; m++)	      
	   end // block: MVAU_BEH4
end // block: BIN_MVAU2      
   end // block: NONGEN_MVAU2   
   else begin: GEN_MVAU
      // Case 4
      always @(do_mvau_beh)
	begin: MVAU_BEH
	   for(int m = 0; m < MMV; m++) begin
	      for(int i = 0; i < MatrixH; i++) begin
		 for(int j = 0; j < ACT_MatrixW; j++) begin
		    mvau_beh[m][i][j] 	 = '0;
		    for(int k = 0; k < ACT_MatrixH/SIMD; k++)
		      for(int l = 0; l < SIMD; l++) begin
			 mvau_beh[m][i][j] += weights[i][k][l]*in_mat[m][k*SIMD+l][j];
		      end
		 end
	      end
	   end // for (int m = 0; m < MMV; m++)	   
	end // block: MVAU_BEH
end // block: GEN_MVAU   

   // Always_FF: CALC_LATENCY
   // Always block for calculating the total run time
   // of simulation in terms of clock cycles
   always_ff @(posedge aclk)
     begin
	if(!aresetn)
	  latency <= 'd0;
	else if(sim_start == 1'b1)
	  latency <= latency+1'b1;
     end

   // Always_Comb: Input Ready
   always @(out_v) begin
      //rready = 1'b0;      
      //#(CLK_PER*100+1)
      //rready = out_v;
      rready = 1'b1;
      
   end
   
   /*
    * Generating data for DUT
    * */
   int m_inp, i_inp, j_inp;
   // Always: Counters
   // Three counters to control the generation of input
   always @(posedge aclk) begin
      if(!aresetn) begin
	 m_inp <= 0;
	 i_inp <= 0;
	 j_inp <= 0;
      end
      else if(wready) begin
	 if(m_inp == MMV-1 & i_inp == ACT_MatrixW-1 & j_inp == ACT_MatrixH/SIMD-1) begin
	    m_inp <= MMV-1;
	    i_inp <= ACT_MatrixW-1;
	    j_inp <= ACT_MatrixH/SIMD-1;
	 end
	 else if(i_inp == ACT_MatrixW-1 & j_inp == ACT_MatrixH/SIMD-1) begin
	    i_inp <= 0;
	    j_inp <= 0;
	    m_inp <= m_inp+1;
	 end
	 else if(j_inp == ACT_MatrixH/SIMD-1) begin
	    j_inp <= 0;
	    i_inp <= i_inp+1;
	 end
	 else
	   j_inp <= j_inp +1;	 
      end      
   end // always @ (posedge aclk)

   // Always: INP_GEN
   // Generating input for the DUT from the input tensor
   always @(aresetn, m_inp, i_inp, j_inp) begin
      for(int k = 0; k < SIMD; k++) begin
	 in[k] = in_mat[m_inp][j_inp*SIMD+k][i_inp];//in_mat[m_inp][i_inp][j_inp][k];
      end
   end

   // always_ff @(posedge aclk) begin
   //    if(!aresetn)
   // 	in_v <= 1'b0;
   //    else
   // 	in_v <= 1'b1;
   // end
   // Always_FF: INP_V_GEN
   // Generating input valid for a variety of cases
   if(ACT_MatrixW==1) begin: COL_1
      if(ACT_MatrixH/SIMD==1) begin: ROW_1
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(m_inp == MMV-1)
	      in_v <= 1'b0;
	    else
	      in_v <= 1'b1;//~in_v;
	 end
end
      else begin: ROW_N
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(m_inp == MMV-1 & j_inp == ACT_MatrixH/SIMD-1)
	      in_v <= 1'b0;
	    else
	      in_v <= 1'b1;
	 end
end
   end // block: COL_1   
   else begin: COL_N
      if(ACT_MatrixH/SIMD==1) begin: ROW_1
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(m_inp == MMV-1 & i_inp == ACT_MatrixW-1)
	      in_v <= 1'b0;
	    else
	      in_v <= 1'b1;
	 end
end
      else begin: ROW_N   
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(m_inp == MMV-1 & i_inp == ACT_MatrixW-1 & j_inp == ACT_MatrixH/SIMD-1)
	      in_v <= 1'b0;
	    else
	      in_v <= 1'b1;
	 end
end
   end // block: COL_N

   /*
    * DUT Instantiation
    * */
   mvau_top #(
	      .KDim        (KDim        ), 
	      .IFMCh	   (IFMCh       ), 
	      .OFMCh	   (OFMCh       ), 
	      .IFMDim 	   (IFMDim      ), 
	      .PAD    	   (PAD         ), 
	      .STRIDE 	   (STRIDE      ), 
	      .OFMDim	   (OFMDim      ), 
	      .MatrixW	   (MatrixW     ), 
	      .MatrixH	   (MatrixH     ), 
	      .SIMD 	   (SIMD        ), 
	      .PE 	   (PE          ), 
	      .WMEM_DEPTH  (WMEM_DEPTH  ), 
	      .MMV    	   (MMV         ), 
	      .TSrcI 	   (TSrcI       ), 
	      .TSrcI_BIN   (TSrcI_BIN   ),  
	      .TI	   (TI          ), 
	      .TW 	   (TW          ), 
	      .TW_BIN  	   (TW_BIN      ), 
	      .TDstI 	   (TDstI       ), 
	      .TO	   (TO          ), 
	      .TA 	   (TA          ), 
	      .DSP_TRUE    (DSP_TRUE    ),
	      .OP_SGN      (OP_SGN      ),
	      .INST_WMEM   (INST_WMEM   ),
	      .USE_ACT	   (USE_ACT     ))	      
   mvau_inst(
	     .aresetn(aresetn),
	     .aclk(aclk),
	     .m0_axis_tready(rready),
	     .s0_axis_tready(wready),
	     .s0_axis_tvalid(in_v),				
	     .s0_axis_tdata(in),
	     .m0_axis_tvalid(out_v),
	     .m0_axis_tdata(out)
	     );
   
endmodule // mvau_tb
