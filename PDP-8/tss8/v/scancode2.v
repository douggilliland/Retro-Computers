// scancode2.v

//
// simple AT style keyboard scancode to ascii convertion
//  keeps track of shift, capslock and control keys
//  inputs scancodes and outputs ascii
//
// implicit state machine version
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

   reg 	     release_prefix;
   reg 	     shift;
   reg 	     ctrl;
   reg 	     capslock;
   
   reg [6:0] sc;
   wire [7:0] rom_data;
   wire       raise;
   
   scancode_rom scancode_rom(.addr({raise,sc}),
			     .data(rom_data));

   assign raise = shift | capslock | ctrl;
   
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       begin
	  shift <= 0;
	  ctrl <= 0;
	  capslock <= 0;
	  release_prefix <= 0;
	  key_up <= 0;
	  strobe_out <= 0;
       end
     else
       begin
	  if (strobe_in)
	    begin
	       strobe_out <= 0;

	       sc = scancode[6:0];
	       case (scancode)
		 8'hf0:	/* release prefix */
		   begin
		      @(posedge clock) release_prefix <= 1;
		   end

		 8'h58:	/* caps lock */
		   begin
		      if (~release_prefix)
			@(posedge clock) capslock = ~capslock;
		   end
		   
		 8'h12,	/* left shift */
		   8'h59:	/* right shift */
		     begin
			@(posedge clock) shift = release_prefix ? 0 : 1;
		     end
		   
		 8'h14:	/* left ctrl */
		   begin
		      @(posedge clock) ctrl = release_prefix ? 0 : 1;
		   end
		   
		 default:
		   begin
		      if (release_prefix)
			begin
			   @(posedge clock)
			     begin
				ascii = ctrl ? (rom_data - 8'h40) : rom_data;
				strobe_out <= 1;
			     end
			   @(posedge clock) strobe_out <= 1;
			   @(posedge clock)
			     begin
				strobe_out <= 0;
				release_prefix <= 0;
			     end
			end
		      else
			begin
			   @(posedge clock)
			     begin
 /*
				ascii = ctrl ? (rom_data - 8'h40) : rom_data;
				strobe_out <= 1;
 */
				key_up <= 1;
			     end
			   @(posedge clock) strobe_out <= 0;
			   @(posedge clock)
			     begin
				strobe_out <= 0;
				release_prefix <= 0;
			     end
			end
		      end
	       endcase // case(scancode)

	    end // if (strobe_in)
       end // else: !if(~reset_n)

endmodule

     
///*  

 
// ------------------

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
	clk = 0;
	reset_n = 0;
	kb_rdy = 0;
       
	#200 begin
           reset_n = 1;
	end

	// press "a"
	#10 begin kb_rdy = 1; testcode = 8'h1c; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h1c; end
	#80 kb_rdy = 0;

	// press "b"
	#1000 begin kb_rdy = 1; testcode = 8'h32; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h32; end
	#80 kb_rdy = 0;

	// enter
	#1000 begin kb_rdy = 1; testcode = 8'h5a; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h5a; end
	#80 kb_rdy = 0;
	
	// shift "a"
	#1000 begin kb_rdy = 1; testcode = 8'h12; end
	#80 kb_rdy = 0;

	#1000 begin kb_rdy = 1; testcode = 8'h1c; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h1c; end
	#80 kb_rdy = 0;
	
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h12; end
	#80 kb_rdy = 0;

	// press "c"
	#1000 begin kb_rdy = 1; testcode = 8'h21; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h21; end
	#80 kb_rdy = 0;

	// ctrl "a"
	#1000 begin kb_rdy = 1; testcode = 8'h14; end
	#80 kb_rdy = 0;

	#1000 begin kb_rdy = 1; testcode = 8'h1c; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h1c; end
	#80 kb_rdy = 0;
	
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h14; end
	#80 kb_rdy = 0;

	// press "d"
	#1000 begin kb_rdy = 1; testcode = 8'h23; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'hf0; end
	#80 kb_rdy = 0;
	#1000 begin kb_rdy = 1; testcode = 8'h23; end
	#80 kb_rdy = 0;

	
       #5000 $finish;
    end

   always
     begin
	#40 clk = 0;
	#40 clk = 1;
     end

endmodule

//*/