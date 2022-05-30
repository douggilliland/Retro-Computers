// scancode.v

//
// simple AT style keyboard scancode to ascii convertion
//  keeps track of shift, capslock and control keys
//  inputs scancodes and outputs ascii
//

`include "scancode_rom.v"

module scancode_convert(clock,
			reset_n,
			scancode,
			ascii,
			key_up,
			strobe_in,
			strobe_out);

   input clock;
   input reset_n;
   input [7:0] scancode;
   output reg [7:0] ascii;
   output reg key_up;
   input strobe_in;
   output reg strobe_out;

   // one-hot state machine states
   parameter [2:0] 
		C_INIT			= 3'd0,
		C_IDLE			= 3'd1,
   		C_KEYPRESS		= 3'd2,
   		C_KEYRELEASE		= 3'd3,
		C_RELEASE		= 3'd4,
		C_HOLD			= 3'd5;

   //
   reg [2:0] state, nextstate;

   reg 	     release_prefix;
   reg 	     release_prefix_set, release_prefix_clear;
  
   reg 	     shift;
   reg 	     shift_set, shift_clear;

   reg 	     ctrl;
   reg 	     ctrl_set, ctrl_clear;
      
   reg 	     capslock;
   reg 	     capslock_toggle;

   reg 	     strobe_out_set, strobe_out_clear;
   reg 	     key_up_set, key_up_clear;

   reg [2:0] hold_count;
    	     
   reg [6:0] sc;
   wire [7:0] rom_data;
   wire       raise;

   // convert scancodes (plus shift/control) into ascii
   scancode_rom scancode_rom(.addr({raise,sc}),
			     .data(rom_data));

   assign raise = shift | capslock | ctrl;
   
   // internal state
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       begin
	  shift <= 1'b0;
	  capslock <= 1'b0;
	  ctrl <= 1'b0;

	  release_prefix <= 1'b0;
	  strobe_out <= 1'b0;
	  key_up <= 1'b0;

	  hold_count <= 3'b0;
       end
     else
       begin
	  if (shift_set)
	    shift <= 1'b1;
	  else
	  if (shift_clear)
	    shift <= 1'b0;

	  if (ctrl_set)
	    ctrl <= 1'b1;
	  else
	  if (ctrl_clear)
	    ctrl <= 1'b0;

	  if (capslock_toggle)
	    capslock <= ~capslock;

	  if (release_prefix_set)
	    release_prefix <= 1'b1;
	  else
	  if (release_prefix_clear)
	    release_prefix <= 1'b0;

	  if (strobe_out_set)
	    strobe_out <= 1'b1;
	  else
	    if (strobe_out_clear)
	      strobe_out <= 1'b0;

	  if (key_up_set)
	    key_up <= 1'b1;
	  else
	    if (key_up_clear)
	      key_up <= 1'b0;

	  //
	  if (state == C_HOLD)
	    hold_count <= hold_count + 1;
	  else
	    hold_count <= 3'd0;
       end

   // next state
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       state <= C_INIT;
     else
       state <= nextstate;

   always @(posedge clock)
     if (state == C_IDLE && strobe_in)
       sc <= scancode[6:0];

   always @(posedge clock)
     if (state == C_KEYPRESS || state == C_KEYRELEASE)
       ascii <= ctrl ? (rom_data - 8'h40) : rom_data;

   always @(state or strobe_in or scancode or release_prefix or shift or ctrl or rom_data or hold_count)
     begin
	shift_set = 1'b0;
	shift_clear = 1'b0;
	ctrl_set = 1'b0;
	ctrl_clear = 1'b0;
	capslock_toggle = 1'b0;
	release_prefix_set = 1'b0;
	release_prefix_clear = 1'b0;
	strobe_out_set = 1'b0;
	strobe_out_clear = 1'b0;
	key_up_set = 1'b0;
	key_up_clear = 1'b0;

	case (state) // synthesis full_case
	  C_INIT:
	    begin
	       nextstate = C_IDLE;
	    end

	  C_IDLE:
	    begin
	       if (strobe_in)
		 begin
		    case (scancode)
		      8'hf0:	/* release prefix */
			begin
			   release_prefix_set = 1'b1;
			   nextstate = C_IDLE;
			end
		      
		      8'h58:	/* caps lock */
			begin
			   if (release_prefix)
			     capslock_toggle = 1'b1;
			   nextstate = C_RELEASE;
			end
		      
		      8'h12,	/* left shift */
			8'h59:	/* right shift */
			  begin
			     if (release_prefix)
			       shift_clear = 1'b1;
			     else
			       shift_set = 1'b1;
			     nextstate = C_RELEASE;
			  end
		      
		      8'h14:	/* left ctrl */
			begin
			   if (release_prefix)
			     ctrl_clear = 1'b1;
			   else
			     ctrl_set = 1'b1;
			   nextstate = C_RELEASE;
			end
		      
		      default:
			nextstate = release_prefix ?
				    C_KEYRELEASE : C_KEYPRESS;
		    endcase
		 end
	       else
		 nextstate = C_IDLE;
	    end

	  C_KEYPRESS:
	    begin
	       strobe_out_set = 1'b1;
	       nextstate = C_RELEASE;
	    end

	  C_KEYRELEASE:
	    begin
`ifdef SEND_KEYUP
	       strobe_out_set = 1'b1;
`endif
	       strobe_out_clear = 1'b1;
	       key_up_set = 1'b1;
	       nextstate = C_RELEASE;
	    end
	  
	  C_RELEASE:
	    begin
	       release_prefix_clear = 1'b1;
	       nextstate = C_HOLD;
	    end

	  C_HOLD:
	    begin
	       nextstate = C_HOLD;

	       if (hold_count == 3'd4)
		 begin
		    strobe_out_clear = 1'b1;
		    key_up_clear = 1'b1;
		    nextstate = C_IDLE;
		 end
	    end
	  
	endcase
     end
   
endmodule


// ------------------

//`define TEST
`ifdef TEST

 
`timescale 1ns / 1ns

module test;

   reg clk, reset_n;
   reg [7:0] 	  testcode;
   wire [7:0] 	  kb_ascii;
   reg 		  kb_rdy;
   wire 	  kb_release;
   wire 	  kb_ascii_rdy;

   scancode_convert scancode_convert(.clock(clk),
				     .reset_n(reset_n),
				     .scancode(testcode),
				     .ascii(kb_ascii),
				     .key_up(kb_release),
				     .strobe_in(kb_rdy),
				     .strobe_out(kb_ascii_rdy));
   

   initial
     begin
	$timeformat(-9, 0, "ns", 7);
	
	$dumpfile("scancode.vcd");
	$dumpvars(0, test.scancode_convert);
     end

   initial
     begin
	clk = 1'b0;
	reset_n = 1'b0;
	kb_rdy = 1'b0;
       
	#200 begin
           reset_n = 1'b1;
	end

	// press "a"
	#10 begin kb_rdy = 1'b1; testcode = 8'h1c; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h1c; end
	#80 kb_rdy = 1'b0;

	// press "b"
	#1000 begin kb_rdy = 1'b1; testcode = 8'h32; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h32; end
	#80 kb_rdy = 1'b0;

	// enter
	#1000 begin kb_rdy = 1'b1; testcode = 8'h5a; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h5a; end
	#80 kb_rdy = 1'b0;
	
	// shift "a"
	#1000 begin kb_rdy = 1'b1; testcode = 8'h12; end
	#80 kb_rdy = 1'b0;

	#1000 begin kb_rdy = 1'b1; testcode = 8'h1c; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h1c; end
	#80 kb_rdy = 1'b0;
	
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h12; end
	#80 kb_rdy = 1'b0;

	// press "c"
	#1000 begin kb_rdy = 1'b1; testcode = 8'h21; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h21; end
	#80 kb_rdy = 1'b0;

	// ctrl "a"
	#1000 begin kb_rdy = 1'b1; testcode = 8'h14; end
	#80 kb_rdy = 1'b0;

	#1000 begin kb_rdy = 1'b1; testcode = 8'h1c; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h1c; end
	#80 kb_rdy = 1'b0;
	
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h14; end
	#80 kb_rdy = 1'b0;

	// press "d"
	#1000 begin kb_rdy = 1'b1; testcode = 8'h23; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'hf0; end
	#80 kb_rdy = 1'b0;
	#1000 begin kb_rdy = 1'b1; testcode = 8'h23; end
	#80 kb_rdy = 1'b0;

	
       #5000 $finish;
    end

   always
     begin
	#20 clk = 1'b0;
	#20 clk = 1'b1;
     end

endmodule

`endif
 