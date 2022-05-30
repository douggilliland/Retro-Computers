// fpga.v

module fpga (clka,
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

   //
   wire [7:0] led_data;

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
	
   // assign 25mhz clock
   assign clk25 = gray_cnt[1];
   
   vga vga (.reset_n(reset_n),
	    .clock(clk25),
	    .pixel(pixel),
	    .blank_n(),
	    .hsync(hsync),
	    .vsync(vsync),
	    .ps2_clk(ps2_clk),
	    .ps2_data(ps2_data),
	    .led_data(led_data));

   assign vga_hsync_n = ~hsync;
   assign vga_vsync_n = ~vsync;

   assign {vga_red2, vga_red1, vga_red0,
	   vga_green2, vga_green1, vga_green0,
	   vga_blue2, vga_blue1, vga_blue0} = pixel;

   assign {fpga_din_d0, fpga_d1, fpga_d2, fpga_d3,
	   fpga_d4, fpga_d5, fpga_d6, fpga_d7} = led_data;
   
endmodule // fpga
