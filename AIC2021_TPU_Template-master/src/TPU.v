// `define DATA_SIZE 8
// `define WORD_SIZE 32
// `define GBUFF_ADDR_SIZE 256
// `define GBUFF_INDX_SIZE (GBUFF_ADDR_SIZE/WORD_SIZE)
// `define GBUFF_INDX_SIZE 8
// `define GBUFF_SIZE (WORD_SIZE*GBUFF_ADDR_SIZE)
`include "define.v"
`include "pe.v"
`define LEFT_BUF_SIZE 7 
`define DOWN_BUF_SIZE 11 

module TPU(clk, rst, wr_en_a, wr_en_b, wr_en_o, index_a, index_b, index_o,
		   data_in_a, data_in_b, data_in_o, /*data_out_a, data_out_b,*/
		   data_out_o, m, n, k, start, done);
	input clk, rst, start;
	output reg done, wr_en_a, wr_en_b, wr_en_o;
	input [3:0] m, n, k;
	output reg [`DATA_SIZE-1:0] index_a,
						   index_b,
						   index_o;
	input [`WORD_SIZE-1:0] data_in_a,
						   data_in_b,
						   data_in_o;
	output reg [`WORD_SIZE-1:0] /*data_out_a,
						    data_out_b,*/
						    data_out_o;
	
	reg [`DATA_SIZE-1:0] left_buf0 [`LEFT_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] left_buf1 [`LEFT_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] left_buf2 [`LEFT_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] left_buf3 [`LEFT_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] down_buf0 [`DOWN_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] down_buf1 [`DOWN_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] down_buf2 [`DOWN_BUF_SIZE-1:0];
	reg [`DATA_SIZE-1:0] down_buf3 [`DOWN_BUF_SIZE-1:0];
	wire [`DATA_SIZE-1:0] down_wire0;
	wire [`DATA_SIZE-1:0] down_wire1;
	wire [`DATA_SIZE-1:0] down_wire2;
	wire [`DATA_SIZE-1:0] down_wire3;
	// reg [`DATA_SIZE-1:0] input_buf [3:0];
	reg [`WORD_SIZE-1:0] output_buf [3:0];
	
	//reg [`WORD_SIZE-1:0] mem_o [`GBUFF_ADDR_SIZE-1:0];
	reg [3:0] state,state_nxt;
	parameter [3:0] IDLE 	= 3'd0,
					LOAD 	= 3'd1,
					EXE  	= 3'd2,
					STORE	= 3'd3,
					OUTPUT	= 3'd4,
					DONE 	= 3'd5;
	/*reg [`DATA_SIZE-1:0] mem_a_index,
						 mem_b_index,
						 mem_o_index;*/
	
	integer i;
	//reg [5:0] /*row_buf_a, row_buf_b,*/ base_buf_a;
	//reg [5:0] col_buf_a, col_buf_b, base_buf_b;
	reg weight_en [15:0];
	reg z_weight [15:0];
	wire [23:0] wire_row_0;
	wire [23:0] wire_row_1;
	wire [23:0] wire_row_2;
	wire [23:0] wire_row_3;
	wire [23:0] wire_col_0;
	wire [23:0] wire_col_1;
	wire [23:0] wire_col_2;
	wire [23:0] wire_col_3;
	
	reg [6:0] load_count;
	reg [1:0] out_count;
	reg [4:0] weight_base;
	reg go_pe,pe_ok;
	reg [3:0] temp_m, temp_n, temp_ka, temp_kb, temp_a, temp_b, temp_o;
	reg [3:0] base_a, base_b;
	reg [4:0] exe_count;
	PE pe00(.clk(clk), .rst(rst), 
			.in_left(left_buf0[0]), .in_up(8'd0), .in_weight(data_in_b[31:24]),
			.out_right(wire_row_0[23:16]), .out_down(wire_col_0[23:16]), .weight_en(weight_en[0]),
			.go(go_pe), .z_weight(z_weight[0])
			); 
	PE pe01(.clk(clk), .rst(rst), 
			.in_left(wire_row_0[23:16]), .in_up(8'd0), .in_weight(data_in_b[23:16]),
			.out_right(wire_row_0[15:8]), .out_down(wire_col_1[23:16]), .weight_en(weight_en[1]),
			.go(go_pe), .z_weight(z_weight[1])
			); 
	PE pe02(.clk(clk), .rst(rst), 
			.in_left(wire_row_0[15:8]), .in_up(8'd0), .in_weight(data_in_b[15:8]),
			.out_right(wire_row_0[7:0]), .out_down(wire_col_2[23:16]), .weight_en(weight_en[2]),
			.go(go_pe), .z_weight(z_weight[2])
			); 
	PE pe03(.clk(clk), .rst(rst), 
			.in_left(wire_row_0[7:0]), .in_up(8'd0), .in_weight(data_in_b[7:0]),
			.out_right(), .out_down(wire_col_3[23:16]), .weight_en(weight_en[3]),
			.go(go_pe), .z_weight(z_weight[3])
			); 
	PE pe10(.clk(clk), .rst(rst), 
			.in_left(left_buf1[0]), .in_up(wire_col_0[23:16]), .in_weight(data_in_b[31:24]),
			.out_right(wire_row_1[23:16]), .out_down(wire_col_0[15:8]), .weight_en(weight_en[4]),
			.go(go_pe), .z_weight(z_weight[4])
			);  
	PE pe11(.clk(clk), .rst(rst), 
			.in_left(wire_row_1[23:16]), .in_up(wire_col_1[23:16]), .in_weight(data_in_b[23:16]),
			.out_right(wire_row_1[15:8]), .out_down(wire_col_1[15:8]), .weight_en(weight_en[5]),
			.go(go_pe), .z_weight(z_weight[5])
			); 
	PE pe12(.clk(clk), .rst(rst), 
			.in_left(wire_row_1[15:8]), .in_up(wire_col_2[23:16]), .in_weight(data_in_b[15:8]),
			.out_right(wire_row_1[7:0]), .out_down(wire_col_2[15:8]), .weight_en(weight_en[6]),
			.go(go_pe), .z_weight(z_weight[6])
			); 
	PE pe13(.clk(clk), .rst(rst), 
			.in_left(wire_row_1[7:0]), .in_up(wire_col_3[23:16]), .in_weight(data_in_b[7:0]),
			.out_right(), .out_down(wire_col_3[15:8]), .weight_en(weight_en[7]),
			.go(go_pe), .z_weight(z_weight[7])
			); 
	PE pe20(.clk(clk), .rst(rst), 
			.in_left(left_buf2[0]), .in_up(wire_col_0[15:8]), .in_weight(data_in_b[31:24]),
			.out_right(wire_row_2[23:16]), .out_down(wire_col_0[7:0]), .weight_en(weight_en[8]),
			.go(go_pe), .z_weight(z_weight[8])
			);  
	PE pe21(.clk(clk), .rst(rst), 
			.in_left(wire_row_2[23:16]), .in_up(wire_col_1[15:8]), .in_weight(data_in_b[23:16]),
			.out_right(wire_row_2[15:8]), .out_down(wire_col_1[7:0]), .weight_en(weight_en[9]),
			.go(go_pe), .z_weight(z_weight[9])
			); 
	PE pe22(.clk(clk), .rst(rst), 
			.in_left(wire_row_2[15:8]), .in_up(wire_col_2[15:8]), .in_weight(data_in_b[15:8]),
			.out_right(wire_row_2[7:0]), .out_down(wire_col_2[7:0]), .weight_en(weight_en[10]),
			.go(go_pe), .z_weight(z_weight[10])
			); 
	PE pe23(.clk(clk), .rst(rst), 
			.in_left(wire_row_2[7:0]), .in_up(wire_col_3[15:8]), .in_weight(data_in_b[7:0]),
			.out_right(), .out_down(wire_col_3[7:0]), .weight_en(weight_en[11]),
			.go(go_pe), .z_weight(z_weight[11])
			); 	
	PE pe30(.clk(clk), .rst(rst), 
			.in_left(left_buf3[0]), .in_up(wire_col_0[7:0]), .in_weight(data_in_b[31:24]),
			.out_right(wire_row_3[23:16]), .out_down(down_wire0[7:0]), .weight_en(weight_en[12]),
			.go(go_pe), .z_weight(z_weight[12])
			);  
	PE pe31(.clk(clk), .rst(rst), 
			.in_left(wire_row_3[23:16]), .in_up(wire_col_1[7:0]), .in_weight(data_in_b[23:16]),
			.out_right(wire_row_3[15:8]), .out_down(down_wire1[7:0]), .weight_en(weight_en[13]),
			.go(go_pe), .z_weight(z_weight[13])
			); 
	PE pe32(.clk(clk), .rst(rst), 
			.in_left(wire_row_3[15:8]), .in_up(wire_col_2[7:0]), .in_weight(data_in_b[15:8]),
			.out_right(wire_row_3[7:0]), .out_down(down_wire2[7:0]), .weight_en(weight_en[14]),
			.go(go_pe), .z_weight(z_weight[14])
			); 
	PE pe33(.clk(clk), .rst(rst), 
			.in_left(wire_row_3[7:0]), .in_up(wire_col_3[7:0]), .in_weight(data_in_b[7:0]),
			.out_right(), .out_down(down_wire3[7:0]), .weight_en(weight_en[15]),
			.go(go_pe), .z_weight(z_weight[15])
			); 			
	always @(*) begin
		case (state)
			IDLE: begin
				go_pe = 0; pe_ok = 0; done = 0;
				wr_en_a = 0; wr_en_b = 0; wr_en_o = 0;
				
				weight_base = 0; load_count = 0;
				//mem_a_index = 0; mem_b_index = 0; mem_o_index = 0;
				index_a = 0; index_b = 0; index_o = 0;
				//row_buf_a = 0; row_buf_b = 0; 
				//col_buf_a = 0; col_buf_b = 0;
				//base_buf_a = 0; base_buf_b = 0;
				temp_m = m; temp_n = n; temp_ka = k; temp_kb = k;
				temp_a = 0; temp_b = 0; temp_o = 0;
				base_a = 0; base_b = 0;
				exe_count = 0;
				out_count = 0;
				wr_en_o = 0;
				if(start == 1'b1) state_nxt = LOAD;
				else state_nxt = IDLE;
			end
			LOAD: begin
				exe_count = 0;
				out_count = 0;
				for(i = 0; i <= 15; i = i + 1) begin
					z_weight[i] = 0;
				end
				go_pe = 0;
				pe_ok = 0;
				wr_en_a = 1'b0; //buffer read
				wr_en_b = 1'b0;
				wr_en_o = 0;
				
				index_a = temp_a + 1;
				index_b = temp_b + 1;
				if(load_count == 0 && temp_a < k) begin
					{left_buf0[0],left_buf0[1],left_buf0[2],left_buf0[3],left_buf0[4],left_buf0[5],left_buf0[6]} = {data_in_a, 24'd0};
				end
				else if(load_count == 1 && temp_a < k) begin
					{left_buf1[0],left_buf1[1],left_buf1[2],left_buf1[3],left_buf1[4],left_buf1[5],left_buf1[6]} = {8'd0,data_in_a, 16'd0};
				end
				else if(load_count == 2 && temp_a < k) begin
					{left_buf2[0],left_buf2[1],left_buf2[2],left_buf2[3],left_buf2[4],left_buf2[5],left_buf2[6]} = {16'd0,data_in_a, 8'd0};
				end
				else if(load_count == 3 && temp_a < k) begin
					{left_buf3[0],left_buf3[1],left_buf3[2],left_buf3[3],left_buf3[4],left_buf3[5],left_buf3[6]} = {24'd0,data_in_a};
				end
				
				if(index_a >= k || (index_a) % 4 == 0) begin
					if(load_count != 0) 
						state_nxt = EXE;
					else
						state_nxt = LOAD;
				end
				else begin
					state_nxt = LOAD;
				end
				for(i = 0; i <= 15; i = i + 1) begin
					if(i >= weight_base && i <= (weight_base + 3)) begin 
						weight_en[i] = 1;
						if(temp_b > k) begin
							z_weight[i] = 1;
						end
					end
					else begin
						weight_en[i] = 0;
					end
				end
				// temp_a <= temp_a + 1; 
				// temp_b <= temp_b + 1;
			end
			EXE: begin
				weight_base = 0;
				wr_en_o = 0;
				go_pe = 1;
				for(i = 0; i <= 15; i = i + 1) begin
					weight_en[i] = 0;
				end
				
				if(exe_count == 11) begin
					pe_ok = 1;
					state_nxt = STORE;
				end
				else begin 
					pe_ok = 0;
					state_nxt = EXE;
				end
				/*
				if(pe_ok) begin
					if(temp_b >= k) begin
						state_nxt = STORE;
					end
					else begin
						state_nxt = LOAD;
					end
				end
				*/
				
			end
			STORE: begin
				wr_en_o = 0;
				// output_buf[0] = output_buf[0] + {down_buf3[4],down_buf2[5],down_buf1[6],down_buf0[7]};
				// output_buf[1] = output_buf[1] + {down_buf3[3],down_buf2[4],down_buf1[5],down_buf0[6]};
				// output_buf[2] = output_buf[2] + {down_buf3[2],down_buf2[3],down_buf1[4],down_buf0[5]};
				// output_buf[3] = output_buf[3] + {down_buf3[1],down_buf2[2],down_buf1[3],down_buf0[4]};
				if( ((base_a + 1) % k == 0 ) || ((base_a + 2) % k == 0 ) || ((base_a + 3) % k == 0 ) || ((base_a + 4) % k == 0 ) && ((base_b + 1) % k == 0 ) || ((base_b + 2) % k == 0 ) || ((base_b + 3) % k == 0 ) || ((base_b + 4) % k == 0 )) begin
					state_nxt = OUTPUT;
				end
				else begin
					base_a = base_a + 4;
					base_b = base_b + 4;
					
					state_nxt = LOAD;
					load_count = 0;
				end
					/*
					if( base_a == ((m-1)/4)*k ) begin
						base_b = base_b + k;
						base_a = 0;
					end
					else begin
						base_a = base_a + k;
						base_b = base_b;
					end
					*/
			end
			OUTPUT: begin
				wr_en_o = 1'b1; //buffer write
				if(out_count == 0) begin
					data_out_o = output_buf[0];
				end
				else if(out_count == 1) begin
					data_out_o = output_buf[1];
				end
				else if(out_count == 2) begin
					data_out_o = output_buf[2];
				end
				else if(out_count == 3) begin
					data_out_o = output_buf[3];
				end
				
				if( (temp_o+1) % 4 == 0) begin
					if(temp_o >= ((((n-1)/4)+1)*m)-1 ) begin
						state_nxt = DONE;
					end
					else begin
						if( (temp_o - 1) % k == 0) begin
							for(i=0; i<4; i=i+1) begin
								output_buf[i] = 0;
							end
						end
						else begin
							for(i=0; i<4; i=i+1) begin
								output_buf[i] = output_buf[i];
							end
						end
						state_nxt = LOAD;
						load_count = 0;
						
						
						if( (base_a + 1) % k == 0) base_a = base_a + 1;
						else if( (base_a + 2) % k == 0) base_a = base_a + 2;
						else if( (base_a + 3) % k == 0) base_a = base_a + 3;
						else if( (base_a + 4) % k == 0) base_a = base_a + 4;
						base_b = ((temp_o+1) / k) * k;
						
						
					end
				end
				else begin
					state_nxt = OUTPUT;
				end
			end
			DONE: begin
				wr_en_o = 0;
				done = 1;
			end
			default: begin
			
			end
			
		endcase
	end
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE; //state_nxt <= IDLE;
			done <= 1'b0; wr_en_a <= 1'b0; wr_en_b <= 1'b0; wr_en_o <= 1'b0;
			/*data_out_a = 0; data_out_b = 0;*/ data_out_o = 0;
			/*
			for(i=0; i<=`GBUFF_ADDR_SIZE; i=i+1) begin
				mem_a[i] <= 0;
				mem_b[i] <= 0;
				mem_o[i] <= 0;
			end
			*/
			for(i=0; i<=`LEFT_BUF_SIZE-1; i=i+1) begin
				left_buf0[i] <= 0;
				left_buf1[i] <= 0;
				left_buf2[i] <= 0;
				left_buf3[i] <= 0;
			end
			for(i=0; i<=`DOWN_BUF_SIZE-1; i=i+1) begin
				down_buf0[i] <= 0;
				down_buf1[i] <= 0;
				down_buf2[i] <= 0;
				down_buf3[i] <= 0;
			end
			for(i=0; i<4; i=i+1) begin
				output_buf[i] <= 0;
			end
			
		end
		else begin
			state <= state_nxt;
			case (state)
				IDLE: begin
				
				end
				LOAD: begin
					load_count <= load_count + 1;
					// index_a <= temp_a + 1;
					// index_b <= temp_b + 1;
					// index_a <= index_a + 1;
					// index_b <= index_b + 1;
					if(load_count <= 3) begin 
						temp_a <= temp_a + 1; 
						temp_b <= temp_b + 1;
					end
					else begin
						temp_a <= temp_a;
						temp_b <= temp_b;
					end
					if(weight_base == 15) weight_base <= 0;
					else weight_base <= weight_base + 4;
				end
				EXE: begin
					down_buf0[0] <= down_wire0[7:0];
					down_buf1[0] <= down_wire1[7:0];
					down_buf2[0] <= down_wire2[7:0];
					down_buf3[0] <= down_wire3[7:0];
					for(i = 0; i < 7; i = i + 1) begin
						left_buf0[i] <= left_buf0[i+1];
						left_buf1[i] <= left_buf1[i+1];
						left_buf2[i] <= left_buf2[i+1];
						left_buf3[i] <= left_buf3[i+1];
						left_buf0[6] <= 0;
						left_buf1[6] <= 0;
						left_buf2[6] <= 0;
						left_buf3[6] <= 0;
					end
					for(i = 0; i < 11; i = i + 1) begin
						down_buf0[i+1] <= down_buf0[i];
						down_buf1[i+1] <= down_buf1[i];
						down_buf2[i+1] <= down_buf2[i];
						down_buf3[i+1] <= down_buf3[i];
					end
					exe_count <= exe_count + 1;
				end
				STORE: begin
					temp_a <= base_a;
					temp_b <= base_b;
					output_buf[0] <= output_buf[0] + {down_buf3[4],down_buf2[5],down_buf1[6],down_buf0[7]};
					output_buf[1] <= output_buf[1] + {down_buf3[3],down_buf2[4],down_buf1[5],down_buf0[6]};
					output_buf[2] <= output_buf[2] + {down_buf3[2],down_buf2[3],down_buf1[4],down_buf0[5]};
					output_buf[3] <= output_buf[3] + {down_buf3[1],down_buf2[2],down_buf1[3],down_buf0[4]};
				end					
				OUTPUT: begin
				/*
					if(out_count == 0) begin
						data_out_o <= {down_buf0[4],down_buf0[5],down_buf0[6],down_buf0[7]};
					end
					else(out_count == 1) begin
						data_out_o <= {down_buf1[5],down_buf1[6],down_buf1[7],down_buf1[8]};
					end
					else(out_count == 2) begin
						data_out_o <= {down_buf2[6],down_buf2[7],down_buf2[8],down_buf2[9]};
					end
					else(out_count == 3) begin
						data_out_o <= {down_buf3[7],down_buf3[8],down_buf3[9],down_buf3[10]};
					end
				*/
					out_count <= out_count + 1;
					index_o <= index_o + 1;
					temp_o <= temp_o + 1;
				/*
					if(mem_o_index < (m * k)) begin
						data_out_o <= mem_o[mem_o_index];
						mem_o_index <= mem_o_index + 1;
						index_o <= index_o + 1;
					end
					else if(mem_o_index == (m * k)) begin
						done <= 1;
					end
				*/
				end
				DONE: begin
				
				end				
				default: begin
				
				end			
			endcase
		end
	end
endmodule