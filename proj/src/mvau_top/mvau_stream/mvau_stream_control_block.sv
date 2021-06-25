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
 * aresetn            - Active low synchronous reset
 * aclk              - Main clock
 * in_v             - Input activation stream valid 
 * 
 * Outputs:
 * ib_wen           - Write enable for the input buffer
 * ib_red           - Read enable for the input buffer
 * sf_clr           - Control signal for resetting the accumulator and a one bit control signal to indicate when sf_cnt == SF-1
 * do_mvau_stream   - Controls how long the MVAU operation continues
 *                    Case 1: NF=1 => do_mvau_stream = in_v (input buffer not reused)
 *                    Case 2: NF>1 => do_mvau_stream = in_v | (~(nf_clr&sf_clr)) (input buffer reused)
 * [SF_T:0] sf_cnt  - Address for the input buffer
 * 
 * Parameters:
 * SF=MatrixW/SIMD - Number of vertical weight matrix chunks and depth of the input buffer
 * NF=MatrixH/PE   - Number of horizontal weight matrix chunks
 * SF_T            - log_2(SF), determines the number of address bits for the input buffer * SF_T
 * */

`timescale 1ns/1ns
//`include "../mvau_defn.sv"

module mvau_stream_control_block #(
			    parameter int SF=8,
			    parameter int NF=1,
			    parameter int SF_T=3
			    )
   (
    input logic 	    aresetn,
    input logic 	    aclk,
    input logic 	    in_v, // input activation stream valid
    //input logic 	    wait_rready, // Signal that indicates whether rready has been asserted after valid
    output logic 	    ib_wen, // Input buffer write enable
    output logic 	    ib_ren, // Input buffer read enable
    output logic 	    wready, // Output ready signal
    output logic 	    wmem_wready, // Output weight stream ready signal
    //output logic 	    do_mvau_stream, // Signal to control all operations
    output logic 	    sf_clr, // To reset the sf_cnt
    output logic [SF_T-1:0] sf_cnt // Address for the input buffer
    );
   
   /*
    * Local Parameters
    * */
   // Parameter: NF_T
   // Word length of the NF counter to control reading and writing from the input buffer
   localparam int 	    NF_T=$clog2(NF); // For nf_cnt

   /*
    * Internal Signals
    * */
   // Signal: inp_active
   // Internal signal to indicate when input data is active
   // Asserted when input valid and output ready asserted
   logic 		    inp_active;
   logic 		    do_mvau_stream;
   logic 		    sf_full;
   logic 		    ap_start;
   //logic 		    halt_mvau_stream;
   
   
   
   /*
    * Controlling for when MatrixH is '1' and PE is also '1'
    * Meaning only one output channel
    * */
   
   generate
      if(NF==1) begin: ONE_FILTER_BANK
	 // This block is implemented when NF=1
	 // meaning input buffer will not be re-used

	 // Wready
	 // Remains one when the input buffer is being filled
	 // Resets to Zero the input buffer is filled and ready
	 // to be reused
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
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
	 
	 assign do_mvau_stream = inp_active;
      end
      else begin: N_FILTER_BANKS

	 
	 enum logic [1:0] {IDLE, WRITE, READ} pres_state, next_state;
	 // Signal: nf_clr
	 // Signal to reset the nf_cnt counter
	 // Only used when multiple output channel
	 logic 		    nf_clr; // To reset the nf_cnt
	 
	 always_ff @(posedge aclk) begin
	    if(!aresetn)
	      pres_state <= IDLE;
	    else
	      pres_state <= next_state;
	 end

	 always_comb begin
	    case(pres_state)
	      IDLE: begin
		 case({inp_active,sf_full})
		   2'b00:next_state=IDLE;
		   2'b01:next_state=IDLE;
		   2'b10:next_state=WRITE;
		   2'b11:next_state=READ;
		 endcase
	      end
	      WRITE: begin
		 case({inp_active,sf_full})
		   2'b00: next_state = IDLE;
		   2'b01: next_state = IDLE;
		   2'b10: next_state = WRITE;
		   2'b11: next_state = READ;
		 endcase	 
	      end
	      READ: begin
		 case({inp_active, nf_clr&sf_clr})
		   2'b00: next_state = READ;
		   2'b01: next_state = IDLE;
		   2'b10: next_state = WRITE;
		   2'b11: next_state = WRITE;
		 endcase // case ({inp_active, nf_clr&sf_clr})
		 if(inp_active)
		   next_state = WRITE;
		 else
		   next_state = READ;		 
	      end
	      default: next_state = IDLE;	      
	    endcase
	 end		

	 always_comb begin
	    ib_ren = 1'b0;
	    ib_wen = 1'b0;
	    do_mvau_stream = 1'b0;	    
	    case(pres_state)
	      IDLE: begin
		 if(inp_active) begin
		    ib_ren = 1'b0;
		    ib_wen = 1'b1;
		    do_mvau_stream = 1'b1;
		 end
		 else begin
		    ib_ren = 1'b0;
		    ib_wen = 1'b0;
		    do_mvau_stream = 1'b0;
		 end
	      end		 
	      WRITE: begin
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
		   // 2'b10: begin
		   //    ib_ren = 1'b0;
		   //    ib_wen = 1'b1;
		   //    do_mvau_stream = 1'b1;
		   // end
		   // 2'b11: begin
		   //    ib_ren = 1'b0;
		   //    ib_wen = 1'b1;
		   //    do_mvau_stream = 1'b1;		      
		   // end		   
		 endcase // case ({inp_active})
	      end
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
		   // 2'b11: begin
		   //    ib_wen = 1'b1;
		   //    do_mvau_stream = 1'b1;
		   // end
		 endcase // case ({inp_active, nf_clr&sf_clr})
	      end
	      default: begin
		 ib_ren = 1'b0;
		 ib_wen = 1'b0;
		 do_mvau_stream = 1'b0;
	      end
	    endcase // case (pres_state)
	 end // always_comb
	 	 
	 // Signal: nf_cnt
	 // A counter to keep track how many weight channels have been processed
	 // Only used when multiple output channels
	 logic [NF_T-1:0]   nf_cnt; // NF counter, keeping track of the NF
	 logic nf_full;   
	 assign nf_full = (nf_cnt == NF_T'(NF-1) & sf_cnt == SF_T'(SF-1));
	 
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
	 	 
	 // Wready
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
   
      end // block: N_FILTER_BANKS
   endgenerate

   //assign halt_mvau_stream = ((sf_cnt == SF_T'(SF-2)) & wait_rready);
   
   assign sf_full = ((sf_cnt == SF_T'(SF-1)) & do_mvau_stream);
   
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


