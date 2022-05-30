// vgacore.v
//
// Creates VGA timing signals to a monitor, currently for 60Hz @ 640 * 480
//
// To change the resolution or refresh rate, change the value of 
// the constants and the generics to whatever is desired.  Changing the 
// resolution and/or refresh also means the clock speed may have to change,
// currently based off a 25MHz clock...
//

module vgacore(reset_n, clock,
	       hblank, vblank,
	       hsync, vsync,
	       enable,
	       hloc, vloc);

   input reset_n;
   input clock;

   output hblank;
   output vblank;

   output hsync;
   output vsync;

   output enable;

   reg 	  hblank;
   reg 	  hsync, vsync;
   reg 	  enable;

   output [9:0] hloc;
   output [9:0] vloc;
   
   parameter H_SIZE = 640;
   parameter V_SIZE = 480;

   // sync signals
   //
   //      |<--- Active Region --->|<--------- Blanking Region ------->|
   //      |       (Pixels)        |                                   |
   //      |                       |                                   |
   //      |                       |                                   |
   // -----+---------- ... --------+-------------          ------------+---
   // |    |                       |            |          |           |
   // |    |                       |<--Front    |<--Sync   |<--Back    |
   // |    |                       |    Porch-->|   Time-->|   Porch-->|
   //--    |                       |            ------------           |
   //      |                       |                                   |
   //      |<---------------------------- Period --------------------->|
   //
   
   // horizontal timing signals
`define H_PIXELS	H_SIZE
`define H_FRONTPORCH	30 + (640 - H_SIZE) / 2
`define H_SYNCTIME	100
`define H_BACKPORCH	30 + (640 - H_SIZE) / 2
`define H_PERIOD	`H_PIXELS+ `H_FRONTPORCH+ `H_SYNCTIME+ `H_BACKPORCH

   // vertical timing signals
`define V_LINES		V_SIZE
`define V_FRONTPORCH	10 + (480 - V_SIZE) / 2
`define V_SYNCTIME	2
`define V_BACKPORCH	32 + (480 - V_SIZE) / 2
`define V_PERIOD	`V_SYNCTIME+ `V_LINES+ `V_FRONTPORCH+ `V_BACKPORCH

   
   reg [10:0] hcnt;	// horizontal pixel counter
   reg [9:0]  vcnt;	// vertical line counter

   // control the reset, increment and overflow of the horiz pixel count
   always @(posedge clock or negedge reset_n)
     // reset asynchronously clears horizontal counter
     if (~reset_n)
       hcnt <= 0;
     else
       // horiz. counter increments on rising edge of dot clock
       // horiz. counter restarts after the horizontal period
       if (hcnt < (`H_PERIOD - 1))
	 hcnt <= hcnt + 1;
       else
	 hcnt <= 0;


   // control the reset, increment and overflow of the vert line ctr,
   // after every horiz line
//   always @(negedge hsync or negedge reset_n)
   always @(negedge hblank or negedge reset_n)
     //	reset asynchronously clears line counter
     if (~reset_n)
       vcnt <= 0;
     else
       // vert. line counter increments after every horiz. line
       // vert. line counter rolls-over after max lines
       if (vcnt < (`V_PERIOD - 1))
	 vcnt <= vcnt + 1;
       else
	 vcnt <= 0;


   // set the horizontal sync high time and low time
   always @(posedge clock or negedge reset_n)
     // reset asynchronously sets horizontal sync to inactive
     if (~reset_n)
       hsync <= 0;
     else
       // horizontal sync is recomputed on the rising edge of every dot clk
       // horiz. sync is low to signal start of a new line
       if (hcnt >= (`H_FRONTPORCH + `H_PIXELS) &&
	   hcnt < (`H_FRONTPORCH + `H_PIXELS + `H_SYNCTIME))
	 hsync <= 1;
       else
	 hsync <= 0;

   // set the vertical sync high time and low time
   always @(posedge clock or negedge reset_n)
     // reset asynchronously sets vertical sync to inactive
     if (~reset_n)
       vsync <= 0;
     else
       // vertical sync is recomputed at the end of every line of pixels
       // vert. sync is low to signal start of a new frame
       if (vcnt >= (`V_LINES + `V_FRONTPORCH) &&
	   vcnt < (`V_LINES + `V_FRONTPORCH + `V_SYNCTIME))
	 vsync <= 1;
       else
	 vsync <= 0;

   // blanking
//   assign hblank = (hcnt >= `H_PIXELS) && (hcnt < `H_PERIOD);
   assign vblank = (vcnt >= `V_LINES) && (vcnt < `V_PERIOD);

   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       hblank <= 0;
     else
       if (hcnt < `H_PIXELS)
	 hblank <= 0;
       else 
	 hblank <= 1;

   // asserts the blanking signal (active low)
   always @(posedge clock)
     // if we are outside the visible range on the screen then blank
     if (hcnt >= `H_PIXELS || vcnt >= `V_LINES)
       enable <= 0;
     else 
       enable <= 1;

   assign hloc = hcnt[9:0];
   assign vloc = vcnt[9:0];

endmodule
