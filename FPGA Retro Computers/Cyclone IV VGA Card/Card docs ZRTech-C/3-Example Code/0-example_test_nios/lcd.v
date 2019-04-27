//Legal Notice: (C)2013 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module lcd (
             // inputs:
              address,
              begintransfer,
              clk,
              read,
              reset_n,
              write,
              writedata,

             // outputs:
              LCD_E,
              LCD_RS,
              LCD_RW,
              LCD_data,
              readdata
           )
;

  output           LCD_E;
  output           LCD_RS;
  output           LCD_RW;
  inout   [  7: 0] LCD_data;
  output  [  7: 0] readdata;
  input   [  1: 0] address;
  input            begintransfer;
  input            clk;
  input            read;
  input            reset_n;
  input            write;
  input   [  7: 0] writedata;

  wire             LCD_E;
  wire             LCD_RS;
  wire             LCD_RW;
  wire    [  7: 0] LCD_data;
  wire    [  7: 0] readdata;
  assign LCD_RW = address[0];
  assign LCD_RS = address[1];
  assign LCD_E = read | write;
  assign LCD_data = (address[0]) ? 8'bz : writedata;
  assign readdata = LCD_data;
  //control_slave, which is an e_avalon_slave

endmodule

