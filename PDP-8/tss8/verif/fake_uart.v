//
// fake model of uart used for sim
//

//`define debug_fake_tx 1
`define debug_fake_rx 1

module fake_uart(clk, reset, state,
		 tx_clk, tx_req, tx_ack, tx_data, tx_empty,
		 rx_clk, rx_req, rx_ack, rx_empty, rx_data);

   input clk;
   input reset;
   input [3:0] state;

   input tx_clk;
   input tx_req;
   input [7:0] tx_data;

   input rx_clk;
   input rx_req;

   output tx_ack;
   output tx_empty;

   output rx_ack;
   output rx_empty;
   output reg [7:0] rx_data;

   //
   reg [1:0] 	t_state;
   wire [1:0] 	t_state_next;
   
   reg [1:0] 	r_state;
   wire [1:0] 	r_state_next;

   integer 	t_delay;
   reg 		t_done;

   //
   assign t_state_next =
			(t_state == 0 && tx_req) ? 1 :
			t_state == 1 ? 2 :
			(t_state == 2 && t_done) ? 0 :
			t_state;

   assign tx_ack = t_state == 1;
   assign tx_empty = t_delay == 0;

   initial
     begin
	t_delay = 0;
	refire_state = 0;
     end

   always @(posedge clk)
     begin
`ifdef debug/*_fake_tx*/
	if (t_state != 0)
	  $display("t_state %d t_delay %d t_done %b tx_empty %b",
		   t_state, t_delay, t_done, tx_empty);
`endif

	if (t_state == 1)
	  begin
	     t_delay = 38/*20*/;
	  end
	if (t_state == 2)
	  begin
	     if (t_delay < 0)
	       begin
		  t_done = 1;
		  $display("xxx t_done; cycles %d", cycles);
	       end

	     if (state == 4'b0001)
	       t_delay = t_delay - 1;
	  end

	if (t_state == 0)
	  t_done = 0;
     end

   integer cycles;
   initial
     cycles = 0;

   parameter BASE = 230000;
   
   always @(posedge clk)
     begin
	if (state == 4'b0001)
	  begin
	     cycles = cycles + 1;
	     //$display("cycles %d", cycles);
//	     if (r_index == r_count && cycles >= 30000)
//	       begin
//		  $display("xxx want input; cycles %d", cycles);
//	       end

	     if (r_index != r_count && cycles == BASE+10000)
	       begin
		  $display("xxx can't boom 1 %d %d", r_index, r_count);
	       end
	     if (r_index == r_count && cycles == BASE+10000)
	       begin
		  ii = 0;
		  rdata[ii] = "L"; ii = ii + 1;
		  rdata[ii] = "O"; ii = ii + 1;
		  rdata[ii] = "G"; ii = ii + 1;
		  rdata[ii] = "I"; ii = ii + 1;
		  rdata[ii] = "N"; ii = ii + 1;
		  rdata[ii] = " "; ii = ii + 1;
		  rdata[ii] = "2"; ii = ii + 1;
		  rdata[ii] = " "; ii = ii + 1;
		  rdata[ii] = "L"; ii = ii + 1;
		  rdata[ii] = "X"; ii = ii + 1;
		  rdata[ii] = "H"; ii = ii + 1;
		  rdata[ii] = "E"; ii = ii + 1;
		  rdata[ii] = "\215"; ii = ii + 1;
		  rdata[ii] = "\215"; ii = ii + 1;
		  r_index = 0;
		  r_count = ii;
		  r_refires = 1;
		  $display("xxx boom 1; cycles %d", cycles);
	       end

	     if (r_index == r_count && cycles == BASE+300000)
	       begin
		  rdata[0] = "\215";
		  r_index = 0;
		  r_count = 1;
		  r_refires = 2;
		  $display("xxx boom 2; cycles %d", cycles);
	       end
	     if (r_index == r_count && cycles == BASE+320000)
	       begin
		  rdata[0] = "\215";
		  r_index = 0;
		  r_count = 1;
		  r_refires = 3;
		  $display("xxx boom 3; cycles %d", cycles);
	       end
`define msg_rcat 1
//`define msg_rfocal 1
//`define msg_rpald 1
//`define msg_rpip 1
	     if (r_index == r_count && cycles == BASE+400000)
	       begin
`ifdef msg_rcat
		  rdata[0] = "R";
		  rdata[1] = " ";
		  rdata[2] = "C";
		  rdata[3] = "A";
		  rdata[4] = "T";
		  rdata[5] = "\215";
		  r_index = 0;
		  r_count = 6;
`endif
`ifdef msg_rfocal
		  rdata[0] = "R";
		  rdata[1] = " ";
		  rdata[2] = "F";
		  rdata[3] = "O";
		  rdata[4] = "C";
		  rdata[5] = "A";
		  rdata[6] = "L";
		  rdata[7] = "\215";
		  r_index = 0;
		  r_count = 8;
`endif
`ifdef msg_rpald
		  rdata[0] = "R";
		  rdata[1] = " ";
		  rdata[2] = "P";
		  rdata[3] = "A";
		  rdata[4] = "L";
		  rdata[5] = "D";
		  rdata[6] = "\215";
		  r_index = 0;
		  r_count = 7;
`endif
`ifdef msg_rpip
		  rdata[0] = "R";
		  rdata[1] = " ";
		  rdata[2] = "P";
		  rdata[3] = "I";
		  rdata[4] = "P";
		  rdata[5] = "\215";
		  r_index = 0;
		  r_count = 6;
`endif
		  r_refires = 4;
		  $display("xxx boom 4; cycles %d", cycles);
	       end
	     if (r_index == r_count && cycles == BASE+500000/*600000*/)
	       begin
		  rdata[0] = "\215";
		  r_index = 0;
		  r_count = 1;
		  r_refires = 5;
		  $display("xxx boom 5; cycles %d", cycles);
	       end
	  end
     end
   
   //
   assign r_state_next =
			r_state == 0 && rx_req ? 1 :
			r_state == 1 ? 2 :
			r_state == 2 ? 0 :
			r_state;
   

   assign rx_ack = r_state == 1;
   
   /* verilator lint_off UNOPTFLAT */
   integer r_index;
   /* verilator lint_off UNOPTFLAT */
   integer r_count, r_refires;

   integer do_refire, refire_state;
   
   assign rx_empty = r_index == r_count;

   initial
     begin
	r_index= 0;
`ifdef no_fake_input
	r_count = 0;
`else
	r_count = 22;
`endif
	r_refires = 0;
     end

   reg [7:0] rdata[50:0];
   integer   ii;

   /* "START\r01:01:85\r10:10\r" */
   initial
     begin
	ii = 0;
	rdata[ii] = 0; ii=ii+1;	
	rdata[ii] = "S"; ii=ii+1;
	rdata[ii] = "T"; ii=ii+1;
	rdata[ii] = "A"; ii=ii+1;
	rdata[ii] = "R"; ii=ii+1;
	rdata[ii] = "T"; ii=ii+1;
	rdata[ii] = "\215"; ii=ii+1;
	rdata[ii] = "0"; ii=ii+1;
	rdata[ii] = "1"; ii=ii+1;
	rdata[ii] = ":"; ii=ii+1;
	rdata[ii] = "0"; ii=ii+1;
	rdata[ii] = "1"; ii=ii+1;
	rdata[ii] = ":"; ii=ii+1;
	rdata[ii] = "8"; ii=ii+1;
	rdata[ii] = "5"; ii=ii+1;
	rdata[ii] = "\215"; ii=ii+1;
	rdata[ii] = "1"; ii=ii+1;
	rdata[ii] = "0"; ii=ii+1;
	rdata[ii] = ":"; ii=ii+1;
	rdata[ii] = "1"; ii=ii+1;
	rdata[ii] = "0"; ii=ii+1;
	rdata[ii] = "\215"; ii=ii+1;
	rdata[ii] = "\215"; ii=ii+1;
	
	rx_data = 0;
     end

   
    always @(posedge clk)
     begin
	if (r_state == 2)
	  begin
`ifdef debug_fake_rx
	     $display("xxx dispense %o %0d %t",
		      rdata[r_index], r_index, $time);
`endif
	     rx_data = rdata[r_index];
	     r_index = r_index + 1;
	  end
     end
	  
   //
   always @(posedge clk)
     if (reset)
       t_state <= 0;
     else
       t_state <= t_state_next;
   
   always @(posedge clk)
     if (reset)
       r_state <= 0;
     else
       r_state <= r_state_next;
   
endmodule

