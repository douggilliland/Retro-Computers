// PDP-8/I in verilog
// copyright Brad Parker <brad@heeltoe.com> 2005-2010
// 
// Based on descriptions in "Computer Engineering" and various PDP-8/I manuals
// fully implements extended memory (IF & DF) and user mode (KT8/I)
//
// Mar 2010
//	co-simulation with simh & behavioral model to boot TSS/8
//	passes 8/I instruction and extended memory diags
//	split out peripherals, added external dma
// Apr 2009
//	major revamp for synthesis, removed latches, added muxes, new top
// Jan 2007
//	cleaned up state machines for synthesis
// 	finished extended memory (IF & DF), user mode (KT8/I)
//	added rf08 registers
// Dec 2006
//	cleaned up a little; now runs focal to prompt
//	moved i/o out to pdp8_io.v
//	added IF, DF, user mode
// Nov 2005 Brad Parker brad@heeltoe.com
//	initial work; runs focal a bit
//

//   
// Instruction format:
//
//  0  1  2   3   4   5   6   7   8   9  10  11
// 11 10  9   8   7   6   5   4   3   2   1   0
// |--op--|
// 0 and
// 1 tad
// 2 isz
// 3 dca
// 4 jms
// 5 jmp
// 6 iot
// 7 opr
// 11 10  9   8   7   6   5   4   3   2   1   0
// group 1
//            0
//               |cla|clf|       |          |
//               |   |   |cma cml|          |
//                               |bsw 001   |
//                               |ral 010   |
//                               |rtl 011   |
//                               |rar 100   |
//                               |rtr 101   |
//                               |          |iac
//
// 11 10  9   8   7   6   5   4   3   2   1   0
// group 2
//            1                               0
//                   |sma|sza|snl|skp|      |
//               |cla|
//                                   |osr|hlt
//
// group 3
// 11 10  9   8   7   6   5   4   3   2   1   0
// eae
//            1                               1
//               |cla|
//                   |mqa|sca|mql|
//                               |isn       |
// 
//

//
// cpu states
//
//  F0 read ram[IF,pc]
//  F1 incr pc
//  F2 ?
//  F3 dispatch
//
// then
//
//    E0 read ram[ea]
//    E1 decode
//    E2 write ram
//    E3 load
//
// or
//
//    D0 read ram[ea]
//    D1 wait
//    D2 write ram
//    D3 load
//
//  H0 halted
//
// ------
// Rules for address calculation
// 0 and
// 1 tad
// 2 isz
// 3 dca
//
// //	11
//	109876543210
//      cccIZooooooo
//
//	bit 8 - indirect
//	bit 7 - page 0
//	bits 6:0 offset
//
//	if 8:7 == 2'b00
//		ea =     IF, pc[11:7], offset[6:0]    ;; current page
//	if 8:7 == 2'b01
//		ea =     IF, 5'b0, offset[6:0]	      ;; page 0
//	if 8:7 == 2'b10
//		ea = (DF, MA( IF, pc[11:7], offset[6:0] ))  ;; *(current page)
//	if 8:7 == 2'b11
//		ea = (DF, MA( IF, 5'b0, offset[6:0] ))      ;; *(page 0)

// 4 jms
// 5 jmp
// 
// ------
// 
//	ea <= if Z
//		if I
//			{DF, 5'b0,     mb[6:0]};
//		else
//			{IF, 5'b0,     mb[6:0]};
//	    else
//		if I
//			{DF, pc[11:7], mb[6:0]};
//		else
//			{IF, pc[11:7], mb[6:0]};
// 
// ------
//
// Actions take during each state:
//
//  F0 fetch
//	ma = {IF,pc}
//	check for interrupt
//
//  F1 incr pc
//	ma = 0
//	ea <= { IF, ir_z_flag ? pc[11:7] : 5'b0, mb[6:0] };
//
//	if opr
//		group 1 processing
// 		group 2 processing
// 
// 	if iot
// 
//	incr pc or skip (incr pc by 2)
// 
//  F2 ??
// 	ma = pc
// 
//  F3 dispatch
//	ma = ea
//	if opr
//		group1 processing
//	if !opr && !iot
// 		possible defer
// 
//  D0
//	ma = ea
//	mb <= ram[ma]
//  D1
//	ma = 0
//  D2 (write index reg)
//	ma = index reg ? ea : {DF,mb}
//	ram_wr = 1
//  D3
//	ea <= mb
//	ma = 0
//
//  E0
//	ma = ea
//	mb <= ram[ma]
//  E1
//	ma = 0
//  E2 (write isz value, dca value, jms return)
//	ma = ea
//	ram_wr = 1
//  E3
//	ma = ea + 1 (only bottom 12 bits)
//

//
// extended memory
//
// 62n1	cdf	change data field; df <= mb[5:3]
// 62n2 cif	change instruction field; if <= mb[5:3], after next jmp or jms
// 6214	rdf     read df into ac[5:3]
// 6224	rif     read if into ac[5:3]
// 6234	rib     read sf into ac[5:0], which is {if,df}
// 6244	rmf     restore memory field, sf => ib, df
// 		(remember that on interrupt, sf <= {if,df})
//

module pdp8(clk, reset, initial_pc, pc_out, ac_out,
	    ram_addr, ram_data_out, ram_data_in, ram_rd, ram_wr,
	    io_select, io_data_out, io_data_in,
	    io_data_avail, io_interrupt, io_skip, io_clear_ac,
	    switches, iot, state, mb,
	    ext_ram_read_req, ext_ram_write_req, ext_ram_done,
	    ext_ram_ma, ext_ram_in, ext_ram_out);

   input clk, reset;
   input [14:0] initial_pc;
   input [11:0] ram_data_in;
   output 	ram_rd;
   output 	ram_wr;
   output [11:0] ram_data_out;
   output [14:0] ram_addr;
   output [11:0] pc_out;
   output [11:0] ac_out;
   
   output [5:0]  io_select;
   input [11:0]  io_data_in;
   output [11:0] io_data_out;

   input 	 io_data_avail;
   input 	 io_interrupt;
   input 	 io_skip;
   input 	 io_clear_ac;

   output 	 iot;
   output [3:0]  state;
   output [11:0] mb;
   
   input [11:0] switches;

   input 	ext_ram_read_req;
   input 	ext_ram_write_req;
   input [14:0] ext_ram_ma;
   input [11:0] ext_ram_in;

   output 	ext_ram_done;
   output [11:0] ext_ram_out;
   

   // memory buffer, holds data, instructions
   reg [11:0] 	mb;

   // generate address of work in memory being accessed
   wire [14:0] 	ma;

   // accumulator & link
   reg [11:0] 	ac;
   reg 		l;

   // MQ
   reg [11:0] 	mq;
   
   // program counter
   reg [11:0] 	pc;
   wire 	pc_incr, pc_skip;

   // instruction register
   reg [2:0] 	ir;
   reg 		ir_z_flag;
   reg 		ir_i_flag;
   

   // extended memory - instruction field & data field
   reg [2:0] 	IF;
   reg [2:0] 	DF;
   reg [2:0] 	IB;
   reg [6:0] 	SF;		// { UF, IF[2:0], DF[2:0] }
   reg 		IB_pending;
   
   // user mode
   reg 		UB;	// user_buffer
   reg 		UF;	// user_flag
   reg		UI;	// user_interrupt
   reg		UB_pending;
 		
   // processor state
   reg [3:0] 	state;
   wire [3:0] 	next_state;

   reg 		run;
   reg 		interrupt_enable;
   reg 		interrupt_cycle;
   reg [1:0]	interrupt_inhibit_delay;
   reg 		interrupt_skip;

   reg 		interrupt;
   
   wire 	interrupt_inhibit;
   wire 	skip_condition;

   wire 	user_interrupt;
 	
   wire 	fetch;	// memory cycle to fetch instruction
   wire 	deferred;// memory cycle to get address of operand
   wire 	execute;// memory cycle to getch (store) operand and execute isn

   assign 	{fetch, deferred, execute} =
		    (state[3:2] == 2'b00) ? 3'b100 :
		    (state[3:2] == 2'b01) ? 3'b010 :
		    (state[3:2] == 2'b10) ? 3'b001 :
		    3'b000 ;

   // instruction op decode
   wire 	i_and,tad,isz,dca,jms,jmp,iot,opr;

   assign 	{i_and,tad,isz,dca,jms,jmp,iot,opr} =
			(ir == 3'b000) ? 8'b10000000 :
			(ir == 3'b001) ? 8'b01000000 :
			(ir == 3'b010) ? 8'b00100000 :
			(ir == 3'b011) ? 8'b00010000 :
			(ir == 3'b100) ? 8'b00001000 :
			(ir == 3'b101) ? 8'b00000100 :
			(ir == 3'b110) ? 8'b00000010 :
		                         8'b00000001 ;


   //-------------

   /*
    * note: bit numbering is opposite that used in "Computer Engineering"
    * 
    * F1
    *	if opr
    * 	  if MB[8] and !MB[0]
    * 	    begin
    * 		if skip.conditions ^ MB[3]
    * 			pc <= pc + 2
    * 		if skip.conditions == MB[3]
    * 			pc <= pc + 1 next
    * 		if MB[7]
    * 			ac <= 0
    *
    * skip conditions are only valid during F1
    *
    */
   assign 	skip_condition = (mb[6] && ac[11]) ||
				 (mb[5] && (ac == 12'b0)) ||
				 (mb[4] && l);

   assign 	pc_incr =
			 /* group 1 */
		  (opr & !mb[8]) ||
			 /* group 2 */
		  (opr && (mb[8] && !mb[0]) && (skip_condition == mb[3])) ||
			 /* group 3? */
		  (opr && (mb[8] && mb[0])) ||
		  iot ||
		  (!(opr || iot) && !interrupt_cycle);

   assign 	pc_skip =
		  (opr && (mb[8] && !mb[0]) && (skip_condition ^ mb[3])) ||
		  (iot && (io_skip || interrupt_skip));

   assign	user_interrupt =
				// i/o operation
				(UF && iot) ||
				// group 2 - user mode halt or osr
				(UF && opr && (mb[8] & !mb[0]) && (mb[2] | mb[1]));
     
   // cpu states
   parameter [3:0]
		F0 = 4'b0000,
		F1 = 4'b0001,
		F2 = 4'b0010,
		F3 = 4'b0011,

		D0 = 4'b0100,
		D1 = 4'b0101,
		D2 = 4'b0110,
		D3 = 4'b0111,

		E0 = 4'b1000,
		E1 = 4'b1001,
		E2 = 4'b1010,
		E3 = 4'b1011,

		H0 = 4'b1100;

   // for display
   assign pc_out = pc;
   assign ac_out = ac;

   //
   // cpu state state machine
   // 
   // clock next cpu state at rising edge of clock
   //

   always @(posedge clk)
     if (reset)
       state <= 0;
     else
       state <= next_state;

   wire next_is_F0;
   wire next_is_E0;
   
   assign next_is_F0 = opr | iot | (!mb[8] & jmp);
   assign next_is_E0 = !mb[8] & !jmp;
    
   assign next_state = state == F0 ? F1 :
		       state == F1 && (~iot | (iot & io_data_avail)) ? F2 :
//		       state == F1 && (iot & ~io_data_avail) ? F1 :
		       state == F2 ? F3 :
		       state == F3 ? (~run ? H0 :
				      next_is_F0 ? F0 :
				      next_is_E0 ? E0 :
				      D0) :
		       state == D0 ? D1 :
		       state == D1 ? D2 :
		       state == D2 ? D3 :
		       state == D3 ? (jmp ? F0 : E0) :
		       state == E0 ? E1 :
		       state == E1 ? E2 :
		       state == E2 ? E3 :
		       state == E3 ? F0 :
		       state == H0 ? H0 :
		       F0;

   //
   // pc
   //
   wire [11:0] pc_mux;

   always @(posedge clk)
     if (reset)
       pc <= initial_pc[11:0];
     else
       begin
	  pc <= pc_mux;
       end

   assign pc_mux = (state == F1 && pc_skip) ? (pc + 12'd2) :
		   (state == F1 && pc_incr) ? (pc + 12'd1) :
		   (state == F3 && !(opr || iot) && (!mb[8] & jmp)) ? ma[11:0] :
		   (state == D3 && jmp) ? mb :
		   (state == E3 && jms) ? ma[11:0] :
		   (state == E3 && isz && mb == 12'b0) ? (pc + 12'd1) :
		   pc;

   //
   // ram
   //
   wire is_index_reg;

   assign ram_rd = (state == F0) ||
		   (state == D0) ||
		   (state == E0) ||
		   (state == F2 && ext_ram_read_req);

   assign ram_wr = (state == D2 && is_index_reg) ||
		   (state == E2 && (isz || dca || jms)) ||
		   (state == F2 && ext_ram_write_req);

   /* peripherals get ram access during F2 */
   wire ext_ram_req;
   wire ext_ram_grant;
   
   assign ext_ram_req = ext_ram_read_req | ext_ram_write_req;
   assign ext_ram_done = state == F2 && ext_ram_req;
   assign ext_ram_grant = state == F2 && ext_ram_req;
   assign ext_ram_out = ext_ram_req ? ram_data_in : 12'b0;
   
   assign ram_addr = ext_ram_grant ? ext_ram_ma : ma;
   assign ram_data_out = ext_ram_grant ? ext_ram_in : mb;

   assign io_select = UF ? 6'b0 : mb[8:3];
   assign io_data_out = ac;

   //
   // ea calculation
   //
   reg [14:0] ea;

   always @(posedge clk)
     if (reset)
       ea <= 0;
     else
	  if (state == F1)
	    ea <= { IF, ir_z_flag ? pc[11:7] : 5'b0, mb[6:0] };
	  else
	    if (state == D3)
	      ea <= { (ir_i_flag && (!jmp && !jms)) ? DF : IF, mb };

   assign is_index_reg = ea[11:3] == 9'o001;
   
   //
   // ma
   //
   assign ma = (state == F0) ? {IF,pc} :
               (state == F2 && (opr || iot)) ? {IF,pc} :
	       ((state == F3 || state == D0 || state == E0) &&
		(!opr && !iot)) ? ea :
	       (state == D2) ? (is_index_reg ? ea : {DF,mb}) :
	       (state == E2 ) ? ea :
	       (state == E3 && jms) ? {ea[14:12], ea[11:0] + 12'b1} :
	       15'b0;

   //
   // interrupt defer logic
   //
   reg 	  interrupt_inhibit_clear;
   reg 	  interrupt_inhibit_ib;
   reg 	  interrupt_inhibit_ub;
   reg 	  interrupt_inhibit_ion;

   assign interrupt_inhibit = interrupt_inhibit_delay[0] |
			      interrupt_inhibit_delay[1] |
			      interrupt_inhibit_ion;

   always @(posedge clk)
     if (reset)
       begin
	  interrupt_inhibit_delay <= 2'b00;
	  IB_pending <= 0;
	  UB_pending <= 0;
       end
     else
       if (interrupt_inhibit_clear)
	 begin
   	    interrupt_inhibit_delay <= 2'b00;
	    IB_pending <= 1'b0;
	    UB_pending <= 1'b0;
	 end
       else
	 if (interrupt_inhibit_ib || interrupt_inhibit_ub)
	   begin
   	      interrupt_inhibit_delay <= 2'b10;
	      if (interrupt_inhibit_ib)
		IB_pending <= 1;
	      if (interrupt_inhibit_ub)
		UB_pending <= 1;
	   end
	 else
	   if (~IB_pending && ~UB_pending)
	     begin
		interrupt_inhibit_delay[1] <= interrupt_inhibit_delay[0];
		interrupt_inhibit_delay[0] <= interrupt_inhibit_ion;
	     end

   //
   // combinatorial
   //
   always @(*)
     begin
	/* defaults - these should be comb logic */
//	interrupt_inhibit_clear = 1'b0;
//	interrupt_inhibit_ion = 1'b0;
//	interrupt_inhibit_ib = 1'b0;
//	interrupt_inhibit_ub = 1'b0;

	interrupt_skip = 0;
	
	/* verilator lint_off CASEINCOMPLETE */
	case (state)
	  F1:
	    begin

//	      if ((jmp || jms) && IB_pending)
//		begin
//		   interrupt_inhibit_clear = 1'b1;
//		end

//	      if ((jmp || jms) && UB_pending)
//		begin
//		   interrupt_inhibit_clear = 1'b1;
//		end
	       
	       if (iot && ~UF)
		 begin
		    /* verilator lint_off CASEINCOMPLETE */
		    casez (io_select)
		      6'b000000:	// ION, IOF
			case (mb[2:0])
//			  3'b001:
//			   interrupt_inhibit_ion = 1'b1;
			  3'b011:
			    if (interrupt_enable)
			      interrupt_skip = 1;
			endcase
		      
		      6'b010???:	// CDF..RMF
			begin
//			  if (mb[1])
//			    begin		// CIF
//			       interrupt_inhibit_ib = 1'b1;
//			    end

			  if (mb[2:0] == 3'b100)
			    begin
			      case (io_select[2:0])
//				3'b100: begin				// RMF
//				   interrupt_inhibit_ib = 1'b1;
//				   interrupt_inhibit_ub = 1'b1;
//				end

				3'b101:					// SINT
				  begin
`ifdef debug
				     $display("SINT: UI %b, state %b",
					      UI, state);
`endif
				     if (UI)
				       interrupt_skip = 1;
				  end

//				3'b110:					// CUF
//				  begin
//				     interrupt_inhibit_ub = 1'b1;
//				  end
				
//				3'b111:					// SUF
//				  begin
//				     interrupt_inhibit_ub = 1'b1;
//				  end
			      endcase
			    end
			  
			end
		    endcase // casex(io_select)
		    /* verilator lint_on CASEINCOMPLETE */
		    
		 end // if (iot && ~UF)
	    end

	endcase
	/* verilator lint_on CASEINCOMPLETE */
     end
   
     
   //
   // registers
   //
   always @(posedge clk)
     if (reset)
       begin
	  mb <= 0;
	  ac <= 0;
	  mq <= 0;
	  l <= 0;

	  ir <= 3'b000;
	  ir_z_flag <= 1'b0;
	  ir_i_flag <= 1'b0;

	  run <= 1;
	  interrupt_enable <= 0;
	  interrupt_cycle <= 0;
	  interrupt <= 0;
	  UI <= 0;
	  IF <= initial_pc[14:12];
	  DF <= 0;
	  IB <= 0;
	  SF <= 0;
	  UF <= 0;
	  UB <= 0;
       end
     else
       case (state)
	 //
	 // FETCH 
	 //
	 F0:
	   begin
//	      interrupt_skip = 0;
	      interrupt_inhibit_ion = 1'b0;
	      
	      if (interrupt && interrupt_enable &&
		  !interrupt_inhibit && !interrupt_cycle)
		begin
`ifdef debug
		   if (1)
		   $display("xxx interrupt, pc %o; %b %b %b; %b %b",
			    pc,
			    interrupt, interrupt_enable, interrupt_cycle,
			    interrupt_inhibit, interrupt_inhibit_delay);
`endif
		   interrupt_cycle <= 1;
		   interrupt <= 0;
		   interrupt_enable <= 0;

		   // simulate a jsr to 0
		   mb <= 12'o4000;
		   ir <= 3'o4;
		   ir_i_flag <= 1'b0;
		   ir_z_flag <= 1'b0;
		   SF <= {UF,IF,DF};
		   IF <= 3'b000;
		   DF <= 3'b000;
		   UF <= 1'b0;
		   UB <= 1'b0;
		end
	      else
		begin
		   interrupt_cycle <= 0;

`ifdef debug
		   if (0)
		   $display("cpu: read ram [%o] -> %o", ram_addr, ram_data_in);
`endif
		   
		   mb <= ram_data_in;
		   ir <= ram_data_in[11:9];
		   ir_i_flag <= ram_data_in[8];
		   ir_z_flag <= ram_data_in[7];
		end
	   end

	 F1:
	   begin
	      /* defaults - these should be comb logic */
	      interrupt_inhibit_clear = 1'b0;
	      interrupt_inhibit_ion = 1'b0;
	      interrupt_inhibit_ib = 1'b0;
	      interrupt_inhibit_ub = 1'b0;

//	      interrupt_skip = 0;
	      
   	      /* defered loading of IF from IB at next jmp/jms */
	      if ((jmp || jms) && IB_pending)
		begin
		   //$display("loading IF %o", IB);
		   IF <= IB;
		   interrupt_inhibit_clear = 1'b1;
		end

	      if ((jmp || jms) && UB_pending)
		begin
		   UF <= UB;
		   interrupt_inhibit_clear = 1'b1;
		end

	      if (opr)
		case ({mb[8],mb[0]})
		  2'b00, 2'b01:	// group 1
		    begin
		       case ({mb[7],mb[5]})
			 2'b00: ;
			 2'b01: ac <= ~ac;
			 2'b10: ac <= 12'o0;
			 2'b11: ac <= 12'o7777;
		       endcase

		       case ({mb[6],mb[4]})
			 2'b00: ;
			 2'b01: l <= ~l;
			 2'b10: l <= 1'b0;
			 2'b11: l <= 1'b1;
		       endcase
		    end

		  2'b10:	// group 2
		    begin
		       if (mb[7])
			 ac <= 0;
		    end

		  2'b11:	// group 3
		    begin
		       if (mb[7])
			 ac <= 0;
		    end
		endcase

	      if (iot && UF)
		begin
		   UI <= 1;
`ifdef debug
		   $display("user iot: set UI");
`endif
		end

	      if (iot && ~UF)
		begin
		   /* verilator lint_off CASEINCOMPLETE */
		   casez (io_select)
		     6'b000000:	// ION, IOF
		       case (mb[2:0])
			 3'b001:
			   begin
			      interrupt_enable <= 1;
			      interrupt_inhibit_ion = 1'b1;
			   end
			 3'b010: interrupt_enable <= 0;
//			 3'b011: if (interrupt_enable)
//				       interrupt_skip = 1;
		       endcase

		     6'b010???:	// CDF..RMF
		       begin
			  if (mb[0])
			    DF <= mb[5:3];	// CDF

			  if (mb[1])
			    begin		// CIF
			       IB <= mb[5:3];
			       interrupt_inhibit_ib = 1'b1;
			    end
			  
			  if (mb[2:0] == 3'b100)
			    begin
			      case (io_select[2:0])
				3'b000: UI <= 0;			// CINT

				3'b001: ac <= ac | { 6'b0, DF, 3'b0 };	// RDF
				3'b010: ac <= ac | { 6'b0, IF, 3'b0 };	// RIF
				3'b011: ac <= ac | { 5'b0, SF };	// RIB
				3'b100: begin				// RMF
				   UB <= SF[6];
				   IB <= SF[5:3];
				   DF <= SF[2:0];
				   interrupt_inhibit_ib = 1'b1;
				   interrupt_inhibit_ub = 1'b1;
			  	end

				3'b101:					// SINT
				  begin
`ifdef debug
				     $display("SINT: UI %b, state %b",
					      UI, state);
`endif
//				     if (UI)
//				       interrupt_skip = 1;
				  end

				3'b110:					// CUF
				  begin
				     UB <= 0;
				     interrupt_inhibit_ub = 1'b1;
				  end
				
				3'b111:					// SUF
				  begin
				     UB <= 1;
				     interrupt_inhibit_ub = 1'b1;
				  end
			      endcase
			    end // if (mb[2:0] == 3'b100)
		       end
		   endcase // case(io_select)
		   /* verilator lint_on CASEINCOMPLETE */
		   
		   if (io_data_avail)
		     begin
`ifdef debug
			if (0) $display("io_data clock %o", io_data_in);
`endif
			ac <= io_data_in;
		     end

		   if (io_clear_ac)
		     begin
			ac <= 0;
		     end

		end // if (iot)
	      
	      if (io_interrupt || user_interrupt)
		begin
`ifdef debug
		   if (0)
		   $display("xxx F1 interrupt; (%b %b %b; %b %b; %b %b %b)",
			    interrupt_enable, 
			    interrupt_inhibit,
			    interrupt_cycle,
			    io_interrupt, iot && UF,
			    IB_pending, UB_pending,
			    interrupt_inhibit_delay);
`endif

		   interrupt <= 1;
		end
	      else
		   interrupt <= 0;

	   end // case: F1

	 F2:
	   begin
	      if (opr)
		begin
		   // group 1
		   if (!mb[8] && mb[0])		/* IAC */
		     {l,ac} <= {l,ac} + 13'o00001;

	     	   // group 3
		   if (mb[8] & mb[0])
		     /* verilator lint_off CASEINCOMPLETE */
		     case ({mb[6:4]})
		       3'b001:			/* MQL */
			 begin
			    mq <= ac;
			    ac <= 0;
			 end
		       3'b100: ac <= ac | mq;	/* MQA */
		       3'b101: ac <= mq;
		     endcase
		   /* verilator lint_on CASEINCOMPLETE */
		end
	   end

	 F3:
	   begin
	      if (opr)
		begin
		   // group 1
		   if (!mb[8])
		     begin
			case (mb[3:1])
			  3'b000: ;
			  3'b001:		// BSW
			    {l,ac} <= {l,ac[5:0],ac[11:6]};
			  3'b010:		// RAL
			    {l,ac} <= {ac[11:0],l};
			  3'b011:		// RTL
			    {l,ac} <= {ac[10:0],l,ac[11]};
			  3'b100:		// RAR
			    {l,ac} <= {ac[0],l,ac[11:1]};
			  3'b101:		// RTR
			    {l,ac} <= {ac[1:0],l,ac[11:2]};
			  3'b110: ;
			  3'b111: ;
			endcase
		     end

		   if (!UF)
		     begin
			// group 2
			if (mb[8] & !mb[0])
			  begin
			     if (mb[2])
			       ac <= ac | switches;
			     if (mb[1])
			       begin
`ifdef debug
				  $display("HLT! %o", mb);
`endif
				  run <= 0;
			       end
			  end
		     end

		   if (UF)
		     begin
			// group 2 - user mode (halt & osr)
			if (mb[8] & !mb[0])
			  begin
			     if (mb[2])
			       UI <= 1;
			     if (mb[1])
			       UI <= 1;
			  end
		     end

		   // group 3
		   if (mb[8] & mb[0])
		     begin
			if (mb[7:4] == 4'b1101)
			  mq <= 0;
		     end
		   
		end // if (opr)

	   end // case: F3
	 
	 //
	 // DEFER
	 //
	 D0:
	   begin
`ifdef debug
	      if (0) $display("read ram [%o] -> %o", ram_addr, ram_data_in);
`endif
	      mb <= ram_data_in;
	   end

	 D1:
	   begin
	      // auto increment locations
	      if (is_index_reg)
		mb <= mb + 1;
	   end

	 D2:
	   begin
`ifdef debug
	      // write ram
	      if (ram_wr)
	      if (0) $display("write ram [%o] <- %o", ram_addr, ram_data_out);
`endif
	   end
	 
	 D3:
	   begin
	   end

	 //
	 // EXECUTE
	 //
	 E0:
	   begin
`ifdef debug
	      if (0) $display("read ram [%o] -> %o", ram_addr, ram_data_in);
`endif
	      mb <= ram_data_in;
	   end

	 E1:
	   begin
	      if (i_and)
		begin
		end

	      if (isz)
		   mb <= mb + 1;
	      else
		if (dca)
		  mb <= ac;
		else
		  if (jms)
		    mb <= pc;
	   end

	 E2:
	   begin
	      // write ram
`ifdef debug
	      if (ram_wr)
	      if (0) $display("write ram [%o] <- %o (pc %o)",
				ram_addr, ram_data_out, pc);
`endif
	   end
	 
	 E3:
	   begin
	      if (i_and)
		ac <= ac & mb;
	      else
		if (tad)
		  {l,ac} <= {l,ac} + {1'b0,mb};
		else
		  if (dca)
		    ac <= 0;
	   end // case: E3

	 default:
	   ;
	 
       endcase // case(state)
   
endmodule

