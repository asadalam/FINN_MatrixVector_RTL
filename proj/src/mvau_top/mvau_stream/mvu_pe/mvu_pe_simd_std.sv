/* 
 * Module: Standard Multiplication based SIMD (mvu_pe_simd_std.sv)
 * 
 * Author(s): Syed Asad Alam <syed.asad.alam@tcd.ie>
 *
 * This file lists an RTL implementation of a SIMD unit based on standard
 * multiplication when word length >= 2. It is part of a processing element
 * which is part of the Matrix-Vector-Multiplication Unit
 *
 * This material is based upon work supported, in part, by Science Foundation
 * Ireland, www.sfi.ie under Grant No. 13/RC/2094 and, in part, by the 
 * European Union's Horizon 2020 research and innovation programme under the 
 * Marie Sklodowska-Curie grant agreement Grant No.754489. 
 *
 * Inputs:
 * [TSrc-1:0] in_act - Input activation stream, word length TSrcI
 * [TW-1:0]   in_wgt - Input weight, word length TW
 * 
 * Outputs:
 * [TDstI-1:0] out   - Output stream, word length TDstI
 * 
 * Parameters:
 * TSrcI - Input word length
 * TW - Weight word length
 * TDstI - Output word length
 * */

`timescale 1ns/1ns

module mvu_pe_simd_std #(
			 parameter int TSrcI=4,
			 parameter int TW=4,
			 parameter int TDstI=16,
			 parameter int OP_SGN=0)
   ( 
     input logic [TSrcI-1:0]  in_act, //Input activation
     input logic  [TW-1:0]     in_wgt, //Input weight
     output logic  [TDstI-1:0] out); //Output   

  if(OP_SGN == 0) begin: UNSIGNED // Both operators unsigned
     // Always_COMB: SIMD_MUL
     // SIMD only performs multiplication
     always_comb begin
	out = in_act*in_wgt;
     end
end   
  else if(OP_SGN == 1) begin: ACT_SGN
     always_comb begin
	out = $signed(in_act)*$signed({1'b0,in_wgt});
     end
end
  else if(OP_SGN == 2) begin: WGT_SGN
     always_comb begin
	out = $signed({1'b0,in_act})*$signed(in_wgt);
     end
end
  else if(OP_SGN == 3) begin: ALL_SGN
     always_comb begin
	out = $signed(in_act) * $signed(in_wgt);
     end
end
      
endmodule // mvu_simd

