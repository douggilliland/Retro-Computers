// PDP-8
// Based on descriptions in "Computer Engineering"
// Nov 2005 Brad Parker brad@heeltoe.com
//	initial work; runs focal a bit
// Dec 2006
//	cleaned up a little; now runs focal to prompt
//	moved i/o out to pdp8_io.v
//	added IF, DF, user mode
// Apr 2009
//	major revamp for synthesis, removed latches, added muxes, new top
//

// TODO:
// fully implement extended memory (IF & DF), user mode (KT8/I)
// add df32/rf08
// 6000 pws ac <= switches
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
//  F0 fetch
//  F1 incr pc
//  F2 write
//  F3 dispatch
//
//  E0 read
//  E1 decode
//  E2 write
//  E3 load
//
// or
//
//  D0 read
//  D1 wait
//  D2 write
//  D3 load
//
//  H0 halted
//
// ------
// 
//  F0 fetch
//	check for interrupt
//
//  F1 incr pc
//	if opr
//		group 1 processing
// 		group 2 processing
// 
// 	if iot
// 
//	incr pc or skip (incr pc by 2)
// 
//  F2 write
// 	ma <= pc
// 
//  F3 dispatch
//	if opr
//		group1 processing
// 
//	if !opr && !iot
// 		possible defer
// 
// 
//  D0
//	mb <= memory
//  D1
//  D2
//  D3
//
//  E0
//	mb <= memory
//  E1
//  E2 write isz value
//  E3
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

module pdp8(clk, reset,
	    ram_addr, ram_data_out, ram_data_in, ram_rd, ram_wr,
	    io_select, io_data_out, io_data_in,
	    io_data_avail, io_interrupt, io_skip,
	    switches, iot, state, mb);

   input clk, reset;
   input [11:0] ram_data_in;
   output 	ram_rd;
   output 	ram_wr;
   output [11:0] ram_data_out;
   output [14:0] ram_addr;

   output [5:0]  io_select;
   input [11:0]  io_data_in;
   output [11:0] io_data_out;

   input 	 io_data_avail;
   input 	 io_interrupt;
   input 	 io_skip;

   output 	 iot;
   output [3:0]  state;
   output [11:0] mb;
   
   input [11:0] switches;

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

   // extended memory - instruction field & data field
   reg [2:0] 	IF;
   reg [2:0] 	DF;
   reg [2:0] 	IB;
   reg [5:0] 	SF;
   reg 		ib_pending;
   
   // user mode
   reg 		UB;
   reg 		UF;
   
   // processor state
   reg [3:0] 	state;
   wire [3:0] 	next_state;

   reg 		run;
   reg 		interrupt_enable;
   reg 		interrupt_cycle;
   reg 		interrupt_inhibit;
   reg 		interrupt_skip;

   reg 		interrupt;
   reg 		user_interrupt;

   wire 	skip_condition;
   
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
    */
   assign 	skip_condition = (mb[6] && ac[11]) ||
				 (mb[5] && (ac == 12'b0)) ||
				 (mb[4] && l);

   assign 	pc_incr =
		  (opr & !mb[8]) ||
		  (opr && (mb[8] && !mb[0]) && (skip_condition == mb[3])) ||
		  iot ||
		  (!(opr || iot) && !interrupt_cycle);

   assign 	pc_skip =
		  (opr && (mb[8] && !mb[0]) && (skip_condition ^ mb[3])) ||
		  (iot && (io_skip || interrupt_skip));
   //		(iot && mb[0] && io_skip);
   

   // cpu states
   parameter 	F0 = 4'b0000;
   parameter 	F1 = 4'b0001;
   parameter 	F2 = 4'b0010;
   parameter 	F3 = 4'b0011;

   parameter 	D0 = 4'b0100;
   parameter 	D1 = 4'b0101;
   parameter 	D2 = 4'b0110;
   parameter 	D3 = 4'b0111;

   parameter 	E0 = 4'b1000;
   parameter 	E1 = 4'b1001;
   parameter 	E2 = 4'b1010;
   parameter 	E3 = 4'b1011;

   parameter 	H0 = 4'b1100;

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
       pc <= 0;
     else
       begin
if (state == F1) $display("pc_skip %b", pc_skip);
	  //if (state == F1 || state == D3 || state == E3)
	    //$display(" pc <- %o", pc_mux);
	    pc <= pc_mux;
       end

   assign pc_mux = (state == F1 && pc_skip) ? (pc + 12'd2) :
		   (state == F1 && pc_incr) ? (pc + 12'd1) :
		   (state == F3 && !(opr || iot) && (!mb[8] & jmp)) ? ma :
		   (state == D3 && jmp) ? mb :
		   (state == E3 && jms) ? ma :
		   (state == E3 && isz && mb == 12'b0) ? (pc + 12'd1) :
		   pc;

   //
   // ram
   //
   assign ram_rd = (state == F0) ||
		   (state == D0) ||
		   (state == E0);

   assign ram_wr = (state == D2 && is_index_reg) ||
		   (state == E2 && (isz || dca || jms));

   assign ram_addr = ma;
   assign ram_data_out = mb;

   assign io_select = mb[8:3];
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
	    ea <= {DF, mb[7] ? pc[11:7] : 5'b0, mb[6:0]};
	  else
	    if (state == D3)
	      ea <= mb;

   wire is_index_reg;
   assign is_index_reg = ea[11:3] == 8'h01;
   
   //
   // ma
   //
   assign ma = (state == F0) ? {IF, pc} :
               (state == F2 && (opr || iot)) ? {IF,pc} :
	       ((state == F3 || state == D0 || state == E0) &&
		(!opr && !iot)) ? ea :
	       (state == D2) ? (is_index_reg ? ea : {DF,mb}) :
	       (state == E2 ) ? ea :
	       (state == E3 && jms) ? {ea[14:12], ea[11:0] + 12'b1} :
	       15'b0;
   
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
	  ir <= 0;
	  run <= 1;
	  interrupt_enable <= 0;
	  interrupt_cycle <= 0;
	  interrupt_inhibit <= 0;
	  interrupt_skip <= 0;
	  interrupt <= 0;
	  user_interrupt <= 0;
	  IF <= 0;
	  DF <= 0;
	  IB <= 0;
	  SF <= 0;
	  UF <= 0;
	  UB <= 0;
	  ib_pending <= 0;
       end
     else
       case (state)
	 // FETCH 
	 F0:
	   begin
	      interrupt_skip <= 0;
	      
	      if (interrupt && interrupt_enable &&
		  !interrupt_inhibit && !interrupt_cycle)
		begin
		   $display("xxx interrupt, pc %o; %b %b %b",
			    pc, interrupt, interrupt_enable, interrupt_cycle);
		   interrupt_cycle <= 1;
		   interrupt <= 0;
		   interrupt_enable <= 0;

		   // simulate a jsr to 0
		   mb <= 12'o4000;
		   ir <= 3'o4;
		   SF <= {IF,DF};
		   IF <= 3'b000;
		   DF <= 3'b000;
		end
	      else
		begin
		   interrupt_cycle <= 0;
//?? interrupt_inhibit <= 0;
//?? ib_pending <= 0;
		   //$display("read ram [%o] -> %o", ram_addr, ram_data_in);
		   mb <= ram_data_in;
		   ir <= ram_data_in[11:9];
		end
	   end

	 F1:
	   begin
	      if (opr)
		case ({mb[8],mb[0]})
		  2'b0x:	// group 1
		    begin
		       if (mb[7]) ac <= 0;
		       if (mb[6]) l <= 0;
		       if (mb[5]) ac <= ~ac;
		       if (mb[4]) l <= ~l;
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

		  default:
		    ;
		endcase

	      if (iot)
		begin
		   case (io_select)
		     6'b000000:	// ION, IOF
		       case (mb[2:0])
			 3'b001: interrupt_enable <= 1;
			 3'b010: interrupt_enable <= 0;
			 3'b011: if (interrupt_enable)
				       interrupt_skip <= 1;
		       endcase

		     6'b010xxx:	// CDF..RMF
		       begin
			  case (mb[2:0])
			    3'b001: DF <= mb[5:3];	// CDF
			    3'b010:			// CIF
			      begin
				 IB <= mb[5:3];
				 ib_pending <= 1;
				 interrupt_inhibit <= 1;
			      end
			    3'b100:
			      case (io_select[2:0])
				3'b001: ac <= { 6'b0, DF, 3'b0 };	// RDF
				3'b010: ac <= { 6'b0, IF, 3'b0 };	// RIF
				3'b011: ac <= { 6'b0, SF };		// RIB
				3'b100: begin				// RMF
				   IB <= SF[5:3];
				   DF <= SF[2:0];
			  	end
			      endcase
			  endcase
		       end
		   endcase // case(io_select)

		   if (io_data_avail)
		     begin
			//$display("io_data clock %o", io_data_in);
			ac <= io_data_in;
		     end
		end // if (iot)
	      
	      if (io_interrupt)
		interrupt <= 1;

	   end // case: F1

	 F2:
	   begin
	      if (opr)
		begin
	     	   // group 3
		   if (mb[8] & mb[0])
		     case ({mb[6:4]})
		       3'b001: mq <= ac; 
		       3'b100: ac <= ac | mq;
		       //3'b101: tmq <= mq;
		       3'b100: ac <= mq;
		       3'b101: ac <= mq;
		     endcase
		end
	   end

	 F3:
	   begin
	      if (opr)
		begin
		   // group 1
		   if (!mb[8])
		     begin
			if (mb[0])			// IAC
			  {l,ac} <= {l,ac} + 1'b1;
			case (mb[3:1])
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
			       run <= 0;
			  end
		     end

		   if (UF)
		     begin
			// group 2 - user mode (halt & osr)
			if (mb[8] & !mb[0])
			  begin
			     if (mb[2])
			       user_interrupt <= 1;
			     if (mb[1])
			       user_interrupt <= 1;
			  end
		     end

		   // group 3
		   if (mb[8] & mb[0])
		     begin
			if (mb[7:4] == 4'b1101)
			  mq <= 0;
		     end
		   
//		   ir <= 0;
//		   mb <= 0;
		end // if (opr)

//	      if (iot)
//		begin
//		   ir <= 0;
//		   mb <= 0;
//		end

//	      if (!(opr || iot))
//		begin
//		   if (!mb[8] & jmp)
//		     begin
//			//pc <= ma;
//			ir <= 0;
//			mb <= 0;
//		     end
//
//		   if (mb[8])
//		     mb <= 0;
//
//		   if (!mb[8] & !jmp)
//		     mb <= 0;
//		end
	   end // case: F3
	 

	 // DEFER

	 D0:
	   begin
	      $display("read ram [%o] -> %o", ram_addr, ram_data_in);
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
	      // write ram
	      $display("write ram [%o] <- %o", ram_addr, ram_data_out);
	   end
	 
	 D3:
	   begin
//	      if (jmp)
//		begin
//		   //pc <= mb;
//		   ir <= 0;
//		   mb <= 0;
//		end
//
//	      if (!jmp)
//		begin
//		   mb <= 0;
//		end
	   end

	 // EXECUTE

	 E0:
	   begin
	      $display("read ram [%o] -> %o", ram_addr, ram_data_in);
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
	      $display("write ram [%o] <- %o", ram_addr, ram_data_out);
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

	      // pc <- ma
//	      ir <= 0;
	   end
       endcase // case(state)

endmodule

