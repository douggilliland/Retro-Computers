// run.v

`include "vga.v"

`timescale 1ns / 1ns

module test;

   reg clk, reset_n;

   wire [8:0] pixel;
   wire 	blank_n;
   wire 	hsync;
   wire 	vsync;
   reg 		ps2_clk;
   reg 		ps2_data;
   wire [7:0] 	led_data;

   vga vga(.reset_n(reset_n),
	   .clock(clk25),
	   .pixel(pixel),
	   .blank_n(blank_n),
	   .hsync(hsync),
	   .vsync(vsync),
	   .ps2_clk(ps2_clk),
	   .ps2_data(ps2_data),
	   .led_data(led_data));

   // clock divider by 4 to for a slower clock
   // uses grey code for minimized logic
   reg [1:0]  gray_cnt;

   always @(posedge clk or negedge reset_n)
     if (~reset_n)
       gray_cnt <= 2'b00;
     else
       case (gray_cnt)
	 2'b00: gray_cnt <= 2'b01;
	 2'b01: gray_cnt <= 2'b11;
	 2'b11: gray_cnt <= 2'b10;
	 2'b10: gray_cnt <= 2'b00;
	 default: gray_cnt <= 2'b00;
       endcase
	
   wire clk25;
   assign clk25 = gray_cnt[1];
   
  initial
    begin
      $timeformat(-9, 0, "ns", 7);

      $dumpfile("vga.vcd");
//      $dumpvars(0, test.vga);
       $dumpvars(0, test);
    end

  initial
    begin
       clk = 0;
       reset_n = 1;
       ps2_clk <= 0;
       ps2_data <= 0;

       #1 begin
          reset_n = 0;
       end

       #100 begin
          reset_n = 1;
       end

       #400000
	 begin
	    vga.scancode_convert.strobe_out = 1;
	    vga.crt_data = 8'h41;
	    vga.scancode_convert.ascii = 8'h41;
	 end
       #200 vga.scancode_convert.strobe_out = 0;

       #400
	 begin
	    vga.scancode_convert.strobe_out = 1;
	    vga.crt_data = 8'h42;
	    vga.scancode_convert.ascii = 8'h42;
	 end
       #200 vga.scancode_convert.strobe_out = 0;
  
//       #100000 $finish;
//       #500000 $finish;
//      #1000000 $finish;
       #20000000 $finish;
    end

   always
     begin
	#5 clk = 0;
	#5 clk = 1;
     end

endmodule

