// PDP-8 i/o
// Based on descriptions in "Computer Engineering"
// Dev 2006 Brad Parker brad@heeltoe.com
// Revamp 2009 Brad Parker brad@heeltoe.com

/*
 iot's touched by focal
 
 6022 PCF
 6203 CDF CIF 00
 6402 PT08
 6412
 6422
 6432
 6442
 6452
 6462
 6472
 6764 DECTAPE
 6772
*/

/*
  RF08
	7750 word count
	7751 current address

  2048 words/track

  660x
  661x
  662x
  664x

  6601 DCMA	Generates System Clear Pulse (SCLP) at IOP time 1.
		Clears disk memory eaddress(DMA), Parity Eror Flag (PEF),
		Data Request Late Flag (DRL), and sets logic to
		initial state for read or write. Does not clear
		interrupt enable or extended address register.
 
  6603 DMAR	Generate SCLP at IOP time 1. At IOP time 2, loads DMA
		with AC and clears AC. Read continues for number words
		in WC register (7750)
  
  6605 DMAW	Generate SCLP at IOP time 1. At IOP time 4, loads DMA
		with AC and clears AC. When the disk word address is located
		writing begins, disk address is incremented for each
		word written
  
  6611 DCIM	clears disk interrupt enable and the extended address
		registers at IOP time 1.

  6612 DSAC	At IOP time 2, skip if Address Confirmed (ADC) set indicating
		the DMA address and disk word address compare. AC is then
 		cleared.
 
  6615 DIML	At IOP time 1, clear interrupt enable and memory address
		extension registers. At IOP time 4, load interrupt enable
		and memory address extension register with AC, clear AC.
 
  6616 DIMA	Clear ??? at IOP time 2. At IOP time 4 load AC with status 
 		register.
 
  6621 DFSE	skip on error skip if DRL, PER WLS or NXD set
 
  6622 ???	skip if data completion DCF set
 
  6623 DISK	skip on error or data completion; enabled at IOP 2
 
  6626 DMAC	clear ac at IOP time 2 load AC from DMA  at IOP time 4.
 
  6641 DCXA	Clears EMA
 
  6643 DXAL	Clears and loads EMA from AC. At IOP time 1, clear EMA, at
		IOP time 2, load EMA with AC. Clear AC
 
  6645 DXAC	Clears AC and loads EMA into AC

  6646 DMMT	Maintenance

 uses 3 cycle data break
 
 ac 7:0, ac 11:0 => 20 bit {EMA,DMA}
 20 bit {EMA,DMA} = { disk-select, track-select 6:0, word-select 11:0 }

 status
*/

//  EIE = WLS | DRL | NXD | PER

/*
 3 cycle data break
 
 1. An address is read from the device to indicate the location of the
word count register. This location specifies the number of words in
the block yet to be transferred.  The address is always the same for a
given device.
 
 2. The content of the specficified word count register is read from
memory and incremented by one.  To transfer a block of n words, the
word count is set to -n during the programmed initialization of the
device.  When this register is incremented to 0, a pulse is sent to
the device to terminate the transfer.
 
 3. The location after the word count register contains the current
address register for the device transfer.  The content of thise
register is set to 1 less than the location to be affected by the next
transfer. To transfer a block beginning at location A, the register is
originally set to A-1.

 4. The content of the current address register is incremented by 1
and then used to specify the location affected by the transfer.
 
 After the transfer of information has been accomplished through the
data break factility, input data (or new output data) is processed,
usually through the program interrupt facility.  An interrupt is
requested when the data transfer is completed and the service routine
will process the information.

 xxx:
 	if (databreak_req)
 	  begin
		databreak_done <= 0;
 		next_state <= DB0;
 	  end

 // read word count
 DB0:
	ma <= wc-address;
 	next_state <= DB1;

 // write word count - 1
 DB1:
 	mb <= memory_bus - 1;
 	ram_we_n <= 0;
	if (mb == 0) databreak_done <= 1;
 	next_state <= DB2;

 // finish write
 DB2:
 	ram_we_n <= 1;
 	next_state <= DB3;

 // read current address
 DB3: 
	ma <= ma | 1;
 	next_state <= DB4;

 // write current address - 1
 DB4:
 	mb <= memory_bus + 1;
 	ram_we_n <= 0;
 	next_state <= DB5;

 // finish write
 DB5:
 	ram_we_n <= 1;
 	next_state <= DB6;

 // set up read/write address
 DB6:
	ma <= mb;
 	next_state <= DB7;

 // do read or start write
 DB7: 
	if (databreak_write)
 	  begin
		data <= memory_bus; 
	 	next_state <= F0;
 	  end
	else 
 	  begin
 		mb <= data;
 		ram_we_n <= 0;
	 	next_state <= DB8;
 	  end

 // finish write
 DB8:
	ram_we_n < = 1;
	next_state <= F0;
 
 */


module pdp8_io(clk, reset, iot, state, mb,
	       io_data_in, io_data_out, io_select,
	       io_data_avail, io_interrupt, io_skip);
   
   input clk, reset, iot;
   input [11:0] io_data_in;
   input [11:0]      mb;
   input [3:0] 	     state;
   input [5:0] 	     io_select;

   output reg [11:0] io_data_out;
   output reg 	     io_data_avail;
   output reg 	     io_interrupt;
   output reg 	     io_skip;
   
   
   reg 		     rx_int, tx_int;
   reg [12:0] 	     rx_data, tx_data;
   reg 		     tx_delaying;
integer tx_delay;

   parameter 	     F0 = 4'b0000;
   parameter 	     F1 = 4'b0001;
   parameter 	     F2 = 4'b0010;
   parameter 	     F3 = 4'b0011;

   parameter 	     D0 = 4'b0100;
   parameter 	     D1 = 4'b0101;
   parameter 	     D2 = 4'b0110;
   parameter 	     D3 = 4'b0111;

   parameter 	     E0 = 4'b1000;
   parameter 	     E1 = 4'b1001;
   parameter 	     E2 = 4'b1010;
   parameter 	     E3 = 4'b1011;


   parameter PCA_bit = 12'o4000;	// photocell status
   parameter DRE_bit = 12'o2000;	// data req enable
   parameter WLS_bit = 12'o1000;	// write lock status
   parameter EIE_bit = 12'o0400;	// error int enable
   parameter PIE_bit = 12'o0200;	// photocell int enb
   parameter CIE_bit = 12'o0100;	// done int enable
   parameter MEX_bit = 12'o0070;	// memory extension
   parameter DRL_bit = 12'o0004;	// data late error
   parameter NXD_bit = 12'o0002;	// non-existent disk
   parameter PER_bit = 12'o0001;	// parity error

   wire      ADC;
   wire      DCF;
   reg [11:0] DMA;
   reg [7:0]  EMA;
   reg 	      PEF;
   reg       rf08_rw;
   reg       rf08_start_io;
   reg 	      CIE, DRE, DRL, EIE, MEX, NXD, PCA, PER, PIE, WLS;
   
   assign    DCF = 1'b0;
   assign    ADC = DMA == /*DWA??*/0;

   // combinatorial
   always @(state or
	    rx_int or tx_int or
	    ADC or DRL or PER or WLS or NXD or DCF)
     begin
	// sampled during f1
	io_skip = 0;
	io_data_out = io_data_in;
	io_data_avail = 1;
	
	if (state == F1 && iot)
	  case (io_select)
	    6'o03:
	      begin
		 if (mb[0])
		   io_skip = rx_int;

		 if (mb[2])
		   io_data_out = rx_data;
	      end
	    
	    6'o04:
	      if (mb[0])
		begin
		   io_skip = tx_int;
		   $display("xxx io_skip %b", tx_int);
		end

	    6'o60:
	      case (mb[2:0])
		3'o03: // DMAR
		  io_data_out = 0;
		3'o03: // DMAW
		  io_data_out = 0;
	      endcase

	    6'o61:
	      case (mb[2:0])
		3'o2: // DSAC
		  if (ADC)
		    begin
		       io_skip = 1;
		       io_data_out = 0;
		    end
		3'o6: // DIMA
		  io_data_out = { PCA, DRE,WLS,EIE, PIE,CIE,MEX, DRL,NXD,PER };
		3'o5: // DIML
		  io_data_out = 0;
		
	      endcase
	    
	    6'o62:
	      case (mb[2:0])
		3'o1: // DFSE
		  if (DRL | PER | WLS | NXD)
		    io_skip = 1;
		3'o2: // ???
		  if (DCF)
		    io_skip = 1;
		3'o3: // DISK
		  if (DRL | PER | WLS | NXD | DCF)
		    io_skip = 1;
		3'o6: // DMAC
		  io_data_out = DMA;
	      endcase 

	    6'o64:
	      case (mb[2:0])
		3: // DXAL
		  io_data_out = 0;
		5: // DXAC
		  io_data_out = EMA;
	      endcase
	    
	  endcase // case(io_select)
     end
   

   //
   // registers
   //
   always @(posedge clk)
     if (reset)
       begin
       end
     else
       case (state)
	  F0:
	    begin
	       // sampled during f1
	       io_data_avail <= 0;
	       
	       if (iot)
		 case (io_select)
		   6'o60: // DCMA
		     if (mb[2:0] == 3'b001)
		       begin
			  DMA <= 0;
			  PEF <= 0;
			  DRL <= 0;
		       end
		   6'o61:
		     case (mb[2:0])
		       3'o1: // DCIM
			 begin
			    CIE <= 0;
			    EMA <= 0;
			 end
		       3'o2: // DSAC
			 begin
			 end
		       3'o5: // DIML
			 begin
			    CIE <= io_data_in[8];
			    EMA <= io_data_in[7:0];
			 end
		     endcase // case(mb[2:0])
		 endcase
	    end

	  F1:
	    if (iot)
	      begin
		 $display("iot2 %t, state %b, mb %o, io_select %o",
			  $time, state, mb, io_select);

		 case (io_select)
		   6'o03:
		     begin
			if (mb[1])
			  rx_int <= 0;
		     end

		   6'o04:
		     begin
			if (mb[0])
			  begin
			  end
			if (mb[1])
			  begin
			     tx_int <= 0;
			     $display("xxx reset tx_int");
			  end
			if (mb[2])
			  begin
			     tx_data <= io_data_in;
			     $display("xxx tx_data %o", io_data_in);
			     tx_int <= 1;
			     tx_delaying <= 1;
			     tx_delay <= 98;
			     $display("xxx set tx_int");
			  end
		     end // case: 6'o04

		   6'o60:
		     case (mb[2:0])
		       3'o03: // DMAR
			 begin
			    // clear ac
			    DMA <= io_data_in;
			    rf08_start_io <= 1;
			    rf08_rw <= 0;
			 end

		       3'o03: // DMAW
			 begin
			    // clear ac
			    DMA <= io_data_in;
			    rf08_start_io <= 1;
			    rf08_rw <= 1;
			 end
		     endcase // case(mb[2:0])

		   6'o64:
		     case (mb[2:0])
		       1: // DCXA
			 EMA <= 0;
		       3: // DXAL
			 // clear ac
			 EMA <= io_data_in;
		     endcase
		   
                 endcase

	      end // if (iot)

	  F2:
	    begin
	       if (io_interrupt)
	       	 $display("iot2 %t, reset io_interrupt", $time);

	       // sampled during f0
	       io_interrupt <= 0;
	    end

	  F3:
	    begin
	       if (tx_delaying)
		 begin
		    tx_delay <= tx_delay - 1;
		    //$display("xxx delay %d", tx_delay);
		    if (tx_delay == 0)
		      begin
			 $display("iot2 %t, xxx set io_interrupt", $time);
			 tx_delaying <= 0;
			 io_interrupt <= 1;
		      end
		 end
	    end

       endcase // case(state)
   
endmodule
