/*
 * Module: mvau_tb_v3.sv (testbench)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * v3.0:
 * This file lists a test bench for the matrix-vector activation batch unit.
 * The input and weights are read from a file generated by HLS. The output from
 * DUT is matched against data generated from HLS. This
 * test bench is part of the regression test for MVAU batch unit.
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

module mvau_tb_v3;

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
   // Signal: rready
   // Input signal to DUT indicating that successor logic is ready to consume data
   logic 	 rready;
   // Signal: wready
   // Output signal from DUT indicating to the predecessor logic should start sending data
   logic 	 wready;   
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
   // Signal: in_mat
   // Input activation matrix
   // Dimension: ACT_MatrixH x ACT_MatrixW, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] in_mat [0:MMV-1][0:ACT_MatrixW-1][0:ACT_MatrixH/SIMD-1];
   // Signal: in
   // Input activation stream to DUT
   // Dimension: SIMD, word length: TSrcI
   logic [0:SIMD-1][TSrcI-1:0] in;
   // Signal: mvau_beh
   // Output matrix holding output of behavioral simulation
   // Dimension: MatrixH x ACT_MatrixW
   logic [TDstI-1:0] 	       mvau_beh [0:MMV-1][0:ACT_MatrixW-1][0:MatrixH-1];
   // Signal: test_count
   // An integer to count for successful output matching
   integer 		       test_count;
   // Signal: latency
   // An integer to count the total number of cycles taken to get all outputs
   integer 		       latency;
   // Signal: sim_start
   // A signal which indicates when simulation starts
   logic 		       sim_start;
   // Signal: do_comp
   // A signal which indicates the comparison is done, helps in debugging
   logic 		       do_comp;
   // Events for synchronizing the simulation
   event 		       gen_inp;    // generate input activation matrix
   event 		       gen_weights;// generate weight matrix
   event 		       do_mvau_beh;// perform behavioral mvau
   //event 		       test_event; // to start testing
   
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

	// Generating events to generate input vector and coefficients for test	
	#1 		      -> gen_inp; // To populate the input data vector
	#1 		      -> gen_weights; // To generate coefficients
	#1 		      -> do_mvau_beh; // To perform behavioral matrix vector convolution

	#(INIT_DLY);//-CLK_PER/2) -> test_event; // Test event to start generating input
	//#(CLK_PER/2);
	
	aresetn 		      = 1; // Coming out of reset
	rready = 1; // Fixing rready to '1' as this is just test bench
	sim_start = 1; // Simulation starts
	do_comp = 0;
	
	$display($time, " << Coming out of reset >>");
	$display($time, " << Starting simulation with System Verilog based data >>");

	// Checking DUT output with golden output generated in the test bench
	#(CLK_PER*8) // Delaying to synchronize the DUT output
	for(int m = 0; m < MMV; m++) begin
	   for(int i = 0; i < ACT_MatrixW; i++) begin
	      for(int j = 0; j < MatrixH/PE; j++) begin
		 #(CLK_PER*MatrixW/SIMD)
		 do_comp = 1; // Indicating when actual comparison is done, helps in debugging		 
		 @(posedge aclk) begin: DUT_BEH_MATCH
		    if(out_v) begin		    
		       out_packed = out;
		       for(int k = 0; k < PE; k++) begin
			  if(out_packed[k] == mvau_beh[m][i][j*PE+k]) begin
			     $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",
				      k,out_packed[k],i,j*PE+k,mvau_beh[m][i][j*PE+k]);
			     test_count++;
			  end
			  else begin
			     $display($time, "<< PE%d : 0x%0h >>, << Model_%d_%d: 0x%0h",
				      k,out_packed[k],i,j*PE+k,mvau_beh[m][i][j*PE+k]);
			     assert (out_packed[k] == mvau_beh[m][i][j*PE+k])
			       else
				 $fatal(1,"Data MisMatch");
			  end
		       end // for (int k = 0; k < PE; k++)
		    end // if (out_v)
		 end // block: DUT_BEH_MATCH
		 do_comp = 0;		 
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
   
   // Always: INP_MAT_GEN
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
   
   /*
    * Generating data from DUT
    * */
   always @(posedge aclk)//(test_event)   
     begin
	if(wready) begin
	   #1;	   
	   for(int m = 0; m < MMV; m++) begin
	      for(int i = 0; i < ACT_MatrixW; i++) begin
		 for(int j = 0; j < ACT_MatrixH/SIMD; j++) begin
		    #(CLK_PER/2);
		    in_v = wready;//1'b1;
		    for(int k = 0; k < SIMD; k++) begin
		       in[k] = in_mat[m][i][j][k];
		    end
		    //$display($time, " << Row: %d, Col%d => Data In: 0x%0h >>", j,i,in);
		    #(CLK_PER/2);	   
		 end
		 in_v = 1'b0;
		 #(CLK_PER*((MatrixW/SIMD)*(MatrixH/PE-1)));
	      end // for (int i = 0; i < ACT_MatrixW; i++)
	   end // for (int m = 0; m < MMV; m++)
	end // if (wready)	
     end // always @ (posedge aclk)   

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
	      .USE_DSP 	   (USE_DSP     ), 
	      .INST_WMEM   (INST_WMEM   ), 
	      .USE_ACT	   (USE_ACT     ))	      
	      mvau_inst(
		      .aresetn,
		      .aclk,
		      .rready,
		      .wready,
		      .in_v,				
		      .in,
		      .out_v,
		      .out);
   
endmodule // mvau_tb
