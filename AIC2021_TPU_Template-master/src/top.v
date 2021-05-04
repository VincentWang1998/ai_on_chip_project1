//============================================================================//
// AIC2021 Project1 - TPU Design                                              //
// file: pe.v                                                                 //
// description: Top module                                                    //
// authors: yuwen (vincent08tw@yahoo.com.tw)                                  //
//                                                                            //
//============================================================================//
`include "define.v"
`include "global_buffer.v"
`include "TPU.v"

module top(clk, rst, start, m, n,  k, done);

  input clk;
  input rst;
  input start;
  input [3:0] m, k, n;
  output reg done;
  wire done_wire;
  wire                  wr_en_a,
                        wr_en_b,
                        wr_en_out;
  wire  [`DATA_SIZE-1:0] index_a,
                        index_b,
                        index_out;
  wire  [`WORD_SIZE-1:0] data_in_a,
                        data_in_b,
                        data_in_o;
  wire [`WORD_SIZE-1:0] data_out_a,
                        data_out_b,
                        data_out_o;

//----------------------------------------------------------------------------//
// TPU module declaration                                                     //
//----------------------------------------------------------------------------//
  //****TPU tpu1(); add your design here*****//
 TPU tpu1(.clk			(clk),
		  .rst			(rst),
		  .wr_en_a		(wr_en_a),
		  .wr_en_b		(wr_en_b),
		  .wr_en_o		(wr_en_out),
		  .index_a		(index_a),
		  .index_b		(index_b),
		  .index_o		(index_out),
		  .data_in_a	(data_out_a),
		  .data_in_b	(data_out_b),
		  .data_in_o	(data_out_o),
		  //.data_out_a	(data_in_a),
		  //.data_out_b	(data_in_b),
		  .data_out_o	(data_in_o),
		  .m			(m),
		  .n			(n),
		  .k			(k),
		  .start		(start),
		  .done			(done_wire)
		  );
//----------------------------------------------------------------------------//
// Global buffers declaration                                                 //
//----------------------------------------------------------------------------//
  global_buffer GBUFF_A(.clk     (clk       ),
                        .rst     (rst       ),
                        .wr_en   (wr_en_a   ),
                        .index   (index_a   ),
                        .data_in (data_in_a ),
                        .data_out(data_out_a));

  global_buffer GBUFF_B(.clk     (clk       ),
                        .rst     (rst       ),
                        .wr_en   (wr_en_b   ),
                        .index   (index_b   ),
                        .data_in (data_in_b ),
                        .data_out(data_out_b));

  global_buffer GBUFF_OUT(.clk     (clk      ),
                          .rst     (rst      ),
                          .wr_en   (wr_en_out),
                          .index   (index_out),
                          .data_in (data_in_o),
                          .data_out(data_out_o));
						  
	always @(*) begin
		done = done_wire;
	end

endmodule
