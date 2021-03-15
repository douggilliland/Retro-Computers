// this is verilator_pdp8.v
// test bench top end for pdp8.v

`define debug
`define sim_time
`define debug_s3ram
`define use_sim_ram_model
`define use_fake_uart
`define debug_ram
//`define debug_vcd
//`define debug_log

`include "../rtl/pdp8_tt.v"
`include "../rtl/pdp8_rf.v"
`include "../rtl/pdp8_kw.v"
`include "../rtl/pdp8_io.v"
`include "../rtl/pdp8_ram.v"
`include "../rtl/pdp8.v"

`ifdef use_fake_uart
 `include "../verif/fake_uart.v"
`else
 `include "../rtl/uart.v"
`endif

`include "../rtl/brg.v"

`include "../rtl/ide_disk.v"
`include "../rtl/ide.v"
`include "../rtl/ram_256x12.v"

`include "../rtl/bootrom.v"

`ifdef use_sim_ram_model
 `include "../rtl/ram_32kx12.v"
`else
`include "../verif/ram_s3board.v"
`endif

`timescale 1ns / 1ns

module wrap_ide(clk, ide_data_in, ide_data_out,
		ide_dior, ide_diow, ide_cs, ide_da);

   input clk;
   input [15:0]  ide_data_in;
   output [15:0] ide_data_out;
   input 	 ide_dior;
   input 	 ide_diow;
   input [1:0] 	 ide_cs;
   input [2:0] 	 ide_da;
		
   import "DPI-C" function void dpi_ide(input integer data_in,
					output integer data_out,
				        input integer dior,
				        input integer diow,
				        input integer cs,
				        input integer da);

   integer dbi, dbo;
   wire [31:0] dboo;
      
   assign dbi = {16'b0, ide_data_in};
   assign dboo = dbo;

   assign ide_data_out = dboo[15:0];

   always @(posedge clk)
     begin
	dpi_ide(dbi,
		dbo,
		{31'b0, ide_dior}, 
		{31'b0, ide_diow},
		{30'b0, ide_cs},
		{29'b0, ide_da});

`ifdef debug_ide
	if (ide_dior == 0)
	  begin
	     $display("wrap_ide: read (%b %b) %x %x %x %x",
		      ide_dior, ide_diow, dbo, dboo, dboo[15:0], ide_data_out);
	  end
	if (ide_diow == 0)
	  begin
	     $display("wrap_ide: write (%b %b) %x %x %x",
		      ide_dior, ide_diow, dbo, dboo, ide_data_out);
	  end
`endif
     end

endmodule

module test;

   reg sysclk/*verilator public_flat_rw @(clk)*/;
   wire clk;
   reg reset/*verilator public_flat_rw @(clk) */;
   reg [11:0] switches;

   wire [14:0] initial_pc;
   wire [11:0] pc_out;
   wire [11:0] ac_out;
   
   wire [11:0] ram_data_in;
   wire        ram_rd;
   wire        ram_wr;
   wire [11:0] ram_data_out;
   wire [14:0] ram_addr;
   wire [11:0] io_data_in;
   wire [11:0] io_data_out;
   wire [11:0] io_addr;
   wire        io_data_avail;
   wire        io_interrupt;
   wire        io_skip;
   wire        io_clear_ac;
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

   wire [17:0] sram_a;
   wire        sram_oe_n;
   wire        sram_we_n;
   wire [15:0] sram1_io;
   wire        sram1_ce_n;
   wire        sram1_ub_n;
   wire        sram1_lb_n;
   wire [15:0] sram2_io;
   wire        sram2_ce_n;
   wire        sram2_ub_n;
   wire        sram2_lb_n;

   wire [15:0] 	ide_data_in;
   wire [15:0] 	ide_data_out;
   wire 	ide_dior, ide_diow;
   wire [1:0] 	ide_cs;
   wire [2:0] 	ide_da;

   reg 	       rs232_in;
   wire        rs232_out;

//   always @(posedge sysclk)
//     clk <= ~clk;
   assign clk = sysclk;
      
  pdp8 cpu(.clk(clk),
	   .reset(reset),
	   .initial_pc(initial_pc),
	   .pc_out(pc_out),
	   .ac_out(ac_out),
	   .ram_addr(ram_addr),
	   .ram_data_in(ram_data_out),
	   .ram_data_out(ram_data_in),
	   .ram_rd(ram_rd),
	   .ram_wr(ram_wr),
	   .io_select(io_select),
	   .io_data_in(io_data_in),
	   .io_data_out(io_data_out),
	   .io_data_avail(io_data_avail),
	   .io_interrupt(io_interrupt),
	   .io_skip(io_skip),
	   .io_clear_ac(io_clear_ac),
	   .switches(switches),
	   .iot(iot),
	   .state(state),
	   .mb(mb),
	   .ext_ram_read_req(ext_ram_read_req),
	   .ext_ram_write_req(ext_ram_write_req),
	   .ext_ram_done(ext_ram_done),
	   .ext_ram_ma(ext_ram_ma),
	   .ext_ram_in(ext_ram_out),
	   .ext_ram_out(ext_ram_in));
   
   pdp8_io io(.clk(clk),
	      .brgclk(clk),
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
	      .rs232_in(rs232_in),
	      .rs232_out(rs232_out));

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
   
`ifndef use_sim_ram_model
   ram_s3board sram(.ram_a(sram_a),
		    .ram_oe_n(sram_oe_n),
		    .ram_we_n(sram_we_n),
		    .ram1_io(sram1_io),
		    .ram1_ce_n(sram1_ce_n),
		    .ram1_ub_n(sram1_ub_n), .ram1_lb_n(sram1_lb_n),
		    .ram2_io(sram2_io),
		    .ram2_ce_n(sram2_ce_n),
		    .ram2_ub_n(sram2_ub_n), .ram2_lb_n(sram2_lb_n));
`endif
   
   wrap_ide wrap_ide(.clk(clk),
		     .ide_data_in(ide_data_out),
		     .ide_data_out(ide_data_in),
		     .ide_dior(ide_dior),
		     .ide_diow(ide_diow),
		     .ide_cs(ide_cs),
		     .ide_da(ide_da));
   
endmodule

