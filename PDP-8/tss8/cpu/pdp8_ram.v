//

`include "ram_32kx12.v"

module pdp8_ram(clk, reset, addr, data_in, data_out, rd, wr);

   input clk;
   input reset;
   input [14:0] addr;
   input [11:0] data_in;
   output [11:0] data_out;
   input 	 rd;
   input 	 wr;

   
   ram_32kx12 ram(.A(addr),
		  .DI(data_in),
		  .DO(data_out),
		  .CE_N(1'b0),
		  .WE_N(~wr));

endmodule
