// run_io.v
// testing top end for pdp8_io.v
//

`define debug
`define sim_time

`include "../rtl/pdp8_tt.v"
`include "../rtl/pdp8_rf.v"
`include "../rtl/pdp8_kw.v"
`include "../rtl/pdp8_io.v"

`include "../verif/fake_uart.v"
`include "../rtl/brg.v"

`include "../rtl/ide_disk.v"
`include "../rtl/ide.v"
`include "../rtl/ram_256x12.v"


`timescale 1ns / 1ns

module test;

   reg clk, reset;

   wire [11:0] io_data_in;
   wire [11:0] io_data_out;
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

   wire [15:0] ide_data_bus;
   wire        ide_dior, ide_diow;
   wire [1:0]  ide_cs;
   wire [2:0]  ide_da;

   reg 	       rs232_in;
   wire        rs232_out;
   
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
	      .ide_data_bus(ide_data_bus),
	      .rs232_in(rs232_in),
	      .rs232_out(rs232_out));

  initial
    begin
      $timeformat(-9, 0, "ns", 7);

      $dumpfile("pdp8_io.vcd");
      $dumpvars(0, test.io);
    end

   initial
     begin
	clk = 0;
	reset = 0;
	rs232_in = 0;
	
	#1 begin
           reset = 1;
	end

	#50 begin
           reset = 0;
	end
	
	#3000 $finish;
     end

   always
     begin
	#10 clk = 0;
	#10 clk = 1;
     end

   //----
   integer cycle;

   initial
     cycle = 0;

   always @(posedge io.clk)
     begin
	cycle = cycle + 1;
     end

endmodule

