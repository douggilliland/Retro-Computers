// run_rf.v
// testing top end for pdp8_rf.v
//

`define debug 1

`include "../rtl/pdp8_rf.v"
`include "../rtl/ide_disk.v"
`include "../rtl/ide.v"
`include "../rtl/ram_256x12.v"
`include "../verif/fake_ram.v"

`timescale 1ns / 1ns

`ifdef use_fake_ide
`include "../verif/fake_ide.v"
`endif

module test;

   reg clk, reset;

   wire [11:0] io_data_out;
   wire        io_data_avail;
   wire        io_interrupt;
   wire        io_skip;

   wire        ram_read_req;
   wire        ram_write_req;
   wire	       ram_done;

   wire [14:0] ram_ma;
   wire [11:0] ram_out;
   wire [11:0]  ram_in;

   reg [5:0]   io_select;
   reg [11:0]  io_data_in;
   reg 	       iot;
   reg [3:0]   state;
   reg [11:0]  mb_in;

   wire        ide_dior;
   wire        ide_diow;
   wire [1:0]  ide_cs;
   wire [2:0]  ide_da;
   wire [15:0] ide_data_bus;

`ifdef use_fake_ide
   fake_ide ide(.ide_dior(ide_dior),
		.ide_diow(ide_diow),
		.ide_cs(ide_cs),
		.ide_da(ide_da),
		.ide_data_bus(ide_data_bus));
`endif

   pdp8_rf rf(.clk(clk),
	      .reset(reset),
	      .iot(iot),
	      .state(state),
	      .mb(mb_in),
	      .io_data_in(io_data_in),
	      .io_data_out(io_data_out),
	      .io_select(io_select),
	      .io_selected(io_selected),
	      .io_data_avail(io_data_avail),
	      .io_interrupt(io_interrupt),
	      .io_skip(io_skip),
	      .io_clear_ac(io_clear_ac),
	      .ram_read_req(ram_read_req),
	      .ram_write_req(ram_write_req),
	      .ram_done(ram_done),
	      .ram_ma(ram_ma),
	      .ram_in(ram_in),
	      .ram_out(ram_out),
	      .ide_dior(ide_dior),
	      .ide_diow(ide_diow),
	      .ide_cs(ide_cs),
	      .ide_da(ide_da),
	      .ide_data_bus(ide_data_bus));

   fake_ram ram(.clk(clk),
		.reset(reset),
		.ram_read_req(ram_read_req),
		.ram_write_req(ram_write_req),
		.ram_done(ram_done),
		.ram_ma(ram_ma),
		.ram_in(ram_out),
		.ram_out(ram_in));


   //
   task write_ram;
      input [14:0] addr;
      input [11:0] data;

      begin
	 @(posedge clk);
	 force ram_ma = addr;
	 force ram_out = data;
	 force ram_write_req = 1;
	 @(posedge clk);
	 force ram_write_req = 0;
	 @(posedge clk);
	 release ram_ma;
	 release ram_out;
	 release ram_write_req;
	 @(posedge clk);
      end
   endtask
   
   //
   task read_ram;
      input [14:0] addr;
      output [11:0] data;

      begin
	 @(posedge clk);
	 force ram_ma = addr;
	 force ram_read_req = 1;
	 @(posedge clk);
	 begin
	    data = ram_in;
	    force ram_read_req = 0;
	 end
	 @(posedge clk);
	 release ram_ma;
	 release ram_read_req;
	 @(posedge clk);
      end
   endtask
   
	
   //
   task write_rf_reg;
      input [11:0] isn;
      input [11:0] data;

      begin
	 @(posedge clk);
	 begin
	    state = 4'h0;
	    mb_in = isn;
	    io_select = isn[8:3];
	    io_data_in = data;
	    iot = 1;
	 end
	 #20 state = 4'h1;
	 #20 state = 4'h2;
	 #20 state = 4'h3;
	 #20 begin
	    state = 4'h0;
	    iot = 0;
	 end
      end
   endtask

   //
   task read_rf_reg;
      input [11:0] isn;
      output [11:0] data;

      begin
	 @(posedge clk);
	 begin
	    state = 4'h0;
	    mb_in = isn;
	    io_select = isn[8:3];
	    io_data_in = 0;
	    iot = 1;
	 end
	 #20 state = 4'h1;
	 #20 begin
	    data = io_data_out;
	    state = 4'h2;
	 end
	 #20 state = 4'h3;
	 #20 begin
	    state = 4'h0;
	    iot = 0;
	 end
      end
   endtask

   //
   task read_rf_skip;
      input [11:0] isn;
      output skip;

      begin
	 @(posedge clk);
	 begin
	    state = 4'h0;
	    mb_in = isn;
	    io_select = isn[8:3];
	    io_data_in = 0;
	    iot = 1;
	 end
	 @(posedge clk);
	 state = 4'h1;
	 @(posedge clk);
	 begin
	    skip = io_skip;
	    state = 4'h2;
	 end
	 @(posedge clk);
	 state = 4'h3;
	 @(posedge clk);
	 begin
	    state = 4'h0;
	    iot = 0;
	 end
      end
   endtask

   //
   task wait_for_rf;
      begin
	 while (rf.DCF == 1'b0)
	   begin
	      @(posedge clk);
	      begin
		 state = 4'h0;
		 mb_in = 0;
		 io_select = 0;
		 io_data_in = 0;
		 iot = 0;
	      end
	      @(posedge clk);
	      state = 4'h1;
	      @(posedge clk);
	      state = 4'h2;
	      @(posedge clk);
	      state = 4'h3;
	      @(posedge clk);
	      state = 4'h0;
	   end
      end
   endtask

   task clear_ram;
      integer a;
      begin
	 ram.ram_debug = 0;
      	 for (a = 0; a <= 12'o7777; a = a + 1)
	   write_ram(a, 0);
	 //ram.ram_debug = 1;
      end
   endtask

   task failure;
      input [14:0] addr;
      input [11:0] got;
      input [11:0] expected;
      
      begin
	 $display("FAILURE addr %o, read %o, expected %o",
		  addr, got, expected);
	 $finish;
      end
   endtask

   task fill_ram;
      input [14:0] addr;
      input [11:0] value;
      input count;

      integer count;
      integer a;
      begin
      	 for (a = addr; count > 0; a = a + 1)
	   begin
	      write_ram(a, value);
	      count = count - 1;
	   end
      end
   endtask

   task check_ram;
      input [14:0] addr;
      input [11:0] value;
      integer a;
      reg [11:0] rv;
      
      begin
	 read_ram(addr, rv);
	 $display("check_ram: %o %o @ %o", rv, value, addr);
	 if (rv != value)
	   failure(addr, rv, value);
      end
   endtask

   task check_fill_ram;
      input [14:0] addr;
      input [11:0] value;
      input count;
      integer count;
      integer a;
      reg [11:0] rv;
      
      begin
      	 for (a = addr; count > 0; a = a + 1)
	   begin
	      read_ram(a, rv);
	      if (rv != value)
		failure(a, rv, value);
	      count = count - 1;
	   end
      end
   endtask

   task write_rf;
      input [17:0] da;
      input [14:0] ma;
      input count;
      integer count;

      reg [11:0] cw;

      begin
	 cw = -count;
	 write_ram(14'o07750, cw);			// word count
	 write_ram(14'o07751, ma[11:0]-1);		// current addr

	 write_rf_reg(12'o6615, {6'b0, ma[14:12], 3'b0});	// DIML
	 write_rf_reg(12'o6643, {6'b0, da[17:12]});		// DXAL
	 write_rf_reg(12'o6605, da[11:0]);			// DMAW
	 wait_for_rf;
      end
   endtask

   task read_rf;
      input [17:0] da;
      input [14:0] ma;
      input count;
      integer count;

      reg [11:0] cw;
      
      begin
	 cw = -count;
	 write_ram(14'o07750, cw);
	 write_ram(14'o07751, ma[11:0]-1);

	 write_rf_reg(12'o6615, {6'b0, ma[14:12], 3'b0});	// DIML
	 write_rf_reg(12'o6643, {6'b0, da[17:12]});		// DXAL
	 write_rf_reg(12'o6603, da[11:0]);			// DMAR
	 wait_for_rf;
      end
   endtask

   initial
     begin
	$timeformat(-9, 0, "ns", 7);
	
	$dumpfile("pdp8_rf.vcd");
	$dumpvars(0, test.rf);
     end

   reg [11:0] data;
   integer     a;

   initial
     begin
	clk = 0;
	reset = 0;

	#1 reset = 1;
	#50 reset = 0;

	//---
	$display("* sanity");
	clear_ram;
	fill_ram(14'o00000, 12'o1111, 8);
	check_fill_ram(14'o00000, 12'o1111, 8);
	check_fill_ram(14'o00010, 12'o0000, 512);
	check_fill_ram(14'o01010, 12'o0000, 512);

`ifdef xxx
	//---
	$display("* prep");
	clear_ram;
	write_rf(18'o000000, 14'o00000, 4096);
	write_rf(18'o010000, 14'o00000, 4096);
	write_rf(18'o020000, 14'o00000, 4096);
	write_rf(18'o030000, 14'o00000, 4096);
	write_rf(18'o040000, 14'o00000, 4096);
	write_rf(18'o050000, 14'o00000, 4096);
	write_rf(18'o060000, 14'o00000, 4096);
	write_rf(18'o070000, 14'o00000, 4096);
`endif
	
`ifdef xxx
	//---
	$display("* write 8 words; cached");
	clear_ram;
	fill_ram(14'o00000, 12'o1111, 8);
	write_rf(18'o000000, 14'o00000, 8);
	clear_ram;
	read_rf (18'o000000, 14'o01000, 8);
	check_fill_ram(14'o00000, 12'o0000, 512);
	check_fill_ram(14'o01000, 12'o1111, 8);
	check_fill_ram(14'o01010, 12'o0000, 512);

	//---
	$display("* write 8 words; force write");
	clear_ram;
	read_rf (18'o010000, 14'o00000, 8);

	//---
	$display("* write 8 words; cached");
	clear_ram;
	fill_ram(14'o00000, 12'o2222, 8);
	write_rf(18'o010000, 14'o00000, 8);
	clear_ram;
	read_rf (18'o010000, 14'o00000, 8);
	check_fill_ram(14'o00000, 12'o2222, 8);
	check_fill_ram(14'o00010, 12'o0000, 512);
	read_rf (18'o000000, 14'o00000, 8);

	//----
	$display("* read/write 2 fields");
	clear_ram;
	fill_ram(14'o10000, 12'o3333, 4096);
	write_rf(18'o000000, 14'o10000, 4032);
	write_rf(18'o010000, 14'o00000, 4096);
	read_rf (18'o000000, 14'o00000, 4032);
	read_rf (18'o010000, 14'o10000, 4096);
	$display("** checking");
	check_fill_ram(14'o00000, 12'o3333, 4032);
	check_fill_ram(14'o10000, 12'o0000, 4096);
`endif
	
	//----
	$display("* read/write individual words");
	clear_ram;
	read_rf (18'o000000, 14'o00000, 256);
	write_ram(14'o00200, 12'o0000);
	write_ram(14'o00201, 12'o1010);
	write_ram(14'o00202, 12'o2020);
	write_ram(14'o00203, 12'o3030);
	$display("** write 4");
//	rf.buffer.ram_debug = 1;
	write_rf(18'o000200, 14'o00200, 4);
//	rf.buffer.ram_debug = 0;
	$display("** read to flush");
	read_rf (18'o010000, 14'o10000, 256);
	$display("** checking");
	clear_ram;
	read_rf (18'o000000, 14'o00000, 512);
	check_ram(14'o00200, 12'o0000);
	check_ram(14'o00201, 12'o1010);
	check_ram(14'o00202, 12'o2020);
	check_ram(14'o00203, 12'o3030);

	//----
	$display("* read/write individual words");
	clear_ram;
	read_rf (18'o000000, 14'o00000, 4032);
	write_ram(14'o00204, 12'o4040);
	write_ram(14'o00205, 12'o5050);
	write_ram(14'o00206, 12'o6060);
	write_ram(14'o00207, 12'o7070);
	write_rf(18'o000204, 14'o00204, 4);
	read_rf (18'o010000, 14'o10000, 4096);
	$display("** checking");
	clear_ram;
	read_rf (18'o000000, 14'o00000, 4032);
	check_ram(14'o00200, 12'o0000);
	check_ram(14'o00201, 12'o1010);
	check_ram(14'o00202, 12'o2020);
	check_ram(14'o00203, 12'o3030);
	check_ram(14'o00204, 12'o4040);
	check_ram(14'o00205, 12'o5050);
	check_ram(14'o00206, 12'o6060);
	check_ram(14'o00207, 12'o7070);
	$finish;
     end

`ifndef use_fake_ide
   always @(posedge clk)
     begin
	$pli_ide(ide_data_bus, ide_dior, ide_diow, ide_cs, ide_da);
     end
`endif
   
  always
    begin
      #10 clk = 0;
      #10 clk = 1;
    end

  //----
  integer cycle;

  initial
    cycle = 0;

  always @(posedge rf.clk)
    begin
      cycle = cycle + 1;
    end

endmodule

