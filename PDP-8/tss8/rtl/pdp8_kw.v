// KW8/I emulation
// brad@heeltoe.com

module pdp8_kw(clk, reset, iot, state, mb,
	       io_select, io_selected, io_interrupt, io_skip);

   input	clk;
   input 	reset;
   input 	iot;
   
   input [3:0] 	state;
   input [11:0] mb;
   input [5:0] 	io_select;

   output reg	     io_selected;
   output  	     io_interrupt;
   output reg 	     io_skip;

   // cpu states
   parameter
       F0 = 4'b0000,
       F1 = 4'b0001,
       F2 = 4'b0010,
       F3 = 4'b0011;

`ifdef sim_time
// `define sim_time_kw 1
`endif
   
`ifdef sim_time
   parameter CLK_DIV = 96000;
`else
   parameter SYS_CLK = 26'd50000000;
   parameter CLK_RATE = 26'd60;
   parameter CLK_DIV = SYS_CLK / CLK_RATE;
`endif

   wire [25:0] kw_clk_div;
   assign      kw_clk_div = CLK_DIV;
   
   // state
   reg [19:0] kw_ctr;
   reg 	      kw_int_en;
   reg 	      kw_clk_en;
   reg 	      kw_flag;
   
   reg 	      assert_kw_flag;
   wire	      assert_kw_ctr_zero;
   
   assign   io_interrupt = kw_int_en && kw_flag;

   // combinatorial
   always @(state or iot or io_select or kw_flag or mb)
     begin
	// sampled during f1
	io_skip = 1'b0;
	io_selected = 1'b0;

	if (state == F1 && iot)
	  /* verilator lint_off CASEINCOMPLETE */
	  case (io_select)
	    6'o13:
	      begin
		 io_selected = 1'b1;

		 /* verilator lint_off CASEINCOMPLETE */
		 case (mb[2:0] )
		 3'o3:
		   if (kw_flag)
		     io_skip = 1'b1;
		 endcase
		 /* verilator lint_on CASEINCOMPLETE */
		 
	      end
	  endcase // case(io_select)
	  /* verilator lint_on CASEINCOMPLETE */
     end
   
`ifdef sim_time_kw
   integer c_cycles, cycles;
   initial
     begin
	c_cycles = 0;
	cycles = 0;
     end
`endif

   //
   // registers
   //
   always @(posedge clk)
     if (reset)
       begin
	  kw_clk_en <= 1'b0;
	  kw_int_en <= 1'b0;
	  kw_flag <= 1'b0;
       end
     else
       case (state)
	  F0:
	    begin
`ifdef sim_time_kw
	       // to make sim deterministic, count cpu fetches
	       cycles = cycles + 1;
	       c_cycles = c_cycles + 1;
	       if (c_cycles > 16004)
		 begin
		    c_cycles = 0;
		    assert_kw_flag = 1;
		    $display("kw8i assert assert_kw_flag sim");
		 end
`endif
	    end

	  F1:
	    begin
	       if (iot && io_select == 6'o13)
		 case (mb[2:0])
		   3'o1:
		     begin
			kw_int_en <= 1'b1;
			kw_clk_en <= 1'b1;
`ifdef debug
			$display("kw8i: clocks on!");
`endif
		     end
		   3'o2:
		     begin
`ifdef debug
			$display("kw8i: CCFF");
`endif
			kw_flag <= 1'b0;
			kw_clk_en <= 1'b0;
			kw_int_en <= 1'b0;
		     end
		   3'o3:
		     begin
`ifdef sim_time_kw
			$display("kw8i: CSCF %d", c_cycles);
`endif
			kw_flag <= 1'b0;
		     end
		   3'o6:
		     begin
`ifdef debug
			$display("kw8i: CCEC");
`endif
			kw_clk_en <= 1;
		     end
		   3'o7:
		     begin
`ifdef debug
			$display("kw8i: CECI");
`endif
			kw_clk_en <= 1;
			kw_int_en <= 1;
		     end
		   default:
		     ;
		 endcase
	    end

	  F3:
	    begin
	       if (assert_kw_flag/* && kw_clk_en*/)
		 begin
		    kw_flag <= 1;
`ifdef debug
		    if (kw_clk_en)
		    $display("kw8i: assert_kw_flag %t", $time);
`endif
`ifdef sim_time_kw
		    if (kw_flag == 0) $display("kw8i: set kw_flag! cycles %d, %t",
					       cycles, $time);
`endif
		 end
	    end

	 default:
	   ;
	 
       endcase // case(state)

   //
   // once kw clock rolls over,
   // assert until next F3 cycles
   // to ensure kw_flag is set if enabled
   //
   always @(posedge clk or posedge reset)
     if (reset)
       assert_kw_flag <= 0;
     else
       if (assert_kw_ctr_zero)
	 begin
`ifdef debug
	    if (kw_clk_en)
	      $display("kw8i assert assert_kw_flag rtl");
`endif
	    assert_kw_flag <= 1;
	 end
       else
	 if (state == F3)
	   begin
`ifdef debug
	      if (assert_kw_flag)
		$display("kw8i deassert assert_kw_flag");
`endif
	      assert_kw_flag <= 0;
	   end
   
`ifndef sim_time_kw
   assign assert_kw_ctr_zero = kw_ctr == 0;
`endif
   
   //
   always @(posedge clk or posedge reset)
     if (reset)
       kw_ctr <= 0;
     else
       if (kw_clk_en)
	 begin
	    if (kw_ctr == kw_clk_div[19:0])
	      kw_ctr <= 0;
	    else
	      kw_ctr <= kw_ctr + 1;

`ifdef debug_clk
	    if (kw_ctr[14:0] == 15'b0)
	      $display("kw8i: ctr %o, max %o", kw_ctr, kw_clk_div[19:0]);
`endif
	 end

endmodule // pdp8_kw

