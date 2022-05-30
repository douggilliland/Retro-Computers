// vga.v

// simple b&w 640x480 terminal with VGA output

`include "vgacore.v"
`include "crt.v"
`include "video_ram.v"
`include "char_rom.v"
`include "ps2.v"
`include "scancode.v"

module vga (reset_n, clock,
	    pixel, blank_n,
	    hsync, vsync,
	    ps2_clk,
	    ps2_data,
	    led_data);

   input reset_n;
   input clock;
   output [8:0] pixel;
   output 	blank_n;
   output 	hsync;
   output 	vsync;
   input 	ps2_clk, ps2_data;
   output [7:0] led_data;
   
   wire		startVGA;
   wire 	resetVGA;
   wire 	done;
   wire 	clearing;

   wire [9:0] 	hloc;	// horiz timing, including sync & blanking
   wire [9:0] 	vloc;

   wire 	hblank;	// set when in non-visable part of frame
   wire 	vblank;
 	
   wire [6:0] 	hpos;	// horiz position 0..79, during visable frame
   wire [8:0] 	vpos;	// vert line 0..480, during visable frame

   reg [8:0] 	pixelData;

   wire [11:0] 	vpos_times_80;
   
   wire 	pixelclk;
   reg [2:0] 	pclk;
   
   wire 	charclk;
   reg 		charload;
   reg [7:0] 	pixel_hold;

   reg 		crtclk;
   wire 	ram_wclk;
   wire 	ram_wslot;
 	
   wire [11:0] 	ram_addr_write, ram_addr_video, ram_addr_mux;
   wire [7:0] 	ram_data, ram_data_out, rom_data_out;
   wire 	ram_we_n;
   wire [9:0] 	rom_addr;
   reg [7:0] 	rom_addr_char;

   char_rom char_rom(.addr(rom_addr),
		     .data(rom_data_out));

   video_ram video_ram(.addr(ram_addr_mux),
		       .data_out(ram_data_out), .clk_r(charload/*charclk*/),
		       .data_in(ram_data), .clk_w(ram_wclk), .we_n(ram_we_n));
   
   vgacore vgacore(.reset_n(reset_n), .clock(clock),
		   .hsync(hsync),
		   .vsync(vsync),
		   .hblank(hblank),
		   .vblank(vblank),
		   .enable(blank_n),
		   .hloc(hloc),
		   .vloc(vloc));


   wire 	  kb_rdy;
   wire 	  kb_bsy;
   wire 	  kb_release;
   wire [7:0] 	  kb_scancode;
   wire [7:0] 	  kb_ascii;
   wire 	  kb_ascii_rdy;
   reg [7:0] 	  crt_data;
   reg		  insert_crt_data;

   ps2 ps2(.clk(clock),
	   .rst_n(reset_n),
	   .ps2_clk(ps2_clk),
	   .ps2_data(ps2_data),
	   .scancode(kb_scancode),
	   .parity(),
	   .busy(kb_bsy),
	   .rdy(kb_rdy),
	   .error()
	   );

   scancode_convert scancode_convert(.clock(clock),
				     .reset_n(reset_n),
				     .scancode(kb_scancode),
				     .ascii(kb_ascii),
				     .key_up(kb_release),
				     .strobe_in(kb_rdy),
				     .strobe_out(kb_ascii_rdy));

   // debug - led output
   assign led_data = { kb_ascii[6], kb_rdy, kb_ascii[5:0] };
   
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       begin
	  crt_data <= 0;
	  insert_crt_data <= 0;
       end
     else
       begin
	  if (kb_ascii_rdy)
	    begin
	       crt_data <= kb_ascii;
	       if (~kb_release)
		 insert_crt_data <= 1;
	    end
	  else
	    insert_crt_data <= 0;
       end
   
//   assign insert_crt_data = kb_ascii_rdy && ~kb_release;

   wire [6:0] 	  cursorh;
   wire [5:0] 	  cursorv;
   wire 	  cursor_match;
   
   crt crt(.reset_n(reset_n),
	   .clock(crtclk),
	   .insert(insert_crt_data),
	   .done(done),
	   .data(crt_data),
	   .clearing(clearing),
	   .ram_addr(ram_addr_write),
	   .ram_data(ram_data),
	   .ram_we_n(ram_we_n),
	   .ram_wclk(ram_wclk),
	   .ram_wslot(ram_wslot),
	   .cursorh(cursorh),
	   .cursorv(cursorv));


   // generate video ram address from (vpos/8) * 80 + hpos
   assign vpos_times_80 = {vpos[8:3], 6'b0} + {2'b00, vpos[8:3], 4'b0};
   assign ram_addr_video = vpos_times_80 + {5'b00000, hpos};
   
   assign ram_addr_mux = ram_we_n ? ram_addr_video : ram_addr_write;
   
   assign rom_addr = {rom_addr_char[6:0], vpos[2:0]};

   assign cursor_match = (cursorh == hpos && cursorv == vpos[8:3]) ? 1 : 0;
   

   // clock divider by 8 - assume 8x8 font
   always @(posedge pixelclk or negedge reset_n)
     if (~reset_n)
       pclk = 3'b111;
     else
       pclk = (hblank || clearing) ? 3'b111 : pclk + 1;

   assign charclk = ~pclk[2];

   // crtclk runs at half speed
   always @(posedge pixelclk or negedge reset_n)
     if (~reset_n)
       crtclk = 1'b0;
     else
       crtclk = ~crtclk;

   // ram "writ slot" sits at 2nd half of charclk cycle
   assign ram_wslot = ~pclk[1] & pclk[2];
   
   // generate hpos, vpos (from hloc, vloc of vgacore)
   assign hpos = hloc[9:3];
   assign vpos = vloc[8:0];
   
    // latch ram output to form rom address
   always @(posedge charclk)
     rom_addr_char <= ram_data_out;

/*   
//temp-debug
//always @(posedge charclk) rom_addr_char <= {1'b0, hpos};
wire [7:0] hack;
assign hack = {1'b0,hpos} + 8'h30;
//assign  hack = {1'b0,hpos};
always @(posedge charclk) rom_addr_char <= hack;
*/
   
   // inhibit shift and load instead during last slot
   always @(negedge pixelclk or negedge reset_n)
     if (~reset_n)
       charload = 0;
     else
       charload = pclk == 3'b111 ? 1 : 0;
   
   // shift pixel data, one bit at a time (or load when at last slot)
   always @(posedge pixelclk)
     pixel_hold <= charload ?
		   (cursor_match ? 8'hff : rom_data_out) :
		   { pixel_hold[6:0], 1'b0 };

   // clock pixel data on pixel clock
   always @(posedge pixelclk)
     pixelData <= pixel_hold[7] ? 9'h1ff : 9'h000;

   assign pixel = (hblank || vblank) ? 9'h000 : pixelData;

   // reset & start VGA 
   assign startVGA = 1;
   assign resetVGA = reset_n & startVGA;

   // Provide 25MHz pixel clock
   assign pixelclk = clock;

endmodule

