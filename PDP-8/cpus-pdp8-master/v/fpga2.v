// fpga2.v

// simple test module for ps2 module

module fpga (clka,
	     clkb,
	     reset_n,
	     ps2_clk,
	     ps2_data,
	     vga_blue0,
	     vga_blue1,
	     vga_blue2,
	     vga_green0,
	     vga_green1,
	     vga_green2,
	     vga_red0,
	     vga_red1,
	     vga_red2,
	     vga_hsync_n,
	     vga_vsync_n,
	     fpga_din_d0,
	     fpga_d1,
	     fpga_d2,
	     fpga_d3,
	     fpga_d4,
	     fpga_d5,
	     fpga_d6,
	     fpga_d7
	     );
   
   input clka;	// 100mhz
   input clkb;	// 50mhz
   input reset_n;

   input ps2_clk, ps2_data;

   output vga_blue0, vga_blue1, vga_blue2;
   output vga_green0, vga_green1, vga_green2;
   output vga_red0, vga_red1, vga_red2;
   output vga_hsync_n, vga_vsync_n;

   output fpga_din_d0, fpga_d1, fpga_d2, fpga_d3,
	  fpga_d4, fpga_d5, fpga_d6, fpga_d7;
   
   //
   wire  hsync, vsync;
   wire [8:0] pixel;

   // signals to create a 25MHz clock from the 100MHz input clock
   wire	      clk25;
   reg [1:0]  gray_cnt;

   // clock divider by 4 to for a slower clock
   // uses grey code for minimized logic
   always @(posedge clka or negedge reset_n)
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
	
   // assign the clock that this entity runs off
   assign clk25 = gray_cnt[1];

   wire 	  kb_rdy;
   wire 	  kb_bsy;
   wire [7:0] 	  kb_scancode;

   wire [7:0] 	  data;
   
   ps2 ps2(.clk(clk25),
	   .rst_n(reset_n),
	   .ps2_clk(ps2_clk),
	   .ps2_data(ps2_data),
	   .scancode(kb_scancode),
	   .parity(),
	   .busy(kb_bsy),
	   .rdy(kb_rdy),
	   .error());
   
   //xc2s200-5fg256

   reg rdy;
   
   always @(posedge kb_rdy or negedge reset_n)
     if (~reset_n)
       rdy <= 0;
     else
       rdy <= ~rdy;
   
   assign {fpga_din_d0, fpga_d1, fpga_d2, fpga_d3,
	   fpga_d4, fpga_d5, fpga_d6, fpga_d7} =
	{ kb_scancode[6], rdy, kb_scancode[5:0] };

endmodule // fpga
