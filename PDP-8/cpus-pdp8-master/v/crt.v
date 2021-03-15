// crt.v

//
// Extremely basic crt ram management
//
// insert character
//   check for printable
//   check for cr,lf
// scroll one line
//   advance start
//   clear last line
//   move to begining of line
// lf
//   move to next line
// cr
//   move to begining of line
//

module crt(reset_n, clock,
	   insert, done, data, clearing,
	   ram_addr, ram_data, ram_we_n, ram_wclk, ram_wslot,
	   cursorh, cursorv);

   input reset_n;
   input clock;
   input insert;
   output reg done;
   output reg clearing;
   input [7:0] data;
   output [11:0] ram_addr;
   output reg [7:0] ram_data;
   output reg 	    ram_we_n;
   output [6:0]     cursorh;
   output [5:0]     cursorv;
   output reg 	    ram_wclk;
   input 	    ram_wslot;
   
   reg [6:0] cursor_h;
   reg [5:0] cursor_v;

   // conditions
   wire	     eol, scroll;

   // output of state machine
   reg 	     inc_h, clr_h;
   reg 	     inc_v, clr_v;
   reg 	     set_newline;
   reg 	     set_done;
 	     
   // external state
   reg 	     newline;

   reg [11:0] offset;
   reg 	      inc_offset, clr_offset;

   reg [3:0]  state, nextstate;
   wire       printable;

   reg [2:0]  write_delay;

   // offset + v*80 + h
   // factored into (v*64 + v*16) + h
   assign ram_addr =
//debug /*offset +*/
		     {cursor_v, 6'b0} + {2'b0, cursor_v, 4'b0} +
		     {4'b000, cursor_h};

   assign printable = ((data[6:0] > 7'h20) && (data[6:0] < 7'h7f)) ?
		      1'b1 : 1'b0;

   // one-hot states
   parameter [3:0]
		T_RESET			= 4'd0,
		T_CLEARALL		= 4'd1,
		T_CLEARALL_NEXT		= 4'd2,
		T_IDLE			= 4'd3,
		T_PREWRITE		= 4'd4,
		T_WRITE			= 4'd5,
		T_POSTWRITE		= 4'd6,
		T_NEWLINE		= 4'd7,
		T_SCROLL		= 4'd8,
		T_CLEARLAST		= 4'd9,
		T_CLEARLAST_WRITE	= 4'd10,
		T_CLEARLAST_NEXT	= 4'd11,
		T_CLEARLAST_DONE	= 4'd12;
   
   
   // don't change unless you fix the factored *80 in ram_addr
   parameter [6:0]   COLS = 80;
   parameter [5:0]   LINES = 25;

   // manage incrementing offset
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       offset <= 12'b0;
     else
       begin
	  if (inc_offset)
	    if (offset == (LINES-1)*COLS)
	      offset <= 12'b0;
	    else
	      offset <= offset + COLS;
       end

   // manage clearing offset when it rolls over
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       clr_offset <= 0;
     else
       begin
	  if (offset >= LINES*COLS)
	    clr_offset <= 1;
	  else
	    clr_offset <= 0;
       end

   // manage incrementing h
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       cursor_h <= 7'b0;
     else
	 begin
	    if (inc_h)
	      cursor_h <= cursor_h + 1;
	    else
	      if (clr_h)
		cursor_h <= 7'b0;
	 end

   // manage incrementing v
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       cursor_v <= 6'b0;
     else
	 begin
	    if (inc_v)
	      cursor_v <= cursor_v + 1;
	    else
	      if (clr_v)
		cursor_v <= 6'b0;
	 end
   
   // manage end of line
   assign eol = cursor_h == (COLS-1);

   // and end of screen
   assign scroll = cursor_v == (LINES-1);

   // manage external state
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       begin
	  ram_data <= 8'b0;
	  done <= 1'b0;
	  newline <= 1'b0;
	  write_delay <= 3'b0;
       end
   else
     begin
	//debug
	if (state == T_CLEARALL_NEXT)
	  begin
	     if (cursor_h == 7'd1)
	       ram_data <= 8'h30 + {5'b0, cursor_v[5:3]};
	     else
	     if (cursor_h == 7'd2)
	       ram_data <= 8'h30 + {5'b0, cursor_v[2:0]};
	     else
	       ram_data <= 8'h30 + {1'b0, cursor_h};
//	       ram_data <= 8'h40;
//	       ram_data <= 8'h20 + {1'b0, cursor_h} + { 2'b00, cursor_v};
	  end
	
	if (state == T_CLEARLAST_WRITE)
	  ram_data <= 8'b0;

	if (state == T_IDLE)
	  begin
	     newline <= 1'b0;
	     done <= 1'b0;
	     if (insert)
	       ram_data <= data;
	  end

	if (state == T_WRITE ||
	    state == T_CLEARLAST_WRITE ||
	    state == T_CLEARALL)
	    write_delay <= write_delay + 1;
	  else
	    write_delay <= 3'd0;

	if (set_newline)
	  newline <= 1'b1;

	if (set_done)
	  done <= 1'b1;
     end
   
   // next state
   always @(posedge clock or negedge reset_n)
     if (~reset_n)
       state <= T_RESET;
     else
       state <= nextstate;

   // insert state machine
   always @(state or insert or eol or newline or scroll or
	    printable or data or write_delay or ram_wslot)
     begin
 	inc_h = 1'b0;
	clr_h = 1'b0;
	inc_v = 1'b0;
	clr_v = 1'b0;
	inc_offset = 1'b0;
	set_newline = 1'b0;
	set_done = 1'b0;
	clearing = 1'b0;
	ram_we_n = 1'b1;
	
     case (state) // synthesis full_case
       T_RESET:
	 begin
	    clearing = 1'b1;
	    nextstate = T_CLEARALL;
nextstate = T_IDLE;
	 end
       
       T_CLEARALL:
	 begin
	    clearing = 1'b1;
	    ram_we_n = 1'b0;
	    ram_wclk = (write_delay == 3'd1) ? 1 : 0;
	    nextstate = (write_delay == 3'd1) ? T_CLEARALL_NEXT : T_CLEARALL;
	 end

       T_CLEARALL_NEXT:
	 begin
	    clearing = 1'b1;
	    nextstate = T_CLEARALL;
	    
 	    if (eol)
	      begin
//debug
// if (cursor_v == 15)
		 if (scroll)
		   begin
		      clr_v = 1'b1;
		      clr_h = 1'b1;
		      nextstate = T_IDLE;
		   end
		 else
		   begin
		      clr_h = 1'b1;
		      inc_v = 1'b1;
		   end
	      end
	    else
		 inc_h = 1'b1;
	 end
       
       T_IDLE:
	 begin
	    clearing = 1'b0;
	    if (insert)
	      begin
		 // if printable character, write to ram
		 if (printable)
		   nextstate = T_PREWRITE;
		 else
		   nextstate = T_POSTWRITE;
	      end
	    else
	      nextstate = T_IDLE;
	 end

       T_PREWRITE:
	 begin
	    // wait until we're in the write slot
	    nextstate = ram_wslot ? T_WRITE : T_PREWRITE;

	    if (eol)
	      begin
		 set_newline = 1'b1;
		 clr_h = 1'b1;
	      end
	 end
       
       T_WRITE:
	 begin
	    ram_we_n = 1'b0;

	    // delay until ram_wclk catches up
	    ram_wclk = (write_delay == 3'd1) ? 1 : 0;
	    nextstate = (write_delay == 3'd1) ? T_POSTWRITE : T_WRITE;
	 end

       T_POSTWRITE:
	 begin
	    set_done = 1'b1;

	    // cr
	    if (data[6:0] == 7'h0d)
	      clr_h = 1'b1;
	    else
	      inc_h = 1'b1;
	      
	    // eol or lf
	    if (newline || (data[6:0] == 7'h0a))
	      nextstate = T_NEWLINE;
	    else
	      nextstate = T_IDLE;
	 end

       T_NEWLINE:
	 begin
	    clr_h = 1'b1;

	    if (scroll)
	      nextstate = T_SCROLL;
	    else
	      begin
		 inc_v = 1'b1;
		 nextstate = T_IDLE;
	    end
	    
	 end
       
       T_SCROLL:
	 begin
	    clr_h = 1'b1;
	    inc_offset = 1'b1;
	    nextstate = T_CLEARLAST;
	 end

       T_CLEARLAST:
	 begin
	    nextstate = T_CLEARLAST_WRITE;
	 end

       T_CLEARLAST_WRITE:
	 begin
	    ram_we_n = 1'b0;

	    // delay until ram_wclk catches up
	    ram_wclk = (write_delay == 3'd1) ? 1 : 0;
	    nextstate = (write_delay == 3'd1) ?
			T_CLEARLAST_NEXT : T_CLEARLAST_WRITE;
	 end

       T_CLEARLAST_NEXT:
	 begin
	    inc_h = 1'b1;
	    ram_we_n = 1'b1;
	    nextstate = T_CLEARLAST_WRITE;
	    
	    if (eol)
	      nextstate = T_CLEARLAST_DONE;
	 end

       T_CLEARLAST_DONE:
	 begin
	    clr_h = 1'b1;
	    nextstate = T_IDLE;
	 end
     endcase
     end
   
   assign cursorh = cursor_h;
   assign cursorv = cursor_v;
   
endmodule


// ------------------

//`define TEST
`ifdef TEST
 
`timescale 1ns / 1ns

module test;

   reg clk, reset_n;
   reg insert;
   wire done;
   reg [7:0] data;
   integer count;
   reg 	   free;

   
   wire [11:0] ram_addr;
   wire [7:0]  ram_data;
   wire        ram_we_n;
   wire [6:0]  cursorh;
   wire [5:0]  cursorv;
   
   crt _crt(reset_n, clk,
	    insert, done, data,
	    ram_addr, ram_data, ram_we_n,
	    cursorh, cursorv);

//   defparam    _crt.LINES = 4;
//   defparam    _crt.COLS = 4;
   
   initial
     begin
	$timeformat(-9, 0, "ns", 7);
	
	$dumpfile("crt.vcd");
	$dumpvars(0, test._crt);
     end

   always @(posedge done)
     if (free)
     begin
	data = 8'h41 + count;
	count = count + 1;
	if (count == 3)
	  begin
	     count = 0;
	     data = 8'o212;
	  end
     end
   
   initial
     begin
	clk = 0;
	reset_n = 1;
	insert = 0;
	data = 0;
	count = 0;
	free = 0;

	#1   reset_n = 0;
	#100 reset_n = 1;

	#200 begin insert = 1; data = 8'h41; end
	#80 insert = 0;

	#200 begin insert = 1; data = 8'h42; end
	#80 insert = 0;

	#200 begin insert = 1; data = 8'h0d; end
	#80 insert = 0;

	#200 begin insert = 1; data = 8'h0a; end
	#80 insert = 0;

	#200 begin insert = 1; data = 8'h43; end
	#80 insert = 0;
	   
//       #50000 $finish;
       #10000 $finish;
    end

   always
     begin
	#20 clk = 0;
	#20 clk = 1;
     end

endmodule

`endif //  `ifdef TEST

