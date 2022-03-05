//-------------------------------------------------------------------
//-- leds_tb.v
//-- Testbench
//-------------------------------------------------------------------
//-- Juan Gonzalez (Obijuan)
//-- Jesus Arroyo Torrens
//-- GPL license
//-------------------------------------------------------------------
`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1ns/1ps
module tb ();
  initial begin
    $dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, vga_uut);
  end

  reg clk;

  initial begin
		clk = 1'b0;
	end

  always #8.3 clk = !clk;

  initial begin
    repeat(1200000) @(posedge clk);

      $finish;
  end

  wire vsync;
  wire hsync;
  wire oe;
  wire [7:0] rgb;
  wire [2:0] leds;
  reg rw = 0;
  reg en = 0;
  reg phi2 = 0;
  reg [2:0] reg_address = 0;
  reg [7:0] data = 0;

  vga vga_uut (
    .VSYNC(vsync),
    .HSYNC(hsync),
    .OE(oe),
    .RGB(rgb),
    .led(leds),
    .CLK_12M(clk),
    .RW(rw),
    .EN(en),
    .PHI2(phi2),
    .REG(reg_address),
    .DATA(data)
  );

endmodule // tb


