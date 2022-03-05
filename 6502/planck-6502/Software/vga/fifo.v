//******************************************************************************
//                                                                             *
// Copyright (C) 2010 Regents of the University of California.                 *
//                                                                             *
// The information contained herein is the exclusive property of the VCL       *
// group but may be used and/or modified for non-comercial purposes if the     *
// author is acknowledged.  For all other uses, permission must be attained    *
// by the VLSI Computation Lab.                                                *
//                                                                             *
// This work has been developed by members of the VLSI Computation Lab         *
// (VCL) in the Department of Electrical and Computer Engineering at           *
// the University of California at Davis.  Contact: bbaas@ece.ucdavis.edu      *
//******************************************************************************
// FIFO.v
//
// 16-bit by 32,  dual-clock circular FIFO for interfacing at clock boundaries
//
// $Id: FIFO.v,v 1.0 7/19/2010 02:15:36 astill Exp $
// Written by: Aaron Stillmaker
//
// Origional AsAP FIFO Written by: Ryan Apperson 
// First In First Out circuitry:
// Main goal in rewriting was to have the whole FIFO in one file and not be
// AsAP specific.  I started fresh writing most code from scratch using 
// Ryan's thesis as a guide, some of code was used from his origional  
// code, and some of the new code was modeled after the origional code.
//

// Define FIFO Address width minus 1 and Data word width minus 1

`define ADDR_WIDTH_M1 6
`define DATA_WIDTH_M1 8

`timescale 10ps/1ps
`celldefine
module FIFO (
   reserve,         // reserve space constant
   wr_sync_cntrl,   // Config input for wr side synchronizer
   clk_wr,          // clock coming from write side of FIFO -- write signals
   data_in,         // data to be written  
   wr_valid,        // write side data is valid for writing to FIFO
   delay_sel,       // choose one/two delay cell for input data
   wr_request,      // low= Full or utilizing reserve space, else NOT FULL
   async_empty,     // true if empty, but referenced to write side
   reset,           // synchronous to read clock  --------------------------
   clk_rd,          // clock coming from read side of FIFO  -- read signals 
   data_out,        // data to be read  
   empty,           // FIFO is EMPTY (combinational in from 1st stage of FIFO)
   rd_request,      // asks the FIFO for data
   async_full,      // true if FIFO is in reserve, but referenced to read side
   rd_sync_cntrl,   // Config input for rd side synchronizer
   nap,              // no increment read pointer signal
   fifo_util        // FIFO utilization, used for DVFS
   );


   // I/O %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   input [1:0]               delay_sel;
   input [`DATA_WIDTH_M1:0]  data_in;
   
   input [`ADDR_WIDTH_M1:0]  reserve;
   input [2:0]               wr_sync_cntrl;   
   input [2:0]               rd_sync_cntrl;    

   input                     clk_wr,
                             clk_rd, 
                             reset,
                             wr_valid, 
                             rd_request,
                             nap;

   output [`DATA_WIDTH_M1:0] data_out;  
   
   output [1:0]              fifo_util;

   output                    empty, 
                             wr_request,
                             async_full,
                             async_empty;


   // Internal Wires %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   wire [`ADDR_WIDTH_M1:0]   temp_adder_out, // temporary address out
                             rd_ptr_on_wr,
                             wr_ptr_gray;    // write pointer in gray code
							
   wire [`DATA_WIDTH_M1:0]   data_out_c;     // data out from memory
				
	
   wire                      wr_conv_temp1,  // temporary wires used in gray
                             wr_conv_temp2,  //to binary conversions
                             rd_conv_temp1,
                             rd_conv_temp2,
							 rd_en,          // read inable flag
                             rd_inc;         // read increment flag
	
   // Internal Registers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   reg  [`ADDR_WIDTH_M1:0]   wr_ptr,         // write pointer
                             rd_ptr,         // read pointer
                             rd_ptr_gray,    // read pointer in gray code
                             wr_ptr_gray_d1, // delayed write ptr in gray code
                             wr_ptr_gray_d2,
                             rd_ptr_gray_d1, // delayed read ptr in gray code
                             rd_ptr_gray_d2,
                             rd_ptr_gray_on_wr,
                             wr_ptr_gray_on_rd,
                             wr_ptr_on_rd,
                             wr_Reg1,        // registered pointers
                             wr_Reg2,
                             wr_Reg3,
                             wr_Reg4,
                             wr_RegS,
                             rd_Reg1,
                             rd_Reg2,
                             rd_Reg3,
                             rd_Reg4,
                             rd_RegS;
							
   reg  [`DATA_WIDTH_M1:0]   data_out,       // data output
                             data_in_d,
                             data_inREG1,    // registered data in values
                             data_inREG2,
                             data_inREG3;


	
   reg                       wr_hold_r,      // delayed write hold value
                             wr_valid_d,
                             validREG1,      // registered valid values
                             validREG2,
                             validREG3;
	
   // Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
	
   // Write Logic %%%
   
	
   // Temporary wires used in the Gray Code to Binary Converter
		
   assign wr_conv_temp1 = (rd_ptr_gray_on_wr[1]^rd_ptr_gray_on_wr[2]);
   assign wr_conv_temp2 = (rd_ptr_gray_on_wr[1]^(~rd_ptr_gray_on_wr[2]));
	
	
   // Reserve Logic Calculation, if the MSB is 1, hold.
   //Accordingly assign the wr request output and async full

   assign temp_adder_out = wr_ptr_on_rd - rd_ptr + {1'b0, reserve};
   assign async_full = temp_adder_out[`ADDR_WIDTH_M1];
   assign wr_request = ~wr_hold_r;
	
			
   // Asynchronous Communication of RD address pointer from RD side to WR side
		
   always @(wr_sync_cntrl or rd_ptr_gray_d2 or wr_Reg1 or wr_Reg2 or wr_Reg3 or
            wr_Reg4) begin
      case(wr_sync_cntrl)        
         3'b000:   wr_RegS = rd_ptr_gray_d2;
         3'b100:   wr_RegS = wr_Reg1;
         3'b101:   wr_RegS = wr_Reg2;
         3'b110:   wr_RegS = wr_Reg3;
         3'b111:   wr_RegS = wr_Reg4;
         default:  wr_RegS = 7'bxxxxxxx;
      endcase
   end

   
   always @(posedge clk_wr or posedge reset) begin


      // Binary Incrementer %%
	  
      // Asynchronous Communication of RD address pointer from RD side to
      //WR side %%
			
      if (reset) begin                //reset address FFs
         wr_ptr <= 7'b0000000;
         wr_ptr_gray_d1 <= #1 7'b0000000;
         wr_ptr_gray_d2 <= #1 7'b0000000;
         wr_hold_r	<= #1 1'b0;
		 
         wr_Reg1  <= 7'b0000000;
         wr_Reg2  <= 7'b0000000;
         wr_Reg3  <= 7'b0000000;
         wr_Reg4  <= 7'b0000000;
         rd_ptr_gray_on_wr <= 7'b0000000;
		 
         // Insert delay to avoid the holdtime violation

         case	(delay_sel)
            0: begin
               wr_valid_d <= wr_valid;
               data_in_d <= data_in;
            end
            1: begin
               wr_valid_d <= validREG1;
               data_in_d <= data_inREG1;
            end
            2: begin
               wr_valid_d <= validREG2;
               data_in_d <= data_inREG2;
            end
            3: begin
               wr_valid_d <= validREG3;
               data_in_d <= data_inREG3;
            end
            default: begin
               wr_valid_d <= wr_valid;
               data_in_d <=	data_in;
            end
	
         endcase
		 
      end 
	  else begin
         wr_ptr <= #1 wr_ptr + wr_valid_d;
         wr_ptr_gray_d1 <= #1 wr_ptr_gray;
         wr_ptr_gray_d2 <= #1 wr_ptr_gray_d1;
         wr_hold_r <= #1 async_full;
		 
         wr_Reg1  <= #1 rd_ptr_gray_d2;
         wr_Reg2  <= #1 wr_Reg1;
         wr_Reg3  <= #1 wr_Reg2;
         wr_Reg4  <= #1 wr_Reg3;

         validREG1  <= #1 wr_valid;
         validREG2  <= #1 validREG1;
         validREG3  <= #1 validREG2;

         data_inREG1  <= #1 data_in;
         data_inREG2  <= #1 data_inREG1;
         data_inREG3  <= #1 data_inREG2;

         rd_ptr_gray_on_wr <= wr_RegS;
		 
		 
         // Insert delay to avoid the holdtime violation

         case	(delay_sel)
            0: begin
               wr_valid_d <= wr_valid;
               data_in_d <= data_in;
            end
            1: begin
               wr_valid_d <= validREG1;
               data_in_d <= data_inREG1;
            end
            2: begin
               wr_valid_d <= validREG2;
               data_in_d <= data_inREG2;
            end
            3: begin
               wr_valid_d <= validREG3;
               data_in_d <= data_inREG3;
            end
            default: begin
               wr_valid_d <= wr_valid;
               data_in_d <=	data_in;
            end
	
         endcase
		 
      end
	  
   end
   
   
   // Binary to Gray Code Converter %%
   
   assign wr_ptr_gray[0] = wr_ptr[0]^wr_ptr[1];
   assign wr_ptr_gray[1] = wr_ptr[1]^wr_ptr[2];
   assign wr_ptr_gray[2] = wr_ptr[2]^wr_ptr[3];
   assign wr_ptr_gray[3] = wr_ptr[3]^wr_ptr[4];
   assign wr_ptr_gray[4] = wr_ptr[4]^wr_ptr[5];
   assign wr_ptr_gray[5] = wr_ptr[5]^wr_ptr[6];
   assign wr_ptr_gray[6] = wr_ptr[6];
   

   // Gray Code to Binary Converter %%

   assign rd_ptr_on_wr[6] = rd_ptr_gray_on_wr[6];
   assign rd_ptr_on_wr[5] = rd_ptr_gray_on_wr[5]^rd_ptr_gray_on_wr[6];
   assign rd_ptr_on_wr[4] = rd_ptr_gray_on_wr[4]^rd_ptr_on_wr[5];
   assign rd_ptr_on_wr[3] = rd_ptr_gray_on_wr[3]^rd_ptr_on_wr[4];
		
   assign rd_ptr_on_wr[2] = rd_ptr_on_wr[3] ? ~rd_ptr_gray_on_wr[2] :
                        rd_ptr_gray_on_wr[2];
   assign rd_ptr_on_wr[1] = rd_ptr_on_wr[3] ? wr_conv_temp2 : wr_conv_temp1;
   assign rd_ptr_on_wr[0] = rd_ptr_on_wr[3] ? wr_conv_temp2^rd_ptr_gray_on_wr[0]
                            : wr_conv_temp1^rd_ptr_gray_on_wr[0];



   // Read Logic %%%
	
	
   // Temporary wires used in the Gray Code to Binary Converter
		
   assign rd_conv_temp1 = (wr_ptr_gray_on_rd[1]^wr_ptr_gray_on_rd[2]);
   assign rd_conv_temp2 = (wr_ptr_gray_on_rd[1]^(~wr_ptr_gray_on_rd[2]));
	
	
   // Read Enable Logic
	
   assign rd_en = ~empty & rd_request;
	
	
   // Increment Enable Logic
	
   assign rd_inc	= rd_en & ~nap;
	
	
   // Empty Logic, see if the next value for the read pointer would be empty
	
   assign empty = (rd_ptr + 1 == wr_ptr_on_rd) & ~nap;
	
			
   // Asynchronous Communication of WR address pointer from WR side to RD side
		
   always @(rd_sync_cntrl or wr_ptr_gray_d2 or rd_Reg1 or rd_Reg2 or rd_Reg3 or
            rd_Reg4) begin
      case(rd_sync_cntrl)
         3'b000: rd_RegS = wr_ptr_gray_d2;
         3'b100: rd_RegS = rd_Reg1;
         3'b101: rd_RegS = rd_Reg2;
         3'b110: rd_RegS = rd_Reg3;
         3'b111: rd_RegS = rd_Reg4;
         default: rd_RegS = 7'bxxxxxxx;
      endcase
   end
	
	
   always @(posedge clk_rd) begin

      // Binary Incrementers %%

      if (reset) begin
         rd_ptr <= #1 7'b1111111;
         wr_ptr_on_rd = 7'b0000000;
         rd_ptr_gray <= #1 7'b0000000;
         rd_ptr_gray_d1 <= #1 7'b0000000;
         rd_ptr_gray_d2 <= #1 7'b0000000;
      end else begin
         rd_ptr <= #1 rd_ptr + rd_inc;
         rd_ptr_gray_d1 <= #1 rd_ptr_gray;
         rd_ptr_gray_d2 <= #1 rd_ptr_gray_d1;
      end
		
      // Binary to Gray Code Converter %%
		
      rd_ptr_gray[0] <= rd_ptr[0]^rd_ptr[1];
      rd_ptr_gray[1] <= rd_ptr[1]^rd_ptr[2];
      rd_ptr_gray[2] <= rd_ptr[2]^rd_ptr[3];
      rd_ptr_gray[3] <= rd_ptr[3]^rd_ptr[4];
      rd_ptr_gray[4] <= rd_ptr[4]^rd_ptr[5];
      rd_ptr_gray[5] <= rd_ptr[5]^rd_ptr[6];
      rd_ptr_gray[6] <= rd_ptr[6];
		
		
      // Asynchronous Communication of WR address ptr from WR side to RD side %%
		
      if (reset) begin
         rd_Reg1  <= 7'b0000000;
         rd_Reg2  <= 7'b0000000;
         rd_Reg3  <= 7'b0000000;
         rd_Reg4  <= 7'b0000000;
         wr_ptr_gray_on_rd <= 7'b0000000;
      end else begin
         rd_Reg1  <= #1 wr_ptr_gray_d2;
         rd_Reg2  <= #1 rd_Reg1;
         rd_Reg3  <= #1 rd_Reg2;
         rd_Reg4  <= #1 rd_Reg3;
         wr_ptr_gray_on_rd <= rd_RegS;
      end
		
		
      // Gray Code to Binary Converter %%

      wr_ptr_on_rd[6] = wr_ptr_gray_on_rd[6];
      wr_ptr_on_rd[5] = wr_ptr_gray_on_rd[5]^wr_ptr_gray_on_rd[6];
      wr_ptr_on_rd[4] = wr_ptr_gray_on_rd[4]^wr_ptr_on_rd[5];
      wr_ptr_on_rd[3] = wr_ptr_gray_on_rd[3]^wr_ptr_on_rd[4];
		
      wr_ptr_on_rd[2] = wr_ptr_on_rd[3] ? ~wr_ptr_gray_on_rd[2] :
                        wr_ptr_gray_on_rd[2];
      wr_ptr_on_rd[1] = wr_ptr_on_rd[3] ? rd_conv_temp2 : rd_conv_temp1;
      wr_ptr_on_rd[0] = wr_ptr_on_rd[3] ? rd_conv_temp2^wr_ptr_gray_on_rd[0] :
                        rd_conv_temp1^wr_ptr_gray_on_rd[0];

		
      // Register the SRAM output
		
      data_out	<= #1 data_out_c;
		
		
   end
   
	
   // Asychronous Empty Logic, used for asynchrnous wake
	
   assign async_empty	= (wr_ptr == rd_ptr_on_wr);
	
   
   // FIFO utilization used by Dynamic Voltage and Frequency Scaling logic %%%
   wire [6:0] fifo_util_temp;
   assign fifo_util_temp = wr_ptr - rd_ptr - 1;
   
   reg [1:0] fifo_util;
   always @ ( fifo_util_temp )
   begin
       if( fifo_util_temp[6] == 1'b1 ) begin	// util = 64
          fifo_util = 2'b11;
       end
       else begin
          fifo_util = fifo_util_temp[5:4];	// util = 0 to 63
       end
   end


endmodule
`endcelldefine


`celldefine
