// RF08 Emulation using IDE disk
// brad@heeltoe.com

//`define debug_rf

/* 
  RF08 Sizes:
 
  2048 words/track	11 bits
  128 tracks		 7 bits
  4 disks		 2 bits
                        -------
                        20 bits
 
       1       111
  dma  98765432109876543210  
       ddtttttttwwwwwwwwwww
  ema  876543210
 
  mapping RF08 to IDE disk drive
    2048 x 12 bits -> 2048 x 16 bits = 8 blocks of 512 bytes
    each track is 8 blocks
    each disk is (128 * 8) = 1024 blocks
  
  ide_block = (track * 8) + (word / 256)
  ide_block_index = word % 256

  ema bits 7 & 8 select which rs08 disk
  ema bits 6 - 0 select disk head  (track #)
 
  dma contains lower disk word address (offset into block)

  writes to dma trigger i/o; adc is asserted after match w/disk
 
  -------------

  PDP-8 memory:

 	7750 word count
	7751 current address
 
  PDP-8 IOT's:
 
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

  Real RF08 uses 3 cycle data break
 
  ac 8:0, ac 10:0 => 20 bit {EMA,DMA}
  20 bit {EMA,DMA} = { disk-select, track-select 6:0, word-select 11:0 }

 status
    EIE = WLS | DRL | NXD | PER

*/


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
address register for the device transfer.  The content of this
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

 -----------    -----------    -----------    ----------- 
*/

/*
 HIGH LEVEL DISK STATE MACHINE:
  
 idle
 
 start-xfer
   read wc
   read addr

   if read
     goto check-xfer-read
   else
     goto begin-xfer-write
 
 check-xfer-read
   if memory buffer contains disk page
      read word from memory buffer at offset
      goto next-xfer-read
   else
      if memory buffer dirty
         goto write-old-page
      else
         goto read-new-page
 
 next-xfer-read
   write memory at addr
   goto next-xfer-incr
 
 next-xfer-incr
   incr addr
   incr wc
   if wc == 0
      goto done-xfer
   if read
     goto check-xfer-read
   else
     goto begin-xfer-write
 
 begin-xfer-write
   read from memory at addr
   goto check-xfer-write
  
 check-xfer-write
   if memory buffer contains disk page
      write word to memory buffer at offset
      set memory buffer dirty
      goto next-xfer-incr
   else
      if memory buffer dirty
         goto write-old-page
      else
         goto read-new-page

 done-xfer
   write addr to memory
   write wc to memory
   set done/interrupt
   goto idle

 read-new-page
   read memory buffer from ide
   remember memory buffer disk address
   clear memory buffer dirty
   if read
     goto check-xfer-read
   else
     goto check-xfer-write
 
 write-old-page
   write memory buffer to ide
   clear memory buffer dirty
   goto read-new-page
 
 -----------    -----------    -----------    ----------- 
 
 DISK / DMA STATE MACHINE:

 external signals:

 ma_out
 ram_write_req
 ram_read_req
 ram_done
 mb_in
 mb_out 
 
 internal signals:

 reg [19:0] disk_addr;
  
 wire [8:0] track;
 wire [11:0] ide_block;
 wire [7:0] ide_block_index;
 
 track = {ema[7:0], dma[11]};
 ide_block = {1'b0, track, 3'b0} + {8'b0, dma[11:8]}
 ide_block_index = dma[7:0];


 db_done <= 0; 
 dma_done = 0; 
 ram_read_req = 0;
 ram_write_req = 0;
 
 // idle
 DB_idle:
 
 // read word count
 DB_start_xfer1:
	disk_addr <= {ema, dma};
	ma_out = wc-address
 	ram_read_req = 1
 	dma_wc <= mb_in + 1;
 	if ram_done db_next_state = DB_start_xfer2;

 // read addr
 DB_start_xfer2:
	ma_out = wc-address | 1
 	ram_read_req = 1
 	dma_addr <= mb_in + 1
        db_next_state = DB_start_xfer3; 
 
 DB_start_xfer3:
 	dma_done = dma_wc == 0
        if read
 	  db_next_state = DB_check_xfer_read; 
        else
          db_next_state = DB_begin_xfer_write; 

 // check buffer address
 DB_check_xfer_read:
 	buffer_addr = disk_addr_offset
        if disk-addr-page == memory-buffer-addr-page
          buffer_rd = 1
  	  db_next_state = DB_next_xfer_read;
        else
          if buffer_dirty == 0
 	    db_next_state = DB_read_new_page;
          else
  	    db_next_state = DB_write_old_page;

 // write to ram
 DB_next_xfer_read: 
 	disk_addr <= disk_addr + 1
        ma_out = dma_addr
 	mb_out = buffer_out
        ram_write_req = 1
 
 	if ma_out = 7750
            dma_wc = buffer_out + 1

        if ma_out = 7751
            dma_addr = buffer_out + 1
 
 	if ram_done
 	    else
              dma_done = dma_wc == 0
  	     if dma_done
   	       db_next_state = DB_done_xfer
  	     else
  	       db_next_state = DB_next_xfer_incr;
 
 DB_next_xfer_incr: 
 	dma_addr <= dma_addr + 1
        dma_wc <= dma_wc + 1
            if read
 	      db_next_state = DB_check_xfer_read; 
            else
              db_next_state = DB_begin_xfer_write; 

 // read from ram
 DB_begin_xfer_write:
        ma_out = dma_addr
 	buffer_hold <= ram_in
        ram_read_req = 1
 	if ram_done db_next_state = DB_check_xfer_write;

 // check buffer address
 DB_check_xfer_write:
        buffer_addr = disk_addr_offset
        if disk-addr-page == memory-buffer-addr-page
           buffer_wr = 1
           buffer_dirty <= 1
 	   disk_addr <= disk_addr + 1
           dma_done = dma_wc == 0
 	   if dma_done
  	     db_next_state = DB_done_xfer
 	   else
 	     db_next_state = DB_next_xfer_incr;
        else
           if buffer_dirty == 0
             db_next_state = DB_read_new_page
           else
             db_next_state = DB_write_old_page

 // done 
 DB_done_xfer:
  	ema <= disk_addr[18:11];
  	dma <= disk_addr[10:0];

	ma_out = wc-address;
        mb_out = dma_addr
 	ram_write_req = 1;
 	if ram_done db_next_state = DB_start_xfer1;
 
 DB_done_xfer1:
	ma_out = wc-address | 1;
        mb_out = dma_wc
 	ram_write_req = 1;
 	if ram_done db_next_state = DB_done_xfer2;

 DB_done_xfer2:
 	// wait for F2
 	if state == F2
 	  db_next_state = DB_done_xfer3
	else
 	  db_next_state = DB_done_xfer2
 
 DB_done_xfer3:
 	db_done <= 1
 	//interrupt
        db_next_state = DB_idle

 DB_read_new_page:
	read block from ide
 	set memory-buffer-addr-page
        buffer_dirty <= 0
	if read
	  db_next_state = DB_check_xfer_read
 	else
	  db_next_state = DB_check_xfer_write
 
 DB_write_old_page:
	write block to ide
        buffer_dirty <= 0
	db_next_state = DB_read_new_page

 -----------    -----------    -----------    ----------- 
*/


module pdp8_rf(clk, reset, iot, state, mb,
	       io_data_in, io_data_out, io_select, io_selected,
	       io_data_avail, io_interrupt, io_skip, io_clear_ac,
	       ram_read_req, ram_write_req, ram_done,
	       ram_ma, ram_in, ram_out,
	       ide_dior, ide_diow, ide_cs, ide_da, ide_data_in, ide_data_out);

   input clk, reset, iot;
   input [11:0] io_data_in;
   input [11:0] mb;
   input [3:0] 	state;
   input [5:0] 	io_select;
   input 	ram_done;
   input [11:0] ram_in;
   
   output reg [11:0] io_data_out;
   output reg 	     io_selected;
   output reg 	     io_data_avail;
   output 	     io_interrupt;
   output reg 	     io_skip;
   output reg 	     io_clear_ac;
   
   output 	     ram_read_req;
   output 	     ram_write_req;
   output [11:0]     ram_out;
   output [14:0]     ram_ma;

   output 	     ide_dior;
   output 	     ide_diow;
   output [1:0]      ide_cs;
   output [2:0]      ide_da;
   input [15:0]      ide_data_in;
   output [15:0]     ide_data_out;
   
   // -------------------------------------------------------
   
   parameter [3:0]
		F0 = 4'b0000,
		F1 = 4'b0001,
		F2 = 4'b0010,
		F3 = 4'b0011;

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

   parameter WC_ADDR = 15'o07750;
   parameter CA_ADDR = 15'o07751;

   wire      ADC;
   wire      DRE;
   wire      DRL;
   wire      PER;
   wire      PCA;
   
   reg [11:0] DMA;
   reg [7:0]  EMA;
   reg 	      DCF;
   reg 	      PEF;
   reg 	      CIE, EIE, NXD, PIE, WLS;
   reg [2:0]  MEX;
   
   assign DRL = 1'b0;
   assign PER = 1'b0;
   
   reg [7:0] photocell_counter;
   
   parameter [3:0]
		DB_idle		 	= 4'd0,
		DB_start_xfer1		= 4'd1,
		DB_start_xfer2		= 4'd2,
		DB_start_xfer3		= 4'd3,
		DB_check_xfer_read	= 4'd4,
		DB_next_xfer_read	= 4'd5,
		DB_next_xfer_incr	= 4'd6,
		DB_begin_xfer_write	= 4'd7,
		DB_check_xfer_write	= 4'd8,
		DB_done_xfer		= 4'd9,
		DB_done_xfer1		= 4'd10,
		DB_done_xfer2		= 4'd11,
		DB_done_xfer3		= 4'd12,
		DB_read_new_page	= 4'd13,
		DB_write_old_page	= 4'd14;
     
   reg [3:0]  db_next_state;
   reg [3:0]  db_state;

   wire	      active;
   reg 	      is_read;
   reg 	      is_write;

   reg 	      dma_start;
   reg 	      db_done;
   wire       dma_done;

   reg       clear_db_done;
   reg 	     set_db_done;
   
   reg [14:0] dma_addr;
   reg [11:0] dma_wc;

   reg [19:0] disk_addr;

   reg       load_disk_addr;
   reg 	     incr_disk_addr;

   wire [7:0] buffer_addr;
   reg [19:8] buffer_disk_addr;
   reg 	      buffer_dirty;

   reg [11:0] buffer_hold;

   reg 	      load_buffer_hold;
   reg 	      set_buffer_addr;
   reg 	      set_buffer_dirty;

   wire       buffer_matches_DMA;
   wire       buffer_rd;
   wire       buffer_wr;
   
   wire       ide_read_req;
   wire       ide_write_req;
   wire       ide_done;
   wire       ide_error;
       
   //
   assign io_interrupt = (CIE & DCF) ||
			 (PIE & PCA) ||
			 (EIE & (WLS | DRL | NXD | PER));

   assign active = is_read | is_write;

   assign buffer_matches_DMA = buffer_disk_addr[19:8] == disk_addr[19:8];
   assign buffer_addr = disk_addr[7:0];
			 
   //
   // sector buffer
   //
   wire       ide_active;
   wire [7:0] buff_addr;
   wire [11:0] buff_in;
   wire [11:0] buff_out;
   wire        buff_rd;
   wire        buff_wr;

   wire [7:0]  ide_buffer_addr;
   wire [23:0] ide_block_number;
   wire [11:0] ide_buffer_in;
   wire [11:0] ide_buffer_out;
   wire        ide_buffer_rd;
   wire        ide_buffer_wr;
  
   // ide sector buffer
   ram_256x12 buffer(.clk(clk),
		     .reset(reset),
		     .a(buff_addr),
		     .din(buff_in),
		     .dout(buff_out),
		     .ce(buff_rd | buff_wr),
		     .we(buff_wr));

   assign ide_buffer_in = buff_out;
   
   assign ide_active = ide_read_req | ide_write_req;
   
   assign buff_addr = ide_active ? ide_buffer_addr : buffer_addr;
   assign buff_in = ide_active ? ide_buffer_out : buffer_hold;
   assign buff_rd = ide_active ? ide_buffer_rd : /*1'b1*/buffer_rd;
   assign buff_wr = ide_active ? ide_buffer_wr : buffer_wr;
   
   // ide disk
   ide_disk disk(.clk(clk),
		 .reset(reset),
		 .ide_lba(ide_block_number),
		 .ide_read_req(ide_read_req),
		 .ide_write_req(ide_write_req),
		 .ide_error(ide_error),
		 .ide_done(ide_done),
		 .buffer_addr(ide_buffer_addr),
		 .buffer_rd(ide_buffer_rd), 
		 .buffer_wr(ide_buffer_wr),
		 .buffer_in(ide_buffer_in),
		 .buffer_out(ide_buffer_out),
		 .ide_data_in(ide_data_in),
		 .ide_data_out(ide_data_out),
		 .ide_dior(ide_dior),
		 .ide_diow(ide_diow), 
		 .ide_cs(ide_cs),
		 .ide_da(ide_da));

   assign ide_block_number = ide_read_req ?
			     { 12'b0, disk_addr[19:8] } :
			     { 12'b0, buffer_disk_addr[19:8] };

   //
   // RF controller
   //
   
   // combinatorial logic
   always @(state or iot or io_select or mb or io_data_in or
	    ADC or DRL or PER or WLS or NXD or DCF or
	    PCA or DRE or EIE or PIE or CIE or MEX or DMA or EMA or
	    disk_addr)
     begin
	// sampled during f1
	io_skip = 0;
	io_clear_ac = 0;
	io_data_out = io_data_in;
	io_data_avail = 1'b1;
	dma_start = 1'b0;
	io_selected = 1'b0;
	
	if (state == F1 && iot)
	  case (io_select)
	    6'o60:
	      begin
		 io_selected = 1'b1;
		 case (mb[2:0] )
		   3'o3: // DMAR
		     begin
			io_data_out = 0;
			dma_start = 1'b1;
			io_clear_ac = 1;
`ifdef debug
			$display("rf: DMAR disk_addr %o",  {EMA, DMA});
`endif
		     end
		   3'o5: // DMAW
		     begin
			io_data_out = 0;
			dma_start = 1'b1;
			io_clear_ac = 1;
`ifdef debug
			$display("rf: DMAW disk_addr %o", {EMA, DMA});
`endif
		     end
		   default:
		     ;
		 endcase
	      end // case: 6'o60
	    
	    6'o61:
	      begin
		 io_selected = 1'b1;
		 case (mb[2:0])
		   3'o2: // DSAC
		     if (ADC)
		       begin
			  io_skip = 1;
			  io_data_out = 0;
		       end
		   3'o6: // DIMA
		     io_data_out = { PCA,DRE,WLS,
				     EIE,PIE,CIE,
				     MEX, 
				     DRL,NXD,PER };
		   3'o5: // DIML
		     begin
			io_data_out = 0;
			io_clear_ac = 1;
		     end

		   default:
		     ;
		   
		 endcase // case(mb[2:0])
	      end
	    
	    6'o62:
	      begin
		 io_selected = 1'b1;
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
		     begin
			io_data_out = DMA;
			io_clear_ac = 1;
		     end
		   default:
		     ;
		 endcase 
	      end
		   
	    6'o64:
	      begin
		 io_selected = 1'b1;
		 case (mb[2:0])
		   3'o3: // DXAL
		     begin
			io_data_out = 0;
			io_clear_ac = 1;
		     end
		   3'o5: // DXAC
		     io_data_out = { 4'b0, EMA };
		   default:
		     ;
		 endcase // case(mb[2:0])
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
	  is_read <= 1'b0;
	  is_write <= 1'b0;

	  EMA <= 8'b0;
	  DMA <= 12'b0;
	  MEX <= 3'b0;
	  PEF <= 1'b0;
	  CIE <= 1'b0;
	  PIE <= 1'b0;
	  EIE <= 1'b0;
	  DCF <= 1'b1;
	  NXD <= 1'b0;
       end
     else
       case (state)
	  F0:
	    begin
	       if (iot)
		 case (io_select)
		   6'o60: // DCMA
		     if (mb[2:0] == 3'b001)
		       begin
`ifdef debug
			  $display("rf: DCMA");
`endif
			  DMA <= 0;
			  PEF <= 1'b0;
			  NXD <= 1'b0;
			  DCF <= 1'b0;
		       end
		   6'o61:
		     case (mb[2:0])
		       3'o1: // DCIM
			 begin
			    EIE <= 1'b0;
			    PIE <= 1'b0;
			    CIE <= 1'b0;
			    MEX <= 3'b0;
`ifdef debug
			 $display("rf: DCIM");
`endif
			 end
		       3'o2: // DSAC
			 begin
			 end
		       3'o5: // DIML
			 begin
			 end
		       default:
			 ;
		     endcase // case(mb[2:0])

		   default:
		     ;
		 endcase
	    end

	  F1:
	    if (iot)
	      begin
`ifdef debug_rf
		 if (io_select == 6'o60 || io_select == 6'o64)
		 $display("iot2 %t, state %b, mb %o, io_select %o",
			  $time, state, mb, io_select);
`endif
		 case (io_select)
		   6'o60:
		     case (mb[2:0])
		       3'o3: // DMAR
			 begin
			    // clear ac
			    DMA <= io_data_in;
			    is_read <= 1'b1;
			    DCF <= 1'b0;
`ifdef debug
			    $display("rf: DMAR ac %o", io_data_in);
`endif
			 end

		       3'o5: // DMAW
			 begin
			    // clear ac
			    DMA <= io_data_in;
			    is_write <= 1'b1;
			    DCF <= 1'b0;
`ifdef debug
			    $display("rf: DMAW ac %o", io_data_in);
`endif
			 end

		       default:
			 ;
		     endcase // case(mb[2:0])

		   6'o61:
		     case (mb[2:0])
		       3'o5: // DIML
			   begin
			      EIE <= io_data_in[8];
			      PIE <= io_data_in[7];
			      CIE <= io_data_in[6];
			      MEX <= io_data_in[5:3];
`ifdef debug
			      $display("rf: DIML %o", io_data_in);
`endif
			 end
		       default:
			 ;
		     endcase // case(mb[2:0])
		   
		   6'o64:
		     case (mb[2:0])
		       1: // DCXA
			 EMA <= 0;
		       3: // DXAL
			 begin
			    // clear ac
			    EMA <= io_data_in[7:0];
			 end
		       default:
			 ;
		     endcase
		   
		   default:
		     ;
                 endcase

	      end // if (iot)

	  F2:
	    begin
	    end

	 // F3 is a convenient time to do this
	 // note that state machine waits when done till next F2
	 // to sync up DB_done_xfer3 and F3
	 F3:
	   if (db_state == DB_done_xfer3)
	     begin
  		EMA <= disk_addr[19:12];
  		DMA <= disk_addr[11:0];
		is_read <= 1'b0;
		is_write <= 1'b0;
`ifdef debug
		$display("rf: set DCF (CIE %b)", CIE);
`endif
		DCF <= 1'b1;
	     end

	 default:
	   ;

       endcase // case(state)

   // comb logic to create 'next state'
   always @(*)
     begin
	db_next_state = db_state;
	load_disk_addr = 0;
	incr_disk_addr = 0;
	set_buffer_addr = 0;
	set_buffer_dirty = 0;
	load_buffer_hold = 0;
	set_db_done = 0;
	clear_db_done = 0;
	
	case (db_state)
	  DB_idle:
	    if (dma_start)
	      db_next_state = DB_start_xfer1;

	  DB_start_xfer1:
	    if (ram_done)
	      begin
		 clear_db_done = 1;
		 load_disk_addr = 1;
		 db_next_state = DB_start_xfer2;
	      end
	  
	  DB_start_xfer2:
	    if (ram_done)
	      begin
		 set_db_done = 1;
		 db_next_state = DB_start_xfer3;
	      end
	  
	  DB_start_xfer3:
	    begin
	       db_next_state = is_read ? DB_check_xfer_read : DB_begin_xfer_write;
	    end

	  DB_check_xfer_read:
	    begin
               if (buffer_matches_DMA)
		 db_next_state = DB_next_xfer_read;
               else
		 begin
  		    db_next_state = buffer_dirty ?
				    DB_write_old_page :
				    DB_read_new_page;
		 end
	    end
	  
	  DB_next_xfer_read:
	    if (ram_done)
	      begin
		 incr_disk_addr = 1;
		 db_next_state = dma_done ? DB_done_xfer : DB_next_xfer_incr;
	      end
	  
	  DB_next_xfer_incr:
	      db_next_state = is_read ? DB_check_xfer_read:DB_begin_xfer_write;

	  DB_begin_xfer_write:
	    begin
	       if (ram_done)
		 begin
		    //$display("begin-xfer-write; done, wc %o", dma_wc);
		    load_buffer_hold = 1;
 		    db_next_state = DB_check_xfer_write;
		 end
	    end
	  
	  DB_check_xfer_write:
	    if (buffer_matches_DMA)
	      begin
		 set_buffer_dirty = 1;
		 incr_disk_addr = 1;
		 db_next_state = dma_done ? DB_done_xfer : DB_next_xfer_incr;
	      end
	    else
	      begin
  		 db_next_state = buffer_dirty ? DB_write_old_page : DB_read_new_page;
	      end

	  DB_done_xfer:
	    begin
	       //$display("done-xfer");
	       if (ram_done)
		 db_next_state = DB_done_xfer1;
	    end

	  DB_done_xfer1:
	    if (ram_done)
	      db_next_state = DB_done_xfer2;

	  DB_done_xfer2:
	    if (state == F2)
	      db_next_state = DB_done_xfer3;

	  DB_done_xfer3:
            db_next_state = DB_idle;

	  DB_read_new_page:
	    begin
	       if (ide_done)
		 begin
		    //$display("read-new-page done; wc %o; is-read %b", dma_wc, is_read);
		    set_buffer_addr = 1;
		    db_next_state = is_read ?
				    DB_check_xfer_read :
				    DB_check_xfer_write;
		 end
	    end
	  
	  DB_write_old_page:
	    begin
	       if (ide_done)
		 begin
		    //$display("write-new-page done; wc %o; is-read %b", dma_wc, is_read);
		    set_buffer_addr = 1;
		    db_next_state = DB_read_new_page;
		 end
	    end

	  default:
	    ;
	  
	endcase
     end

   // db_state
   always @(posedge clk)
     if (reset)
       db_state <= DB_idle;
     else
       begin
	  db_state <= db_next_state;
`ifdef debug_state
	  if (is_write)
	    $display("rf: state %d", db_next_state);
`endif
`ifdef debug	  
	  case (db_next_state)
	    DB_start_xfer3:
	      begin
	  	 $display("start-xfer; is-read %b, buffer_matches_DMA %b, buffer-disk-addr %o, disk-addr %o",
			  is_read, buffer_matches_DMA, buffer_disk_addr[19:8], disk_addr[19:8]);
	      end

	    DB_write_old_page:
	      if (db_state != DB_write_old_page)
	      begin
		 $display("flush; buffer-dirty %b, buffer-disk-addr %o, disk-addr %o",
			  buffer_dirty, buffer_disk_addr[19:8], disk_addr[19:8]);
	      end
	    
	    DB_read_new_page:
	      if (db_state != DB_read_new_page)
	      begin
		 $display("read-new; buffer-dirty %b, buffer-disk-addr %o, disk-addr %o",
			  buffer_dirty, buffer_disk_addr[19:8], disk_addr[19:8]);
	      end

	    default:
	      ;
	  endcase
`endif
       end

      assign dma_done = dma_wc == 12'o0000;

   // general state - wc & ca
   always @(posedge clk)
     if (reset)
       begin
	  dma_wc <= 12'b0;
	  dma_addr <= 15'b0;
       end
     else
       begin
	  case (db_state)
	    
	    DB_start_xfer1:
	      begin
		 dma_wc <= ram_in + 12'o0001;
`ifdef debug
		 if (ram_done) $display("rf: read wc %o", ram_in);
`endif
	      end
	    
	    DB_start_xfer2:
	      begin
		 dma_addr <= { MEX, ram_in + 12'o0001 };
`ifdef debug
		 if (ram_done)
		   $display("rf: read ca %o (dma_addr %o)",
			    ram_in, { MEX, ram_in + 12'o0001 });
`endif
	      end

	    DB_start_xfer3:
	      begin
		 // this state might be not be needed
`ifdef debug
		 if (is_read)
		   $display("rf: start! read disk_addr %o (%o %o) (ma %o wc %o)",
			    disk_addr, EMA, DMA, dma_addr, dma_wc);
		 else
		   $display("rf: start! write disk_addr %o (%o %o) (ma %o wc %o)",
			    disk_addr, EMA, DMA, dma_addr, dma_wc);
`endif
	      end

	    DB_next_xfer_incr:
	      begin
		 dma_addr[11:0] <= dma_addr[11:0] + 12'o0001;
		 dma_wc <= dma_wc + 12'b1;
`ifdef debug_rf
		 $display("dma_wc %o dma_addr %o MEX %o",dma_wc,dma_addr,MEX);
`endif
	      end

	    DB_next_xfer_read:
	      begin
		 /* snoop for our wc & ca */
 		 if (dma_addr == 15'o07750 && ram_done)
		   begin
		      dma_wc <= buff_out;
`ifdef debug
		      $display("rf: snoop update wc %o", buff_out);
`endif	
		   end

		 if (dma_addr == 15'o07751 && ram_done)
		   begin
		      dma_addr[11:0] <= buff_out;
`ifdef debug
		      $display("rf: snoop update ca %o", buff_out);
`endif
		   end

`ifdef debug_rf
		 if (ram_done)
		   $display("rf: buffer read[%o] = %o", buff_addr, buff_out);
`endif
	      end

`ifdef debug
	    DB_done_xfer:
	      if (ram_done) $display("rf: done; write wc %o", dma_wc);

	    DB_done_xfer1:
	      if (ram_done) $display("rf: done; write ca %o", dma_addr);
	    
	    DB_done_xfer2:
	      begin
		 if (buffer_dirty)
		   $display("rf: done; buffer-dirty");
		 else
		   $display("rf: done; buffer-clean");
	      end
`endif

	    default:
	      ;
	  endcase
       end

   //
   always @(posedge clk)
     if (reset)
       buffer_hold <= 12'b0;
     else
       if (load_buffer_hold)
	 buffer_hold <= ram_in;

   // done state
   always @(posedge clk)
     if (reset)
       db_done <= 1'b1;
     else
       if (clear_db_done)
	 db_done <= 1'b0;
       else
	 if (set_db_done)
	   db_done <= 1'b1;
   
   // buffer address
   always @(posedge clk)
     if (reset)
       begin
	  buffer_disk_addr[19:8] <= 12'b111111111111;
	  buffer_dirty <= 1'b0;
       end
     else
       if (set_buffer_dirty)
	 begin
	    //$display("set-buffer-dirty; %t", $time);
	    buffer_dirty <= 1'b1;
	 end
       else
	 if (set_buffer_addr)
	   begin
`ifdef debug
	      $display("set-buffer-addr; clean, disk-addr %o, %t", disk_addr[19:8], $time);
`endif
	      buffer_dirty <= 1'b0;
	      buffer_disk_addr[19:8] <= disk_addr[19:8];
	   end

   // disk address
   always @(posedge clk)
     if (reset)
       disk_addr <= 0;
     else
       if (load_disk_addr)
	 disk_addr <= {EMA, DMA};
       else
	 if (incr_disk_addr)
	   disk_addr <= disk_addr + 20'b1;

		    
   //
   // external ram control (for dma to/from pdp-8 memory)
   //
   assign ram_ma =
		  db_state == DB_start_xfer1 ? WC_ADDR :
		  db_state == DB_start_xfer2 ? CA_ADDR :
		  db_state == DB_next_xfer_read ? dma_addr :
		  db_state == DB_begin_xfer_write ? dma_addr :
		  db_state == DB_done_xfer ? WC_ADDR :
		  db_state == DB_done_xfer1 ? CA_ADDR :
		  15'b0;

   assign ram_read_req =
			(db_state == DB_start_xfer1) |
			(db_state == DB_start_xfer2) |
			(db_state == DB_begin_xfer_write);
   
   assign ram_write_req =
			 (db_state == DB_next_xfer_read) |
			 (db_state == DB_done_xfer) |
			 (db_state == DB_done_xfer1);

   assign ram_out =
		   db_state == DB_next_xfer_read ? buff_out :
		   db_state == DB_begin_xfer_write ? buffer_hold :
		   db_state == DB_done_xfer ? dma_wc :
		   db_state == DB_done_xfer1 ? dma_addr[11:0] :
		   12'b0;

   assign buffer_rd = db_state == DB_check_xfer_read && buffer_matches_DMA;
   assign buffer_wr = db_state == DB_check_xfer_write && buffer_matches_DMA;
   
   assign ide_read_req = db_state == DB_read_new_page;
   assign ide_write_req = db_state == DB_write_old_page;

   //
   // RF08 state
   //
   assign ADC = buffer_matches_DMA;

   // fake the photocell sensor
   always @(posedge clk)
     if (reset)
       photocell_counter <= 0;
     else
       begin
	  photocell_counter <= photocell_counter + 1;
       end

   assign PCA = photocell_counter < 16;
   assign DRE = ~db_done;

   /* we don't support write lock */
   always @(posedge clk)
     if (reset)
       begin
	  WLS <= 1'b0;
       end

`ifdef debug_rf_state
   always @(posedge clk)
     /* verilator lint_off CASEINCOMPLETE */
     case (db_state)
       DB_idle: $display("db_state: DB_idle");
       DB_start_xfer1: $display("db_state: DB_start_xfer1");
       DB_start_xfer2: $display("db_state: DB_start_xfer2");
       DB_start_xfer3: $display("db_state: DB_start_xfer3");
       DB_check_xfer_read: $display("db_state: DB_check_xfer_read");
       DB_next_xfer_read: $display("db_state: DB_next_xfer_read");
       DB_next_xfer_incr: $display("db_state: DB_next_xfer_incr");
       DB_begin_xfer_write: $display("db_state: DB_begin_xfer_write");
       DB_check_xfer_write: $display("db_state: DB_check_xfer_write");
       DB_done_xfer: $display("db_state: DB_done_xfer");
       DB_done_xfer1: $display("db_state: DB_done_xfer1");
       DB_done_xfer2: $display("db_state: DB_done_xfer2");
       DB_done_xfer3: $display("db_state: DB_done_xfer3");
       DB_read_new_page: $display("db_state: DB_read_new_page");
       DB_write_old_page: $display("db_state: DB_write_old_page %t", $time);
     endcase
     /* verilator lint_on CASEINCOMPLETE */

`endif

endmodule

