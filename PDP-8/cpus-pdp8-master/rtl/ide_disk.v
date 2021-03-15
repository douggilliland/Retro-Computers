//
// ide_disk.v
// single block (512 byte/256 work) IDE disk read/write
//

module ide_disk(clk, reset,
		ide_lba, ide_read_req, ide_write_req,
		ide_error, ide_done,
		buffer_addr, buffer_rd, buffer_wr,
		buffer_in, buffer_out,
		ide_data_in, ide_data_out, ide_dior, ide_diow, ide_cs, ide_da);

   input clk;
   input reset;
   input [23:0] ide_lba;
   input 	ide_read_req;
   input 	ide_write_req;

   output 	ide_error;
   output 	ide_done;
   
   output reg [7:0] buffer_addr;
   output reg 	    buffer_rd;
   output reg 	    buffer_wr;
   output reg [11:0] buffer_out;
   input [11:0]      buffer_in;

   parameter [4:0]
		ready = 5'd0,
		init0 = 5'd1,
		init1 = 5'd2,
		init2 = 5'd3,
		init3 = 5'd4,
		init4 = 5'd5,
		init5 = 5'd6,
		init6 = 5'd7,
		init7 = 5'd8,
		init8 = 5'd9,
		init9 = 5'd10,
		init10 = 5'd11,
		init11 = 5'd12,
		read0 = 5'd13,
		read1 = 5'd14,
		write0 = 5'd15,
		write1 = 5'd16,
		last0 = 5'd17,
		last1 = 5'd18,
		last2 = 5'd19,
		last3 = 5'd20,
		wait0 = 5'd21,
		wait1 = 5'd22;

   parameter ATA_ALTER   = 5'b01110;
   parameter ATA_DEVCTRL = 5'b01110; /* bit [2] is a nIEN */
   parameter ATA_DATA    = 5'b10000;
   parameter ATA_ERROR   = 5'b10001;
   parameter ATA_FEATURE = 5'b10001;
   parameter ATA_SECCNT  = 5'b10010;
   parameter ATA_SECNUM  = 5'b10011; /* LBA[7:0] */
   parameter ATA_CYLLOW  = 5'b10100; /* LBA[15:8] */
   parameter ATA_CYLHIGH = 5'b10101; /* LBA[23:16] */
   parameter ATA_DRVHEAD = 5'b10110; /* LBA + DRV + LBA[27:24] */
   parameter ATA_STATUS  = 5'b10111;
   parameter ATA_COMMAND = 5'b10111;

   parameter IDE_STATUS_BSY =  7;
   parameter IDE_STATUS_DRDY = 6;
   parameter IDE_STATUS_DWF =  5;
   parameter IDE_STATUS_DSC =  4;
   parameter IDE_STATUS_DRQ =  3;
   parameter IDE_STATUS_CORR = 2;
   parameter IDE_STATUS_IDX =  1;
   parameter IDE_STATUS_ERR =  0;
   
   parameter ATA_CMD_READ = 16'h0020;
   parameter ATA_CMD_WRITE = 16'h0030;

   reg 		 ata_rd;
   reg 		 ata_wr;
   reg [4:0] 	 ata_addr;
   reg [15:0] 	 ata_in;
   wire [15:0] 	 ata_out;
   wire 	 ata_done;

   input [15:0]  ide_data_in;
   output [15:0] ide_data_out;
   output 	 ide_dior;
   output 	 ide_diow;
   output [1:0]  ide_cs;
   output [2:0]  ide_da;

   //
   reg [4:0] 	 ide_state;
   reg [4:0] 	 ide_state_next;
   
   reg [7:0] 	 offset;
   reg [7:0] 	 wc;
   reg 		 err;
   reg 		 done;

   reg 		 set_done, clear_done;
   reg 		 set_err, clear_err;
   reg 		 inc_offset;

   reg [11:0] 	 buffer_in_hold;
   reg 		 grab_buffer_in;
   
   // 
   ide ide(.clk(clk), .reset(reset),
	   .ata_rd(ata_rd), .ata_wr(ata_wr), .ata_addr(ata_addr),
	   .ata_in(ata_in), .ata_out(ata_out), .ata_done(ata_done),
	   .ide_data_in(ide_data_in), .ide_data_out(ide_data_out),
	   .ide_dior(ide_dior), .ide_diow(ide_diow),
	   .ide_cs(ide_cs), .ide_da(ide_da));

   //
   wire [23:0] 	 lba;
   wire 	start;

   assign lba = ide_lba;
   assign start = ide_read_req | ide_write_req;
   assign ide_done = done;
   

   //
   always @(posedge clk)
     if (reset)
       begin
	  err <= 1'b0;
	  done <= 1'b0;
	  offset <= 8'b0;
	  wc <= 8'b0;
	  buffer_in_hold <= 12'b0;
       end
     else
       begin
	  if (set_err)
	    err <= 1'b1;
	  else
	    if (clear_err)
	      err <= 1'b0;

	  if (set_done)
	    done <= 1'b1;
	  else
	    if (clear_done)
	      done <= 1'b0;

	  if (inc_offset)
	    begin
	       offset <= offset + 8'h01;
	       wc <= wc + 8'h01;
	    end

	  if (grab_buffer_in)
	    begin
`ifdef debug
	       $display("ide_disk: grabbing buffer_in %o", buffer_in);
`endif
	       buffer_in_hold <= buffer_in;
	    end
       end

   //
   // ide state machine
   //
   always @(posedge clk)
     if (reset)
       ide_state <= ready;
     else
       begin
	  ide_state <= ide_state_next;
`ifdef debug_write
	  if (ide_write_req)
	    $display("ide_disk: state %d", ide_state_next);
`endif
       end

   always @(ide_state or ide_write_req or ide_read_req or
	    lba or offset or wc or start or
            ata_done or ata_out or
	    buffer_in or buffer_in_hold)
     begin
	ide_state_next = ide_state;

	set_err = 0;
	clear_err = 0;

	set_done = 0;
	clear_done = 0;

	inc_offset = 0;
	grab_buffer_in = 0;
	
	ata_rd = 0;
	ata_wr = 0;
	ata_addr = 0;
	ata_in = 0;
	
	buffer_rd = 0;
	buffer_wr = 0;
	buffer_addr = 0;
	buffer_out = 0;

	case (ide_state)
	  ready:
	    begin
	       if (start)
		 begin
		    ide_state_next = init0;
		    clear_done = 1;
`ifdef debug
		    $display("ide_disk: XXX go!");
`endif
		 end
	    end
	  
	  init0:
	    begin
	       ata_addr = ATA_STATUS;
	       ata_rd = 1;
	       if (ata_done &&
		   ~ata_out[IDE_STATUS_BSY] &&
		   ata_out[IDE_STATUS_DRDY])
		 ide_state_next = init1;
	    end

	  init1:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_DRVHEAD;
	       ata_in = 16'h0040;
	       if (ata_done)
		 ide_state_next = wait0;
	    end

	  wait0:
	    begin
	       // cnt = 1;
	       // if (cnt_rdy)
	       ide_state_next = init2;
	    end

	  init2:
	    begin
	       ata_addr = ATA_STATUS;
	       ata_rd = 1;
	       if (ata_done &&
		   ~ata_out[IDE_STATUS_BSY] &&
		   ata_out[IDE_STATUS_DRDY])
		 ide_state_next = init3;
	    end

	  init3:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_DEVCTRL;
	       ata_in = 16'h0002;		// nIEN
	       if (ata_done)
		 ide_state_next = init4;
	    end
	  
	  init4:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_SECCNT;
	       ata_in = { 8'b0, 8'd1 };
	       if (ata_done)
		 ide_state_next = init5;
	    end
	  
	  init5:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_SECNUM;
	       ata_in = {8'b0, lba[7:0]};	// LBA[7:0]
	       if (ata_done)
		 ide_state_next = init6;
	    end

	  init6:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_CYLLOW;
	       ata_in = {8'b0, lba[15:8]};	// LBA[15:8]
	       if (ata_done)
		 ide_state_next = init7;
	    end

	  
	  init7:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_CYLHIGH;
	       ata_in = {8'b0, lba[23:16]};	// LBA[23:16]
	       if (ata_done)
		 ide_state_next = init8;
	    end

	  init8:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_DRVHEAD;
	       ata_in = 16'h0040;		// LBA[27:24] + LBA
	       if (ata_done)
		 ide_state_next = init9;
	    end

	  init9:
	    begin
	       ata_wr = 1;
	       ata_addr = ATA_COMMAND;
	       ata_in = ide_write_req ? ATA_CMD_WRITE :
			ide_read_req ? ATA_CMD_READ : 16'b0;
	       if (ata_done)
		 ide_state_next = wait1;
	    end

	  wait1:
	    begin
//	       cnt = 1;
//	       if (cnt_rdy)
		 ide_state_next = init10;
	    end
	  
	  init10:
	    begin
	       ata_rd = 1;
	       ata_addr = ATA_ALTER;
	       if (ata_done)
		 ide_state_next = init11;
	    end
	  
	  init11:
	    begin
	       ata_rd = 1;
	       ata_addr = ATA_STATUS;

	       //if (ata_done) $display("ide_disk: XXX init11 ata_out %x", ata_out);
	       if (ata_done && ~ata_out[IDE_STATUS_BSY])
		 begin
		    if (ide_write_req)
		      ide_state_next = write0;
		    else
		    if (ide_read_req && ata_out[IDE_STATUS_DRQ])
		      ide_state_next = read0;
		 end

	       if (ata_out[IDE_STATUS_ERR])
		    set_err = 1;
	    end

	  read0:
	    begin
	       ata_rd = 1;
	       ata_addr = ATA_DATA;

	       if (ata_done)
		 ide_state_next = read1;
	    end
	  
	  read1:
	    begin
	       //buffer write
	       buffer_addr = offset;
	       buffer_out = ata_out[11:0];
	       
	       if (0) $display("ide_disk: buffer_addr %o, buffer_out %o",
				 buffer_addr, buffer_out);
			    
	       buffer_wr = 1;
	       inc_offset = 1;

	       if (wc == 8'hff)
		 ide_state_next = last0;
	       else
//		 if (wc == 16'hff00)
//		   ide_state_next = init10;
//		 else
		   ide_state_next = read0;
	    end

	  write0:
	    begin
	       //buffer read
	       buffer_addr = offset;
	       buffer_rd = 1;
//	       grab_buffer_in = 1;
	       
	       ata_in = {4'b0, buffer_in};
	       inc_offset = 1;
	       ide_state_next = write1;
	    end

	  write1:
	    begin
	       grab_buffer_in = 1;
	       ata_wr = 1;
	       ata_addr = ATA_DATA;
	       ata_in = {4'b0, buffer_in_hold};
`ifdef debug
	       $display("ide_disk: write1, %o", buffer_in_hold);
`endif	       
	       if (ata_done)
		 begin
		    if (wc == 8'h00)
		      ide_state_next = last0;
		    else
		      ide_state_next = write0;
		 end
	    end

	  last0:
	    begin
	       ata_rd = 1;
	       ata_addr = ATA_ALTER;
	       if (ata_done)
		 ide_state_next = last1;
	    end
	  
	  last1:
	    begin
	       ata_rd = 1;
	       ata_addr = ATA_STATUS;
	       if (ata_done)
		 ide_state_next = last2;
	    end

	  last2:
	    begin
	       clear_err = 1;
	       set_done = 1;
	       ide_state_next = last3;
	    end

	  last3:
	    begin
	       clear_done = 1;
	       ide_state_next = ready;
`ifdef debug
	       $display("ide_disk: XXX last3, done");
`endif
	    end
		 
	  default:
	    begin
	    end
	  
	endcase
     end

`ifdef debug_ide_state
   always @(posedge clk)
     /* verilator lint_off CASEINCOMPLETE */
     case (ide_state)
       ready: $display("ide_state: ready");
       init0: $display("ide_state: init");
       init1: $display("ide_state: init1");
       init2: $display("ide_state: init2");
       init3: $display("ide_state: init3");
       init4: $display("ide_state: init4");
       init5: $display("ide_state: init5");
       init6: $display("ide_state: init6");
       init7: $display("ide_state: init7");
       init8: $display("ide_state: init8");
       init9: $display("ide_state: init9");
       init10: $display("ide_state: init10");
       init11: $display("ide_state: init11");
       read0: $display("ide_state: read0");
       read1: $display("ide_state: read1");
       write0: $display("ide_state: write0");
       write1: $display("ide_state: write1");
       last0: $display("ide_state: last0");
       last1: $display("ide_state: last1");
       last2: $display("ide_state: last2");
       last3: $display("ide_state: last3");
       wait0: $display("ide_state: wait0");
       wait1: $display("ide_state: wait1");
     endcase
     /* verilator lint_on CASEINCOMPLETE */
`endif
   
endmodule

