/*
 * Module: mvau_stream_tb_v2.sv (testbench)
 *
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * v4.0: 
 * Reads input data from a file and reads weights from a file
 * Compares output of DUT with outputs from a file.This file lists
 * a test bench for the matrix-vector activation streaming unit by splitting the valid into
 * two halves. This test bench is part of the regression test for MVAU stream unit.
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

`include "mvau_defn.sv" // compile the package file

module mvau_stream_tb_v4;

   // parameters for controlling the simulation and inserting some delays
   parameter int CLK_PER=20;
   parameter int INIT_DLY=(CLK_PER*2)+1;
   parameter int RAND_DLY=21;
   parameter int NO_IN_VEC = 100;
   parameter int ACT_MatrixW = OFMDim*OFMDim; // input activation matrix height
   parameter int ACT_MatrixH = (KDim*KDim*IFMCh); // input activation matrix weight
   parameter int TOTAL_OUTPUTS = MatrixH*ACT_MatrixW;
   
   // Signals Declarations
   // Signal: aclk
   // Main clock
   logic 	 aclk;
   // Signal: aresetn
   // Asynchronous active low reset
   logic 	 aresetn;
   // Signal: rready
   // Input signal to DUT indicating that successor logic is ready to consume data
   logic 	 rready;
   // Signal: wready
   // Output signal from DUT indicating to the predecessor logic should start sending data
   logic 	 wready;  
   // Signal: wmem_wready
   // Output signal from DUT indicating to the predecessor weight stream logic should start sending weights
   logic 	 wmem_wready;   
   // Signal: in_v
   // Input valid
   logic 	 in_v;
   // Signal: in_wgt_v
   // Weight stream valid signal
   logic 	 in_wgt_v;   
   // Signal: weights
   // The weight matrix of dimensions (MatrixW/SIMD)*(MatrixH/PE) x MatrixH of word length TW x SIMD
   logic [PE-1:0][0:SIMD-1][TW-1:0] weights [0:MatrixH/PE-1][0:MatrixW/SIMD-1];
   // Signal: in_wgt_packed
   // Input weight stream packed
   // Dimension: PE*TW*SIMD
   logic [0:PE*SIMD*TW-1] 	    in_wgt_packed;   
   // Signal: in_wgt_um
   // Input weight stream extracting weights from weight matrix
   // Dimension: PE, word length: TW*SIMD
   logic [0:SIMD-1][TW-1:0] 	    in_wgt_um[0:PE-1];   
   // Signal: in_mat
   // Input activation matrix
   // Dimension: ACT_MatrixH x ACT_MatrixW, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] 	    in_mat [0:MMV-1][0:ACT_MatrixW-1][0:ACT_MatrixH/SIMD-1];
   // Signal: in_act
   // Input activation stream to DUT
   // Dimension: SIMD, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] 	    in_act;
   // Signal: mvau_beh
   // Output matrix holding output of behavioral simulation
   // Dimension: MatrixH x ACT_MatrixW
   logic [TDstI-1:0] 		    mvau_beh [0:ACT_MatrixW-1][0:MatrixH-1];
   // Signal: out_v
   // Output valid signal
   logic 			    out_v;
   // Signal: out
   // Output from DUT, word length: TO = PExTDstI
   logic [TO-1:0] 		    out;
   // Signal: out_packed
   // Output signal from DUT where each element is divided into multiple elements   
   // as DUT produces a packed output of size PE x TDstI.
   // Dimension: PE, word length: TDstI
   logic [0:PE-1][TDstI-1:0] 	    out_packed;
   // Signal: test_count
   // An integer to count for successful output matching
   integer 			    test_count;
   // Signal: latency
   // An integer to count the total number of cycles taken to get all outputs
   integer 			    latency;
   // Signal: sim_start
   // A signal which indicates when simulation starts
   logic 			    sim_start;
   // Signal: do_comp
   // A signal which indicates the comparison is done, helps in debugging
   logic 			    do_comp;      
   // Events for synchronizing the simulation
   event 			    gen_inp;    // generate input activation matrix
   event 			    gen_weights;// generate weight matrix
   event 			    do_mvau_beh;// perform behavioral mvau
   int 				    m_inp, i_inp, j_inp, dly_cnt, rand_dly1, rand_dly2, rand_range1, rand_range2;
   
   //    
   //Generating Clock and Reset
   initial
     begin
	$display($time, " << Starting Simulation >>");	
	aclk 		      = 0;	
	aresetn 	= 0;
	sim_start = 0;
	test_count 	      = 0;
	
	// Generating events to generate input vector and coefficients for test	
	#1 		      -> gen_inp; // To populate the input data vector
	#1 		      -> gen_weights; // To generate coefficients
	#1 		      -> do_mvau_beh; // To perform behavioral matrix vector convolution

	#(INIT_DLY);//-CLK_PER/2) -> test_event; // Test event to start generating input
	//#(CLK_PER/2);

	aresetn 		      = 1; // Coming out of reset
	//rready = 1; // Fixing rready to '1' as this is just test bench
	sim_start = 1;
	do_comp = 0;	
	$display($time, " << Coming out of reset >>");
	$display($time, " << Starting simulation with HLS based data >>");

	// Checking DUT output with golden output generated by HLS
	// #(CLK_PER*4);// Delaying to synchronize the DUT output
	for(int i = 0; i < ACT_MatrixW; i++) begin
	   for(int j = 0; j < MatrixH/PE; j++) begin
	      //#(CLK_PER*MatrixW/SIMD);
	      do_comp = 1;
	      wait(out_v == 1'b1);	      
	      @(posedge aclk) begin: TEST_DATA
		 if(out_v) begin		    
		    out_packed = out;
		    for(int k = 0; k < PE; k++) begin
		       if(out_packed[PE-k-1] == mvau_beh[i][j*PE+k]) begin
			  $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",
				   k,out_packed[PE-k-1],j*PE+k,i,mvau_beh[i][j*PE+k]);
			  test_count++;
		       end
		       else begin
			  $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",
				   k,out_packed[PE-k-1],j*PE+k,i,mvau_beh[i][j*PE+k]);
			  assert (out_packed[PE-k-1] == mvau_beh[i][j*PE+k])
			    else begin
			       $fatal(1,"Data MisMatch");
			       $display($time, " << Delay1: %d, Delay2: %d", rand_dly1, rand_dly2);
			    end			  
		       end // else: !if(out_packed[PE-k-1] == mvau_beh[i][j*PE+k])		       
		    end // for (int k = 0; k < PE; k++)		    
		 end // if (out_v)
	      end // block: TEST_DATA
	      do_comp = 0;	  
	      wait(out_v==1'b0);	      
	   end // for (int j = 0; j < MatrixH/PE; j++)
	end // for (int i = 0; i < ACT_MatrixW; i++)
	sim_start = 0;
	
	#RAND_DLY;
	if(test_count == TOTAL_OUTPUTS) begin
	   integer f,d;	   
	   $display($time, " << Simulation Complete. Total successul outputs: %d >>", test_count);
	   $display($time, " << Latency: %d >>", latency);
	   $display($time, " << Delay1: %d, Delay2: %d", rand_dly1, rand_dly2);	   
	   f = $fopen("latency.txt","w");
	   $fwrite(f,"%d",latency);
	   $fclose(f);
	   d = $fopen("delay.txt","w");
	   $fwrite(f,"%d,%d",rand_dly1,rand_dly2);
	   $fclose(d);
	   $stop;
	end
	else begin
	   $display($time, " << Simulation complete, failed >>");
	   $display($time, " << Delay1: %d, Delay2: %d", rand_dly1, rand_dly2);	   
	   $stop;
	end
     end // initial begin

   
   // Always: CLK_GEN
   // Generating clock using the CLK_PER as clock period
   always
     #(CLK_PER/2) aclk = ~aclk;

   // Always: WGT_MAT_GEN
   // Always block for populating the weight matrix from
   // a memory file
   always @(gen_weights) begin: WGT_MAT_GEN
      $readmemh("inp_wgt.mem",weights);      
   end
   
   // Always: INP_ACT_MAT_GEN
   // Always block for populating the input activation matrix
   // from a memory file
   always @(gen_inp)
     begin: INP_ACT_MAT_GEN
	$readmemh("inp_act.mem",in_mat);
     end

   // Always: OUT_ACT_MAT_GEN
   // Always block for populating the output activation matrix
   // from a memory file
   always @(do_mvau_beh)
     begin: OUT_ACT_MAT_GEN
	$readmemh("out_act.mem",mvau_beh);
     end

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
   always @(out_v)
     rready = out_v;

   /*
    * Generating data for DUT
    * */
   
   assign rand_range1 = $urandom_range(1,ACT_MatrixH/SIMD-2);   
   assign rand_range2 = $urandom_range(1,ACT_MatrixH/SIMD-2);

   assign rand_dly1 = rand_range1 >= 1 ? rand_range1: 1;   
   assign rand_dly2 = rand_range2 >= 1 ? rand_range2: 1;
   
   always @(posedge aclk) begin
      if(!aresetn)
	dly_cnt <= 0;
      else if (dly_cnt == rand_dly2)//ACT_MatrixH/(SIMD*2)-1)
	dly_cnt <= 0;
      else if(j_inp == rand_dly1)//ACT_MatrixH/(SIMD*2)-rand_dly1)
	dly_cnt <= dly_cnt + 1;
   end

   always @(posedge aclk) begin
      if(!aresetn) begin
	 m_inp <= 0;
	 i_inp <= 0;
	 j_inp <= 0;
	 //in_v_init <= 1'd0;	 
      end
      else if(wready) begin
	 if(m_inp == MMV-1 & i_inp == ACT_MatrixW-1 & j_inp == ACT_MatrixH/SIMD-1) begin
	    m_inp <= MMV-1;
	    i_inp <= ACT_MatrixW-1;
	    j_inp <= ACT_MatrixH/SIMD-1;
	    //in_v_init <= 1'd0;	    
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
	 else if(dly_cnt == rand_dly2)//ACT_MatrixH/(SIMD*2)-1)
	   j_inp <= j_inp +1;
	 else if(j_inp == rand_dly1)//ACT_MatrixH/(SIMD*2)-rand_dly1)
	   j_inp <= j_inp;
	 else
	   j_inp <= j_inp +1;	 
      end // if (wready)      
   end // always @ (posedge clk)

   always @(aresetn, m_inp, i_inp, j_inp) begin
      for(int k = 0; k < SIMD; k++) begin
	 in_act[k] = in_mat[m_inp][i_inp][j_inp][k];
      end
   end

   
   if(ACT_MatrixW==1) begin: COL_1
      if(ACT_MatrixH/SIMD==1) begin: ROW_1
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(dly_cnt == rand_dly2)//ACT_MatrixH/(SIMD*2)-1)
	      in_v <= 1'b1;      
	    else if(j_inp == rand_dly1)//ACT_MatrixH/(SIMD*2)-rand_dly1)
	      in_v <= 1'b0;      	    	    
	    else
	      in_v <= ~in_v;
	 end
end
      else begin: ROW_N
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(dly_cnt == rand_dly2)//ACT_MatrixH/(SIMD*2)-1)
	      in_v <= 1'b1;      
	    else if(j_inp == rand_dly1)//ACT_MatrixH/(SIMD*2)-rand_dly1)
	      in_v <= 1'b0;           
	    else if(m_inp == MMV-1 & j_inp == ACT_MatrixH/SIMD-1)
	      in_v <= 1'b1;
	    else if(m_inp == MMV-1 & j_inp == ACT_MatrixH/SIMD-1)
	      in_v <= 1'b1;
	    else
	      in_v <= 1'b0;
	 end
end
   end // block: COL_1   
   else begin: COL_N
      if(ACT_MatrixH/SIMD==1) begin: ROW_1
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      in_v <= 1'b0;
	    else if(dly_cnt == rand_dly2)//ACT_MatrixH/(SIMD*2)-1)
	      in_v <= 1'b1;      
	    else if(j_inp == rand_dly1)//ACT_MatrixH/(SIMD*2)-rand_dly1)
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
	    else if(dly_cnt == rand_dly2)//ACT_MatrixH/(SIMD*2)-1)
	      in_v <= 1'b1;      
	    else if(j_inp == rand_dly1)//ACT_MatrixH/(SIMD*2)-rand_dly1)
	      in_v <= 1'b0;      
	    else if(m_inp == MMV-1 & i_inp == ACT_MatrixW-1 & j_inp == ACT_MatrixH/SIMD-1)
	      in_v <= 1'b0;
	    else
	      in_v <= 1'b1;
	 end
end
   end // block: COL_N

   
   int x_inp, r_inp, s_inp;
   
   always @(posedge aclk) begin
      if(!aresetn) begin
	 x_inp <= 0;
	 r_inp <= 0;
	 s_inp <= 0;
      end
      else if(wmem_wready) begin
	 if(x_inp == ACT_MatrixW-1 & r_inp == MatrixH/PE-1 & s_inp == MatrixW/SIMD-1) begin
	    x_inp <= ACT_MatrixW-1;
	    r_inp <= MatrixH/PE-1;
	    s_inp <= MatrixW/SIMD-1;
	 end
	 else if(r_inp == MatrixH/PE-1 & s_inp == MatrixW/SIMD-1) begin
	    r_inp <= 0;
	    s_inp <= 0;
	    x_inp <= x_inp+1;
	 end
	 else if(s_inp == MatrixW/SIMD-1) begin
	    s_inp <= 0;
	    r_inp <= r_inp+1;
	 end
	 else
	   s_inp <= s_inp +1;	 
      end // if (wmem_wready)      
   end // always @ (posedge clk)

   always @(aresetn, x_inp, r_inp, s_inp) begin
      for(int k = PE-1; k >= 0; k--) begin
	 in_wgt_um[k] = weights[r_inp][s_inp][k];
      end
   end
				       
   always_ff @(posedge aclk) begin
      if(!aresetn)
	in_wgt_v <= 1'b0;
      else if(x_inp == ACT_MatrixW-1 & r_inp == MatrixH/PE-1 & s_inp == MatrixW/SIMD-1)
	in_wgt_v <= 1'b0;
      else
	in_wgt_v <= 1'b1;
   end


   generate
      for(genvar p = 0; p < PE; p++) begin
	  assign in_wgt_packed[SIMD*TW*p:SIMD*TW*p+(SIMD*TW-1)] = in_wgt_um[p];
      end
   endgenerate
	  
   
   /*
    * DUT Instantiation
    * */
   mvau_stream_top #(
		     .KDim        (KDim        ), 
		     .IFMCh	  (IFMCh       ), 
		     .OFMCh	  (OFMCh       ), 
		     .IFMDim      (IFMDim      ), 
		     .PAD         (PAD         ), 
		     .STRIDE      (STRIDE      ), 
		     .OFMDim      (OFMDim      ), 
		     .MatrixW     (MatrixW     ), 
		     .MatrixH     (MatrixH     ), 
		     .SIMD 	  (SIMD        ), 
		     .PE 	  (PE          ), 
		     .WMEM_DEPTH  (WMEM_DEPTH  ), 
		     .MMV         (MMV         ), 
		     .TSrcI       (TSrcI       ), 
		     .TSrcI_BIN   (TSrcI_BIN   ),  
		     .TI	  (TI          ), 
		     .TW 	  (TW          ), 
		     .TW_BIN      (TW_BIN      ), 
		     .TDstI       (TDstI       ), 
		     .TO	  (TO          ), 
		     .TA 	  (TA          ), 
		     .USE_DSP     (USE_DSP     ),
		     .USE_ACT     (USE_ACT     ))
   mvau_stream_inst(
   		    .aresetn        (aresetn),
   		    .aclk           (aclk),		    
		    .s0_axis_tready (wready),
		    .s0_axis_tvalid (in_v),
   		    .s0_axis_tdata  (in_act),
   		    .s1_axis_tdata  (in_wgt_packed),
		    .s1_axis_tvalid (in_wgt_v),
		    .s1_axis_tready (wmem_wready),
		    .m0_axis_tready (rready),
		    .m0_axis_tvalid (out_v),
   		    .m0_axis_tdata  (out)
		    );
   
endmodule // mvau_stream_tb


   // always @(posedge aclk)   
   //   begin
   // 	if(wready) begin
   // 	   #1;
   // 	   for(int i = 0; i < ACT_MatrixW; i++) begin
   // 	      for(int j = 0; j < ACT_MatrixH/SIMD; j++) begin
   // 		 #(CLK_PER/2);
   // 		 in_v = 1'b1;
   // 		 for(int k = 0; k < SIMD; k++) begin
   // 		    in_act[k] = in_mat[i][j][k];//[j*SIMD+k][i];		 
   // 		 end
   // 		 //$display($time, " << Row: %d, Col%d => Data In: 0x%0h >>", j,i,in_act);
   // 		 #(CLK_PER/2);	   
   // 	      end
   // 	      in_v = 1'b0;
   // 	      #(CLK_PER*((MatrixW/SIMD)*(MatrixH/PE-1)));
   // 	   end // for (int i = 0; i < ACT_MatrixW; i++)
   // 	end // if (wready)
   //   end // always @ (posedge aclk)

   // always @(posedge aclk)//test_event)
   //   begin
   // 	if(wready) begin
   // 	   #1;	   
   // 	   for(int x = 0; x < ACT_MatrixW; x++) begin
   // 	      for(int i = 0; i < MatrixH/PE; i++) begin
   // 		 for(int j = 0; j < MatrixW/SIMD; j++) begin
   // 		    #(CLK_PER/2);
   // 		    for(int k = PE-1; k >= 0; k--) begin
   // 		       in_wgt_um[k] = weights[i][j][k];
   // 		    end		 
   // 		    #(CLK_PER/2);
   // 		 end
   // 	      end // for (int i = 0; i < MatrixH/PE; i++)
   // 	   end // for (int x = 0; x < ACT_MatrixW; x++)
   // 	end // if (wready)
   //   end // always @ (posedge aclk)
