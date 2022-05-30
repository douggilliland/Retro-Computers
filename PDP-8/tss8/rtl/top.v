//
// pdp-8/i in verilog - fpga top level
// copyright Brad Parker <brad@heeltoe.com> 2009-2010
//

`timescale 1ns / 1ns

module top(rs232_txd, rs232_rxd,
	   button, led, sysclk,
	   sevenseg, sevenseg_an,
	   slideswitch,
	   sram_a, sram_oe_n, sram_we_n,
	   sram1_io, sram1_ce_n, sram1_ub_n, sram1_lb_n,
	   sram2_io, sram2_ce_n, sram2_ub_n, sram2_lb_n,
	   ide_data_bus, ide_dior, ide_diow, ide_cs, ide_da);

   input	rs232_rxd;
   output	rs232_txd;

   input [3:0] 	button;

   output [7:0] led;
   input 	sysclk;

   output [7:0] sevenseg;
   output [3:0] sevenseg_an;

   input [7:0] 	slideswitch;

   output [17:0] sram_a;
   output 	 sram_oe_n;
   output 	 sram_we_n;

   inout [15:0]	 sram1_io;
   output 	 sram1_ce_n;
   output 	 sram1_ub_n;
   output 	 sram1_lb_n;

   inout [15:0]	 sram2_io;
   output 	 sram2_ce_n;
   output 	 sram2_ub_n;
   output 	 sram2_lb_n;
   
   inout [15:0]  ide_data_bus;
   output 	 ide_dior;
   output 	 ide_diow;
   output [1:0]  ide_cs;
   output [2:0]  ide_da;

   wire [15:0] 	 ide_data_in;
   wire [15:0] 	 ide_data_out;

   // -----------------------------------------------------------------

`ifndef sim_time
// `define slower
`endif

`ifdef slower
   reg clk;
   reg [24:0] clkdiv;
   wire [24:0] clkmax;

   assign clkmax = (slideswitch[3:0] == 4'd0)  ? 25'h1 :
		   (slideswitch[3:0] == 4'd1)  ? 25'h2 :
		   (slideswitch[3:0] == 4'd2)  ? 25'h1ff :
		   (slideswitch[3:0] == 4'd3)  ? 25'h7ff :
		   (slideswitch[3:0] == 4'd4)  ? 25'h1fff :
		   (slideswitch[3:0] == 4'd5)  ? 25'h7fff :
		   (slideswitch[3:0] == 4'd6)  ? 25'h1ffff :
		   (slideswitch[3:0] == 4'd7)  ? 25'h7ffff :
		   (slideswitch[3:0] == 4'd8)  ? 25'h1fffff :
		   (slideswitch[3:0] == 4'd9)  ? 25'h3fffff :
		   (slideswitch[3:0] == 4'd10) ? 25'h7fffff :
   		   (slideswitch[3:0] == 4'd11) ? 25'hffffff :
		   25'h1ffffff;
     
   always @(posedge sysclk)
     begin
        if (clkdiv == clkmax)
	  begin
             clk <= ~clk;
             clkdiv <= 0;
	  end
	else
          clkdiv <= clkdiv + 25'b1;
     end
`else
   wire 	clk;
   assign clk = sysclk;
`endif

   // -------------------------------------------------------------
   
   reg [11:0] switches;
   wire       reset;

   wire [11:0] ram_data_in;
   wire        ram_rd;
   wire        ram_wr;
   wire [11:0] ram_data_out;
   wire [14:0] ram_addr;
   wire [11:0] io_data_in;
   wire [11:0] io_data_out;
   wire        io_data_avail;
   wire        io_interrupt;
   wire        io_skip;
   wire [5:0]  io_select;
   
   wire        iot;
   wire [3:0]  state;
   wire [11:0] mb;

   wire        ext_ram_read_req;
   wire        ext_ram_write_req;
   wire [14:0] ext_ram_ma;
   wire [11:0] ext_ram_in;
   wire        ext_ram_done;
   wire [11:0] ext_ram_out;

   wire [14:0] initial_pc;
   wire [11:0] pc;
   wire [11:0] ac;
   
   debounce reset_sw(.clk(sysclk), .in(button[3]), .out(reset));

   display show_pc(.clk(sysclk), .reset(reset),
		   .pc(pc), .dots(ac[3:0]),
		   .sevenseg(sevenseg), .sevenseg_an(sevenseg_an));
   assign led = ac[11:4];
   
  pdp8 cpu(.clk(clk),
	   .reset(reset),
	   .initial_pc(initial_pc),
	   .pc_out(pc),
	   .ac_out(ac),
	   .ram_addr(ram_addr),
	   .ram_data_in(ram_data_out),
	   .ram_data_out(ram_data_in),
	   .ram_rd(ram_rd),
	   .ram_wr(ram_wr),
	   .state(state),
	   .io_select(io_select),
	   .io_data_in(io_data_in),
	   .io_data_out(io_data_out),
	   .io_data_avail(io_data_avail),
	   .io_interrupt(io_interrupt),
	   .io_skip(io_skip),
	   .io_clear_ac(io_clear_ac),
	   .iot(iot),
	   .mb(mb),
	   .switches(switches),
	   .ext_ram_read_req(ext_ram_read_req),
	   .ext_ram_write_req(ext_ram_write_req),
	   .ext_ram_done(ext_ram_done),
	   .ext_ram_ma(ext_ram_ma),
	   .ext_ram_in(ext_ram_out),
	   .ext_ram_out(ext_ram_in));
   
   pdp8_io io(.clk(clk),
	      .brgclk(sysclk),
	      .reset(reset),
	      .iot(iot),
	      .state(state),
	      .mb(mb),
	      .io_data_in(io_data_out),
	      .io_data_out(io_data_in),
	      .io_select(io_select),
	      .io_data_avail(io_data_avail),
	      .io_interrupt(io_interrupt),
	      .io_skip(io_skip),
   	      .io_clear_ac(io_clear_ac),
	      .io_ram_read_req(ext_ram_read_req),
	      .io_ram_write_req(ext_ram_write_req),
	      .io_ram_done(ext_ram_done),
	      .io_ram_ma(ext_ram_ma),
	      .io_ram_in(ext_ram_in),
	      .io_ram_out(ext_ram_out),
   	      .ide_dior(ide_dior),
	      .ide_diow(ide_diow),
	      .ide_cs(ide_cs),
	      .ide_da(ide_da),
	      .ide_data_in(ide_data_in),
	      .ide_data_out(ide_data_out),
	      .rs232_in(rs232_rxd),
	      .rs232_out(rs232_txd));

   assign ide_data_bus = ~ide_diow ? ide_data_out : 16'bz;
   assign ide_data_in = ide_data_bus;
   
   pdp8_ram ram(.clk(clk),
		.reset(reset), 
		.addr(ram_addr),
		.data_in(ram_data_in),
		.data_out(ram_data_out),
		.rd(ram_rd),
   		.wr(ram_wr),

   		.sram_a(sram_a),
		.sram_oe_n(sram_oe_n), .sram_we_n(sram_we_n),

		.sram1_io(sram1_io), .sram1_ce_n(sram1_ce_n),
		.sram1_ub_n(sram1_ub_n), .sram1_lb_n(sram1_lb_n),
		   
		.sram2_io(sram2_io), .sram2_ce_n(sram2_ce_n), 
		.sram2_ub_n(sram2_ub_n), .sram2_lb_n(sram2_lb_n));

   assign initial_pc = 15'o07400;

endmodule

