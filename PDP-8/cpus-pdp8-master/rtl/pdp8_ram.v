//
// interface to async sram
// used on s3board
//
// multiplexes between to high speed SRAMs
//

//`define use_sim_model 1

module pdp8_ram(clk, reset, addr, data_in, data_out, rd, wr,
		sram_a, sram_oe_n, sram_we_n,
		sram1_io, sram1_ce_n, sram1_ub_n, sram1_lb_n,
		sram2_io, sram2_ce_n, sram2_ub_n, sram2_lb_n);

   input clk;
   input reset;
   input [14:0] addr;
   input [11:0] data_in;
   output [11:0] data_out;
   input 	 rd;
   input 	 wr;

   output [17:0] sram_a;
   output 	 sram_oe_n, sram_we_n;
   inout [15:0]  sram1_io;
   output 	 sram1_ce_n, sram1_ub_n, sram1_lb_n;
   inout [15:0]  sram2_io;
   output 	 sram2_ce_n, sram2_ub_n, sram2_lb_n;

   //
   wire 	 rom_decode;
   wire [11:0] 	 rom_data;
   
   bootrom rom(.clk(clk),
	       .reset(reset),
	       .addr(addr),
	       .data_out(rom_data),
	       .rd(rd),
	       .selected(rom_decode));
   
   
`ifdef use_sim_ram_model

   wire [11:0] 	 sram_data_in;
   wire [11:0] 	 sram_data_out;
   
   ram_32kx12 ram(.A(addr),
		  .DI(sram_data_in),
		  .DO(sram_data_out),
		  .CE_N(1'b0),
		  .WE_N(~wr));

   assign sram_data_in = data_in;
   
   assign data_out = rom_decode ? rom_data : sram_data_out;

//   always @(posedge clk)
//     $display("addr %o, rom_decode %b %o", addr, rom_decode, rom_data);
   
`else
   //
   wire sram1_ub, sram1_lb;

   // common
   assign sram_a = {3'b0, addr};
   assign sram_oe_n = ~rd;
   assign sram_we_n = ~wr;

   // sram1
   assign sram1_ub = 1'b1;
   assign sram1_lb = 1'b1;

   assign sram1_ce_n = 1'b0;
   assign sram1_ub_n = ~sram1_ub;
   assign sram1_lb_n = ~sram1_lb;

   assign data_out = rom_decode ? rom_data : sram1_io[11:0];
   assign sram1_io = ~sram_oe_n ? 16'bz : {4'b0, data_in};

   // sram2 not used
   assign sram2_io = 16'b0;
   assign sram2_ce_n = 1'b1;
   assign sram2_ub_n = 1'b1;
   assign sram2_lb_n = 1'b1;
`endif

endmodule

