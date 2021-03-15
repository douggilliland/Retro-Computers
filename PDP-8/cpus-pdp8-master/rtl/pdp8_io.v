// PDP-8 i/o
// Based on descriptions in "Computer Engineering"
// Dev 2006 Brad Parker brad@heeltoe.com
// Revamp 2009 Brad Parker brad@heeltoe.com

module pdp8_io(clk, brgclk, reset, iot, state, mb,
	       io_data_in, io_data_out, io_select,
	       io_data_avail, io_interrupt, io_skip, io_clear_ac,
	       io_ram_read_req, io_ram_write_req, io_ram_done,
	       io_ram_ma, io_ram_in, io_ram_out,
               ide_dior, ide_diow, ide_cs, ide_da, ide_data_in, ide_data_out,
	       rs232_in, rs232_out);
   
   input clk;
   input brgclk;
   input reset;
   input iot;
   input [11:0] io_data_in;
   input [11:0]      mb;
   input [3:0] 	     state;
   input [5:0] 	     io_select;
   input wire 	     io_ram_done;
   input wire [11:0] io_ram_in;

   output wire [11:0] io_data_out;
   output wire 	      io_data_avail;
   output wire 	      io_interrupt;
   output wire 	      io_skip;
   output wire 	      io_clear_ac;

   output wire 	      io_ram_read_req;
   output wire 	      io_ram_write_req;
   output wire [14:0] io_ram_ma;
   output wire [11:0] io_ram_out;

   output 	     ide_dior;
   output 	     ide_diow;
   output [1:0]      ide_cs;
   output [2:0]      ide_da;
   input [15:0]      ide_data_in;
   output [15:0]     ide_data_out;

   input	     rs232_in;
   output	     rs232_out;

   wire 	     kw_io_selected;
   wire 	     kw_io_interrupt;
   wire 	     kw_io_skip;
   
   wire 	     tt_io_selected;
   wire [11:0] 	     tt_io_data_out;
   wire 	     tt_io_data_avail;
   wire 	     tt_io_interrupt;
   wire 	     tt_io_skip;
   wire 	     tt_io_clear_ac;

   wire 	     rf_io_selected;
   wire [11:0] 	     rf_io_data_out;
   wire 	     rf_io_data_avail;
   wire 	     rf_io_interrupt;
   wire 	     rf_io_skip;
   wire 	     rf_io_clear_ac;

   pdp8_kw kw(.clk(clk),
	      .reset(reset),
	      .iot(iot),
	      .state(state),
	      .mb(mb),
	      .io_select(io_select),

	      .io_selected(kw_io_selected),
	      .io_interrupt(kw_io_interrupt),
	      .io_skip(kw_io_skip));
	      
   pdp8_tt tt(.clk(clk),
	      .brgclk(brgclk),
	      .reset(reset),
	      .iot(iot),
	      .state(state),
	      .mb(mb),
	      .io_data_in(io_data_in),
	      .io_select(io_select),

	      .io_selected(tt_io_selected),
	      .io_data_out(tt_io_data_out),
	      .io_data_avail(tt_io_data_avail),
	      .io_interrupt(tt_io_interrupt),
	      .io_skip(tt_io_skip),

	      .uart_in(rs232_in),
	      .uart_out(rs232_out));

`ifndef use_rf_pli
   pdp8_rf rf(.clk(clk),
	      .reset(reset),
	      .iot(iot),
	      .state(state),
	      .mb(mb),
	      .io_data_in(io_data_in),
	      .io_select(io_select),

	      .io_selected(rf_io_selected),
	      .io_data_out(rf_io_data_out),
	      .io_data_avail(rf_io_data_avail),
	      .io_interrupt(rf_io_interrupt),
	      .io_skip(rf_io_skip),
	      .io_clear_ac(rf_io_clear_ac),

	      .ram_read_req(io_ram_read_req),
	      .ram_write_req(io_ram_write_req),
	      .ram_done(io_ram_done),
	      .ram_ma(io_ram_ma),
	      .ram_in(io_ram_in),
	      .ram_out(io_ram_out),

   	      .ide_dior(ide_dior),
	      .ide_diow(ide_diow),
	      .ide_cs(ide_cs),
	      .ide_da(ide_da),
	      .ide_data_in(ide_data_in),
	      .ide_data_out(ide_data_out));
`endif
   
   assign tt_io_clear_ac = 1'b0;

   assign io_data_out =
		       tt_io_selected ? tt_io_data_out :
		       rf_io_selected ? rf_io_data_out :
		       12'b0;

   assign io_data_avail =
			 tt_io_selected ? tt_io_data_avail :
			 rf_io_selected ? rf_io_data_avail :
			 1'b0;

`ifdef debug_ints
//   always @(*)
   always @(kw_io_interrupt or tt_io_interrupt or rf_io_interrupt or io_interrupt)
     if (io_interrupt)
       $display("io: io_interrupt: %b %b %b", 
		kw_io_interrupt, tt_io_interrupt, rf_io_interrupt);
`endif
   
   assign io_interrupt = kw_io_interrupt |
			 tt_io_interrupt |
			 rf_io_interrupt;

   assign io_skip =
		   kw_io_selected ? kw_io_skip :
		   tt_io_selected ? tt_io_skip :
		   rf_io_selected ? rf_io_skip :
		   1'b0;

   assign io_clear_ac =
		       tt_io_selected ? tt_io_clear_ac :
		       rf_io_selected ? rf_io_clear_ac :
		       1'b0;

`ifdef use_rf_pli
   always @(posedge clk or iot or state or mb or io_select)
     begin
	$pli_rf(clk, reset, iot, state, mb, io_data_in,
		io_select, rf_io_selected, rf_io_data_out, rf_io_data_avail,
		rf_io_interrupt, rf_io_skip, rf_io_clear_ac);
     end
`endif
   
endmodule
