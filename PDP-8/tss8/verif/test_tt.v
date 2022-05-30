// run_tt.v
// testing top end for pdp8_tt.v
//

`define sim_time 1

`include "../verif/fake_uart.v"
`include "../rtl/brg.v"
`include "../rtl/pdp8_tt.v"

`timescale 1ns / 1ns

module test_tt;

   reg clk, brgclk;
   reg reset;

   reg [11:0] io_data_in;
   wire [11:0] io_data_out;
   wire        io_data_avail;
   wire        io_interrupt;
   wire        io_skip;
   reg [5:0]   io_select;
   
   reg 	       iot;
   reg [3:0]   state;
   reg [11:0]  mb_in;

   reg 	       uin;
   wire        uout;
   
   pdp8_tt tt(.clk(clk),
	      .brgclk(brgclk),
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
	      .uart_in(uin),
	      .uart_out(uout));

   reg [11:0]  data;
   reg 	       sample_skip;
   
   //
   task write_tt_reg;
      input [11:0] isn;
      input [11:0] data;

      begin
	 @(posedge clk);
	 begin
	    uin = 0;
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
   task read_tt_reg;
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
	 #10 state = 4'h1;
	 #10 sample_skip = io_skip;
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

   integer w;

   task failure;
      input [15:0] addr;
      input [15:0] got;
      input [15:0] wanted;
      
      begin
	 $display("FAILURE addr %o, read %x, desired %x",
		  addr, got, wanted);
      end
   endtask

   
   //
   task wait_for_tto;
      begin
	 sample_skip = 0;
	 w = 0;
	 
	 while (sample_skip == 0)
	   begin
	      read_tt_reg(12'o6041, data);
	      w = w + 1;
	      if (w > 100)
		begin
		   $display("FAILURE - waiting for tti");
		   $finish;
		end
	   end
      end
   endtask

   //
   task wait_for_tti;
      begin
	 sample_skip = 0;
	 w = 0;

	 while (sample_skip == 0)
	   begin
	      read_tt_reg(12'o6031, data);
	      w = w + 1;
	      if (w > 100)
		begin
		   $display("FAILURE - waiting for tto");
		   $finish;
		end
	   end
      end
   endtask
   
   initial
     begin
	$timeformat(-9, 0, "ns", 7);
	
	$dumpfile("pdp8_tt.vcd");
	$dumpvars(0, test_tt.tt);
     end

  initial
    begin
       clk = 0;
       brgclk = 0;
       reset = 0;

       #1 begin
          reset = 1;
       end

       #50 begin
          reset = 0;
       end

       //
       write_tt_reg(12'o6000, 12'o0000);

       wait_for_tti;
       read_tt_reg(12'o6036, data);

       wait_for_tti;
       read_tt_reg(12'o6036, data);

       wait_for_tti;
       read_tt_reg(12'o6036, data);

       //
       write_tt_reg(12'o6000, 12'o0000);

       wait_for_tto;
       write_tt_reg(12'o6046, 12'o0207);

       wait_for_tto;
       write_tt_reg(12'o6046, 12'o0215);

       wait_for_tto;
       write_tt_reg(12'o6000, 12'o0000);
  
       #40000 $finish;
    end

   always
     begin
	#10 clk = 0;
	#10 clk = 1;
     end

   always
     begin
	#10 brgclk = 0;
	#10 brgclk = 1;
     end

  //----
  integer cycle;

  initial
    cycle = 0;

  always @(posedge tt.clk)
    begin
      cycle = cycle + 1;
    end

endmodule

