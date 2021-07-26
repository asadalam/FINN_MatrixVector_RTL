/*
 * Module: MVAU Streaming Block Control Unit (mvau_stream_control_block.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 * 
 * This file lists an RTL implementation of the control block
 * It is used to control the input buffer
 * and generation of the correct control signals to control
 * the multiplication operation and generate address, write 
 * and read enable for the input buffer. It also contains 
 * free running counters to track as each input activation vector
 * is processed
 * 
 * It is part of the Xilinx FINN open source framework for implementing
 * quantized neural networks on FPGAs
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 * 
 * Inputs:
 * aresetn          - Active low synchronous reset
 * aclk             - Main clock
 * in_v             - Input activation stream valid 
 * wait_rready      - Signal that indicates whether rready has been asserted after valid
 * Outputs:
 * ib_wen           - Write enable for the input buffer
 * ib_red           - Read enable for the input buffer
 * wready           - Output ready signal, to indicate when the input buffer can accept new input
 * wmem_wready      - Output ready signal for the weight memory
 * sf_clr           - Control signal for resetting the accumulator and a one bit control signal to indicate when sf_cnt == SF-1
 * [SF_T:0] sf_cnt  - Address for the input buffer
 * 
 * Parameters:
 * SF=MatrixW/SIMD - Number of vertical weight matrix chunks and depth of the input buffer
 * NF=MatrixH/PE   - Number of horizontal weight matrix chunks
 * SF_T            - log_2(SF), determines the number of address bits for the input buffer * SF_T
 * NF_T            - log_2(NF), word length of the NF counter to control reading and writing from the input buffer
 * */

`timescale 1ns/1ns

module mvau_stream_control_block #(
			    parameter int SF=8,
			    parameter int NF=1,
			    parameter int SF_T=3,
			    parameter int NF_T=1
			    )
   (
    input logic 	    aresetn,
    input logic 	    aclk,
    input logic 	    in_v, // input activation stream valid
    input logic 	    wait_rready, // Signal that indicates whether rready has been asserted after valid
    output logic 	    ib_wen, // Input buffer write enable
    output logic 	    ib_ren, // Input buffer read enable
    output logic 	    wready, // Output ready signal
    output logic 	    wmem_wready, // Output weight stream ready signal
    output logic 	    sf_clr, // To reset the sf_cnt
    output logic [SF_T-1:0] sf_cnt // Address for the input buffer
    );
      
   /*
    * Internal Signals
    * */
   // Signal: inp_active
   // Internal signal to indicate when input data is active
   // Asserted when input valid and output ready asserted
   logic 		    inp_active;
   // Signal: do_mvau_stream
   // Internal signal to indicate when to perform all computations
   logic 		    do_mvau_stream;
   // Signal: sf_full
   // Internal signal to indicate if sf_cnt has gone full
   logic 		    sf_full;
   // Signal: ap_start
   // Internal signal to indicate when to start computations after reset
   logic 		    ap_start;
   // Signal: halt_mvau_stream
   // Internal signal to halt the computations in case of missing input ready   
   logic 		    halt_mvau_stream;
   
   /*
    * Controlling for when MatrixH is '1' and PE is also '1'
    * Meaning only one output channel
    * */   
   generate
      if(NF==1) begin: ONE_FILTER_BANK
	 // This block is implemented when NF=1
	 // meaning input buffer will not be re-used

	 logic wait_rready_dly;
	 
	 // Wready
	 // Remains one when the input buffer is being filled
	 // Resets to Zero the input buffer is filled and ready
	 // to be reused
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      wready <= 1'b0;
	    else if(halt_mvau_stream)
	      wready <= 1'b0;
	    else
	      wready <= 1'b1;	    
	 end
	 // Always_FF: SF_CNT
	 // A sequential 'always' block for a counter
	 // which keeps track when the input buffer is full.
	 // Only runs when do_mvau_stream is asserted
	 // A counter similar to sf in mvau.hpp
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      sf_cnt <= 'd0;
	    else if(sf_full)//sf_cnt == SF_T'(SF-1))
	      sf_cnt <= 'd0;
	    else if(do_mvau_stream)
	      sf_cnt <= sf_cnt + 1;
	 end
   
	 // Write enable only when input active
	 assign ib_wen = inp_active;

	 // Read enable is always zero
	 assign ib_ren = 1'b0;

	 // Compute the output when ever the input is active
	 assign do_mvau_stream = inp_active;

	 // Always_FF: DLY_WAIT_READY
	 // Delaying the wait ready signal by one clock signal
	 // If the wait_rready signal is asserted for two consecutive
	 // clock cycles, need to halt computation
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      wait_rready_dly <= 1'b0;
	    else
	      wait_rready_dly <= wait_rready;
	 end
	 // halting MVAU computation
	 assign halt_mvau_stream = wait_rready & wait_rready_dly;
	 
      
      end
      else begin: N_FILTER_BANKS
	 // This block is implemented when NF>1
	 // Meaning the input buffer will be reused

	 // Signal: State variables
	 // Three states:
	 // a) IDLE: When no input available or when computation is halted
	 // b) WRITE: When writing to the input buffer
	 // c) READ: When reading from the input buffer
	 enum logic [1:0] {IDLE, WRITE, READ} pres_state, next_state;
	 
	 // Signal: nf_clr
	 // Signal to reset the nf_cnt counter
	 // Only used when multiple output channel
	 logic 		    nf_clr; // To reset the nf_cnt
	 // Signal: nf_zero
	 // Signal to indicate when nf_cnt equals zero
	 logic 		    nf_zero;
	 // Signal: nf_cnt
	 // A counter to keep track how many weight channels have been processed
	 // Only used when multiple output channels
	 logic [NF_T-1:0]   nf_cnt; // NF counter, keeping track of the NF
	 // Signal: nf_full
	 // Signal to indicate the the nf_cnt has saturated along with sf_cnt
	 logic nf_full;

	 // Assigning nf_full
	 assign nf_full = (nf_cnt == NF_T'(NF-1) & sf_full);//sf_cnt == SF_T'(SF-1));

	 // Assigning nf_zero
	 assign nf_zero = (nf_cnt=='d0);
	 
	 // Always_FF: PRES_STATE
	 // Always block to assign the pres_state signal
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      pres_state <= IDLE;
	    else
	      pres_state <= next_state;
	 end

	 // Always_COMB: NEXT_STATE
	 // Computing the next state
	 always_comb begin
	    case(pres_state)
	      IDLE: begin
		 casez({wait_rready,inp_active,nf_zero,sf_full})
		   4'b0000: next_state = READ;
		   4'b0001: next_state = IDLE;
		   4'b0010: next_state = IDLE;
		   4'b0011: next_state = READ;
		   4'b0100: next_state = WRITE;
		   4'b0101: next_state = WRITE;
		   4'b0110: next_state = WRITE;
		   4'b0111: next_state = READ;		   
		   4'b10??: next_state = IDLE;
		   4'b1100: next_state = WRITE;
		   4'b1101: next_state = IDLE;
		   4'b1110: next_state = WRITE;
		   4'b1111: next_state = IDLE;		   
		   default: next_state = IDLE;		   
		 endcase
	      end
	      WRITE: begin
		 casez({halt_mvau_stream,inp_active,sf_full})
		   3'b000: next_state = IDLE;
		   3'b001: next_state = IDLE;
		   3'b010: next_state = WRITE;
		   3'b011: next_state = READ;
		   3'b1??: next_state = IDLE;		   
		 endcase	 
	      end
	      READ: begin
		 casez({halt_mvau_stream,inp_active, nf_clr&sf_clr})
		   3'b000: next_state = READ;
		   3'b001: next_state = IDLE;
		   3'b010: next_state = WRITE;
		   3'b011: next_state = WRITE;
		   3'b1??: next_state = IDLE;		   
		 endcase // case ({inp_active, nf_clr&sf_clr})		 
	      end
	      default: next_state = IDLE;	      
	    endcase
	 end		

	 // Always_COMB: STATE_OUT
	 // Computing the outputs of the state machine
	 always_comb begin
	    ib_ren = 1'b0;
	    ib_wen = 1'b0;
	    do_mvau_stream = 1'b0;	    
	    case(pres_state)
	      IDLE: begin
		 ib_ren = 1'b0;
		 ib_wen = 1'b0;
		 do_mvau_stream = 1'b0;		 
		 case({inp_active})//,sf_full})
		   1'b0: begin
		      ib_ren = 1'b0;
		      ib_wen = 1'b0;
		      do_mvau_stream = 1'b0;		      
		   end
		   1'b1: begin
		      ib_ren = 1'b0;		      
		      ib_wen = 1'b1;
		      do_mvau_stream = 1'b1;
		   end
		 endcase // case ({inp_active})	
	      end // case: IDLE	      
	      WRITE: begin
		 ib_ren = 1'b0;
		 ib_wen = 1'b0;
		 do_mvau_stream = 1'b0;		 
		 case({inp_active})//,sf_full})
		   1'b0: begin
		      ib_ren = 1'b0;
		      ib_wen = 1'b0;
		      do_mvau_stream = 1'b0;		      
		   end
		   1'b1: begin
		      ib_ren = 1'b0;		      
		      ib_wen = 1'b1;
		      do_mvau_stream = 1'b1;
		   end   
		 endcase // case ({inp_active})
	      end // case: WRITE	      
	      READ: begin
		 ib_ren = 1'b0;
		 ib_wen = 1'b0;
		 do_mvau_stream = 1'b0;		 
		 case({inp_active})//, nf_clr&sf_clr})
		   1'b0: begin
		      ib_ren = ~(nf_clr&sf_clr);//1'b1;
		      do_mvau_stream = ~(nf_clr&sf_clr);//1'b1;
		   end
		   //2'b01: ib_ren = 1'b0;
		   1'b1: begin
		      ib_wen = 1'b1;
		      do_mvau_stream = 1'b1;
		   end
		 endcase // case ({inp_active, nf_clr&sf_clr})
	      end // case: READ	      
	      default: begin
		 ib_ren = 1'b0;
		 ib_wen = 1'b0;
		 do_mvau_stream = 1'b0;
	      end	      
	    endcase // case (pres_state)
	 end // always_comb
	 	 
	 	 
	 // Always_FF: NF_CLR
	 // A one bit control signal to indicate when nf_cnt == NF	 
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      nf_clr <= 1'b0;
	    else if(nf_cnt==NF_T'(NF-1)) //assign nf_clr = nf_cnt==NF_T'(NF-1) ? 1'b1 : 1'b0;
	      nf_clr <= 1'b1;
	    else
	      nf_clr <= 1'b0;
	 end
	 	 
	 // Always_FF: WRDY
	 // Remains one when the input buffer is being filled
	 // Resets to Zero the input buffer is filled and ready
	 // to be reused
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      wready <= 1'b0;
	    else if(ap_start)
	      wready <= 1'b1;	  
	    else if(nf_full)//(nf_cnt == NF_T'(NF-1) & sf_cnt == SF_T'(SF-1))//(nf_cnt == 'd0)
	      wready <= 1'b1;	    
	    else if(sf_full)// (sf_cnt == SF_T'(SF-1))
	      wready <= 1'b0;
	 end
	  
	 // Always_FF: NF_CNT
	 // A counter to keep track when we are done writing to the
	 // input buffer so that it can be reused again
	 // Similar to the variable nf in mvau.hpp
	 // Only used when multiple output channels
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      nf_cnt <= 'd0;//NF_T'(NF-1);
	    else if(nf_clr & sf_clr)
	      nf_cnt <= 'd0;
	    else if(sf_clr)//sf_full)//(sf_cnt==SF_T'(SF-1))//(sf_clr)
	      nf_cnt <= nf_cnt + 1;
	 end

	 // Always_FF: SF_CNT
	 // A sequential 'always' block for a counter
	 // which keeps track when the input buffer is full.
	 // Only runs when do_mvau_stream is asserted
	 // A counter similar to sf in mvau.hpp
	 always_ff @(posedge aclk) begin
 	    if(!aresetn)
	      sf_cnt <= 'd0;//SF_T'(SF-1);
	    else if(sf_full)//(sf_cnt == SF_T'(SF-1))
	      sf_cnt <= 'd0;
	    else if(nf_full)//(nf_cnt == NF_T'(NF-1) & sf_cnt == SF_T'(SF-1))
	      sf_cnt <= 'd0;      
	    else if (do_mvau_stream)
	      sf_cnt <= sf_cnt + 1;
	    //end
	 end
	 assign halt_mvau_stream = ((sf_cnt == SF_T'(SF-2)) & wait_rready);
      end // block: N_FILTER_BANKS
   endgenerate
   assign sf_full = ((sf_cnt == SF_T'(SF-1)) & do_mvau_stream);

   // Always_FF: AP_START
   // Always block for indicating when the system comes out of reset
   always_ff @(posedge aclk) begin
      if(!aresetn)
	ap_start <= 1'b1;
      else
	ap_start <= 1'b0;
   end
   
   // Always_FF: SF_CLR
   // A one bit control signal to indicate when sf_cnt == SF-1   
   always_ff @(posedge aclk) begin
      if(!aresetn)
	sf_clr <= 1'b0;
      else if(sf_full)// & do_mvau_stream)//(sf_cnt == SF_T'(SF-1)) //assign sf_clr = sf_cnt==SF_T'(SF-1) ? 1'b1 : 1'b0;
	sf_clr <= 1'b1;
      else
	sf_clr <= 1'b0;
   end

   // The following signal shows that input valid and ready are both asserted, so data is active
   assign inp_active = wready & in_v;

   // Output ready for weight stream same as do_mvau_stream
   assign wmem_wready = do_mvau_stream;
         
endmodule // mvau_stream_control_block


