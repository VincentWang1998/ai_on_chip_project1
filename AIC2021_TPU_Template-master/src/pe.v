//============================================================================//
// AIC2021 Project1 - TPU Design                                              //
// file: pe.v                                                                 //
// description: processing element module                                     //
// authors: yuwen (vincent08tw@yahoo.com.tw)                                  //
//                                                                            //
//============================================================================//

`include "define.v"

module PE(clk,rst,in_left,in_up,in_weight,out_right,out_down,weight_en,go,z_weight);
	
	input clk, rst;
	input [`DATA_SIZE-1:0] in_left;
	input [`DATA_SIZE-1:0] in_up;
	input [`DATA_SIZE-1:0] in_weight;
	output reg [`DATA_SIZE-1:0] out_right;
	output reg [`DATA_SIZE-1:0] out_down;
	input weight_en,go,z_weight;
	
	reg [`DATA_SIZE-1:0] weight;
	always @(*) begin
		if(z_weight) begin
			weight = 0;
		end
		else begin
			// if(weight_en) weight = in_weight;
			// else weight = weight;
		end
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			out_right <= 0; out_down <= 0;
			weight <= 0;
		end
		else begin
			if(weight_en) weight = in_weight;
			else weight = weight;
			
			if(go) begin
				out_right <= in_left;
				out_down <= in_up + (in_left * weight);
			end
			else begin
				out_right <= 0;
				out_down <= 0;
			end
		end
	end
endmodule
