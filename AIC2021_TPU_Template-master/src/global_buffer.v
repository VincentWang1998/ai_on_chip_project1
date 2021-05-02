//============================================================================//
// AIC2021 Project1 - TPU Design                                              //
// file: global_buffer.v                                                      //
// description: global buffer read write behavior module                      //
// authors: kaikai (deekai9139@gmail.com)                                     //
//          suhan  (jjs93126@gmail.com)                                       //
//============================================================================//

`include "define.v"

module global_buffer(clk, rst, wr_en, index, data_in, data_out);

  input clk;
  input rst;
  input wr_en; // Write enable: 1->write 0->read
  input      [`GBUFF_INDX_SIZE-1:0] index;
  input      [`WORD_SIZE-1:0]       data_in;
  output reg [`WORD_SIZE-1:0]       data_out;
  integer i;
  reg wr_en_reg;
//----------------------------------------------------------------------------//
// Global buffer (Don't change the name)                                      //
//----------------------------------------------------------------------------//
  //reg [`GBUFF_ADDR_SIZE-1:0] gbuff [`WORD_SIZE-1:0];
  reg [`WORD_SIZE-1:0] gbuff [`GBUFF_ADDR_SIZE-1:0];

//----------------------------------------------------------------------------//
// Global buffer read write behavior                                          //
//----------------------------------------------------------------------------//
  always @ (*) begin
	wr_en_reg = wr_en;
  end
  always @ (posedge clk or posedge rst) begin
    if(rst)begin
      for(i=0; i<=256; i=i+1)
        gbuff[i] <= 32'd0;
    end
    else begin
      if(wr_en_reg) begin
        gbuff[index] <= data_in;
      end
      else begin
        data_out <= gbuff[index];
      end
    end
  end

endmodule
