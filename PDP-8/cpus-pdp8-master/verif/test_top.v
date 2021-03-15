// run_top.v
// testing top end for pdp8.v
//

`define sim_time 1

`include "../rtl/ide.v"
`include "../rtl/ide_disk.v"
`include "../rtl/brg.v"
`include "../rtl/uart.v"
`include "../rtl/pdp8_kw.v"
`include "../rtl/pdp8_tt.v"
`include "../rtl/pdp8_rf.v"
`include "../rtl/pdp8_io.v"
`include "../rtl/pdp8_ram.v"
`include "../rtl/pdp8.v"
`include "../rtl/top.v"
`include "../rtl/ram_256x12.v"
`include "../rtl/debounce.v"
`include "../rtl/bootrom.v"
`include "../rtl/display.v"
`include "../rtl/sevensegdecode.v"
`include "../verif/ram_s3board.v"

`timescale 1ns / 1ns

module test;

   wire	rs232_txd;
   wire rs232_rxd;

   reg [3:0] button;

   wire [7:0] led;
   reg 	      sysclk;

   wire [7:0] sevenseg;
   wire [3:0] sevenseg_an;

   reg [7:0]  slideswitch;

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
   
   wire [15:0] ide_data_bus;
   wire        ide_dior, ide_diow;
   wire [1:0]  ide_cs;
   wire [2:0]  ide_da;

   top top(.rs232_txd(rs232_txd),
	   .rs232_rxd(rs232_rxd),
	   .button(button),
	   .led(led),
	   .sysclk(sysclk),
	   .sevenseg(sevenseg),
	   .sevenseg_an(sevenseg_an),
	   .slideswitch(slideswitch),
	   .sram_a(sram_a),
	   .sram_oe_n(sram_oe_n),
	   .sram_we_n(sram_we_n),

	   .sram1_io(sram1_io),
	   .sram1_ce_n(sram1_ce_n),
	   .sram1_ub_n(sram1_ub_n),
	   .sram1_lb_n(sram1_lb_n),

	   .sram2_io(sram2_io),
	   .sram2_ce_n(sram2_ce_n),
	   .sram2_ub_n(sram2_ub_n),
	   .sram2_lb_n(sram2_lb_n),

	   .ide_data_bus(ide_data_bus),
	   .ide_dior(ide_dior),
	   .ide_diow(ide_diow),
	   .ide_cs(ide_cs),
	   .ide_da(ide_da));

    ram_s3board ram2(.ram_a(sram_a),
		    .ram_oe_n(sram_oe_n),
		    .ram_we_n(sram_we_n),
		    .ram1_io(sram1_io),
		    .ram1_ce_n(sram1_ce_n),
		    .ram1_ub_n(sram1_ub_n), .ram1_lb_n(sram1_lb_n),
		    .ram2_io(sram2_io),
		    .ram2_ce_n(sram2_ce_n),
		    .ram2_ub_n(sram2_ub_n), .ram2_lb_n(sram2_lb_n));

  initial
    begin
      $timeformat(-9, 0, "ns", 7);

      $dumpfile("pdp8.vcd");
      $dumpvars(0, test.top);
    end

  initial
    begin
       sysclk = 0;
      #3000000 $finish;
    end

  always
    begin
      #10 sysclk = 0;
      #10 sysclk = 1;
    end

  //----
  integer cycle;

  initial
    cycle = 0;

  always @(posedge top.cpu.clk)
   if (top.cpu.state == 4'b0000)
    begin
      cycle = cycle + 1;
      #1 $display("pc %o ir %o l %b ac %o ion %o",
		  top.cpu.pc, top.cpu.mb, top.cpu.l, top.cpu.ac,
		  top.cpu.interrupt_enable);

       if (top.cpu.state == 4'b1100)
	 $finish;
    end

endmodule

