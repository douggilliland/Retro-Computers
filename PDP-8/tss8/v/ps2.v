// ps2.v
//
// Monitor the serial datastream and clock from a PS/2 keyboard
// and output a scancode for any key that is pressed.
//
// Notes:
//   
// The clock from the PS/2 keyboard is used directly.  It is sampled at
// the frequency of the  main clock input; edges are extracted from the
// sample clock.  The main clock must be substantially faster than
// the 10 KHz PS/2 clock - 200 KHz or more.
//
// The scancode is only valid when the ready signal is high.  The scancode
// should be registered by an external circuit on the first clock edge
// after the ready signal goes high.
//
// The ready signal pulses only after the key is released.
//
// The error flag is set whenever the PS/2 clock stops pulsing and the
// PS/2 clock is either at a low level or less than 11 bits of serial
// data have been received (start + 8 data + parity + stop).
//

module ps2(clk,		// main clock
	   rst_n,	// asynchronous reset
	   ps2_clk,	// clock from keyboard
	   ps2_data,	// data from keyboard
	   scancode,	// key scancode
	   parity,	// parity bit for scancode
	   busy,	// busy receiving scancode
	   rdy,		// scancode ready pulse
	   error	// error receiving scancode
	   );
   
   input clk, rst_n;
   input ps2_clk;
   input ps2_data;
   output [7:0] scancode;
   output 	parity;
   output 	busy;
   output 	rdy;
   output 	error;

	   
   parameter 	FREQ = 25000; // frequency of the main clock (KHz)
   parameter 	PS2_FREQ = 10;  // keyboard clock frequency (KHz)
   parameter 	TIMEOUT  = FREQ / PS2_FREQ;  // ps2_clk quiet timeout
   parameter [7:0] KEY_RELEASE = 8'b11110000;  // sent when key is rel'd

   reg [13:0]  timer_r;		// time since last PS/2 clock edge
   wire [13:0] timer_x;

   reg [3:0]   bitcnt_r;	// number of received scancode bits
   wire [3:0]  bitcnt_x;

   reg [4:0]   ps2_clk_r;	// PS/2 clock sync / edge detect
   wire [4:0]  ps2_clk_x;

   reg [9:0]   sc_r;	 	// scancode shift register
   wire [9:0]  sc_x;

   reg 	       keyrel_r;	// set when key release received
   wire        keyrel_x;

   reg 	       rdy_r;	 	// set when scancode ready
   wire        rdy_x;

   reg 	       error_r;	 	// set when an error occurs
   wire        error_x;

   wire        ps2_clk_fall_edge; // on falling edge of PS/2 clock
   wire        ps2_clk_rise_edge; // on rising edge of PS/2 clock
   wire        ps2_clk_edge;	 // on either edge of PS/2 clock
   wire        ps2_clk_quiet;	 // when no edges on PS/2 clock for TIMEOUT
   wire        scancode_rdy;	 // when scancode has been received


   // shift the level on the PS/2 clock into a shift register
   assign ps2_clk_x = {ps2_clk_r[3:0], ps2_clk};

   // look at the PS/2 clock levels stored in the shift register
   //  and find rising or falling edges
   assign ps2_clk_fall_edge = ps2_clk_r[4:1] == 4'b1100;
   assign ps2_clk_rise_edge = ps2_clk_r[4:1] == 4'b0011;
   assign ps2_clk_edge      = ps2_clk_fall_edge || ps2_clk_rise_edge;

   // shift the keyboard scancode into the shift register on the
   //  falling edge of the PS/2 clock
   assign sc_x = ps2_clk_fall_edge ? {ps2_data, sc_r[9:1]} : sc_r;

   // clear the timer right after a PS/2 clock edge and
   //  then keep incrementing it until the next edge
   assign timer_x = ps2_clk_edge ? 0 : (timer_r + 1);

   // indicate when the PS/2 clock has stopped pulsing and
   //  is at a high level.
   assign ps2_clk_quiet = timer_r == TIMEOUT && ps2_clk_r[1];

   // increment bit counter on each falling edge of the PS/2 clock.
   // reset the bit counter if the PS/2 clock stops pulsing or 
   // if there was an error receiving the scancode.
   // otherwise, keep the bit counter unchanged.
   assign bitcnt_x = ps2_clk_fall_edge ? (bitcnt_r + 1) :
		     (ps2_clk_quiet || error_r) ? 0 :
		     bitcnt_r;

   // a scancode has been received if the bit counter is 11 and
   //  the PS/2 clock has stopped pulsing
   assign scancode_rdy = bitcnt_r == 4'd11 && ps2_clk_quiet;

/*
   // look for the scancode sent when the key is released
   assign keyrel_x = (sc_r[7:0] == KEY_RELEASE && scancode_rdy) ? 1 :
		     (rdy_r || error_r) ? 0 :
		     keyrel_r;

   // the scancode for the pressed key arrives after receiving
   //  the key-release scancode 
   assign rdy_x = keyrel_r && scancode_rdy;
*/ 
   assign rdy_x = scancode_rdy;

   // indicate an error if the clock is low for too long or
   //  if it stops pulsing in the middle of a scancode
   assign error_x = (timer_r == TIMEOUT && ps2_clk_r[1] == 0) ||
		    (ps2_clk_quiet && bitcnt_r != 4'd11 && bitcnt_r != 4'd0) ?
		    1 : error_r;

   // outputs
   assign scancode = sc_r[7:0];		// scancode
   assign parity   = sc_r[8];		// parity bit for the scancode
   assign busy     = bitcnt_r != 4'd0;	// busy when recv'ing scancode
   assign rdy      = rdy_r;		// scancode ready flag
   assign error    = error_r;		// error flag

   // update the various registers
   always @(posedge clk or negedge rst_n)
     if (~rst_n)
       begin
	  ps2_clk_r <= 5'b11111;  // assume PS/2 clock has been high
	  sc_r      <= 0;
	  keyrel_r  <= 0;
	  rdy_r     <= 0;
	  timer_r   <= 0;
	  bitcnt_r  <= 0;
	  error_r   <= 0;
       end
     else
       begin
	  ps2_clk_r <= ps2_clk_x;
	  sc_r      <= sc_x;
	  keyrel_r  <= keyrel_x;
	  rdy_r     <= rdy_x;
	  timer_r   <= timer_x;
	  bitcnt_r  <= bitcnt_x;
	  error_r   <= error_x;
       end

   
endmodule
