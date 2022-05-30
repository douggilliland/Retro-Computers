// video_mem.v

/* 2kx8 static sync ram */

module video_ram(addr, data_in, data_out, clk_r, clk_w, we_n);

   input [11:0] addr;
   input [7:0] 	data_in;
   input 	clk_r, clk_w, we_n;
   output [7:0] data_out;

   reg [7:0] 	ram [0:2048];
   reg [11:0] 	ram_addr_w;
   reg [11:0] 	ram_addr_r;

   always @(posedge clk_w)
     begin
	ram_addr_w <= addr;
	if (we_n == 0)
          ram[ram_addr_w] <= data_in;
    end

   always @(posedge clk_r)
     begin
	ram_addr_r <= addr;
     end
   
   assign data_out = ram[ram_addr_r];

//   assign data_out = 8'h20 + addr[7:0];

endmodule
