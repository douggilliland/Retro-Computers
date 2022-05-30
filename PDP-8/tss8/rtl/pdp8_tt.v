// PDP-8 console emulation
// brad@heeltoe.com

`ifdef debug
`define debug_tt_int 1
//`define debug_tt_reg 1
//`define debug_tt_state 1
`define debug_tt_data 1
`endif

module pdp8_tt(clk, brgclk, reset,
	       iot, state, mb,
	       io_data_in, io_data_out, io_select, io_selected,
	       io_data_avail, io_interrupt, io_skip,
	       uart_in, uart_out);
   
   input	clk;
   input 	brgclk;
   input 	reset;
   input 	iot;
   
   input [3:0] 	state;
   input [11:0] mb;
   input [11:0] io_data_in;
   input [5:0] 	io_select;
   input	uart_in;

   output reg [11:0] io_data_out;
   output reg	     io_selected;
   output  	     io_data_avail;
   output  	     io_interrupt;
   output reg 	     io_skip;
   output	     uart_out;
   
   // internal state
   reg [7:0] 	     tx_data;
   reg 		     tx_int;
   wire 	     tx_empty;
   wire 	     tx_ack;

   wire [11:0] 	     rx_data;
   reg 		     rx_int;
   wire 	     rx_empty;
   wire 	     rx_ack;

   wire 	     assert_tx_int;
   wire 	     assert_rx_int;

   wire		     tx_busy;
 	     
   // interface to uart
   reg [2:0] 	     tto_state;
   wire [2:0] 	     tto_state_next;
   wire 	     tto_empty;
   wire 	     tto_req;
   reg 		     tto_write;
   
   reg [1:0] 	     tti_state;
   wire [1:0] 	     tti_state_next;
   wire 	     tti_full;
   wire 	     tti_req;
   reg 		     tti_read;
   
   wire 	     uart_tx_clk;
   wire 	     uart_rx_clk;

   // cpu states
   parameter [3:0]
		F0 = 4'b0000,
 		F1 = 4'b0001,
 		F2 = 4'b0010,
 		F3 = 4'b0011;

   //
   brg baud_rate_generator(.clk(brgclk),
			   .reset(reset),
			   .tx_baud_clk(uart_tx_clk),
			   .rx_baud_clk(uart_rx_clk));

`ifdef use_fake_uart
   //
   fake_uart tt_uart(.clk(clk),
		     .reset(reset),
		     .state(state),
		     
		     .tx_clk(uart_tx_clk),
		     .tx_req(tto_req),
		     .tx_ack(tx_ack),
		     .tx_data(tx_data), 
		     .tx_empty(tx_empty),
		     
		     .rx_clk(uart_rx_clk),
		     .rx_req(tti_req),
		     .rx_ack(rx_ack),
		     .rx_empty(rx_empty),
		     .rx_data(rx_data[7:0]));
`else
   //
   uart tt_uart(.clk(clk),
		.reset(reset),

		.tx_clk(uart_tx_clk),
		.tx_req(tto_req),
		.tx_ack(tx_ack),
		.tx_data(tx_data), 
		.tx_empty(tx_empty),
		     
		.rx_clk(uart_rx_clk),
		.rx_req(tti_req),
		.rx_ack(rx_ack),
		.rx_data(rx_data[7:0]),
		.rx_empty(rx_empty),

		.rx_in(uart_in),
		.tx_out(uart_out));
`endif
   
   // interrupt output
   assign io_interrupt = rx_int || tx_int;

   assign io_data_avail = 1'b1;

   assign rx_data[11:8] = 4'b0;
   
   // combinatorial
   always @(state or iot or io_select or mb or
	    rx_int or tx_int or tx_busy or io_data_in or rx_data)
     begin
	// sampled during f1
	io_skip = 1'b0;
	io_data_out = io_data_in;
	io_selected = 1'b0;

	tti_read = 0;
	tto_write = 0;
	
	if (state == F1 && iot)
	  case (io_select)
	    6'o03:
	      begin
		 io_selected = 1'b1;
		 if (mb[0])
		   io_skip = rx_int;

		 if (mb[1])
		   begin
		      tti_read = 1;
		   end
		 
		 if (mb[2])
		   begin
`ifdef debug_tt_data
		      if (mb[1])
			$display("xxx rx_data %o", rx_data);
`endif
		      io_data_out = rx_data;
		   end
		 else
		   io_data_out = 12'b0;

	      end
	    
	    6'o04:
	      begin
		 io_selected = 1'b1;
		 if (mb[0])
		   begin
//		      io_skip = tx_int;
//		      $display("xxx io_skip %b", tx_int);
		      io_skip = ~tx_busy;
		   end
		 if (mb[2])
		   tto_write = 1;
	      end

	    default:
	      ;
	    
	  endcase // case(io_select)
     end
   
   //
   // registers
   //
   always @(posedge clk)
     if (reset)
       begin
	  rx_int <= 0;
	  tx_int <= 0;

	  tx_data <= 8'b0;
       end
     else
       begin

//	  if (assert_rx_int)
//	    begin
//	       //$display("xxx set rx_int");
//	       rx_int <= 1;
//	    end

	  if (iot && state == F1)
	    begin
`ifdef debug_tt_reg
	       if (io_select == 6'o03 || io_select == 6'o04)
		 $display("iot2 %t, state %b, mb %o, io_select %o",
			  $time, state, mb, io_select);
`endif
	       case (io_select)
		 6'o03:
		   begin
		      if (mb[1] /*&& ~assert_rx_int*/)
			begin
			   rx_int <= 1'b0;
`ifdef debug
			   $display("xxx reset rx_int");
`endif
			end
		   end

		 6'o04:
		   begin
		      if (mb[0])
			begin
			end
		      if (mb[1] && ~assert_tx_int)
			begin
			   tx_int <= 1'b0;
`ifdef debug
			   $display("xxx reset tx_int");
`endif
			end
		      if (mb[2])
			begin
tx_int <= 1'b0;
			   tx_data <= io_data_in[7:0];
`ifdef debug_tt_data
			   $display("xxx tx_data %o %t", io_data_in, $time);
`endif
			end
		   end

		 default:
		   ;
		 
               endcase
	    end // if (iot && state == F1)
	  else
	    begin
	       if (assert_rx_int && ~rx_int)
		 begin
`ifdef debug
		    $display("xxx set rx_int");
`endif
		    rx_int <= 1;
		 end

	       if (assert_tx_int && ~tx_int)
		 begin
`ifdef debug
		    $display("xxx set tx_int");
`endif
		    tx_int <= 1;
		 end

//	       if (assert_tx_int)
//		 begin
//`ifdef debug_tt_int
//		    $display("xxx set tx_int");
//`endif
//		    tx_int <= 1;
//		 end
	    end // else: !if(iot && state == F1)
	  
       end // else: !if(reset)
   

   // tto state machine
   // assert tx_req until uart catches up
   // hold off cpu until tx_empty does full transition
   // state 0 - idle; wait for iot write to data
   // state 1 - wait for tx_ack to assert
   // state 2 - wait for tx_ack to deassert
   // state 3 - wait for tx_empty to assert
   
   always @(posedge clk)
     if (reset)
       tto_state <= 0;
     else
       tto_state <= tto_state_next;

   assign tto_req = tto_state == 1;
   assign tto_empty = tto_state == 0;
   assign tx_busy = ~tto_empty;
   
   assign tto_state_next = (tto_state == 0 && tto_write) ? 1 :
			   (tto_state == 1 && tx_ack) ? 2 :
			   (tto_state == 2 && ~tx_ack) ? 3 :
			   (tto_state == 3 && tx_empty) ? 4 :
			   (tto_state == 4) ? 0 :
			   tto_state;

   assign assert_tx_int = tto_state == 4;

`ifdef debug
   always @(posedge clk)
     if (tto_state != 0)
       $display("tto_state %d; tx_ack %b tx_empty %b",
		tto_state, tx_ack, tx_empty);
`endif
   
`ifdef debug_tt_int
   always @(posedge clk)
     if (assert_tx_int)
       $display("xxx assert_tx_int");
`endif
   
`ifdef debug_tt_state
   always @(posedge clk) if (tto_state) $display("tto_state %d", tto_state);
`endif
   
   // tti state machine
   // don't become ready until we've clock data out of uart holding reg
   // state 0 - idle; wait for rx_empty to deassert
   // state 1 - wait for rx_empty to assert
   // state 2 - wait for rx_empty to deassert
   // state 3 - wait for iot read of uart (tti)

   always @(posedge clk)
     if (reset)
       tti_state <= 0;
     else
       tti_state <= tti_state_next;

   assign tti_req = tti_state == 1;
   assign tti_full = tti_state == 3;

   assign tti_state_next = (tti_state == 0 && ~rx_empty) ? 1 :
			   (tti_state == 1 && rx_ack) ? 2 :
			   (tti_state == 2 && ~rx_ack) ? 3 :
			   (tti_state == 3 && tti_read) ? 0 :
			   tti_state;

   assign assert_rx_int = tti_full;

`ifdef debug_tt_state
   always @(posedge clk) if (tti_state) $display("tti_state %d", tti_state);
`endif
   
endmodule
