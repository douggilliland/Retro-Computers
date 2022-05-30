// run.v
// testing top end for pdp8.v
//

`include "pdp8.v"
`include "pdp8_io.v"
`include "pdp8_ram.v"

`timescale 1ns / 1ns

module test;

   reg clk, reset;
   reg [11:0] switches;

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
   wire [5:0]  io_select;
   
   wire        iot;
   wire [3:0]  state;
   wire [11:0] mb;
   
  pdp8 cpu(.clk(clk),
	   .reset(reset),
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
	   .iot(iot),
	   .mb(mb),
	   .switches(switches));
   
   pdp8_io io(.clk(clk),
	      .reset(reset),
	      .iot(iot),
	      .state(state),
	      .mb(mb),
	      .io_data_in(io_data_out),
	      .io_data_out(io_data_in),
	      .io_select(io_select),
	      .io_data_avail(io_data_avail),
	      .io_interrupt(io_interrupt),
	      .io_skip(io_skip));

   pdp8_ram ram(.clk(clk),
	       .reset(reset), 
	       .addr(ram_addr),
	       .data_in(ram_data_in),
	       .data_out(ram_data_out),
	       .rd(ram_rd),
   	       .wr(ram_wr));


  initial
    begin
      $timeformat(-9, 0, "ns", 7);

      $dumpfile("pdp8.vcd");
      $dumpvars(0, test.cpu);
    end

  initial
    begin
      clk = 0;
      reset = 0;

    #1 begin
         reset = 1;
       end

    #50 begin
         reset = 0;
       end
  
      #3000000 $finish;
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

  always @(posedge cpu.clk)
   if (cpu.state == 4'b0000)
    begin
      cycle = cycle + 1;
//      #1 $display("#%d, r%b s%d, pc %o ir%o ma %o mb %o j%b l%b ac %o, i%b/%b",
//		cycle, cpu.run, cpu.state, cpu.pc,
//		cpu.ir, cpu.ma, cpu.mb, cpu.jmp, cpu.l, cpu.ac,
//		cpu.interrupt_enable, cpu.interrupt);
       //#1 $display("   io_data_in %o, io_data_out %o",
       //io_data_in, io_data_out);

      #1 $display("pc %o ir %o l %b ac %o ion %o",
		  cpu.pc, cpu.mb, cpu.l, cpu.ac, cpu.interrupt_enable);

       if (state == 4'b1100)
	 $finish;
    end

endmodule

