//megafunction wizard: %Altera SOPC Builder%
//GENERATION: STANDARD
//VERSION: WM1.0


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

module beep_s1_arbitrator (
                            // inputs:
                             beep_s1_readdata,
                             clk,
                             cpu_data_master_address_to_slave,
                             cpu_data_master_read,
                             cpu_data_master_waitrequest,
                             cpu_data_master_write,
                             cpu_data_master_writedata,
                             reset_n,

                            // outputs:
                             beep_s1_address,
                             beep_s1_chipselect,
                             beep_s1_readdata_from_sa,
                             beep_s1_reset_n,
                             beep_s1_write_n,
                             beep_s1_writedata,
                             cpu_data_master_granted_beep_s1,
                             cpu_data_master_qualified_request_beep_s1,
                             cpu_data_master_read_data_valid_beep_s1,
                             cpu_data_master_requests_beep_s1,
                             d1_beep_s1_end_xfer
                          )
;

  output  [  1: 0] beep_s1_address;
  output           beep_s1_chipselect;
  output  [ 31: 0] beep_s1_readdata_from_sa;
  output           beep_s1_reset_n;
  output           beep_s1_write_n;
  output  [ 31: 0] beep_s1_writedata;
  output           cpu_data_master_granted_beep_s1;
  output           cpu_data_master_qualified_request_beep_s1;
  output           cpu_data_master_read_data_valid_beep_s1;
  output           cpu_data_master_requests_beep_s1;
  output           d1_beep_s1_end_xfer;
  input   [ 31: 0] beep_s1_readdata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;

  wire    [  1: 0] beep_s1_address;
  wire             beep_s1_allgrants;
  wire             beep_s1_allow_new_arb_cycle;
  wire             beep_s1_any_bursting_master_saved_grant;
  wire             beep_s1_any_continuerequest;
  wire             beep_s1_arb_counter_enable;
  reg     [  1: 0] beep_s1_arb_share_counter;
  wire    [  1: 0] beep_s1_arb_share_counter_next_value;
  wire    [  1: 0] beep_s1_arb_share_set_values;
  wire             beep_s1_beginbursttransfer_internal;
  wire             beep_s1_begins_xfer;
  wire             beep_s1_chipselect;
  wire             beep_s1_end_xfer;
  wire             beep_s1_firsttransfer;
  wire             beep_s1_grant_vector;
  wire             beep_s1_in_a_read_cycle;
  wire             beep_s1_in_a_write_cycle;
  wire             beep_s1_master_qreq_vector;
  wire             beep_s1_non_bursting_master_requests;
  wire    [ 31: 0] beep_s1_readdata_from_sa;
  reg              beep_s1_reg_firsttransfer;
  wire             beep_s1_reset_n;
  reg              beep_s1_slavearbiterlockenable;
  wire             beep_s1_slavearbiterlockenable2;
  wire             beep_s1_unreg_firsttransfer;
  wire             beep_s1_waits_for_read;
  wire             beep_s1_waits_for_write;
  wire             beep_s1_write_n;
  wire    [ 31: 0] beep_s1_writedata;
  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_beep_s1;
  wire             cpu_data_master_qualified_request_beep_s1;
  wire             cpu_data_master_read_data_valid_beep_s1;
  wire             cpu_data_master_requests_beep_s1;
  wire             cpu_data_master_saved_grant_beep_s1;
  reg              d1_beep_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_beep_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_beep_s1_from_cpu_data_master;
  wire             wait_for_beep_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~beep_s1_end_xfer;
    end


  assign beep_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_beep_s1));
  //assign beep_s1_readdata_from_sa = beep_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign beep_s1_readdata_from_sa = beep_s1_readdata;

  assign cpu_data_master_requests_beep_s1 = ({cpu_data_master_address_to_slave[26 : 4] , 4'b0} == 27'h3950) & (cpu_data_master_read | cpu_data_master_write);
  //beep_s1_arb_share_counter set values, which is an e_mux
  assign beep_s1_arb_share_set_values = 1;

  //beep_s1_non_bursting_master_requests mux, which is an e_mux
  assign beep_s1_non_bursting_master_requests = cpu_data_master_requests_beep_s1;

  //beep_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign beep_s1_any_bursting_master_saved_grant = 0;

  //beep_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign beep_s1_arb_share_counter_next_value = beep_s1_firsttransfer ? (beep_s1_arb_share_set_values - 1) : |beep_s1_arb_share_counter ? (beep_s1_arb_share_counter - 1) : 0;

  //beep_s1_allgrants all slave grants, which is an e_mux
  assign beep_s1_allgrants = |beep_s1_grant_vector;

  //beep_s1_end_xfer assignment, which is an e_assign
  assign beep_s1_end_xfer = ~(beep_s1_waits_for_read | beep_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_beep_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_beep_s1 = beep_s1_end_xfer & (~beep_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //beep_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign beep_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_beep_s1 & beep_s1_allgrants) | (end_xfer_arb_share_counter_term_beep_s1 & ~beep_s1_non_bursting_master_requests);

  //beep_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          beep_s1_arb_share_counter <= 0;
      else if (beep_s1_arb_counter_enable)
          beep_s1_arb_share_counter <= beep_s1_arb_share_counter_next_value;
    end


  //beep_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          beep_s1_slavearbiterlockenable <= 0;
      else if ((|beep_s1_master_qreq_vector & end_xfer_arb_share_counter_term_beep_s1) | (end_xfer_arb_share_counter_term_beep_s1 & ~beep_s1_non_bursting_master_requests))
          beep_s1_slavearbiterlockenable <= |beep_s1_arb_share_counter_next_value;
    end


  //cpu/data_master beep/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = beep_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //beep_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign beep_s1_slavearbiterlockenable2 = |beep_s1_arb_share_counter_next_value;

  //cpu/data_master beep/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = beep_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //beep_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign beep_s1_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_beep_s1 = cpu_data_master_requests_beep_s1 & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //beep_s1_writedata mux, which is an e_mux
  assign beep_s1_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_beep_s1 = cpu_data_master_qualified_request_beep_s1;

  //cpu/data_master saved-grant beep/s1, which is an e_assign
  assign cpu_data_master_saved_grant_beep_s1 = cpu_data_master_requests_beep_s1;

  //allow new arb cycle for beep/s1, which is an e_assign
  assign beep_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign beep_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign beep_s1_master_qreq_vector = 1;

  //beep_s1_reset_n assignment, which is an e_assign
  assign beep_s1_reset_n = reset_n;

  assign beep_s1_chipselect = cpu_data_master_granted_beep_s1;
  //beep_s1_firsttransfer first transaction, which is an e_assign
  assign beep_s1_firsttransfer = beep_s1_begins_xfer ? beep_s1_unreg_firsttransfer : beep_s1_reg_firsttransfer;

  //beep_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign beep_s1_unreg_firsttransfer = ~(beep_s1_slavearbiterlockenable & beep_s1_any_continuerequest);

  //beep_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          beep_s1_reg_firsttransfer <= 1'b1;
      else if (beep_s1_begins_xfer)
          beep_s1_reg_firsttransfer <= beep_s1_unreg_firsttransfer;
    end


  //beep_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign beep_s1_beginbursttransfer_internal = beep_s1_begins_xfer;

  //~beep_s1_write_n assignment, which is an e_mux
  assign beep_s1_write_n = ~(cpu_data_master_granted_beep_s1 & cpu_data_master_write);

  assign shifted_address_to_beep_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //beep_s1_address mux, which is an e_mux
  assign beep_s1_address = shifted_address_to_beep_s1_from_cpu_data_master >> 2;

  //d1_beep_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_beep_s1_end_xfer <= 1;
      else 
        d1_beep_s1_end_xfer <= beep_s1_end_xfer;
    end


  //beep_s1_waits_for_read in a cycle, which is an e_mux
  assign beep_s1_waits_for_read = beep_s1_in_a_read_cycle & beep_s1_begins_xfer;

  //beep_s1_in_a_read_cycle assignment, which is an e_assign
  assign beep_s1_in_a_read_cycle = cpu_data_master_granted_beep_s1 & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = beep_s1_in_a_read_cycle;

  //beep_s1_waits_for_write in a cycle, which is an e_mux
  assign beep_s1_waits_for_write = beep_s1_in_a_write_cycle & 0;

  //beep_s1_in_a_write_cycle assignment, which is an e_assign
  assign beep_s1_in_a_write_cycle = cpu_data_master_granted_beep_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = beep_s1_in_a_write_cycle;

  assign wait_for_beep_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //beep/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_jtag_debug_module_arbitrator (
                                          // inputs:
                                           clk,
                                           cpu_data_master_address_to_slave,
                                           cpu_data_master_byteenable,
                                           cpu_data_master_debugaccess,
                                           cpu_data_master_read,
                                           cpu_data_master_waitrequest,
                                           cpu_data_master_write,
                                           cpu_data_master_writedata,
                                           cpu_instruction_master_address_to_slave,
                                           cpu_instruction_master_latency_counter,
                                           cpu_instruction_master_read,
                                           cpu_instruction_master_read_data_valid_sdram_s1_shift_register,
                                           cpu_jtag_debug_module_readdata,
                                           cpu_jtag_debug_module_resetrequest,
                                           reset_n,

                                          // outputs:
                                           cpu_data_master_granted_cpu_jtag_debug_module,
                                           cpu_data_master_qualified_request_cpu_jtag_debug_module,
                                           cpu_data_master_read_data_valid_cpu_jtag_debug_module,
                                           cpu_data_master_requests_cpu_jtag_debug_module,
                                           cpu_instruction_master_granted_cpu_jtag_debug_module,
                                           cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
                                           cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
                                           cpu_instruction_master_requests_cpu_jtag_debug_module,
                                           cpu_jtag_debug_module_address,
                                           cpu_jtag_debug_module_begintransfer,
                                           cpu_jtag_debug_module_byteenable,
                                           cpu_jtag_debug_module_chipselect,
                                           cpu_jtag_debug_module_debugaccess,
                                           cpu_jtag_debug_module_readdata_from_sa,
                                           cpu_jtag_debug_module_reset_n,
                                           cpu_jtag_debug_module_resetrequest_from_sa,
                                           cpu_jtag_debug_module_write,
                                           cpu_jtag_debug_module_writedata,
                                           d1_cpu_jtag_debug_module_end_xfer
                                        )
;

  output           cpu_data_master_granted_cpu_jtag_debug_module;
  output           cpu_data_master_qualified_request_cpu_jtag_debug_module;
  output           cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  output           cpu_data_master_requests_cpu_jtag_debug_module;
  output           cpu_instruction_master_granted_cpu_jtag_debug_module;
  output           cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  output           cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  output           cpu_instruction_master_requests_cpu_jtag_debug_module;
  output  [  8: 0] cpu_jtag_debug_module_address;
  output           cpu_jtag_debug_module_begintransfer;
  output  [  3: 0] cpu_jtag_debug_module_byteenable;
  output           cpu_jtag_debug_module_chipselect;
  output           cpu_jtag_debug_module_debugaccess;
  output  [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  output           cpu_jtag_debug_module_reset_n;
  output           cpu_jtag_debug_module_resetrequest_from_sa;
  output           cpu_jtag_debug_module_write;
  output  [ 31: 0] cpu_jtag_debug_module_writedata;
  output           d1_cpu_jtag_debug_module_end_xfer;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input   [  3: 0] cpu_data_master_byteenable;
  input            cpu_data_master_debugaccess;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 26: 0] cpu_instruction_master_address_to_slave;
  input            cpu_instruction_master_latency_counter;
  input            cpu_instruction_master_read;
  input            cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  input   [ 31: 0] cpu_jtag_debug_module_readdata;
  input            cpu_jtag_debug_module_resetrequest;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_cpu_jtag_debug_module;
  wire             cpu_data_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_data_master_requests_cpu_jtag_debug_module;
  wire             cpu_data_master_saved_grant_cpu_jtag_debug_module;
  wire             cpu_instruction_master_arbiterlock;
  wire             cpu_instruction_master_arbiterlock2;
  wire             cpu_instruction_master_continuerequest;
  wire             cpu_instruction_master_granted_cpu_jtag_debug_module;
  wire             cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_instruction_master_requests_cpu_jtag_debug_module;
  wire             cpu_instruction_master_saved_grant_cpu_jtag_debug_module;
  wire    [  8: 0] cpu_jtag_debug_module_address;
  wire             cpu_jtag_debug_module_allgrants;
  wire             cpu_jtag_debug_module_allow_new_arb_cycle;
  wire             cpu_jtag_debug_module_any_bursting_master_saved_grant;
  wire             cpu_jtag_debug_module_any_continuerequest;
  reg     [  1: 0] cpu_jtag_debug_module_arb_addend;
  wire             cpu_jtag_debug_module_arb_counter_enable;
  reg     [  1: 0] cpu_jtag_debug_module_arb_share_counter;
  wire    [  1: 0] cpu_jtag_debug_module_arb_share_counter_next_value;
  wire    [  1: 0] cpu_jtag_debug_module_arb_share_set_values;
  wire    [  1: 0] cpu_jtag_debug_module_arb_winner;
  wire             cpu_jtag_debug_module_arbitration_holdoff_internal;
  wire             cpu_jtag_debug_module_beginbursttransfer_internal;
  wire             cpu_jtag_debug_module_begins_xfer;
  wire             cpu_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_jtag_debug_module_byteenable;
  wire             cpu_jtag_debug_module_chipselect;
  wire    [  3: 0] cpu_jtag_debug_module_chosen_master_double_vector;
  wire    [  1: 0] cpu_jtag_debug_module_chosen_master_rot_left;
  wire             cpu_jtag_debug_module_debugaccess;
  wire             cpu_jtag_debug_module_end_xfer;
  wire             cpu_jtag_debug_module_firsttransfer;
  wire    [  1: 0] cpu_jtag_debug_module_grant_vector;
  wire             cpu_jtag_debug_module_in_a_read_cycle;
  wire             cpu_jtag_debug_module_in_a_write_cycle;
  wire    [  1: 0] cpu_jtag_debug_module_master_qreq_vector;
  wire             cpu_jtag_debug_module_non_bursting_master_requests;
  wire    [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  reg              cpu_jtag_debug_module_reg_firsttransfer;
  wire             cpu_jtag_debug_module_reset_n;
  wire             cpu_jtag_debug_module_resetrequest_from_sa;
  reg     [  1: 0] cpu_jtag_debug_module_saved_chosen_master_vector;
  reg              cpu_jtag_debug_module_slavearbiterlockenable;
  wire             cpu_jtag_debug_module_slavearbiterlockenable2;
  wire             cpu_jtag_debug_module_unreg_firsttransfer;
  wire             cpu_jtag_debug_module_waits_for_read;
  wire             cpu_jtag_debug_module_waits_for_write;
  wire             cpu_jtag_debug_module_write;
  wire    [ 31: 0] cpu_jtag_debug_module_writedata;
  reg              d1_cpu_jtag_debug_module_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_cpu_jtag_debug_module;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module;
  reg              last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module;
  wire    [ 26: 0] shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master;
  wire    [ 26: 0] shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master;
  wire             wait_for_cpu_jtag_debug_module_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~cpu_jtag_debug_module_end_xfer;
    end


  assign cpu_jtag_debug_module_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_cpu_jtag_debug_module | cpu_instruction_master_qualified_request_cpu_jtag_debug_module));
  //assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata;

  assign cpu_data_master_requests_cpu_jtag_debug_module = ({cpu_data_master_address_to_slave[26 : 11] , 11'b0} == 27'h3000) & (cpu_data_master_read | cpu_data_master_write);
  //cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  assign cpu_jtag_debug_module_arb_share_set_values = 1;

  //cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  assign cpu_jtag_debug_module_non_bursting_master_requests = cpu_data_master_requests_cpu_jtag_debug_module |
    cpu_instruction_master_requests_cpu_jtag_debug_module |
    cpu_data_master_requests_cpu_jtag_debug_module |
    cpu_instruction_master_requests_cpu_jtag_debug_module;

  //cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  assign cpu_jtag_debug_module_any_bursting_master_saved_grant = 0;

  //cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  assign cpu_jtag_debug_module_arb_share_counter_next_value = cpu_jtag_debug_module_firsttransfer ? (cpu_jtag_debug_module_arb_share_set_values - 1) : |cpu_jtag_debug_module_arb_share_counter ? (cpu_jtag_debug_module_arb_share_counter - 1) : 0;

  //cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  assign cpu_jtag_debug_module_allgrants = (|cpu_jtag_debug_module_grant_vector) |
    (|cpu_jtag_debug_module_grant_vector) |
    (|cpu_jtag_debug_module_grant_vector) |
    (|cpu_jtag_debug_module_grant_vector);

  //cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  assign cpu_jtag_debug_module_end_xfer = ~(cpu_jtag_debug_module_waits_for_read | cpu_jtag_debug_module_waits_for_write);

  //end_xfer_arb_share_counter_term_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_cpu_jtag_debug_module = cpu_jtag_debug_module_end_xfer & (~cpu_jtag_debug_module_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  assign cpu_jtag_debug_module_arb_counter_enable = (end_xfer_arb_share_counter_term_cpu_jtag_debug_module & cpu_jtag_debug_module_allgrants) | (end_xfer_arb_share_counter_term_cpu_jtag_debug_module & ~cpu_jtag_debug_module_non_bursting_master_requests);

  //cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_arb_share_counter <= 0;
      else if (cpu_jtag_debug_module_arb_counter_enable)
          cpu_jtag_debug_module_arb_share_counter <= cpu_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_slavearbiterlockenable <= 0;
      else if ((|cpu_jtag_debug_module_master_qreq_vector & end_xfer_arb_share_counter_term_cpu_jtag_debug_module) | (end_xfer_arb_share_counter_term_cpu_jtag_debug_module & ~cpu_jtag_debug_module_non_bursting_master_requests))
          cpu_jtag_debug_module_slavearbiterlockenable <= |cpu_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu/data_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = cpu_jtag_debug_module_slavearbiterlockenable & cpu_data_master_continuerequest;

  //cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign cpu_jtag_debug_module_slavearbiterlockenable2 = |cpu_jtag_debug_module_arb_share_counter_next_value;

  //cpu/data_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = cpu_jtag_debug_module_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //cpu/instruction_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_instruction_master_arbiterlock = cpu_jtag_debug_module_slavearbiterlockenable & cpu_instruction_master_continuerequest;

  //cpu/instruction_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_instruction_master_arbiterlock2 = cpu_jtag_debug_module_slavearbiterlockenable2 & cpu_instruction_master_continuerequest;

  //cpu/instruction_master granted cpu/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= cpu_instruction_master_saved_grant_cpu_jtag_debug_module ? 1 : (cpu_jtag_debug_module_arbitration_holdoff_internal | ~cpu_instruction_master_requests_cpu_jtag_debug_module) ? 0 : last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module;
    end


  //cpu_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_instruction_master_continuerequest = last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module & cpu_instruction_master_requests_cpu_jtag_debug_module;

  //cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  assign cpu_jtag_debug_module_any_continuerequest = cpu_instruction_master_continuerequest |
    cpu_data_master_continuerequest;

  assign cpu_data_master_qualified_request_cpu_jtag_debug_module = cpu_data_master_requests_cpu_jtag_debug_module & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write) | cpu_instruction_master_arbiterlock);
  //cpu_jtag_debug_module_writedata mux, which is an e_mux
  assign cpu_jtag_debug_module_writedata = cpu_data_master_writedata;

  assign cpu_instruction_master_requests_cpu_jtag_debug_module = (({cpu_instruction_master_address_to_slave[26 : 11] , 11'b0} == 27'h3000) & (cpu_instruction_master_read)) & cpu_instruction_master_read;
  //cpu/data_master granted cpu/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= cpu_data_master_saved_grant_cpu_jtag_debug_module ? 1 : (cpu_jtag_debug_module_arbitration_holdoff_internal | ~cpu_data_master_requests_cpu_jtag_debug_module) ? 0 : last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module;
    end


  //cpu_data_master_continuerequest continued request, which is an e_mux
  assign cpu_data_master_continuerequest = last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module & cpu_data_master_requests_cpu_jtag_debug_module;

  assign cpu_instruction_master_qualified_request_cpu_jtag_debug_module = cpu_instruction_master_requests_cpu_jtag_debug_module & ~((cpu_instruction_master_read & ((cpu_instruction_master_latency_counter != 0) | (|cpu_instruction_master_read_data_valid_sdram_s1_shift_register))) | cpu_data_master_arbiterlock);
  //local readdatavalid cpu_instruction_master_read_data_valid_cpu_jtag_debug_module, which is an e_mux
  assign cpu_instruction_master_read_data_valid_cpu_jtag_debug_module = cpu_instruction_master_granted_cpu_jtag_debug_module & cpu_instruction_master_read & ~cpu_jtag_debug_module_waits_for_read;

  //allow new arb cycle for cpu/jtag_debug_module, which is an e_assign
  assign cpu_jtag_debug_module_allow_new_arb_cycle = ~cpu_data_master_arbiterlock & ~cpu_instruction_master_arbiterlock;

  //cpu/instruction_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  assign cpu_jtag_debug_module_master_qreq_vector[0] = cpu_instruction_master_qualified_request_cpu_jtag_debug_module;

  //cpu/instruction_master grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_instruction_master_granted_cpu_jtag_debug_module = cpu_jtag_debug_module_grant_vector[0];

  //cpu/instruction_master saved-grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_instruction_master_saved_grant_cpu_jtag_debug_module = cpu_jtag_debug_module_arb_winner[0] && cpu_instruction_master_requests_cpu_jtag_debug_module;

  //cpu/data_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  assign cpu_jtag_debug_module_master_qreq_vector[1] = cpu_data_master_qualified_request_cpu_jtag_debug_module;

  //cpu/data_master grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_data_master_granted_cpu_jtag_debug_module = cpu_jtag_debug_module_grant_vector[1];

  //cpu/data_master saved-grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_data_master_saved_grant_cpu_jtag_debug_module = cpu_jtag_debug_module_arb_winner[1] && cpu_data_master_requests_cpu_jtag_debug_module;

  //cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  assign cpu_jtag_debug_module_chosen_master_double_vector = {cpu_jtag_debug_module_master_qreq_vector, cpu_jtag_debug_module_master_qreq_vector} & ({~cpu_jtag_debug_module_master_qreq_vector, ~cpu_jtag_debug_module_master_qreq_vector} + cpu_jtag_debug_module_arb_addend);

  //stable onehot encoding of arb winner
  assign cpu_jtag_debug_module_arb_winner = (cpu_jtag_debug_module_allow_new_arb_cycle & | cpu_jtag_debug_module_grant_vector) ? cpu_jtag_debug_module_grant_vector : cpu_jtag_debug_module_saved_chosen_master_vector;

  //saved cpu_jtag_debug_module_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_saved_chosen_master_vector <= 0;
      else if (cpu_jtag_debug_module_allow_new_arb_cycle)
          cpu_jtag_debug_module_saved_chosen_master_vector <= |cpu_jtag_debug_module_grant_vector ? cpu_jtag_debug_module_grant_vector : cpu_jtag_debug_module_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign cpu_jtag_debug_module_grant_vector = {(cpu_jtag_debug_module_chosen_master_double_vector[1] | cpu_jtag_debug_module_chosen_master_double_vector[3]),
    (cpu_jtag_debug_module_chosen_master_double_vector[0] | cpu_jtag_debug_module_chosen_master_double_vector[2])};

  //cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  assign cpu_jtag_debug_module_chosen_master_rot_left = (cpu_jtag_debug_module_arb_winner << 1) ? (cpu_jtag_debug_module_arb_winner << 1) : 1;

  //cpu/jtag_debug_module's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_arb_addend <= 1;
      else if (|cpu_jtag_debug_module_grant_vector)
          cpu_jtag_debug_module_arb_addend <= cpu_jtag_debug_module_end_xfer? cpu_jtag_debug_module_chosen_master_rot_left : cpu_jtag_debug_module_grant_vector;
    end


  assign cpu_jtag_debug_module_begintransfer = cpu_jtag_debug_module_begins_xfer;
  //cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  assign cpu_jtag_debug_module_reset_n = reset_n;

  //assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest;

  assign cpu_jtag_debug_module_chipselect = cpu_data_master_granted_cpu_jtag_debug_module | cpu_instruction_master_granted_cpu_jtag_debug_module;
  //cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  assign cpu_jtag_debug_module_firsttransfer = cpu_jtag_debug_module_begins_xfer ? cpu_jtag_debug_module_unreg_firsttransfer : cpu_jtag_debug_module_reg_firsttransfer;

  //cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  assign cpu_jtag_debug_module_unreg_firsttransfer = ~(cpu_jtag_debug_module_slavearbiterlockenable & cpu_jtag_debug_module_any_continuerequest);

  //cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_reg_firsttransfer <= 1'b1;
      else if (cpu_jtag_debug_module_begins_xfer)
          cpu_jtag_debug_module_reg_firsttransfer <= cpu_jtag_debug_module_unreg_firsttransfer;
    end


  //cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign cpu_jtag_debug_module_beginbursttransfer_internal = cpu_jtag_debug_module_begins_xfer;

  //cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign cpu_jtag_debug_module_arbitration_holdoff_internal = cpu_jtag_debug_module_begins_xfer & cpu_jtag_debug_module_firsttransfer;

  //cpu_jtag_debug_module_write assignment, which is an e_mux
  assign cpu_jtag_debug_module_write = cpu_data_master_granted_cpu_jtag_debug_module & cpu_data_master_write;

  assign shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master = cpu_data_master_address_to_slave;
  //cpu_jtag_debug_module_address mux, which is an e_mux
  assign cpu_jtag_debug_module_address = (cpu_data_master_granted_cpu_jtag_debug_module)? (shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master >> 2) :
    (shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master >> 2);

  assign shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master = cpu_instruction_master_address_to_slave;
  //d1_cpu_jtag_debug_module_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_cpu_jtag_debug_module_end_xfer <= 1;
      else 
        d1_cpu_jtag_debug_module_end_xfer <= cpu_jtag_debug_module_end_xfer;
    end


  //cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  assign cpu_jtag_debug_module_waits_for_read = cpu_jtag_debug_module_in_a_read_cycle & cpu_jtag_debug_module_begins_xfer;

  //cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  assign cpu_jtag_debug_module_in_a_read_cycle = (cpu_data_master_granted_cpu_jtag_debug_module & cpu_data_master_read) | (cpu_instruction_master_granted_cpu_jtag_debug_module & cpu_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = cpu_jtag_debug_module_in_a_read_cycle;

  //cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  assign cpu_jtag_debug_module_waits_for_write = cpu_jtag_debug_module_in_a_write_cycle & 0;

  //cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  assign cpu_jtag_debug_module_in_a_write_cycle = cpu_data_master_granted_cpu_jtag_debug_module & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = cpu_jtag_debug_module_in_a_write_cycle;

  assign wait_for_cpu_jtag_debug_module_counter = 0;
  //cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  assign cpu_jtag_debug_module_byteenable = (cpu_data_master_granted_cpu_jtag_debug_module)? cpu_data_master_byteenable :
    -1;

  //debugaccess mux, which is an e_mux
  assign cpu_jtag_debug_module_debugaccess = (cpu_data_master_granted_cpu_jtag_debug_module)? cpu_data_master_debugaccess :
    0;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu/jtag_debug_module enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_granted_cpu_jtag_debug_module + cpu_instruction_master_granted_cpu_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_saved_grant_cpu_jtag_debug_module + cpu_instruction_master_saved_grant_cpu_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_data_master_arbitrator (
                                    // inputs:
                                     beep_s1_readdata_from_sa,
                                     clk,
                                     cpu_data_master_address,
                                     cpu_data_master_byteenable_sdram_s1,
                                     cpu_data_master_granted_beep_s1,
                                     cpu_data_master_granted_cpu_jtag_debug_module,
                                     cpu_data_master_granted_epcs_controller_epcs_control_port,
                                     cpu_data_master_granted_high_res_timer_s1,
                                     cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_granted_key_s1,
                                     cpu_data_master_granted_lcd_control_slave,
                                     cpu_data_master_granted_led_s1,
                                     cpu_data_master_granted_onchip_ram_s1,
                                     cpu_data_master_granted_sdram_s1,
                                     cpu_data_master_granted_spi_adc_spi_control_port,
                                     cpu_data_master_granted_spi_flash_spi_control_port,
                                     cpu_data_master_granted_sys_clk_timer_s1,
                                     cpu_data_master_granted_sysid_control_slave,
                                     cpu_data_master_granted_uart_s1,
                                     cpu_data_master_qualified_request_beep_s1,
                                     cpu_data_master_qualified_request_cpu_jtag_debug_module,
                                     cpu_data_master_qualified_request_epcs_controller_epcs_control_port,
                                     cpu_data_master_qualified_request_high_res_timer_s1,
                                     cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_qualified_request_key_s1,
                                     cpu_data_master_qualified_request_lcd_control_slave,
                                     cpu_data_master_qualified_request_led_s1,
                                     cpu_data_master_qualified_request_onchip_ram_s1,
                                     cpu_data_master_qualified_request_sdram_s1,
                                     cpu_data_master_qualified_request_spi_adc_spi_control_port,
                                     cpu_data_master_qualified_request_spi_flash_spi_control_port,
                                     cpu_data_master_qualified_request_sys_clk_timer_s1,
                                     cpu_data_master_qualified_request_sysid_control_slave,
                                     cpu_data_master_qualified_request_uart_s1,
                                     cpu_data_master_read,
                                     cpu_data_master_read_data_valid_beep_s1,
                                     cpu_data_master_read_data_valid_cpu_jtag_debug_module,
                                     cpu_data_master_read_data_valid_epcs_controller_epcs_control_port,
                                     cpu_data_master_read_data_valid_high_res_timer_s1,
                                     cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_read_data_valid_key_s1,
                                     cpu_data_master_read_data_valid_lcd_control_slave,
                                     cpu_data_master_read_data_valid_led_s1,
                                     cpu_data_master_read_data_valid_onchip_ram_s1,
                                     cpu_data_master_read_data_valid_sdram_s1,
                                     cpu_data_master_read_data_valid_sdram_s1_shift_register,
                                     cpu_data_master_read_data_valid_spi_adc_spi_control_port,
                                     cpu_data_master_read_data_valid_spi_flash_spi_control_port,
                                     cpu_data_master_read_data_valid_sys_clk_timer_s1,
                                     cpu_data_master_read_data_valid_sysid_control_slave,
                                     cpu_data_master_read_data_valid_uart_s1,
                                     cpu_data_master_requests_beep_s1,
                                     cpu_data_master_requests_cpu_jtag_debug_module,
                                     cpu_data_master_requests_epcs_controller_epcs_control_port,
                                     cpu_data_master_requests_high_res_timer_s1,
                                     cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_requests_key_s1,
                                     cpu_data_master_requests_lcd_control_slave,
                                     cpu_data_master_requests_led_s1,
                                     cpu_data_master_requests_onchip_ram_s1,
                                     cpu_data_master_requests_sdram_s1,
                                     cpu_data_master_requests_spi_adc_spi_control_port,
                                     cpu_data_master_requests_spi_flash_spi_control_port,
                                     cpu_data_master_requests_sys_clk_timer_s1,
                                     cpu_data_master_requests_sysid_control_slave,
                                     cpu_data_master_requests_uart_s1,
                                     cpu_data_master_write,
                                     cpu_data_master_writedata,
                                     cpu_jtag_debug_module_readdata_from_sa,
                                     d1_beep_s1_end_xfer,
                                     d1_cpu_jtag_debug_module_end_xfer,
                                     d1_epcs_controller_epcs_control_port_end_xfer,
                                     d1_high_res_timer_s1_end_xfer,
                                     d1_jtag_uart_avalon_jtag_slave_end_xfer,
                                     d1_key_s1_end_xfer,
                                     d1_lcd_control_slave_end_xfer,
                                     d1_led_s1_end_xfer,
                                     d1_onchip_ram_s1_end_xfer,
                                     d1_sdram_s1_end_xfer,
                                     d1_spi_adc_spi_control_port_end_xfer,
                                     d1_spi_flash_spi_control_port_end_xfer,
                                     d1_sys_clk_timer_s1_end_xfer,
                                     d1_sysid_control_slave_end_xfer,
                                     d1_uart_s1_end_xfer,
                                     epcs_controller_epcs_control_port_irq_from_sa,
                                     epcs_controller_epcs_control_port_readdata_from_sa,
                                     high_res_timer_s1_irq_from_sa,
                                     high_res_timer_s1_readdata_from_sa,
                                     jtag_uart_avalon_jtag_slave_irq_from_sa,
                                     jtag_uart_avalon_jtag_slave_readdata_from_sa,
                                     jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
                                     key_s1_irq_from_sa,
                                     key_s1_readdata_from_sa,
                                     lcd_control_slave_readdata_from_sa,
                                     lcd_control_slave_wait_counter_eq_0,
                                     lcd_control_slave_wait_counter_eq_1,
                                     led_s1_readdata_from_sa,
                                     onchip_ram_s1_readdata_from_sa,
                                     registered_cpu_data_master_read_data_valid_onchip_ram_s1,
                                     reset_n,
                                     sdram_s1_readdata_from_sa,
                                     sdram_s1_waitrequest_from_sa,
                                     spi_adc_spi_control_port_irq_from_sa,
                                     spi_adc_spi_control_port_readdata_from_sa,
                                     spi_flash_spi_control_port_irq_from_sa,
                                     spi_flash_spi_control_port_readdata_from_sa,
                                     sys_clk_timer_s1_irq_from_sa,
                                     sys_clk_timer_s1_readdata_from_sa,
                                     sysid_control_slave_readdata_from_sa,
                                     uart_s1_irq_from_sa,
                                     uart_s1_readdata_from_sa,

                                    // outputs:
                                     cpu_data_master_address_to_slave,
                                     cpu_data_master_dbs_address,
                                     cpu_data_master_dbs_write_16,
                                     cpu_data_master_irq,
                                     cpu_data_master_no_byte_enables_and_last_term,
                                     cpu_data_master_readdata,
                                     cpu_data_master_waitrequest
                                  )
;

  output  [ 26: 0] cpu_data_master_address_to_slave;
  output  [  1: 0] cpu_data_master_dbs_address;
  output  [ 15: 0] cpu_data_master_dbs_write_16;
  output  [ 31: 0] cpu_data_master_irq;
  output           cpu_data_master_no_byte_enables_and_last_term;
  output  [ 31: 0] cpu_data_master_readdata;
  output           cpu_data_master_waitrequest;
  input   [ 31: 0] beep_s1_readdata_from_sa;
  input            clk;
  input   [ 26: 0] cpu_data_master_address;
  input   [  1: 0] cpu_data_master_byteenable_sdram_s1;
  input            cpu_data_master_granted_beep_s1;
  input            cpu_data_master_granted_cpu_jtag_debug_module;
  input            cpu_data_master_granted_epcs_controller_epcs_control_port;
  input            cpu_data_master_granted_high_res_timer_s1;
  input            cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_granted_key_s1;
  input            cpu_data_master_granted_lcd_control_slave;
  input            cpu_data_master_granted_led_s1;
  input            cpu_data_master_granted_onchip_ram_s1;
  input            cpu_data_master_granted_sdram_s1;
  input            cpu_data_master_granted_spi_adc_spi_control_port;
  input            cpu_data_master_granted_spi_flash_spi_control_port;
  input            cpu_data_master_granted_sys_clk_timer_s1;
  input            cpu_data_master_granted_sysid_control_slave;
  input            cpu_data_master_granted_uart_s1;
  input            cpu_data_master_qualified_request_beep_s1;
  input            cpu_data_master_qualified_request_cpu_jtag_debug_module;
  input            cpu_data_master_qualified_request_epcs_controller_epcs_control_port;
  input            cpu_data_master_qualified_request_high_res_timer_s1;
  input            cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_qualified_request_key_s1;
  input            cpu_data_master_qualified_request_lcd_control_slave;
  input            cpu_data_master_qualified_request_led_s1;
  input            cpu_data_master_qualified_request_onchip_ram_s1;
  input            cpu_data_master_qualified_request_sdram_s1;
  input            cpu_data_master_qualified_request_spi_adc_spi_control_port;
  input            cpu_data_master_qualified_request_spi_flash_spi_control_port;
  input            cpu_data_master_qualified_request_sys_clk_timer_s1;
  input            cpu_data_master_qualified_request_sysid_control_slave;
  input            cpu_data_master_qualified_request_uart_s1;
  input            cpu_data_master_read;
  input            cpu_data_master_read_data_valid_beep_s1;
  input            cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  input            cpu_data_master_read_data_valid_epcs_controller_epcs_control_port;
  input            cpu_data_master_read_data_valid_high_res_timer_s1;
  input            cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_read_data_valid_key_s1;
  input            cpu_data_master_read_data_valid_lcd_control_slave;
  input            cpu_data_master_read_data_valid_led_s1;
  input            cpu_data_master_read_data_valid_onchip_ram_s1;
  input            cpu_data_master_read_data_valid_sdram_s1;
  input            cpu_data_master_read_data_valid_sdram_s1_shift_register;
  input            cpu_data_master_read_data_valid_spi_adc_spi_control_port;
  input            cpu_data_master_read_data_valid_spi_flash_spi_control_port;
  input            cpu_data_master_read_data_valid_sys_clk_timer_s1;
  input            cpu_data_master_read_data_valid_sysid_control_slave;
  input            cpu_data_master_read_data_valid_uart_s1;
  input            cpu_data_master_requests_beep_s1;
  input            cpu_data_master_requests_cpu_jtag_debug_module;
  input            cpu_data_master_requests_epcs_controller_epcs_control_port;
  input            cpu_data_master_requests_high_res_timer_s1;
  input            cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_requests_key_s1;
  input            cpu_data_master_requests_lcd_control_slave;
  input            cpu_data_master_requests_led_s1;
  input            cpu_data_master_requests_onchip_ram_s1;
  input            cpu_data_master_requests_sdram_s1;
  input            cpu_data_master_requests_spi_adc_spi_control_port;
  input            cpu_data_master_requests_spi_flash_spi_control_port;
  input            cpu_data_master_requests_sys_clk_timer_s1;
  input            cpu_data_master_requests_sysid_control_slave;
  input            cpu_data_master_requests_uart_s1;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  input            d1_beep_s1_end_xfer;
  input            d1_cpu_jtag_debug_module_end_xfer;
  input            d1_epcs_controller_epcs_control_port_end_xfer;
  input            d1_high_res_timer_s1_end_xfer;
  input            d1_jtag_uart_avalon_jtag_slave_end_xfer;
  input            d1_key_s1_end_xfer;
  input            d1_lcd_control_slave_end_xfer;
  input            d1_led_s1_end_xfer;
  input            d1_onchip_ram_s1_end_xfer;
  input            d1_sdram_s1_end_xfer;
  input            d1_spi_adc_spi_control_port_end_xfer;
  input            d1_spi_flash_spi_control_port_end_xfer;
  input            d1_sys_clk_timer_s1_end_xfer;
  input            d1_sysid_control_slave_end_xfer;
  input            d1_uart_s1_end_xfer;
  input            epcs_controller_epcs_control_port_irq_from_sa;
  input   [ 31: 0] epcs_controller_epcs_control_port_readdata_from_sa;
  input            high_res_timer_s1_irq_from_sa;
  input   [ 15: 0] high_res_timer_s1_readdata_from_sa;
  input            jtag_uart_avalon_jtag_slave_irq_from_sa;
  input   [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  input            jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  input            key_s1_irq_from_sa;
  input   [ 31: 0] key_s1_readdata_from_sa;
  input   [  7: 0] lcd_control_slave_readdata_from_sa;
  input            lcd_control_slave_wait_counter_eq_0;
  input            lcd_control_slave_wait_counter_eq_1;
  input   [ 31: 0] led_s1_readdata_from_sa;
  input   [ 31: 0] onchip_ram_s1_readdata_from_sa;
  input            registered_cpu_data_master_read_data_valid_onchip_ram_s1;
  input            reset_n;
  input   [ 15: 0] sdram_s1_readdata_from_sa;
  input            sdram_s1_waitrequest_from_sa;
  input            spi_adc_spi_control_port_irq_from_sa;
  input   [ 15: 0] spi_adc_spi_control_port_readdata_from_sa;
  input            spi_flash_spi_control_port_irq_from_sa;
  input   [ 15: 0] spi_flash_spi_control_port_readdata_from_sa;
  input            sys_clk_timer_s1_irq_from_sa;
  input   [ 15: 0] sys_clk_timer_s1_readdata_from_sa;
  input   [ 31: 0] sysid_control_slave_readdata_from_sa;
  input            uart_s1_irq_from_sa;
  input   [ 15: 0] uart_s1_readdata_from_sa;

  wire    [ 26: 0] cpu_data_master_address_to_slave;
  reg     [  1: 0] cpu_data_master_dbs_address;
  wire    [  1: 0] cpu_data_master_dbs_increment;
  wire    [ 15: 0] cpu_data_master_dbs_write_16;
  wire    [ 31: 0] cpu_data_master_irq;
  reg              cpu_data_master_no_byte_enables_and_last_term;
  wire    [ 31: 0] cpu_data_master_readdata;
  wire             cpu_data_master_run;
  reg              cpu_data_master_waitrequest;
  reg     [ 15: 0] dbs_16_reg_segment_0;
  wire             dbs_count_enable;
  wire             dbs_counter_overflow;
  wire             last_dbs_term_and_run;
  wire    [  1: 0] next_dbs_address;
  wire    [ 15: 0] p1_dbs_16_reg_segment_0;
  wire    [ 31: 0] p1_registered_cpu_data_master_readdata;
  wire             pre_dbs_count_enable;
  wire             r_0;
  wire             r_1;
  wire             r_2;
  reg     [ 31: 0] registered_cpu_data_master_readdata;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_data_master_qualified_request_beep_s1 | ~cpu_data_master_requests_beep_s1) & ((~cpu_data_master_qualified_request_beep_s1 | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_beep_s1 | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & (cpu_data_master_qualified_request_cpu_jtag_debug_module | ~cpu_data_master_requests_cpu_jtag_debug_module) & (cpu_data_master_granted_cpu_jtag_debug_module | ~cpu_data_master_qualified_request_cpu_jtag_debug_module) & ((~cpu_data_master_qualified_request_cpu_jtag_debug_module | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_cpu_jtag_debug_module | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & (cpu_data_master_qualified_request_epcs_controller_epcs_control_port | ~cpu_data_master_requests_epcs_controller_epcs_control_port) & (cpu_data_master_granted_epcs_controller_epcs_control_port | ~cpu_data_master_qualified_request_epcs_controller_epcs_control_port) & ((~cpu_data_master_qualified_request_epcs_controller_epcs_control_port | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_epcs_controller_epcs_control_port | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_high_res_timer_s1 | ~cpu_data_master_requests_high_res_timer_s1) & ((~cpu_data_master_qualified_request_high_res_timer_s1 | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_high_res_timer_s1 | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & (cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave | ~cpu_data_master_requests_jtag_uart_avalon_jtag_slave);

  //cascaded wait assignment, which is an e_assign
  assign cpu_data_master_run = r_0 & r_1 & r_2;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = ((~cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & ~jtag_uart_avalon_jtag_slave_waitrequest_from_sa & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & ~jtag_uart_avalon_jtag_slave_waitrequest_from_sa & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_key_s1 | ~cpu_data_master_requests_key_s1) & ((~cpu_data_master_qualified_request_key_s1 | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_key_s1 | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & ((~cpu_data_master_qualified_request_lcd_control_slave | ~cpu_data_master_read | (1 & lcd_control_slave_wait_counter_eq_1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_lcd_control_slave | ~cpu_data_master_write | (1 & lcd_control_slave_wait_counter_eq_1 & cpu_data_master_write))) & 1 & (cpu_data_master_qualified_request_led_s1 | ~cpu_data_master_requests_led_s1) & ((~cpu_data_master_qualified_request_led_s1 | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_led_s1 | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & (cpu_data_master_qualified_request_onchip_ram_s1 | registered_cpu_data_master_read_data_valid_onchip_ram_s1 | ~cpu_data_master_requests_onchip_ram_s1) & (cpu_data_master_granted_onchip_ram_s1 | ~cpu_data_master_qualified_request_onchip_ram_s1) & ((~cpu_data_master_qualified_request_onchip_ram_s1 | ~cpu_data_master_read | (registered_cpu_data_master_read_data_valid_onchip_ram_s1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_onchip_ram_s1 | ~(cpu_data_master_read | cpu_data_master_write) | (1 & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_sdram_s1 | (cpu_data_master_read_data_valid_sdram_s1 & cpu_data_master_dbs_address[1]) | (cpu_data_master_write & !cpu_data_master_byteenable_sdram_s1 & cpu_data_master_dbs_address[1]) | ~cpu_data_master_requests_sdram_s1);

  //r_2 master_run cascaded wait assignment, which is an e_assign
  assign r_2 = (cpu_data_master_granted_sdram_s1 | ~cpu_data_master_qualified_request_sdram_s1) & ((~cpu_data_master_qualified_request_sdram_s1 | ~cpu_data_master_read | (cpu_data_master_read_data_valid_sdram_s1 & (cpu_data_master_dbs_address[1]) & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_sdram_s1 | ~cpu_data_master_write | (1 & ~sdram_s1_waitrequest_from_sa & (cpu_data_master_dbs_address[1]) & cpu_data_master_write))) & 1 & ((~cpu_data_master_qualified_request_spi_adc_spi_control_port | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_spi_adc_spi_control_port | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & 1 & ((~cpu_data_master_qualified_request_spi_flash_spi_control_port | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_spi_flash_spi_control_port | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_sys_clk_timer_s1 | ~cpu_data_master_requests_sys_clk_timer_s1) & ((~cpu_data_master_qualified_request_sys_clk_timer_s1 | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_sys_clk_timer_s1 | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & ((~cpu_data_master_qualified_request_sysid_control_slave | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_sysid_control_slave | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & ((~cpu_data_master_qualified_request_uart_s1 | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_uart_s1 | ~(cpu_data_master_read | cpu_data_master_write) | (1 & 1 & (cpu_data_master_read | cpu_data_master_write))));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_data_master_address_to_slave = {cpu_data_master_address[26],
    1'b0,
    cpu_data_master_address[24 : 0]};

  //cpu/data_master readdata mux, which is an e_mux
  assign cpu_data_master_readdata = ({32 {~cpu_data_master_requests_beep_s1}} | beep_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_cpu_jtag_debug_module}} | cpu_jtag_debug_module_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_epcs_controller_epcs_control_port}} | epcs_controller_epcs_control_port_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_high_res_timer_s1}} | high_res_timer_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_jtag_uart_avalon_jtag_slave}} | registered_cpu_data_master_readdata) &
    ({32 {~cpu_data_master_requests_key_s1}} | key_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_lcd_control_slave}} | lcd_control_slave_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_led_s1}} | led_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_onchip_ram_s1}} | onchip_ram_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_sdram_s1}} | registered_cpu_data_master_readdata) &
    ({32 {~cpu_data_master_requests_spi_adc_spi_control_port}} | spi_adc_spi_control_port_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_spi_flash_spi_control_port}} | spi_flash_spi_control_port_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_sys_clk_timer_s1}} | sys_clk_timer_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_sysid_control_slave}} | sysid_control_slave_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_uart_s1}} | uart_s1_readdata_from_sa);

  //actual waitrequest port, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_data_master_waitrequest <= ~0;
      else 
        cpu_data_master_waitrequest <= ~((~(cpu_data_master_read | cpu_data_master_write))? 0: (cpu_data_master_run & cpu_data_master_waitrequest));
    end


  //irq assign, which is an e_assign
  assign cpu_data_master_irq = {1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    high_res_timer_s1_irq_from_sa,
    spi_adc_spi_control_port_irq_from_sa,
    spi_flash_spi_control_port_irq_from_sa,
    key_s1_irq_from_sa,
    uart_s1_irq_from_sa,
    jtag_uart_avalon_jtag_slave_irq_from_sa,
    sys_clk_timer_s1_irq_from_sa,
    epcs_controller_epcs_control_port_irq_from_sa};

  //unpredictable registered wait state incoming data, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          registered_cpu_data_master_readdata <= 0;
      else 
        registered_cpu_data_master_readdata <= p1_registered_cpu_data_master_readdata;
    end


  //registered readdata mux, which is an e_mux
  assign p1_registered_cpu_data_master_readdata = ({32 {~cpu_data_master_requests_jtag_uart_avalon_jtag_slave}} | jtag_uart_avalon_jtag_slave_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_sdram_s1}} | {sdram_s1_readdata_from_sa[15 : 0],
    dbs_16_reg_segment_0});

  //no_byte_enables_and_last_term, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_data_master_no_byte_enables_and_last_term <= 0;
      else 
        cpu_data_master_no_byte_enables_and_last_term <= last_dbs_term_and_run;
    end


  //compute the last dbs term, which is an e_mux
  assign last_dbs_term_and_run = (cpu_data_master_dbs_address == 2'b10) & cpu_data_master_write & !cpu_data_master_byteenable_sdram_s1;

  //pre dbs count enable, which is an e_mux
  assign pre_dbs_count_enable = (((~cpu_data_master_no_byte_enables_and_last_term) & cpu_data_master_requests_sdram_s1 & cpu_data_master_write & !cpu_data_master_byteenable_sdram_s1)) |
    cpu_data_master_read_data_valid_sdram_s1 |
    (cpu_data_master_granted_sdram_s1 & cpu_data_master_write & 1 & 1 & ~sdram_s1_waitrequest_from_sa);

  //input to dbs-16 stored 0, which is an e_mux
  assign p1_dbs_16_reg_segment_0 = sdram_s1_readdata_from_sa;

  //dbs register for dbs-16 segment 0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dbs_16_reg_segment_0 <= 0;
      else if (dbs_count_enable & ((cpu_data_master_dbs_address[1]) == 0))
          dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
    end


  //mux write dbs 1, which is an e_mux
  assign cpu_data_master_dbs_write_16 = (cpu_data_master_dbs_address[1])? cpu_data_master_writedata[31 : 16] :
    cpu_data_master_writedata[15 : 0];

  //dbs count increment, which is an e_mux
  assign cpu_data_master_dbs_increment = (cpu_data_master_requests_sdram_s1)? 2 :
    0;

  //dbs counter overflow, which is an e_assign
  assign dbs_counter_overflow = cpu_data_master_dbs_address[1] & !(next_dbs_address[1]);

  //next master address, which is an e_assign
  assign next_dbs_address = cpu_data_master_dbs_address + cpu_data_master_dbs_increment;

  //dbs count enable, which is an e_mux
  assign dbs_count_enable = pre_dbs_count_enable &
    (~(cpu_data_master_requests_sdram_s1 & ~cpu_data_master_waitrequest));

  //dbs counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_data_master_dbs_address <= 0;
      else if (dbs_count_enable)
          cpu_data_master_dbs_address <= next_dbs_address;
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_instruction_master_arbitrator (
                                           // inputs:
                                            clk,
                                            cpu_instruction_master_address,
                                            cpu_instruction_master_granted_cpu_jtag_debug_module,
                                            cpu_instruction_master_granted_epcs_controller_epcs_control_port,
                                            cpu_instruction_master_granted_onchip_ram_s1,
                                            cpu_instruction_master_granted_sdram_s1,
                                            cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
                                            cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port,
                                            cpu_instruction_master_qualified_request_onchip_ram_s1,
                                            cpu_instruction_master_qualified_request_sdram_s1,
                                            cpu_instruction_master_read,
                                            cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
                                            cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port,
                                            cpu_instruction_master_read_data_valid_onchip_ram_s1,
                                            cpu_instruction_master_read_data_valid_sdram_s1,
                                            cpu_instruction_master_read_data_valid_sdram_s1_shift_register,
                                            cpu_instruction_master_requests_cpu_jtag_debug_module,
                                            cpu_instruction_master_requests_epcs_controller_epcs_control_port,
                                            cpu_instruction_master_requests_onchip_ram_s1,
                                            cpu_instruction_master_requests_sdram_s1,
                                            cpu_jtag_debug_module_readdata_from_sa,
                                            d1_cpu_jtag_debug_module_end_xfer,
                                            d1_epcs_controller_epcs_control_port_end_xfer,
                                            d1_onchip_ram_s1_end_xfer,
                                            d1_sdram_s1_end_xfer,
                                            epcs_controller_epcs_control_port_readdata_from_sa,
                                            onchip_ram_s1_readdata_from_sa,
                                            reset_n,
                                            sdram_s1_readdata_from_sa,
                                            sdram_s1_waitrequest_from_sa,

                                           // outputs:
                                            cpu_instruction_master_address_to_slave,
                                            cpu_instruction_master_dbs_address,
                                            cpu_instruction_master_latency_counter,
                                            cpu_instruction_master_readdata,
                                            cpu_instruction_master_readdatavalid,
                                            cpu_instruction_master_waitrequest
                                         )
;

  output  [ 26: 0] cpu_instruction_master_address_to_slave;
  output  [  1: 0] cpu_instruction_master_dbs_address;
  output           cpu_instruction_master_latency_counter;
  output  [ 31: 0] cpu_instruction_master_readdata;
  output           cpu_instruction_master_readdatavalid;
  output           cpu_instruction_master_waitrequest;
  input            clk;
  input   [ 26: 0] cpu_instruction_master_address;
  input            cpu_instruction_master_granted_cpu_jtag_debug_module;
  input            cpu_instruction_master_granted_epcs_controller_epcs_control_port;
  input            cpu_instruction_master_granted_onchip_ram_s1;
  input            cpu_instruction_master_granted_sdram_s1;
  input            cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  input            cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port;
  input            cpu_instruction_master_qualified_request_onchip_ram_s1;
  input            cpu_instruction_master_qualified_request_sdram_s1;
  input            cpu_instruction_master_read;
  input            cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  input            cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port;
  input            cpu_instruction_master_read_data_valid_onchip_ram_s1;
  input            cpu_instruction_master_read_data_valid_sdram_s1;
  input            cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  input            cpu_instruction_master_requests_cpu_jtag_debug_module;
  input            cpu_instruction_master_requests_epcs_controller_epcs_control_port;
  input            cpu_instruction_master_requests_onchip_ram_s1;
  input            cpu_instruction_master_requests_sdram_s1;
  input   [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  input            d1_cpu_jtag_debug_module_end_xfer;
  input            d1_epcs_controller_epcs_control_port_end_xfer;
  input            d1_onchip_ram_s1_end_xfer;
  input            d1_sdram_s1_end_xfer;
  input   [ 31: 0] epcs_controller_epcs_control_port_readdata_from_sa;
  input   [ 31: 0] onchip_ram_s1_readdata_from_sa;
  input            reset_n;
  input   [ 15: 0] sdram_s1_readdata_from_sa;
  input            sdram_s1_waitrequest_from_sa;

  reg              active_and_waiting_last_time;
  reg     [ 26: 0] cpu_instruction_master_address_last_time;
  wire    [ 26: 0] cpu_instruction_master_address_to_slave;
  reg     [  1: 0] cpu_instruction_master_dbs_address;
  wire    [  1: 0] cpu_instruction_master_dbs_increment;
  reg     [  1: 0] cpu_instruction_master_dbs_rdv_counter;
  wire    [  1: 0] cpu_instruction_master_dbs_rdv_counter_inc;
  wire             cpu_instruction_master_is_granted_some_slave;
  reg              cpu_instruction_master_latency_counter;
  wire    [  1: 0] cpu_instruction_master_next_dbs_rdv_counter;
  reg              cpu_instruction_master_read_but_no_slave_selected;
  reg              cpu_instruction_master_read_last_time;
  wire    [ 31: 0] cpu_instruction_master_readdata;
  wire             cpu_instruction_master_readdatavalid;
  wire             cpu_instruction_master_run;
  wire             cpu_instruction_master_waitrequest;
  wire             dbs_count_enable;
  wire             dbs_counter_overflow;
  reg     [ 15: 0] dbs_latent_16_reg_segment_0;
  wire             dbs_rdv_count_enable;
  wire             dbs_rdv_counter_overflow;
  wire             latency_load_value;
  wire    [  1: 0] next_dbs_address;
  wire             p1_cpu_instruction_master_latency_counter;
  wire    [ 15: 0] p1_dbs_latent_16_reg_segment_0;
  wire             pre_dbs_count_enable;
  wire             pre_flush_cpu_instruction_master_readdatavalid;
  wire             r_0;
  wire             r_1;
  wire             r_2;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_instruction_master_qualified_request_cpu_jtag_debug_module | ~cpu_instruction_master_requests_cpu_jtag_debug_module) & (cpu_instruction_master_granted_cpu_jtag_debug_module | ~cpu_instruction_master_qualified_request_cpu_jtag_debug_module) & ((~cpu_instruction_master_qualified_request_cpu_jtag_debug_module | ~cpu_instruction_master_read | (1 & ~d1_cpu_jtag_debug_module_end_xfer & cpu_instruction_master_read))) & 1 & (cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port | ~cpu_instruction_master_requests_epcs_controller_epcs_control_port) & (cpu_instruction_master_granted_epcs_controller_epcs_control_port | ~cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port) & ((~cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port | ~(cpu_instruction_master_read) | (1 & ~d1_epcs_controller_epcs_control_port_end_xfer & (cpu_instruction_master_read))));

  //cascaded wait assignment, which is an e_assign
  assign cpu_instruction_master_run = r_0 & r_1 & r_2;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = 1 & (cpu_instruction_master_qualified_request_onchip_ram_s1 | ~cpu_instruction_master_requests_onchip_ram_s1) & (cpu_instruction_master_granted_onchip_ram_s1 | ~cpu_instruction_master_qualified_request_onchip_ram_s1) & ((~cpu_instruction_master_qualified_request_onchip_ram_s1 | ~cpu_instruction_master_read | (1 & cpu_instruction_master_read)));

  //r_2 master_run cascaded wait assignment, which is an e_assign
  assign r_2 = 1 & (cpu_instruction_master_qualified_request_sdram_s1 | ~cpu_instruction_master_requests_sdram_s1) & (cpu_instruction_master_granted_sdram_s1 | ~cpu_instruction_master_qualified_request_sdram_s1) & ((~cpu_instruction_master_qualified_request_sdram_s1 | ~cpu_instruction_master_read | (1 & ~sdram_s1_waitrequest_from_sa & (cpu_instruction_master_dbs_address[1]) & cpu_instruction_master_read)));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_instruction_master_address_to_slave = {cpu_instruction_master_address[26],
    1'b0,
    cpu_instruction_master_address[24 : 0]};

  //cpu_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_read_but_no_slave_selected <= 0;
      else 
        cpu_instruction_master_read_but_no_slave_selected <= cpu_instruction_master_read & cpu_instruction_master_run & ~cpu_instruction_master_is_granted_some_slave;
    end


  //some slave is getting selected, which is an e_mux
  assign cpu_instruction_master_is_granted_some_slave = cpu_instruction_master_granted_cpu_jtag_debug_module |
    cpu_instruction_master_granted_epcs_controller_epcs_control_port |
    cpu_instruction_master_granted_onchip_ram_s1 |
    cpu_instruction_master_granted_sdram_s1;

  //latent slave read data valids which may be flushed, which is an e_mux
  assign pre_flush_cpu_instruction_master_readdatavalid = cpu_instruction_master_read_data_valid_onchip_ram_s1 |
    (cpu_instruction_master_read_data_valid_sdram_s1 & dbs_rdv_counter_overflow);

  //latent slave read data valid which is not flushed, which is an e_mux
  assign cpu_instruction_master_readdatavalid = cpu_instruction_master_read_but_no_slave_selected |
    pre_flush_cpu_instruction_master_readdatavalid |
    cpu_instruction_master_read_data_valid_cpu_jtag_debug_module |
    cpu_instruction_master_read_but_no_slave_selected |
    pre_flush_cpu_instruction_master_readdatavalid |
    cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port |
    cpu_instruction_master_read_but_no_slave_selected |
    pre_flush_cpu_instruction_master_readdatavalid |
    cpu_instruction_master_read_but_no_slave_selected |
    pre_flush_cpu_instruction_master_readdatavalid;

  //cpu/instruction_master readdata mux, which is an e_mux
  assign cpu_instruction_master_readdata = ({32 {~(cpu_instruction_master_qualified_request_cpu_jtag_debug_module & cpu_instruction_master_read)}} | cpu_jtag_debug_module_readdata_from_sa) &
    ({32 {~(cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port & cpu_instruction_master_read)}} | epcs_controller_epcs_control_port_readdata_from_sa) &
    ({32 {~cpu_instruction_master_read_data_valid_onchip_ram_s1}} | onchip_ram_s1_readdata_from_sa) &
    ({32 {~cpu_instruction_master_read_data_valid_sdram_s1}} | {sdram_s1_readdata_from_sa[15 : 0],
    dbs_latent_16_reg_segment_0});

  //actual waitrequest port, which is an e_assign
  assign cpu_instruction_master_waitrequest = ~cpu_instruction_master_run;

  //latent max counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_latency_counter <= 0;
      else 
        cpu_instruction_master_latency_counter <= p1_cpu_instruction_master_latency_counter;
    end


  //latency counter load mux, which is an e_mux
  assign p1_cpu_instruction_master_latency_counter = ((cpu_instruction_master_run & cpu_instruction_master_read))? latency_load_value :
    (cpu_instruction_master_latency_counter)? cpu_instruction_master_latency_counter - 1 :
    0;

  //read latency load values, which is an e_mux
  assign latency_load_value = {1 {cpu_instruction_master_requests_onchip_ram_s1}} & 1;

  //input to latent dbs-16 stored 0, which is an e_mux
  assign p1_dbs_latent_16_reg_segment_0 = sdram_s1_readdata_from_sa;

  //dbs register for latent dbs-16 segment 0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dbs_latent_16_reg_segment_0 <= 0;
      else if (dbs_rdv_count_enable & ((cpu_instruction_master_dbs_rdv_counter[1]) == 0))
          dbs_latent_16_reg_segment_0 <= p1_dbs_latent_16_reg_segment_0;
    end


  //dbs count increment, which is an e_mux
  assign cpu_instruction_master_dbs_increment = (cpu_instruction_master_requests_sdram_s1)? 2 :
    0;

  //dbs counter overflow, which is an e_assign
  assign dbs_counter_overflow = cpu_instruction_master_dbs_address[1] & !(next_dbs_address[1]);

  //next master address, which is an e_assign
  assign next_dbs_address = cpu_instruction_master_dbs_address + cpu_instruction_master_dbs_increment;

  //dbs count enable, which is an e_mux
  assign dbs_count_enable = pre_dbs_count_enable;

  //dbs counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_dbs_address <= 0;
      else if (dbs_count_enable)
          cpu_instruction_master_dbs_address <= next_dbs_address;
    end


  //p1 dbs rdv counter, which is an e_assign
  assign cpu_instruction_master_next_dbs_rdv_counter = cpu_instruction_master_dbs_rdv_counter + cpu_instruction_master_dbs_rdv_counter_inc;

  //cpu_instruction_master_rdv_inc_mux, which is an e_mux
  assign cpu_instruction_master_dbs_rdv_counter_inc = 2;

  //master any slave rdv, which is an e_mux
  assign dbs_rdv_count_enable = cpu_instruction_master_read_data_valid_sdram_s1;

  //dbs rdv counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_dbs_rdv_counter <= 0;
      else if (dbs_rdv_count_enable)
          cpu_instruction_master_dbs_rdv_counter <= cpu_instruction_master_next_dbs_rdv_counter;
    end


  //dbs rdv counter overflow, which is an e_assign
  assign dbs_rdv_counter_overflow = cpu_instruction_master_dbs_rdv_counter[1] & ~cpu_instruction_master_next_dbs_rdv_counter[1];

  //pre dbs count enable, which is an e_mux
  assign pre_dbs_count_enable = cpu_instruction_master_granted_sdram_s1 & cpu_instruction_master_read & 1 & 1 & ~sdram_s1_waitrequest_from_sa;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_instruction_master_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_address_last_time <= 0;
      else 
        cpu_instruction_master_address_last_time <= cpu_instruction_master_address;
    end


  //cpu/instruction_master waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= cpu_instruction_master_waitrequest & (cpu_instruction_master_read);
    end


  //cpu_instruction_master_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_instruction_master_address != cpu_instruction_master_address_last_time))
        begin
          $write("%0d ns: cpu_instruction_master_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_instruction_master_read check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_read_last_time <= 0;
      else 
        cpu_instruction_master_read_last_time <= cpu_instruction_master_read;
    end


  //cpu_instruction_master_read matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_instruction_master_read != cpu_instruction_master_read_last_time))
        begin
          $write("%0d ns: cpu_instruction_master_read did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module epcs_controller_epcs_control_port_arbitrator (
                                                      // inputs:
                                                       clk,
                                                       cpu_data_master_address_to_slave,
                                                       cpu_data_master_read,
                                                       cpu_data_master_write,
                                                       cpu_data_master_writedata,
                                                       cpu_instruction_master_address_to_slave,
                                                       cpu_instruction_master_latency_counter,
                                                       cpu_instruction_master_read,
                                                       cpu_instruction_master_read_data_valid_sdram_s1_shift_register,
                                                       epcs_controller_epcs_control_port_dataavailable,
                                                       epcs_controller_epcs_control_port_endofpacket,
                                                       epcs_controller_epcs_control_port_irq,
                                                       epcs_controller_epcs_control_port_readdata,
                                                       epcs_controller_epcs_control_port_readyfordata,
                                                       reset_n,

                                                      // outputs:
                                                       cpu_data_master_granted_epcs_controller_epcs_control_port,
                                                       cpu_data_master_qualified_request_epcs_controller_epcs_control_port,
                                                       cpu_data_master_read_data_valid_epcs_controller_epcs_control_port,
                                                       cpu_data_master_requests_epcs_controller_epcs_control_port,
                                                       cpu_instruction_master_granted_epcs_controller_epcs_control_port,
                                                       cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port,
                                                       cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port,
                                                       cpu_instruction_master_requests_epcs_controller_epcs_control_port,
                                                       d1_epcs_controller_epcs_control_port_end_xfer,
                                                       epcs_controller_epcs_control_port_address,
                                                       epcs_controller_epcs_control_port_chipselect,
                                                       epcs_controller_epcs_control_port_dataavailable_from_sa,
                                                       epcs_controller_epcs_control_port_endofpacket_from_sa,
                                                       epcs_controller_epcs_control_port_irq_from_sa,
                                                       epcs_controller_epcs_control_port_read_n,
                                                       epcs_controller_epcs_control_port_readdata_from_sa,
                                                       epcs_controller_epcs_control_port_readyfordata_from_sa,
                                                       epcs_controller_epcs_control_port_reset_n,
                                                       epcs_controller_epcs_control_port_write_n,
                                                       epcs_controller_epcs_control_port_writedata
                                                    )
;

  output           cpu_data_master_granted_epcs_controller_epcs_control_port;
  output           cpu_data_master_qualified_request_epcs_controller_epcs_control_port;
  output           cpu_data_master_read_data_valid_epcs_controller_epcs_control_port;
  output           cpu_data_master_requests_epcs_controller_epcs_control_port;
  output           cpu_instruction_master_granted_epcs_controller_epcs_control_port;
  output           cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port;
  output           cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port;
  output           cpu_instruction_master_requests_epcs_controller_epcs_control_port;
  output           d1_epcs_controller_epcs_control_port_end_xfer;
  output  [  8: 0] epcs_controller_epcs_control_port_address;
  output           epcs_controller_epcs_control_port_chipselect;
  output           epcs_controller_epcs_control_port_dataavailable_from_sa;
  output           epcs_controller_epcs_control_port_endofpacket_from_sa;
  output           epcs_controller_epcs_control_port_irq_from_sa;
  output           epcs_controller_epcs_control_port_read_n;
  output  [ 31: 0] epcs_controller_epcs_control_port_readdata_from_sa;
  output           epcs_controller_epcs_control_port_readyfordata_from_sa;
  output           epcs_controller_epcs_control_port_reset_n;
  output           epcs_controller_epcs_control_port_write_n;
  output  [ 31: 0] epcs_controller_epcs_control_port_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 26: 0] cpu_instruction_master_address_to_slave;
  input            cpu_instruction_master_latency_counter;
  input            cpu_instruction_master_read;
  input            cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  input            epcs_controller_epcs_control_port_dataavailable;
  input            epcs_controller_epcs_control_port_endofpacket;
  input            epcs_controller_epcs_control_port_irq;
  input   [ 31: 0] epcs_controller_epcs_control_port_readdata;
  input            epcs_controller_epcs_control_port_readyfordata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_epcs_controller_epcs_control_port;
  wire             cpu_data_master_qualified_request_epcs_controller_epcs_control_port;
  wire             cpu_data_master_read_data_valid_epcs_controller_epcs_control_port;
  wire             cpu_data_master_requests_epcs_controller_epcs_control_port;
  wire             cpu_data_master_saved_grant_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_arbiterlock;
  wire             cpu_instruction_master_arbiterlock2;
  wire             cpu_instruction_master_continuerequest;
  wire             cpu_instruction_master_granted_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_requests_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_saved_grant_epcs_controller_epcs_control_port;
  reg              d1_epcs_controller_epcs_control_port_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port;
  wire    [  8: 0] epcs_controller_epcs_control_port_address;
  wire             epcs_controller_epcs_control_port_allgrants;
  wire             epcs_controller_epcs_control_port_allow_new_arb_cycle;
  wire             epcs_controller_epcs_control_port_any_bursting_master_saved_grant;
  wire             epcs_controller_epcs_control_port_any_continuerequest;
  reg     [  1: 0] epcs_controller_epcs_control_port_arb_addend;
  wire             epcs_controller_epcs_control_port_arb_counter_enable;
  reg     [  1: 0] epcs_controller_epcs_control_port_arb_share_counter;
  wire    [  1: 0] epcs_controller_epcs_control_port_arb_share_counter_next_value;
  wire    [  1: 0] epcs_controller_epcs_control_port_arb_share_set_values;
  wire    [  1: 0] epcs_controller_epcs_control_port_arb_winner;
  wire             epcs_controller_epcs_control_port_arbitration_holdoff_internal;
  wire             epcs_controller_epcs_control_port_beginbursttransfer_internal;
  wire             epcs_controller_epcs_control_port_begins_xfer;
  wire             epcs_controller_epcs_control_port_chipselect;
  wire    [  3: 0] epcs_controller_epcs_control_port_chosen_master_double_vector;
  wire    [  1: 0] epcs_controller_epcs_control_port_chosen_master_rot_left;
  wire             epcs_controller_epcs_control_port_dataavailable_from_sa;
  wire             epcs_controller_epcs_control_port_end_xfer;
  wire             epcs_controller_epcs_control_port_endofpacket_from_sa;
  wire             epcs_controller_epcs_control_port_firsttransfer;
  wire    [  1: 0] epcs_controller_epcs_control_port_grant_vector;
  wire             epcs_controller_epcs_control_port_in_a_read_cycle;
  wire             epcs_controller_epcs_control_port_in_a_write_cycle;
  wire             epcs_controller_epcs_control_port_irq_from_sa;
  wire    [  1: 0] epcs_controller_epcs_control_port_master_qreq_vector;
  wire             epcs_controller_epcs_control_port_non_bursting_master_requests;
  wire             epcs_controller_epcs_control_port_read_n;
  wire    [ 31: 0] epcs_controller_epcs_control_port_readdata_from_sa;
  wire             epcs_controller_epcs_control_port_readyfordata_from_sa;
  reg              epcs_controller_epcs_control_port_reg_firsttransfer;
  wire             epcs_controller_epcs_control_port_reset_n;
  reg     [  1: 0] epcs_controller_epcs_control_port_saved_chosen_master_vector;
  reg              epcs_controller_epcs_control_port_slavearbiterlockenable;
  wire             epcs_controller_epcs_control_port_slavearbiterlockenable2;
  wire             epcs_controller_epcs_control_port_unreg_firsttransfer;
  wire             epcs_controller_epcs_control_port_waits_for_read;
  wire             epcs_controller_epcs_control_port_waits_for_write;
  wire             epcs_controller_epcs_control_port_write_n;
  wire    [ 31: 0] epcs_controller_epcs_control_port_writedata;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_data_master_granted_slave_epcs_controller_epcs_control_port;
  reg              last_cycle_cpu_instruction_master_granted_slave_epcs_controller_epcs_control_port;
  wire    [ 26: 0] shifted_address_to_epcs_controller_epcs_control_port_from_cpu_data_master;
  wire    [ 26: 0] shifted_address_to_epcs_controller_epcs_control_port_from_cpu_instruction_master;
  wire             wait_for_epcs_controller_epcs_control_port_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~epcs_controller_epcs_control_port_end_xfer;
    end


  assign epcs_controller_epcs_control_port_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_epcs_controller_epcs_control_port | cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port));
  //assign epcs_controller_epcs_control_port_readdata_from_sa = epcs_controller_epcs_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_controller_epcs_control_port_readdata_from_sa = epcs_controller_epcs_control_port_readdata;

  assign cpu_data_master_requests_epcs_controller_epcs_control_port = ({cpu_data_master_address_to_slave[26 : 11] , 11'b0} == 27'h0) & (cpu_data_master_read | cpu_data_master_write);
  //assign epcs_controller_epcs_control_port_dataavailable_from_sa = epcs_controller_epcs_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_controller_epcs_control_port_dataavailable_from_sa = epcs_controller_epcs_control_port_dataavailable;

  //assign epcs_controller_epcs_control_port_readyfordata_from_sa = epcs_controller_epcs_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_controller_epcs_control_port_readyfordata_from_sa = epcs_controller_epcs_control_port_readyfordata;

  //epcs_controller_epcs_control_port_arb_share_counter set values, which is an e_mux
  assign epcs_controller_epcs_control_port_arb_share_set_values = 1;

  //epcs_controller_epcs_control_port_non_bursting_master_requests mux, which is an e_mux
  assign epcs_controller_epcs_control_port_non_bursting_master_requests = cpu_data_master_requests_epcs_controller_epcs_control_port |
    cpu_instruction_master_requests_epcs_controller_epcs_control_port |
    cpu_data_master_requests_epcs_controller_epcs_control_port |
    cpu_instruction_master_requests_epcs_controller_epcs_control_port;

  //epcs_controller_epcs_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  assign epcs_controller_epcs_control_port_any_bursting_master_saved_grant = 0;

  //epcs_controller_epcs_control_port_arb_share_counter_next_value assignment, which is an e_assign
  assign epcs_controller_epcs_control_port_arb_share_counter_next_value = epcs_controller_epcs_control_port_firsttransfer ? (epcs_controller_epcs_control_port_arb_share_set_values - 1) : |epcs_controller_epcs_control_port_arb_share_counter ? (epcs_controller_epcs_control_port_arb_share_counter - 1) : 0;

  //epcs_controller_epcs_control_port_allgrants all slave grants, which is an e_mux
  assign epcs_controller_epcs_control_port_allgrants = (|epcs_controller_epcs_control_port_grant_vector) |
    (|epcs_controller_epcs_control_port_grant_vector) |
    (|epcs_controller_epcs_control_port_grant_vector) |
    (|epcs_controller_epcs_control_port_grant_vector);

  //epcs_controller_epcs_control_port_end_xfer assignment, which is an e_assign
  assign epcs_controller_epcs_control_port_end_xfer = ~(epcs_controller_epcs_control_port_waits_for_read | epcs_controller_epcs_control_port_waits_for_write);

  //end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port = epcs_controller_epcs_control_port_end_xfer & (~epcs_controller_epcs_control_port_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //epcs_controller_epcs_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  assign epcs_controller_epcs_control_port_arb_counter_enable = (end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port & epcs_controller_epcs_control_port_allgrants) | (end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port & ~epcs_controller_epcs_control_port_non_bursting_master_requests);

  //epcs_controller_epcs_control_port_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_controller_epcs_control_port_arb_share_counter <= 0;
      else if (epcs_controller_epcs_control_port_arb_counter_enable)
          epcs_controller_epcs_control_port_arb_share_counter <= epcs_controller_epcs_control_port_arb_share_counter_next_value;
    end


  //epcs_controller_epcs_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_controller_epcs_control_port_slavearbiterlockenable <= 0;
      else if ((|epcs_controller_epcs_control_port_master_qreq_vector & end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port) | (end_xfer_arb_share_counter_term_epcs_controller_epcs_control_port & ~epcs_controller_epcs_control_port_non_bursting_master_requests))
          epcs_controller_epcs_control_port_slavearbiterlockenable <= |epcs_controller_epcs_control_port_arb_share_counter_next_value;
    end


  //cpu/data_master epcs_controller/epcs_control_port arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = epcs_controller_epcs_control_port_slavearbiterlockenable & cpu_data_master_continuerequest;

  //epcs_controller_epcs_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign epcs_controller_epcs_control_port_slavearbiterlockenable2 = |epcs_controller_epcs_control_port_arb_share_counter_next_value;

  //cpu/data_master epcs_controller/epcs_control_port arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = epcs_controller_epcs_control_port_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //cpu/instruction_master epcs_controller/epcs_control_port arbiterlock, which is an e_assign
  assign cpu_instruction_master_arbiterlock = epcs_controller_epcs_control_port_slavearbiterlockenable & cpu_instruction_master_continuerequest;

  //cpu/instruction_master epcs_controller/epcs_control_port arbiterlock2, which is an e_assign
  assign cpu_instruction_master_arbiterlock2 = epcs_controller_epcs_control_port_slavearbiterlockenable2 & cpu_instruction_master_continuerequest;

  //cpu/instruction_master granted epcs_controller/epcs_control_port last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_instruction_master_granted_slave_epcs_controller_epcs_control_port <= 0;
      else 
        last_cycle_cpu_instruction_master_granted_slave_epcs_controller_epcs_control_port <= cpu_instruction_master_saved_grant_epcs_controller_epcs_control_port ? 1 : (epcs_controller_epcs_control_port_arbitration_holdoff_internal | ~cpu_instruction_master_requests_epcs_controller_epcs_control_port) ? 0 : last_cycle_cpu_instruction_master_granted_slave_epcs_controller_epcs_control_port;
    end


  //cpu_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_instruction_master_continuerequest = last_cycle_cpu_instruction_master_granted_slave_epcs_controller_epcs_control_port & cpu_instruction_master_requests_epcs_controller_epcs_control_port;

  //epcs_controller_epcs_control_port_any_continuerequest at least one master continues requesting, which is an e_mux
  assign epcs_controller_epcs_control_port_any_continuerequest = cpu_instruction_master_continuerequest |
    cpu_data_master_continuerequest;

  assign cpu_data_master_qualified_request_epcs_controller_epcs_control_port = cpu_data_master_requests_epcs_controller_epcs_control_port & ~(cpu_instruction_master_arbiterlock);
  //epcs_controller_epcs_control_port_writedata mux, which is an e_mux
  assign epcs_controller_epcs_control_port_writedata = cpu_data_master_writedata;

  //assign epcs_controller_epcs_control_port_endofpacket_from_sa = epcs_controller_epcs_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_controller_epcs_control_port_endofpacket_from_sa = epcs_controller_epcs_control_port_endofpacket;

  assign cpu_instruction_master_requests_epcs_controller_epcs_control_port = (({cpu_instruction_master_address_to_slave[26 : 11] , 11'b0} == 27'h0) & (cpu_instruction_master_read)) & cpu_instruction_master_read;
  //cpu/data_master granted epcs_controller/epcs_control_port last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_data_master_granted_slave_epcs_controller_epcs_control_port <= 0;
      else 
        last_cycle_cpu_data_master_granted_slave_epcs_controller_epcs_control_port <= cpu_data_master_saved_grant_epcs_controller_epcs_control_port ? 1 : (epcs_controller_epcs_control_port_arbitration_holdoff_internal | ~cpu_data_master_requests_epcs_controller_epcs_control_port) ? 0 : last_cycle_cpu_data_master_granted_slave_epcs_controller_epcs_control_port;
    end


  //cpu_data_master_continuerequest continued request, which is an e_mux
  assign cpu_data_master_continuerequest = last_cycle_cpu_data_master_granted_slave_epcs_controller_epcs_control_port & cpu_data_master_requests_epcs_controller_epcs_control_port;

  assign cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port = cpu_instruction_master_requests_epcs_controller_epcs_control_port & ~((cpu_instruction_master_read & ((cpu_instruction_master_latency_counter != 0) | (|cpu_instruction_master_read_data_valid_sdram_s1_shift_register))) | cpu_data_master_arbiterlock);
  //local readdatavalid cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port, which is an e_mux
  assign cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port = cpu_instruction_master_granted_epcs_controller_epcs_control_port & cpu_instruction_master_read & ~epcs_controller_epcs_control_port_waits_for_read;

  //allow new arb cycle for epcs_controller/epcs_control_port, which is an e_assign
  assign epcs_controller_epcs_control_port_allow_new_arb_cycle = ~cpu_data_master_arbiterlock & ~cpu_instruction_master_arbiterlock;

  //cpu/instruction_master assignment into master qualified-requests vector for epcs_controller/epcs_control_port, which is an e_assign
  assign epcs_controller_epcs_control_port_master_qreq_vector[0] = cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port;

  //cpu/instruction_master grant epcs_controller/epcs_control_port, which is an e_assign
  assign cpu_instruction_master_granted_epcs_controller_epcs_control_port = epcs_controller_epcs_control_port_grant_vector[0];

  //cpu/instruction_master saved-grant epcs_controller/epcs_control_port, which is an e_assign
  assign cpu_instruction_master_saved_grant_epcs_controller_epcs_control_port = epcs_controller_epcs_control_port_arb_winner[0] && cpu_instruction_master_requests_epcs_controller_epcs_control_port;

  //cpu/data_master assignment into master qualified-requests vector for epcs_controller/epcs_control_port, which is an e_assign
  assign epcs_controller_epcs_control_port_master_qreq_vector[1] = cpu_data_master_qualified_request_epcs_controller_epcs_control_port;

  //cpu/data_master grant epcs_controller/epcs_control_port, which is an e_assign
  assign cpu_data_master_granted_epcs_controller_epcs_control_port = epcs_controller_epcs_control_port_grant_vector[1];

  //cpu/data_master saved-grant epcs_controller/epcs_control_port, which is an e_assign
  assign cpu_data_master_saved_grant_epcs_controller_epcs_control_port = epcs_controller_epcs_control_port_arb_winner[1] && cpu_data_master_requests_epcs_controller_epcs_control_port;

  //epcs_controller/epcs_control_port chosen-master double-vector, which is an e_assign
  assign epcs_controller_epcs_control_port_chosen_master_double_vector = {epcs_controller_epcs_control_port_master_qreq_vector, epcs_controller_epcs_control_port_master_qreq_vector} & ({~epcs_controller_epcs_control_port_master_qreq_vector, ~epcs_controller_epcs_control_port_master_qreq_vector} + epcs_controller_epcs_control_port_arb_addend);

  //stable onehot encoding of arb winner
  assign epcs_controller_epcs_control_port_arb_winner = (epcs_controller_epcs_control_port_allow_new_arb_cycle & | epcs_controller_epcs_control_port_grant_vector) ? epcs_controller_epcs_control_port_grant_vector : epcs_controller_epcs_control_port_saved_chosen_master_vector;

  //saved epcs_controller_epcs_control_port_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_controller_epcs_control_port_saved_chosen_master_vector <= 0;
      else if (epcs_controller_epcs_control_port_allow_new_arb_cycle)
          epcs_controller_epcs_control_port_saved_chosen_master_vector <= |epcs_controller_epcs_control_port_grant_vector ? epcs_controller_epcs_control_port_grant_vector : epcs_controller_epcs_control_port_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign epcs_controller_epcs_control_port_grant_vector = {(epcs_controller_epcs_control_port_chosen_master_double_vector[1] | epcs_controller_epcs_control_port_chosen_master_double_vector[3]),
    (epcs_controller_epcs_control_port_chosen_master_double_vector[0] | epcs_controller_epcs_control_port_chosen_master_double_vector[2])};

  //epcs_controller/epcs_control_port chosen master rotated left, which is an e_assign
  assign epcs_controller_epcs_control_port_chosen_master_rot_left = (epcs_controller_epcs_control_port_arb_winner << 1) ? (epcs_controller_epcs_control_port_arb_winner << 1) : 1;

  //epcs_controller/epcs_control_port's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_controller_epcs_control_port_arb_addend <= 1;
      else if (|epcs_controller_epcs_control_port_grant_vector)
          epcs_controller_epcs_control_port_arb_addend <= epcs_controller_epcs_control_port_end_xfer? epcs_controller_epcs_control_port_chosen_master_rot_left : epcs_controller_epcs_control_port_grant_vector;
    end


  //epcs_controller_epcs_control_port_reset_n assignment, which is an e_assign
  assign epcs_controller_epcs_control_port_reset_n = reset_n;

  assign epcs_controller_epcs_control_port_chipselect = cpu_data_master_granted_epcs_controller_epcs_control_port | cpu_instruction_master_granted_epcs_controller_epcs_control_port;
  //epcs_controller_epcs_control_port_firsttransfer first transaction, which is an e_assign
  assign epcs_controller_epcs_control_port_firsttransfer = epcs_controller_epcs_control_port_begins_xfer ? epcs_controller_epcs_control_port_unreg_firsttransfer : epcs_controller_epcs_control_port_reg_firsttransfer;

  //epcs_controller_epcs_control_port_unreg_firsttransfer first transaction, which is an e_assign
  assign epcs_controller_epcs_control_port_unreg_firsttransfer = ~(epcs_controller_epcs_control_port_slavearbiterlockenable & epcs_controller_epcs_control_port_any_continuerequest);

  //epcs_controller_epcs_control_port_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_controller_epcs_control_port_reg_firsttransfer <= 1'b1;
      else if (epcs_controller_epcs_control_port_begins_xfer)
          epcs_controller_epcs_control_port_reg_firsttransfer <= epcs_controller_epcs_control_port_unreg_firsttransfer;
    end


  //epcs_controller_epcs_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign epcs_controller_epcs_control_port_beginbursttransfer_internal = epcs_controller_epcs_control_port_begins_xfer;

  //epcs_controller_epcs_control_port_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign epcs_controller_epcs_control_port_arbitration_holdoff_internal = epcs_controller_epcs_control_port_begins_xfer & epcs_controller_epcs_control_port_firsttransfer;

  //~epcs_controller_epcs_control_port_read_n assignment, which is an e_mux
  assign epcs_controller_epcs_control_port_read_n = ~((cpu_data_master_granted_epcs_controller_epcs_control_port & cpu_data_master_read) | (cpu_instruction_master_granted_epcs_controller_epcs_control_port & cpu_instruction_master_read));

  //~epcs_controller_epcs_control_port_write_n assignment, which is an e_mux
  assign epcs_controller_epcs_control_port_write_n = ~(cpu_data_master_granted_epcs_controller_epcs_control_port & cpu_data_master_write);

  assign shifted_address_to_epcs_controller_epcs_control_port_from_cpu_data_master = cpu_data_master_address_to_slave;
  //epcs_controller_epcs_control_port_address mux, which is an e_mux
  assign epcs_controller_epcs_control_port_address = (cpu_data_master_granted_epcs_controller_epcs_control_port)? (shifted_address_to_epcs_controller_epcs_control_port_from_cpu_data_master >> 2) :
    (shifted_address_to_epcs_controller_epcs_control_port_from_cpu_instruction_master >> 2);

  assign shifted_address_to_epcs_controller_epcs_control_port_from_cpu_instruction_master = cpu_instruction_master_address_to_slave;
  //d1_epcs_controller_epcs_control_port_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_epcs_controller_epcs_control_port_end_xfer <= 1;
      else 
        d1_epcs_controller_epcs_control_port_end_xfer <= epcs_controller_epcs_control_port_end_xfer;
    end


  //epcs_controller_epcs_control_port_waits_for_read in a cycle, which is an e_mux
  assign epcs_controller_epcs_control_port_waits_for_read = epcs_controller_epcs_control_port_in_a_read_cycle & epcs_controller_epcs_control_port_begins_xfer;

  //epcs_controller_epcs_control_port_in_a_read_cycle assignment, which is an e_assign
  assign epcs_controller_epcs_control_port_in_a_read_cycle = (cpu_data_master_granted_epcs_controller_epcs_control_port & cpu_data_master_read) | (cpu_instruction_master_granted_epcs_controller_epcs_control_port & cpu_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = epcs_controller_epcs_control_port_in_a_read_cycle;

  //epcs_controller_epcs_control_port_waits_for_write in a cycle, which is an e_mux
  assign epcs_controller_epcs_control_port_waits_for_write = epcs_controller_epcs_control_port_in_a_write_cycle & epcs_controller_epcs_control_port_begins_xfer;

  //epcs_controller_epcs_control_port_in_a_write_cycle assignment, which is an e_assign
  assign epcs_controller_epcs_control_port_in_a_write_cycle = cpu_data_master_granted_epcs_controller_epcs_control_port & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = epcs_controller_epcs_control_port_in_a_write_cycle;

  assign wait_for_epcs_controller_epcs_control_port_counter = 0;
  //assign epcs_controller_epcs_control_port_irq_from_sa = epcs_controller_epcs_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_controller_epcs_control_port_irq_from_sa = epcs_controller_epcs_control_port_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //epcs_controller/epcs_control_port enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_granted_epcs_controller_epcs_control_port + cpu_instruction_master_granted_epcs_controller_epcs_control_port > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_saved_grant_epcs_controller_epcs_control_port + cpu_instruction_master_saved_grant_epcs_controller_epcs_control_port > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module high_res_timer_s1_arbitrator (
                                      // inputs:
                                       clk,
                                       cpu_data_master_address_to_slave,
                                       cpu_data_master_read,
                                       cpu_data_master_waitrequest,
                                       cpu_data_master_write,
                                       cpu_data_master_writedata,
                                       high_res_timer_s1_irq,
                                       high_res_timer_s1_readdata,
                                       reset_n,

                                      // outputs:
                                       cpu_data_master_granted_high_res_timer_s1,
                                       cpu_data_master_qualified_request_high_res_timer_s1,
                                       cpu_data_master_read_data_valid_high_res_timer_s1,
                                       cpu_data_master_requests_high_res_timer_s1,
                                       d1_high_res_timer_s1_end_xfer,
                                       high_res_timer_s1_address,
                                       high_res_timer_s1_chipselect,
                                       high_res_timer_s1_irq_from_sa,
                                       high_res_timer_s1_readdata_from_sa,
                                       high_res_timer_s1_reset_n,
                                       high_res_timer_s1_write_n,
                                       high_res_timer_s1_writedata
                                    )
;

  output           cpu_data_master_granted_high_res_timer_s1;
  output           cpu_data_master_qualified_request_high_res_timer_s1;
  output           cpu_data_master_read_data_valid_high_res_timer_s1;
  output           cpu_data_master_requests_high_res_timer_s1;
  output           d1_high_res_timer_s1_end_xfer;
  output  [  2: 0] high_res_timer_s1_address;
  output           high_res_timer_s1_chipselect;
  output           high_res_timer_s1_irq_from_sa;
  output  [ 15: 0] high_res_timer_s1_readdata_from_sa;
  output           high_res_timer_s1_reset_n;
  output           high_res_timer_s1_write_n;
  output  [ 15: 0] high_res_timer_s1_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            high_res_timer_s1_irq;
  input   [ 15: 0] high_res_timer_s1_readdata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_high_res_timer_s1;
  wire             cpu_data_master_qualified_request_high_res_timer_s1;
  wire             cpu_data_master_read_data_valid_high_res_timer_s1;
  wire             cpu_data_master_requests_high_res_timer_s1;
  wire             cpu_data_master_saved_grant_high_res_timer_s1;
  reg              d1_high_res_timer_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_high_res_timer_s1;
  wire    [  2: 0] high_res_timer_s1_address;
  wire             high_res_timer_s1_allgrants;
  wire             high_res_timer_s1_allow_new_arb_cycle;
  wire             high_res_timer_s1_any_bursting_master_saved_grant;
  wire             high_res_timer_s1_any_continuerequest;
  wire             high_res_timer_s1_arb_counter_enable;
  reg     [  1: 0] high_res_timer_s1_arb_share_counter;
  wire    [  1: 0] high_res_timer_s1_arb_share_counter_next_value;
  wire    [  1: 0] high_res_timer_s1_arb_share_set_values;
  wire             high_res_timer_s1_beginbursttransfer_internal;
  wire             high_res_timer_s1_begins_xfer;
  wire             high_res_timer_s1_chipselect;
  wire             high_res_timer_s1_end_xfer;
  wire             high_res_timer_s1_firsttransfer;
  wire             high_res_timer_s1_grant_vector;
  wire             high_res_timer_s1_in_a_read_cycle;
  wire             high_res_timer_s1_in_a_write_cycle;
  wire             high_res_timer_s1_irq_from_sa;
  wire             high_res_timer_s1_master_qreq_vector;
  wire             high_res_timer_s1_non_bursting_master_requests;
  wire    [ 15: 0] high_res_timer_s1_readdata_from_sa;
  reg              high_res_timer_s1_reg_firsttransfer;
  wire             high_res_timer_s1_reset_n;
  reg              high_res_timer_s1_slavearbiterlockenable;
  wire             high_res_timer_s1_slavearbiterlockenable2;
  wire             high_res_timer_s1_unreg_firsttransfer;
  wire             high_res_timer_s1_waits_for_read;
  wire             high_res_timer_s1_waits_for_write;
  wire             high_res_timer_s1_write_n;
  wire    [ 15: 0] high_res_timer_s1_writedata;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_high_res_timer_s1_from_cpu_data_master;
  wire             wait_for_high_res_timer_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~high_res_timer_s1_end_xfer;
    end


  assign high_res_timer_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_high_res_timer_s1));
  //assign high_res_timer_s1_readdata_from_sa = high_res_timer_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign high_res_timer_s1_readdata_from_sa = high_res_timer_s1_readdata;

  assign cpu_data_master_requests_high_res_timer_s1 = ({cpu_data_master_address_to_slave[26 : 5] , 5'b0} == 27'h38a0) & (cpu_data_master_read | cpu_data_master_write);
  //high_res_timer_s1_arb_share_counter set values, which is an e_mux
  assign high_res_timer_s1_arb_share_set_values = 1;

  //high_res_timer_s1_non_bursting_master_requests mux, which is an e_mux
  assign high_res_timer_s1_non_bursting_master_requests = cpu_data_master_requests_high_res_timer_s1;

  //high_res_timer_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign high_res_timer_s1_any_bursting_master_saved_grant = 0;

  //high_res_timer_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign high_res_timer_s1_arb_share_counter_next_value = high_res_timer_s1_firsttransfer ? (high_res_timer_s1_arb_share_set_values - 1) : |high_res_timer_s1_arb_share_counter ? (high_res_timer_s1_arb_share_counter - 1) : 0;

  //high_res_timer_s1_allgrants all slave grants, which is an e_mux
  assign high_res_timer_s1_allgrants = |high_res_timer_s1_grant_vector;

  //high_res_timer_s1_end_xfer assignment, which is an e_assign
  assign high_res_timer_s1_end_xfer = ~(high_res_timer_s1_waits_for_read | high_res_timer_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_high_res_timer_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_high_res_timer_s1 = high_res_timer_s1_end_xfer & (~high_res_timer_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //high_res_timer_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign high_res_timer_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_high_res_timer_s1 & high_res_timer_s1_allgrants) | (end_xfer_arb_share_counter_term_high_res_timer_s1 & ~high_res_timer_s1_non_bursting_master_requests);

  //high_res_timer_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          high_res_timer_s1_arb_share_counter <= 0;
      else if (high_res_timer_s1_arb_counter_enable)
          high_res_timer_s1_arb_share_counter <= high_res_timer_s1_arb_share_counter_next_value;
    end


  //high_res_timer_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          high_res_timer_s1_slavearbiterlockenable <= 0;
      else if ((|high_res_timer_s1_master_qreq_vector & end_xfer_arb_share_counter_term_high_res_timer_s1) | (end_xfer_arb_share_counter_term_high_res_timer_s1 & ~high_res_timer_s1_non_bursting_master_requests))
          high_res_timer_s1_slavearbiterlockenable <= |high_res_timer_s1_arb_share_counter_next_value;
    end


  //cpu/data_master high_res_timer/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = high_res_timer_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //high_res_timer_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign high_res_timer_s1_slavearbiterlockenable2 = |high_res_timer_s1_arb_share_counter_next_value;

  //cpu/data_master high_res_timer/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = high_res_timer_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //high_res_timer_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign high_res_timer_s1_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_high_res_timer_s1 = cpu_data_master_requests_high_res_timer_s1 & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //high_res_timer_s1_writedata mux, which is an e_mux
  assign high_res_timer_s1_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_high_res_timer_s1 = cpu_data_master_qualified_request_high_res_timer_s1;

  //cpu/data_master saved-grant high_res_timer/s1, which is an e_assign
  assign cpu_data_master_saved_grant_high_res_timer_s1 = cpu_data_master_requests_high_res_timer_s1;

  //allow new arb cycle for high_res_timer/s1, which is an e_assign
  assign high_res_timer_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign high_res_timer_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign high_res_timer_s1_master_qreq_vector = 1;

  //high_res_timer_s1_reset_n assignment, which is an e_assign
  assign high_res_timer_s1_reset_n = reset_n;

  assign high_res_timer_s1_chipselect = cpu_data_master_granted_high_res_timer_s1;
  //high_res_timer_s1_firsttransfer first transaction, which is an e_assign
  assign high_res_timer_s1_firsttransfer = high_res_timer_s1_begins_xfer ? high_res_timer_s1_unreg_firsttransfer : high_res_timer_s1_reg_firsttransfer;

  //high_res_timer_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign high_res_timer_s1_unreg_firsttransfer = ~(high_res_timer_s1_slavearbiterlockenable & high_res_timer_s1_any_continuerequest);

  //high_res_timer_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          high_res_timer_s1_reg_firsttransfer <= 1'b1;
      else if (high_res_timer_s1_begins_xfer)
          high_res_timer_s1_reg_firsttransfer <= high_res_timer_s1_unreg_firsttransfer;
    end


  //high_res_timer_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign high_res_timer_s1_beginbursttransfer_internal = high_res_timer_s1_begins_xfer;

  //~high_res_timer_s1_write_n assignment, which is an e_mux
  assign high_res_timer_s1_write_n = ~(cpu_data_master_granted_high_res_timer_s1 & cpu_data_master_write);

  assign shifted_address_to_high_res_timer_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //high_res_timer_s1_address mux, which is an e_mux
  assign high_res_timer_s1_address = shifted_address_to_high_res_timer_s1_from_cpu_data_master >> 2;

  //d1_high_res_timer_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_high_res_timer_s1_end_xfer <= 1;
      else 
        d1_high_res_timer_s1_end_xfer <= high_res_timer_s1_end_xfer;
    end


  //high_res_timer_s1_waits_for_read in a cycle, which is an e_mux
  assign high_res_timer_s1_waits_for_read = high_res_timer_s1_in_a_read_cycle & high_res_timer_s1_begins_xfer;

  //high_res_timer_s1_in_a_read_cycle assignment, which is an e_assign
  assign high_res_timer_s1_in_a_read_cycle = cpu_data_master_granted_high_res_timer_s1 & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = high_res_timer_s1_in_a_read_cycle;

  //high_res_timer_s1_waits_for_write in a cycle, which is an e_mux
  assign high_res_timer_s1_waits_for_write = high_res_timer_s1_in_a_write_cycle & 0;

  //high_res_timer_s1_in_a_write_cycle assignment, which is an e_assign
  assign high_res_timer_s1_in_a_write_cycle = cpu_data_master_granted_high_res_timer_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = high_res_timer_s1_in_a_write_cycle;

  assign wait_for_high_res_timer_s1_counter = 0;
  //assign high_res_timer_s1_irq_from_sa = high_res_timer_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign high_res_timer_s1_irq_from_sa = high_res_timer_s1_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //high_res_timer/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module jtag_uart_avalon_jtag_slave_arbitrator (
                                                // inputs:
                                                 clk,
                                                 cpu_data_master_address_to_slave,
                                                 cpu_data_master_read,
                                                 cpu_data_master_waitrequest,
                                                 cpu_data_master_write,
                                                 cpu_data_master_writedata,
                                                 jtag_uart_avalon_jtag_slave_dataavailable,
                                                 jtag_uart_avalon_jtag_slave_irq,
                                                 jtag_uart_avalon_jtag_slave_readdata,
                                                 jtag_uart_avalon_jtag_slave_readyfordata,
                                                 jtag_uart_avalon_jtag_slave_waitrequest,
                                                 reset_n,

                                                // outputs:
                                                 cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
                                                 cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
                                                 cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
                                                 cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
                                                 d1_jtag_uart_avalon_jtag_slave_end_xfer,
                                                 jtag_uart_avalon_jtag_slave_address,
                                                 jtag_uart_avalon_jtag_slave_chipselect,
                                                 jtag_uart_avalon_jtag_slave_dataavailable_from_sa,
                                                 jtag_uart_avalon_jtag_slave_irq_from_sa,
                                                 jtag_uart_avalon_jtag_slave_read_n,
                                                 jtag_uart_avalon_jtag_slave_readdata_from_sa,
                                                 jtag_uart_avalon_jtag_slave_readyfordata_from_sa,
                                                 jtag_uart_avalon_jtag_slave_reset_n,
                                                 jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
                                                 jtag_uart_avalon_jtag_slave_write_n,
                                                 jtag_uart_avalon_jtag_slave_writedata
                                              )
;

  output           cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  output           cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  output           cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  output           cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  output           d1_jtag_uart_avalon_jtag_slave_end_xfer;
  output           jtag_uart_avalon_jtag_slave_address;
  output           jtag_uart_avalon_jtag_slave_chipselect;
  output           jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  output           jtag_uart_avalon_jtag_slave_irq_from_sa;
  output           jtag_uart_avalon_jtag_slave_read_n;
  output  [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  output           jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  output           jtag_uart_avalon_jtag_slave_reset_n;
  output           jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  output           jtag_uart_avalon_jtag_slave_write_n;
  output  [ 31: 0] jtag_uart_avalon_jtag_slave_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            jtag_uart_avalon_jtag_slave_dataavailable;
  input            jtag_uart_avalon_jtag_slave_irq;
  input   [ 31: 0] jtag_uart_avalon_jtag_slave_readdata;
  input            jtag_uart_avalon_jtag_slave_readyfordata;
  input            jtag_uart_avalon_jtag_slave_waitrequest;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave;
  reg              d1_jtag_uart_avalon_jtag_slave_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire             jtag_uart_avalon_jtag_slave_address;
  wire             jtag_uart_avalon_jtag_slave_allgrants;
  wire             jtag_uart_avalon_jtag_slave_allow_new_arb_cycle;
  wire             jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant;
  wire             jtag_uart_avalon_jtag_slave_any_continuerequest;
  wire             jtag_uart_avalon_jtag_slave_arb_counter_enable;
  reg     [  1: 0] jtag_uart_avalon_jtag_slave_arb_share_counter;
  wire    [  1: 0] jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
  wire    [  1: 0] jtag_uart_avalon_jtag_slave_arb_share_set_values;
  wire             jtag_uart_avalon_jtag_slave_beginbursttransfer_internal;
  wire             jtag_uart_avalon_jtag_slave_begins_xfer;
  wire             jtag_uart_avalon_jtag_slave_chipselect;
  wire             jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_avalon_jtag_slave_end_xfer;
  wire             jtag_uart_avalon_jtag_slave_firsttransfer;
  wire             jtag_uart_avalon_jtag_slave_grant_vector;
  wire             jtag_uart_avalon_jtag_slave_in_a_read_cycle;
  wire             jtag_uart_avalon_jtag_slave_in_a_write_cycle;
  wire             jtag_uart_avalon_jtag_slave_irq_from_sa;
  wire             jtag_uart_avalon_jtag_slave_master_qreq_vector;
  wire             jtag_uart_avalon_jtag_slave_non_bursting_master_requests;
  wire             jtag_uart_avalon_jtag_slave_read_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  wire             jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  reg              jtag_uart_avalon_jtag_slave_reg_firsttransfer;
  wire             jtag_uart_avalon_jtag_slave_reset_n;
  reg              jtag_uart_avalon_jtag_slave_slavearbiterlockenable;
  wire             jtag_uart_avalon_jtag_slave_slavearbiterlockenable2;
  wire             jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
  wire             jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  wire             jtag_uart_avalon_jtag_slave_waits_for_read;
  wire             jtag_uart_avalon_jtag_slave_waits_for_write;
  wire             jtag_uart_avalon_jtag_slave_write_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_writedata;
  wire    [ 26: 0] shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master;
  wire             wait_for_jtag_uart_avalon_jtag_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~jtag_uart_avalon_jtag_slave_end_xfer;
    end


  assign jtag_uart_avalon_jtag_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave));
  //assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata;

  assign cpu_data_master_requests_jtag_uart_avalon_jtag_slave = ({cpu_data_master_address_to_slave[26 : 3] , 3'b0} == 27'h3978) & (cpu_data_master_read | cpu_data_master_write);
  //assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable;

  //assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata;

  //assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest;

  //jtag_uart_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_arb_share_set_values = 1;

  //jtag_uart_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_non_bursting_master_requests = cpu_data_master_requests_jtag_uart_avalon_jtag_slave;

  //jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant = 0;

  //jtag_uart_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_arb_share_counter_next_value = jtag_uart_avalon_jtag_slave_firsttransfer ? (jtag_uart_avalon_jtag_slave_arb_share_set_values - 1) : |jtag_uart_avalon_jtag_slave_arb_share_counter ? (jtag_uart_avalon_jtag_slave_arb_share_counter - 1) : 0;

  //jtag_uart_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_allgrants = |jtag_uart_avalon_jtag_slave_grant_vector;

  //jtag_uart_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_end_xfer = ~(jtag_uart_avalon_jtag_slave_waits_for_read | jtag_uart_avalon_jtag_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave = jtag_uart_avalon_jtag_slave_end_xfer & (~jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //jtag_uart_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave & jtag_uart_avalon_jtag_slave_allgrants) | (end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave & ~jtag_uart_avalon_jtag_slave_non_bursting_master_requests);

  //jtag_uart_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_avalon_jtag_slave_arb_share_counter <= 0;
      else if (jtag_uart_avalon_jtag_slave_arb_counter_enable)
          jtag_uart_avalon_jtag_slave_arb_share_counter <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
    end


  //jtag_uart_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= 0;
      else if ((|jtag_uart_avalon_jtag_slave_master_qreq_vector & end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave) | (end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave & ~jtag_uart_avalon_jtag_slave_non_bursting_master_requests))
          jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= |jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
    end


  //cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = jtag_uart_avalon_jtag_slave_slavearbiterlockenable & cpu_data_master_continuerequest;

  //jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 = |jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;

  //cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //jtag_uart_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave = cpu_data_master_requests_jtag_uart_avalon_jtag_slave & ~((cpu_data_master_read & (~cpu_data_master_waitrequest)) | ((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //jtag_uart_avalon_jtag_slave_writedata mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_jtag_uart_avalon_jtag_slave = cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;

  //cpu/data_master saved-grant jtag_uart/avalon_jtag_slave, which is an e_assign
  assign cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave = cpu_data_master_requests_jtag_uart_avalon_jtag_slave;

  //allow new arb cycle for jtag_uart/avalon_jtag_slave, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign jtag_uart_avalon_jtag_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign jtag_uart_avalon_jtag_slave_master_qreq_vector = 1;

  //jtag_uart_avalon_jtag_slave_reset_n assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_reset_n = reset_n;

  assign jtag_uart_avalon_jtag_slave_chipselect = cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  //jtag_uart_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_firsttransfer = jtag_uart_avalon_jtag_slave_begins_xfer ? jtag_uart_avalon_jtag_slave_unreg_firsttransfer : jtag_uart_avalon_jtag_slave_reg_firsttransfer;

  //jtag_uart_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_unreg_firsttransfer = ~(jtag_uart_avalon_jtag_slave_slavearbiterlockenable & jtag_uart_avalon_jtag_slave_any_continuerequest);

  //jtag_uart_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_avalon_jtag_slave_reg_firsttransfer <= 1'b1;
      else if (jtag_uart_avalon_jtag_slave_begins_xfer)
          jtag_uart_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
    end


  //jtag_uart_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_beginbursttransfer_internal = jtag_uart_avalon_jtag_slave_begins_xfer;

  //~jtag_uart_avalon_jtag_slave_read_n assignment, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_read_n = ~(cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_read);

  //~jtag_uart_avalon_jtag_slave_write_n assignment, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_write_n = ~(cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_write);

  assign shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master = cpu_data_master_address_to_slave;
  //jtag_uart_avalon_jtag_slave_address mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_address = shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master >> 2;

  //d1_jtag_uart_avalon_jtag_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_jtag_uart_avalon_jtag_slave_end_xfer <= 1;
      else 
        d1_jtag_uart_avalon_jtag_slave_end_xfer <= jtag_uart_avalon_jtag_slave_end_xfer;
    end


  //jtag_uart_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_waits_for_read = jtag_uart_avalon_jtag_slave_in_a_read_cycle & jtag_uart_avalon_jtag_slave_waitrequest_from_sa;

  //jtag_uart_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_in_a_read_cycle = cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = jtag_uart_avalon_jtag_slave_in_a_read_cycle;

  //jtag_uart_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_waits_for_write = jtag_uart_avalon_jtag_slave_in_a_write_cycle & jtag_uart_avalon_jtag_slave_waitrequest_from_sa;

  //jtag_uart_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_in_a_write_cycle = cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = jtag_uart_avalon_jtag_slave_in_a_write_cycle;

  assign wait_for_jtag_uart_avalon_jtag_slave_counter = 0;
  //assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //jtag_uart/avalon_jtag_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module key_s1_arbitrator (
                           // inputs:
                            clk,
                            cpu_data_master_address_to_slave,
                            cpu_data_master_read,
                            cpu_data_master_waitrequest,
                            cpu_data_master_write,
                            cpu_data_master_writedata,
                            key_s1_irq,
                            key_s1_readdata,
                            reset_n,

                           // outputs:
                            cpu_data_master_granted_key_s1,
                            cpu_data_master_qualified_request_key_s1,
                            cpu_data_master_read_data_valid_key_s1,
                            cpu_data_master_requests_key_s1,
                            d1_key_s1_end_xfer,
                            key_s1_address,
                            key_s1_chipselect,
                            key_s1_irq_from_sa,
                            key_s1_readdata_from_sa,
                            key_s1_reset_n,
                            key_s1_write_n,
                            key_s1_writedata
                         )
;

  output           cpu_data_master_granted_key_s1;
  output           cpu_data_master_qualified_request_key_s1;
  output           cpu_data_master_read_data_valid_key_s1;
  output           cpu_data_master_requests_key_s1;
  output           d1_key_s1_end_xfer;
  output  [  1: 0] key_s1_address;
  output           key_s1_chipselect;
  output           key_s1_irq_from_sa;
  output  [ 31: 0] key_s1_readdata_from_sa;
  output           key_s1_reset_n;
  output           key_s1_write_n;
  output  [ 31: 0] key_s1_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            key_s1_irq;
  input   [ 31: 0] key_s1_readdata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_key_s1;
  wire             cpu_data_master_qualified_request_key_s1;
  wire             cpu_data_master_read_data_valid_key_s1;
  wire             cpu_data_master_requests_key_s1;
  wire             cpu_data_master_saved_grant_key_s1;
  reg              d1_key_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_key_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [  1: 0] key_s1_address;
  wire             key_s1_allgrants;
  wire             key_s1_allow_new_arb_cycle;
  wire             key_s1_any_bursting_master_saved_grant;
  wire             key_s1_any_continuerequest;
  wire             key_s1_arb_counter_enable;
  reg     [  1: 0] key_s1_arb_share_counter;
  wire    [  1: 0] key_s1_arb_share_counter_next_value;
  wire    [  1: 0] key_s1_arb_share_set_values;
  wire             key_s1_beginbursttransfer_internal;
  wire             key_s1_begins_xfer;
  wire             key_s1_chipselect;
  wire             key_s1_end_xfer;
  wire             key_s1_firsttransfer;
  wire             key_s1_grant_vector;
  wire             key_s1_in_a_read_cycle;
  wire             key_s1_in_a_write_cycle;
  wire             key_s1_irq_from_sa;
  wire             key_s1_master_qreq_vector;
  wire             key_s1_non_bursting_master_requests;
  wire    [ 31: 0] key_s1_readdata_from_sa;
  reg              key_s1_reg_firsttransfer;
  wire             key_s1_reset_n;
  reg              key_s1_slavearbiterlockenable;
  wire             key_s1_slavearbiterlockenable2;
  wire             key_s1_unreg_firsttransfer;
  wire             key_s1_waits_for_read;
  wire             key_s1_waits_for_write;
  wire             key_s1_write_n;
  wire    [ 31: 0] key_s1_writedata;
  wire    [ 26: 0] shifted_address_to_key_s1_from_cpu_data_master;
  wire             wait_for_key_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~key_s1_end_xfer;
    end


  assign key_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_key_s1));
  //assign key_s1_readdata_from_sa = key_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign key_s1_readdata_from_sa = key_s1_readdata;

  assign cpu_data_master_requests_key_s1 = ({cpu_data_master_address_to_slave[26 : 4] , 4'b0} == 27'h3940) & (cpu_data_master_read | cpu_data_master_write);
  //key_s1_arb_share_counter set values, which is an e_mux
  assign key_s1_arb_share_set_values = 1;

  //key_s1_non_bursting_master_requests mux, which is an e_mux
  assign key_s1_non_bursting_master_requests = cpu_data_master_requests_key_s1;

  //key_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign key_s1_any_bursting_master_saved_grant = 0;

  //key_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign key_s1_arb_share_counter_next_value = key_s1_firsttransfer ? (key_s1_arb_share_set_values - 1) : |key_s1_arb_share_counter ? (key_s1_arb_share_counter - 1) : 0;

  //key_s1_allgrants all slave grants, which is an e_mux
  assign key_s1_allgrants = |key_s1_grant_vector;

  //key_s1_end_xfer assignment, which is an e_assign
  assign key_s1_end_xfer = ~(key_s1_waits_for_read | key_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_key_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_key_s1 = key_s1_end_xfer & (~key_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //key_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign key_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_key_s1 & key_s1_allgrants) | (end_xfer_arb_share_counter_term_key_s1 & ~key_s1_non_bursting_master_requests);

  //key_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          key_s1_arb_share_counter <= 0;
      else if (key_s1_arb_counter_enable)
          key_s1_arb_share_counter <= key_s1_arb_share_counter_next_value;
    end


  //key_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          key_s1_slavearbiterlockenable <= 0;
      else if ((|key_s1_master_qreq_vector & end_xfer_arb_share_counter_term_key_s1) | (end_xfer_arb_share_counter_term_key_s1 & ~key_s1_non_bursting_master_requests))
          key_s1_slavearbiterlockenable <= |key_s1_arb_share_counter_next_value;
    end


  //cpu/data_master key/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = key_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //key_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign key_s1_slavearbiterlockenable2 = |key_s1_arb_share_counter_next_value;

  //cpu/data_master key/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = key_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //key_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign key_s1_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_key_s1 = cpu_data_master_requests_key_s1 & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //key_s1_writedata mux, which is an e_mux
  assign key_s1_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_key_s1 = cpu_data_master_qualified_request_key_s1;

  //cpu/data_master saved-grant key/s1, which is an e_assign
  assign cpu_data_master_saved_grant_key_s1 = cpu_data_master_requests_key_s1;

  //allow new arb cycle for key/s1, which is an e_assign
  assign key_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign key_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign key_s1_master_qreq_vector = 1;

  //key_s1_reset_n assignment, which is an e_assign
  assign key_s1_reset_n = reset_n;

  assign key_s1_chipselect = cpu_data_master_granted_key_s1;
  //key_s1_firsttransfer first transaction, which is an e_assign
  assign key_s1_firsttransfer = key_s1_begins_xfer ? key_s1_unreg_firsttransfer : key_s1_reg_firsttransfer;

  //key_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign key_s1_unreg_firsttransfer = ~(key_s1_slavearbiterlockenable & key_s1_any_continuerequest);

  //key_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          key_s1_reg_firsttransfer <= 1'b1;
      else if (key_s1_begins_xfer)
          key_s1_reg_firsttransfer <= key_s1_unreg_firsttransfer;
    end


  //key_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign key_s1_beginbursttransfer_internal = key_s1_begins_xfer;

  //~key_s1_write_n assignment, which is an e_mux
  assign key_s1_write_n = ~(cpu_data_master_granted_key_s1 & cpu_data_master_write);

  assign shifted_address_to_key_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //key_s1_address mux, which is an e_mux
  assign key_s1_address = shifted_address_to_key_s1_from_cpu_data_master >> 2;

  //d1_key_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_key_s1_end_xfer <= 1;
      else 
        d1_key_s1_end_xfer <= key_s1_end_xfer;
    end


  //key_s1_waits_for_read in a cycle, which is an e_mux
  assign key_s1_waits_for_read = key_s1_in_a_read_cycle & key_s1_begins_xfer;

  //key_s1_in_a_read_cycle assignment, which is an e_assign
  assign key_s1_in_a_read_cycle = cpu_data_master_granted_key_s1 & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = key_s1_in_a_read_cycle;

  //key_s1_waits_for_write in a cycle, which is an e_mux
  assign key_s1_waits_for_write = key_s1_in_a_write_cycle & 0;

  //key_s1_in_a_write_cycle assignment, which is an e_assign
  assign key_s1_in_a_write_cycle = cpu_data_master_granted_key_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = key_s1_in_a_write_cycle;

  assign wait_for_key_s1_counter = 0;
  //assign key_s1_irq_from_sa = key_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign key_s1_irq_from_sa = key_s1_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //key/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module lcd_control_slave_arbitrator (
                                      // inputs:
                                       clk,
                                       cpu_data_master_address_to_slave,
                                       cpu_data_master_byteenable,
                                       cpu_data_master_read,
                                       cpu_data_master_write,
                                       cpu_data_master_writedata,
                                       lcd_control_slave_readdata,
                                       reset_n,

                                      // outputs:
                                       cpu_data_master_granted_lcd_control_slave,
                                       cpu_data_master_qualified_request_lcd_control_slave,
                                       cpu_data_master_read_data_valid_lcd_control_slave,
                                       cpu_data_master_requests_lcd_control_slave,
                                       d1_lcd_control_slave_end_xfer,
                                       lcd_control_slave_address,
                                       lcd_control_slave_begintransfer,
                                       lcd_control_slave_read,
                                       lcd_control_slave_readdata_from_sa,
                                       lcd_control_slave_reset_n,
                                       lcd_control_slave_wait_counter_eq_0,
                                       lcd_control_slave_wait_counter_eq_1,
                                       lcd_control_slave_write,
                                       lcd_control_slave_writedata
                                    )
;

  output           cpu_data_master_granted_lcd_control_slave;
  output           cpu_data_master_qualified_request_lcd_control_slave;
  output           cpu_data_master_read_data_valid_lcd_control_slave;
  output           cpu_data_master_requests_lcd_control_slave;
  output           d1_lcd_control_slave_end_xfer;
  output  [  1: 0] lcd_control_slave_address;
  output           lcd_control_slave_begintransfer;
  output           lcd_control_slave_read;
  output  [  7: 0] lcd_control_slave_readdata_from_sa;
  output           lcd_control_slave_reset_n;
  output           lcd_control_slave_wait_counter_eq_0;
  output           lcd_control_slave_wait_counter_eq_1;
  output           lcd_control_slave_write;
  output  [  7: 0] lcd_control_slave_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input   [  3: 0] cpu_data_master_byteenable;
  input            cpu_data_master_read;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [  7: 0] lcd_control_slave_readdata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_lcd_control_slave;
  wire             cpu_data_master_qualified_request_lcd_control_slave;
  wire             cpu_data_master_read_data_valid_lcd_control_slave;
  wire             cpu_data_master_requests_lcd_control_slave;
  wire             cpu_data_master_saved_grant_lcd_control_slave;
  reg              d1_lcd_control_slave_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_lcd_control_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [  1: 0] lcd_control_slave_address;
  wire             lcd_control_slave_allgrants;
  wire             lcd_control_slave_allow_new_arb_cycle;
  wire             lcd_control_slave_any_bursting_master_saved_grant;
  wire             lcd_control_slave_any_continuerequest;
  wire             lcd_control_slave_arb_counter_enable;
  reg     [  1: 0] lcd_control_slave_arb_share_counter;
  wire    [  1: 0] lcd_control_slave_arb_share_counter_next_value;
  wire    [  1: 0] lcd_control_slave_arb_share_set_values;
  wire             lcd_control_slave_beginbursttransfer_internal;
  wire             lcd_control_slave_begins_xfer;
  wire             lcd_control_slave_begintransfer;
  wire    [  5: 0] lcd_control_slave_counter_load_value;
  wire             lcd_control_slave_end_xfer;
  wire             lcd_control_slave_firsttransfer;
  wire             lcd_control_slave_grant_vector;
  wire             lcd_control_slave_in_a_read_cycle;
  wire             lcd_control_slave_in_a_write_cycle;
  wire             lcd_control_slave_master_qreq_vector;
  wire             lcd_control_slave_non_bursting_master_requests;
  wire             lcd_control_slave_pretend_byte_enable;
  wire             lcd_control_slave_read;
  wire    [  7: 0] lcd_control_slave_readdata_from_sa;
  reg              lcd_control_slave_reg_firsttransfer;
  wire             lcd_control_slave_reset_n;
  reg              lcd_control_slave_slavearbiterlockenable;
  wire             lcd_control_slave_slavearbiterlockenable2;
  wire             lcd_control_slave_unreg_firsttransfer;
  reg     [  5: 0] lcd_control_slave_wait_counter;
  wire             lcd_control_slave_wait_counter_eq_0;
  wire             lcd_control_slave_wait_counter_eq_1;
  wire             lcd_control_slave_waits_for_read;
  wire             lcd_control_slave_waits_for_write;
  wire             lcd_control_slave_write;
  wire    [  7: 0] lcd_control_slave_writedata;
  wire    [ 26: 0] shifted_address_to_lcd_control_slave_from_cpu_data_master;
  wire             wait_for_lcd_control_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~lcd_control_slave_end_xfer;
    end


  assign lcd_control_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_lcd_control_slave));
  //assign lcd_control_slave_readdata_from_sa = lcd_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign lcd_control_slave_readdata_from_sa = lcd_control_slave_readdata;

  assign cpu_data_master_requests_lcd_control_slave = ({cpu_data_master_address_to_slave[26 : 4] , 4'b0} == 27'h3960) & (cpu_data_master_read | cpu_data_master_write);
  //lcd_control_slave_arb_share_counter set values, which is an e_mux
  assign lcd_control_slave_arb_share_set_values = 1;

  //lcd_control_slave_non_bursting_master_requests mux, which is an e_mux
  assign lcd_control_slave_non_bursting_master_requests = cpu_data_master_requests_lcd_control_slave;

  //lcd_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign lcd_control_slave_any_bursting_master_saved_grant = 0;

  //lcd_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign lcd_control_slave_arb_share_counter_next_value = lcd_control_slave_firsttransfer ? (lcd_control_slave_arb_share_set_values - 1) : |lcd_control_slave_arb_share_counter ? (lcd_control_slave_arb_share_counter - 1) : 0;

  //lcd_control_slave_allgrants all slave grants, which is an e_mux
  assign lcd_control_slave_allgrants = |lcd_control_slave_grant_vector;

  //lcd_control_slave_end_xfer assignment, which is an e_assign
  assign lcd_control_slave_end_xfer = ~(lcd_control_slave_waits_for_read | lcd_control_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_lcd_control_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_lcd_control_slave = lcd_control_slave_end_xfer & (~lcd_control_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //lcd_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign lcd_control_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_lcd_control_slave & lcd_control_slave_allgrants) | (end_xfer_arb_share_counter_term_lcd_control_slave & ~lcd_control_slave_non_bursting_master_requests);

  //lcd_control_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          lcd_control_slave_arb_share_counter <= 0;
      else if (lcd_control_slave_arb_counter_enable)
          lcd_control_slave_arb_share_counter <= lcd_control_slave_arb_share_counter_next_value;
    end


  //lcd_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          lcd_control_slave_slavearbiterlockenable <= 0;
      else if ((|lcd_control_slave_master_qreq_vector & end_xfer_arb_share_counter_term_lcd_control_slave) | (end_xfer_arb_share_counter_term_lcd_control_slave & ~lcd_control_slave_non_bursting_master_requests))
          lcd_control_slave_slavearbiterlockenable <= |lcd_control_slave_arb_share_counter_next_value;
    end


  //cpu/data_master lcd/control_slave arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = lcd_control_slave_slavearbiterlockenable & cpu_data_master_continuerequest;

  //lcd_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign lcd_control_slave_slavearbiterlockenable2 = |lcd_control_slave_arb_share_counter_next_value;

  //cpu/data_master lcd/control_slave arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = lcd_control_slave_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //lcd_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign lcd_control_slave_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_lcd_control_slave = cpu_data_master_requests_lcd_control_slave;
  //lcd_control_slave_writedata mux, which is an e_mux
  assign lcd_control_slave_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_lcd_control_slave = cpu_data_master_qualified_request_lcd_control_slave;

  //cpu/data_master saved-grant lcd/control_slave, which is an e_assign
  assign cpu_data_master_saved_grant_lcd_control_slave = cpu_data_master_requests_lcd_control_slave;

  //allow new arb cycle for lcd/control_slave, which is an e_assign
  assign lcd_control_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign lcd_control_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign lcd_control_slave_master_qreq_vector = 1;

  assign lcd_control_slave_begintransfer = lcd_control_slave_begins_xfer;
  //lcd_control_slave_reset_n assignment, which is an e_assign
  assign lcd_control_slave_reset_n = reset_n;

  //lcd_control_slave_firsttransfer first transaction, which is an e_assign
  assign lcd_control_slave_firsttransfer = lcd_control_slave_begins_xfer ? lcd_control_slave_unreg_firsttransfer : lcd_control_slave_reg_firsttransfer;

  //lcd_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign lcd_control_slave_unreg_firsttransfer = ~(lcd_control_slave_slavearbiterlockenable & lcd_control_slave_any_continuerequest);

  //lcd_control_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          lcd_control_slave_reg_firsttransfer <= 1'b1;
      else if (lcd_control_slave_begins_xfer)
          lcd_control_slave_reg_firsttransfer <= lcd_control_slave_unreg_firsttransfer;
    end


  //lcd_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign lcd_control_slave_beginbursttransfer_internal = lcd_control_slave_begins_xfer;

  //lcd_control_slave_read assignment, which is an e_mux
  assign lcd_control_slave_read = ((cpu_data_master_granted_lcd_control_slave & cpu_data_master_read))& ~lcd_control_slave_begins_xfer & (lcd_control_slave_wait_counter < 12);

  //lcd_control_slave_write assignment, which is an e_mux
  assign lcd_control_slave_write = ((cpu_data_master_granted_lcd_control_slave & cpu_data_master_write)) & ~lcd_control_slave_begins_xfer & (lcd_control_slave_wait_counter >= 12) & (lcd_control_slave_wait_counter < 24) & lcd_control_slave_pretend_byte_enable;

  assign shifted_address_to_lcd_control_slave_from_cpu_data_master = cpu_data_master_address_to_slave;
  //lcd_control_slave_address mux, which is an e_mux
  assign lcd_control_slave_address = shifted_address_to_lcd_control_slave_from_cpu_data_master >> 2;

  //d1_lcd_control_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_lcd_control_slave_end_xfer <= 1;
      else 
        d1_lcd_control_slave_end_xfer <= lcd_control_slave_end_xfer;
    end


  //lcd_control_slave_wait_counter_eq_1 assignment, which is an e_assign
  assign lcd_control_slave_wait_counter_eq_1 = lcd_control_slave_wait_counter == 1;

  //lcd_control_slave_waits_for_read in a cycle, which is an e_mux
  assign lcd_control_slave_waits_for_read = lcd_control_slave_in_a_read_cycle & wait_for_lcd_control_slave_counter;

  //lcd_control_slave_in_a_read_cycle assignment, which is an e_assign
  assign lcd_control_slave_in_a_read_cycle = cpu_data_master_granted_lcd_control_slave & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = lcd_control_slave_in_a_read_cycle;

  //lcd_control_slave_waits_for_write in a cycle, which is an e_mux
  assign lcd_control_slave_waits_for_write = lcd_control_slave_in_a_write_cycle & wait_for_lcd_control_slave_counter;

  //lcd_control_slave_in_a_write_cycle assignment, which is an e_assign
  assign lcd_control_slave_in_a_write_cycle = cpu_data_master_granted_lcd_control_slave & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = lcd_control_slave_in_a_write_cycle;

  assign lcd_control_slave_wait_counter_eq_0 = lcd_control_slave_wait_counter == 0;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          lcd_control_slave_wait_counter <= 0;
      else 
        lcd_control_slave_wait_counter <= lcd_control_slave_counter_load_value;
    end


  assign lcd_control_slave_counter_load_value = ((lcd_control_slave_in_a_read_cycle & lcd_control_slave_begins_xfer))? 22 :
    ((lcd_control_slave_in_a_write_cycle & lcd_control_slave_begins_xfer))? 34 :
    (~lcd_control_slave_wait_counter_eq_0)? lcd_control_slave_wait_counter - 1 :
    0;

  assign wait_for_lcd_control_slave_counter = lcd_control_slave_begins_xfer | ~lcd_control_slave_wait_counter_eq_0;
  //lcd_control_slave_pretend_byte_enable byte enable port mux, which is an e_mux
  assign lcd_control_slave_pretend_byte_enable = (cpu_data_master_granted_lcd_control_slave)? cpu_data_master_byteenable :
    -1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //lcd/control_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module led_s1_arbitrator (
                           // inputs:
                            clk,
                            cpu_data_master_address_to_slave,
                            cpu_data_master_read,
                            cpu_data_master_waitrequest,
                            cpu_data_master_write,
                            cpu_data_master_writedata,
                            led_s1_readdata,
                            reset_n,

                           // outputs:
                            cpu_data_master_granted_led_s1,
                            cpu_data_master_qualified_request_led_s1,
                            cpu_data_master_read_data_valid_led_s1,
                            cpu_data_master_requests_led_s1,
                            d1_led_s1_end_xfer,
                            led_s1_address,
                            led_s1_chipselect,
                            led_s1_readdata_from_sa,
                            led_s1_reset_n,
                            led_s1_write_n,
                            led_s1_writedata
                         )
;

  output           cpu_data_master_granted_led_s1;
  output           cpu_data_master_qualified_request_led_s1;
  output           cpu_data_master_read_data_valid_led_s1;
  output           cpu_data_master_requests_led_s1;
  output           d1_led_s1_end_xfer;
  output  [  2: 0] led_s1_address;
  output           led_s1_chipselect;
  output  [ 31: 0] led_s1_readdata_from_sa;
  output           led_s1_reset_n;
  output           led_s1_write_n;
  output  [ 31: 0] led_s1_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 31: 0] led_s1_readdata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_led_s1;
  wire             cpu_data_master_qualified_request_led_s1;
  wire             cpu_data_master_read_data_valid_led_s1;
  wire             cpu_data_master_requests_led_s1;
  wire             cpu_data_master_saved_grant_led_s1;
  reg              d1_led_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_led_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [  2: 0] led_s1_address;
  wire             led_s1_allgrants;
  wire             led_s1_allow_new_arb_cycle;
  wire             led_s1_any_bursting_master_saved_grant;
  wire             led_s1_any_continuerequest;
  wire             led_s1_arb_counter_enable;
  reg     [  1: 0] led_s1_arb_share_counter;
  wire    [  1: 0] led_s1_arb_share_counter_next_value;
  wire    [  1: 0] led_s1_arb_share_set_values;
  wire             led_s1_beginbursttransfer_internal;
  wire             led_s1_begins_xfer;
  wire             led_s1_chipselect;
  wire             led_s1_end_xfer;
  wire             led_s1_firsttransfer;
  wire             led_s1_grant_vector;
  wire             led_s1_in_a_read_cycle;
  wire             led_s1_in_a_write_cycle;
  wire             led_s1_master_qreq_vector;
  wire             led_s1_non_bursting_master_requests;
  wire    [ 31: 0] led_s1_readdata_from_sa;
  reg              led_s1_reg_firsttransfer;
  wire             led_s1_reset_n;
  reg              led_s1_slavearbiterlockenable;
  wire             led_s1_slavearbiterlockenable2;
  wire             led_s1_unreg_firsttransfer;
  wire             led_s1_waits_for_read;
  wire             led_s1_waits_for_write;
  wire             led_s1_write_n;
  wire    [ 31: 0] led_s1_writedata;
  wire    [ 26: 0] shifted_address_to_led_s1_from_cpu_data_master;
  wire             wait_for_led_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~led_s1_end_xfer;
    end


  assign led_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_led_s1));
  //assign led_s1_readdata_from_sa = led_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign led_s1_readdata_from_sa = led_s1_readdata;

  assign cpu_data_master_requests_led_s1 = ({cpu_data_master_address_to_slave[26 : 5] , 5'b0} == 27'h3840) & (cpu_data_master_read | cpu_data_master_write);
  //led_s1_arb_share_counter set values, which is an e_mux
  assign led_s1_arb_share_set_values = 1;

  //led_s1_non_bursting_master_requests mux, which is an e_mux
  assign led_s1_non_bursting_master_requests = cpu_data_master_requests_led_s1;

  //led_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign led_s1_any_bursting_master_saved_grant = 0;

  //led_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign led_s1_arb_share_counter_next_value = led_s1_firsttransfer ? (led_s1_arb_share_set_values - 1) : |led_s1_arb_share_counter ? (led_s1_arb_share_counter - 1) : 0;

  //led_s1_allgrants all slave grants, which is an e_mux
  assign led_s1_allgrants = |led_s1_grant_vector;

  //led_s1_end_xfer assignment, which is an e_assign
  assign led_s1_end_xfer = ~(led_s1_waits_for_read | led_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_led_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_led_s1 = led_s1_end_xfer & (~led_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //led_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign led_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_led_s1 & led_s1_allgrants) | (end_xfer_arb_share_counter_term_led_s1 & ~led_s1_non_bursting_master_requests);

  //led_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          led_s1_arb_share_counter <= 0;
      else if (led_s1_arb_counter_enable)
          led_s1_arb_share_counter <= led_s1_arb_share_counter_next_value;
    end


  //led_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          led_s1_slavearbiterlockenable <= 0;
      else if ((|led_s1_master_qreq_vector & end_xfer_arb_share_counter_term_led_s1) | (end_xfer_arb_share_counter_term_led_s1 & ~led_s1_non_bursting_master_requests))
          led_s1_slavearbiterlockenable <= |led_s1_arb_share_counter_next_value;
    end


  //cpu/data_master led/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = led_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //led_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign led_s1_slavearbiterlockenable2 = |led_s1_arb_share_counter_next_value;

  //cpu/data_master led/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = led_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //led_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign led_s1_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_led_s1 = cpu_data_master_requests_led_s1 & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //led_s1_writedata mux, which is an e_mux
  assign led_s1_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_led_s1 = cpu_data_master_qualified_request_led_s1;

  //cpu/data_master saved-grant led/s1, which is an e_assign
  assign cpu_data_master_saved_grant_led_s1 = cpu_data_master_requests_led_s1;

  //allow new arb cycle for led/s1, which is an e_assign
  assign led_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign led_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign led_s1_master_qreq_vector = 1;

  //led_s1_reset_n assignment, which is an e_assign
  assign led_s1_reset_n = reset_n;

  assign led_s1_chipselect = cpu_data_master_granted_led_s1;
  //led_s1_firsttransfer first transaction, which is an e_assign
  assign led_s1_firsttransfer = led_s1_begins_xfer ? led_s1_unreg_firsttransfer : led_s1_reg_firsttransfer;

  //led_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign led_s1_unreg_firsttransfer = ~(led_s1_slavearbiterlockenable & led_s1_any_continuerequest);

  //led_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          led_s1_reg_firsttransfer <= 1'b1;
      else if (led_s1_begins_xfer)
          led_s1_reg_firsttransfer <= led_s1_unreg_firsttransfer;
    end


  //led_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign led_s1_beginbursttransfer_internal = led_s1_begins_xfer;

  //~led_s1_write_n assignment, which is an e_mux
  assign led_s1_write_n = ~(cpu_data_master_granted_led_s1 & cpu_data_master_write);

  assign shifted_address_to_led_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //led_s1_address mux, which is an e_mux
  assign led_s1_address = shifted_address_to_led_s1_from_cpu_data_master >> 2;

  //d1_led_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_led_s1_end_xfer <= 1;
      else 
        d1_led_s1_end_xfer <= led_s1_end_xfer;
    end


  //led_s1_waits_for_read in a cycle, which is an e_mux
  assign led_s1_waits_for_read = led_s1_in_a_read_cycle & led_s1_begins_xfer;

  //led_s1_in_a_read_cycle assignment, which is an e_assign
  assign led_s1_in_a_read_cycle = cpu_data_master_granted_led_s1 & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = led_s1_in_a_read_cycle;

  //led_s1_waits_for_write in a cycle, which is an e_mux
  assign led_s1_waits_for_write = led_s1_in_a_write_cycle & 0;

  //led_s1_in_a_write_cycle assignment, which is an e_assign
  assign led_s1_in_a_write_cycle = cpu_data_master_granted_led_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = led_s1_in_a_write_cycle;

  assign wait_for_led_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //led/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module onchip_ram_s1_arbitrator (
                                  // inputs:
                                   clk,
                                   cpu_data_master_address_to_slave,
                                   cpu_data_master_byteenable,
                                   cpu_data_master_read,
                                   cpu_data_master_waitrequest,
                                   cpu_data_master_write,
                                   cpu_data_master_writedata,
                                   cpu_instruction_master_address_to_slave,
                                   cpu_instruction_master_latency_counter,
                                   cpu_instruction_master_read,
                                   cpu_instruction_master_read_data_valid_sdram_s1_shift_register,
                                   onchip_ram_s1_readdata,
                                   reset_n,

                                  // outputs:
                                   cpu_data_master_granted_onchip_ram_s1,
                                   cpu_data_master_qualified_request_onchip_ram_s1,
                                   cpu_data_master_read_data_valid_onchip_ram_s1,
                                   cpu_data_master_requests_onchip_ram_s1,
                                   cpu_instruction_master_granted_onchip_ram_s1,
                                   cpu_instruction_master_qualified_request_onchip_ram_s1,
                                   cpu_instruction_master_read_data_valid_onchip_ram_s1,
                                   cpu_instruction_master_requests_onchip_ram_s1,
                                   d1_onchip_ram_s1_end_xfer,
                                   onchip_ram_s1_address,
                                   onchip_ram_s1_byteenable,
                                   onchip_ram_s1_chipselect,
                                   onchip_ram_s1_clken,
                                   onchip_ram_s1_readdata_from_sa,
                                   onchip_ram_s1_reset,
                                   onchip_ram_s1_write,
                                   onchip_ram_s1_writedata,
                                   registered_cpu_data_master_read_data_valid_onchip_ram_s1
                                )
;

  output           cpu_data_master_granted_onchip_ram_s1;
  output           cpu_data_master_qualified_request_onchip_ram_s1;
  output           cpu_data_master_read_data_valid_onchip_ram_s1;
  output           cpu_data_master_requests_onchip_ram_s1;
  output           cpu_instruction_master_granted_onchip_ram_s1;
  output           cpu_instruction_master_qualified_request_onchip_ram_s1;
  output           cpu_instruction_master_read_data_valid_onchip_ram_s1;
  output           cpu_instruction_master_requests_onchip_ram_s1;
  output           d1_onchip_ram_s1_end_xfer;
  output  [  9: 0] onchip_ram_s1_address;
  output  [  3: 0] onchip_ram_s1_byteenable;
  output           onchip_ram_s1_chipselect;
  output           onchip_ram_s1_clken;
  output  [ 31: 0] onchip_ram_s1_readdata_from_sa;
  output           onchip_ram_s1_reset;
  output           onchip_ram_s1_write;
  output  [ 31: 0] onchip_ram_s1_writedata;
  output           registered_cpu_data_master_read_data_valid_onchip_ram_s1;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input   [  3: 0] cpu_data_master_byteenable;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 26: 0] cpu_instruction_master_address_to_slave;
  input            cpu_instruction_master_latency_counter;
  input            cpu_instruction_master_read;
  input            cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  input   [ 31: 0] onchip_ram_s1_readdata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_onchip_ram_s1;
  wire             cpu_data_master_qualified_request_onchip_ram_s1;
  wire             cpu_data_master_read_data_valid_onchip_ram_s1;
  reg              cpu_data_master_read_data_valid_onchip_ram_s1_shift_register;
  wire             cpu_data_master_read_data_valid_onchip_ram_s1_shift_register_in;
  wire             cpu_data_master_requests_onchip_ram_s1;
  wire             cpu_data_master_saved_grant_onchip_ram_s1;
  wire             cpu_instruction_master_arbiterlock;
  wire             cpu_instruction_master_arbiterlock2;
  wire             cpu_instruction_master_continuerequest;
  wire             cpu_instruction_master_granted_onchip_ram_s1;
  wire             cpu_instruction_master_qualified_request_onchip_ram_s1;
  wire             cpu_instruction_master_read_data_valid_onchip_ram_s1;
  reg              cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register;
  wire             cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register_in;
  wire             cpu_instruction_master_requests_onchip_ram_s1;
  wire             cpu_instruction_master_saved_grant_onchip_ram_s1;
  reg              d1_onchip_ram_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_onchip_ram_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_data_master_granted_slave_onchip_ram_s1;
  reg              last_cycle_cpu_instruction_master_granted_slave_onchip_ram_s1;
  wire    [  9: 0] onchip_ram_s1_address;
  wire             onchip_ram_s1_allgrants;
  wire             onchip_ram_s1_allow_new_arb_cycle;
  wire             onchip_ram_s1_any_bursting_master_saved_grant;
  wire             onchip_ram_s1_any_continuerequest;
  reg     [  1: 0] onchip_ram_s1_arb_addend;
  wire             onchip_ram_s1_arb_counter_enable;
  reg     [  1: 0] onchip_ram_s1_arb_share_counter;
  wire    [  1: 0] onchip_ram_s1_arb_share_counter_next_value;
  wire    [  1: 0] onchip_ram_s1_arb_share_set_values;
  wire    [  1: 0] onchip_ram_s1_arb_winner;
  wire             onchip_ram_s1_arbitration_holdoff_internal;
  wire             onchip_ram_s1_beginbursttransfer_internal;
  wire             onchip_ram_s1_begins_xfer;
  wire    [  3: 0] onchip_ram_s1_byteenable;
  wire             onchip_ram_s1_chipselect;
  wire    [  3: 0] onchip_ram_s1_chosen_master_double_vector;
  wire    [  1: 0] onchip_ram_s1_chosen_master_rot_left;
  wire             onchip_ram_s1_clken;
  wire             onchip_ram_s1_end_xfer;
  wire             onchip_ram_s1_firsttransfer;
  wire    [  1: 0] onchip_ram_s1_grant_vector;
  wire             onchip_ram_s1_in_a_read_cycle;
  wire             onchip_ram_s1_in_a_write_cycle;
  wire    [  1: 0] onchip_ram_s1_master_qreq_vector;
  wire             onchip_ram_s1_non_bursting_master_requests;
  wire    [ 31: 0] onchip_ram_s1_readdata_from_sa;
  reg              onchip_ram_s1_reg_firsttransfer;
  wire             onchip_ram_s1_reset;
  reg     [  1: 0] onchip_ram_s1_saved_chosen_master_vector;
  reg              onchip_ram_s1_slavearbiterlockenable;
  wire             onchip_ram_s1_slavearbiterlockenable2;
  wire             onchip_ram_s1_unreg_firsttransfer;
  wire             onchip_ram_s1_waits_for_read;
  wire             onchip_ram_s1_waits_for_write;
  wire             onchip_ram_s1_write;
  wire    [ 31: 0] onchip_ram_s1_writedata;
  wire             p1_cpu_data_master_read_data_valid_onchip_ram_s1_shift_register;
  wire             p1_cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register;
  wire             registered_cpu_data_master_read_data_valid_onchip_ram_s1;
  wire    [ 26: 0] shifted_address_to_onchip_ram_s1_from_cpu_data_master;
  wire    [ 26: 0] shifted_address_to_onchip_ram_s1_from_cpu_instruction_master;
  wire             wait_for_onchip_ram_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~onchip_ram_s1_end_xfer;
    end


  assign onchip_ram_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_onchip_ram_s1 | cpu_instruction_master_qualified_request_onchip_ram_s1));
  //assign onchip_ram_s1_readdata_from_sa = onchip_ram_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign onchip_ram_s1_readdata_from_sa = onchip_ram_s1_readdata;

  assign cpu_data_master_requests_onchip_ram_s1 = ({cpu_data_master_address_to_slave[26 : 12] , 12'b0} == 27'h2000) & (cpu_data_master_read | cpu_data_master_write);
  //registered rdv signal_name registered_cpu_data_master_read_data_valid_onchip_ram_s1 assignment, which is an e_assign
  assign registered_cpu_data_master_read_data_valid_onchip_ram_s1 = cpu_data_master_read_data_valid_onchip_ram_s1_shift_register_in;

  //onchip_ram_s1_arb_share_counter set values, which is an e_mux
  assign onchip_ram_s1_arb_share_set_values = 1;

  //onchip_ram_s1_non_bursting_master_requests mux, which is an e_mux
  assign onchip_ram_s1_non_bursting_master_requests = cpu_data_master_requests_onchip_ram_s1 |
    cpu_instruction_master_requests_onchip_ram_s1 |
    cpu_data_master_requests_onchip_ram_s1 |
    cpu_instruction_master_requests_onchip_ram_s1;

  //onchip_ram_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign onchip_ram_s1_any_bursting_master_saved_grant = 0;

  //onchip_ram_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign onchip_ram_s1_arb_share_counter_next_value = onchip_ram_s1_firsttransfer ? (onchip_ram_s1_arb_share_set_values - 1) : |onchip_ram_s1_arb_share_counter ? (onchip_ram_s1_arb_share_counter - 1) : 0;

  //onchip_ram_s1_allgrants all slave grants, which is an e_mux
  assign onchip_ram_s1_allgrants = (|onchip_ram_s1_grant_vector) |
    (|onchip_ram_s1_grant_vector) |
    (|onchip_ram_s1_grant_vector) |
    (|onchip_ram_s1_grant_vector);

  //onchip_ram_s1_end_xfer assignment, which is an e_assign
  assign onchip_ram_s1_end_xfer = ~(onchip_ram_s1_waits_for_read | onchip_ram_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_onchip_ram_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_onchip_ram_s1 = onchip_ram_s1_end_xfer & (~onchip_ram_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //onchip_ram_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign onchip_ram_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_onchip_ram_s1 & onchip_ram_s1_allgrants) | (end_xfer_arb_share_counter_term_onchip_ram_s1 & ~onchip_ram_s1_non_bursting_master_requests);

  //onchip_ram_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_ram_s1_arb_share_counter <= 0;
      else if (onchip_ram_s1_arb_counter_enable)
          onchip_ram_s1_arb_share_counter <= onchip_ram_s1_arb_share_counter_next_value;
    end


  //onchip_ram_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_ram_s1_slavearbiterlockenable <= 0;
      else if ((|onchip_ram_s1_master_qreq_vector & end_xfer_arb_share_counter_term_onchip_ram_s1) | (end_xfer_arb_share_counter_term_onchip_ram_s1 & ~onchip_ram_s1_non_bursting_master_requests))
          onchip_ram_s1_slavearbiterlockenable <= |onchip_ram_s1_arb_share_counter_next_value;
    end


  //cpu/data_master onchip_ram/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = onchip_ram_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //onchip_ram_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign onchip_ram_s1_slavearbiterlockenable2 = |onchip_ram_s1_arb_share_counter_next_value;

  //cpu/data_master onchip_ram/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = onchip_ram_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //cpu/instruction_master onchip_ram/s1 arbiterlock, which is an e_assign
  assign cpu_instruction_master_arbiterlock = onchip_ram_s1_slavearbiterlockenable & cpu_instruction_master_continuerequest;

  //cpu/instruction_master onchip_ram/s1 arbiterlock2, which is an e_assign
  assign cpu_instruction_master_arbiterlock2 = onchip_ram_s1_slavearbiterlockenable2 & cpu_instruction_master_continuerequest;

  //cpu/instruction_master granted onchip_ram/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_instruction_master_granted_slave_onchip_ram_s1 <= 0;
      else 
        last_cycle_cpu_instruction_master_granted_slave_onchip_ram_s1 <= cpu_instruction_master_saved_grant_onchip_ram_s1 ? 1 : (onchip_ram_s1_arbitration_holdoff_internal | ~cpu_instruction_master_requests_onchip_ram_s1) ? 0 : last_cycle_cpu_instruction_master_granted_slave_onchip_ram_s1;
    end


  //cpu_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_instruction_master_continuerequest = last_cycle_cpu_instruction_master_granted_slave_onchip_ram_s1 & cpu_instruction_master_requests_onchip_ram_s1;

  //onchip_ram_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  assign onchip_ram_s1_any_continuerequest = cpu_instruction_master_continuerequest |
    cpu_data_master_continuerequest;

  assign cpu_data_master_qualified_request_onchip_ram_s1 = cpu_data_master_requests_onchip_ram_s1 & ~((cpu_data_master_read & ((|cpu_data_master_read_data_valid_onchip_ram_s1_shift_register))) | ((~cpu_data_master_waitrequest) & cpu_data_master_write) | cpu_instruction_master_arbiterlock);
  //cpu_data_master_read_data_valid_onchip_ram_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  assign cpu_data_master_read_data_valid_onchip_ram_s1_shift_register_in = cpu_data_master_granted_onchip_ram_s1 & cpu_data_master_read & ~onchip_ram_s1_waits_for_read & ~(|cpu_data_master_read_data_valid_onchip_ram_s1_shift_register);

  //shift register p1 cpu_data_master_read_data_valid_onchip_ram_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  assign p1_cpu_data_master_read_data_valid_onchip_ram_s1_shift_register = {cpu_data_master_read_data_valid_onchip_ram_s1_shift_register, cpu_data_master_read_data_valid_onchip_ram_s1_shift_register_in};

  //cpu_data_master_read_data_valid_onchip_ram_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_data_master_read_data_valid_onchip_ram_s1_shift_register <= 0;
      else 
        cpu_data_master_read_data_valid_onchip_ram_s1_shift_register <= p1_cpu_data_master_read_data_valid_onchip_ram_s1_shift_register;
    end


  //local readdatavalid cpu_data_master_read_data_valid_onchip_ram_s1, which is an e_mux
  assign cpu_data_master_read_data_valid_onchip_ram_s1 = cpu_data_master_read_data_valid_onchip_ram_s1_shift_register;

  //onchip_ram_s1_writedata mux, which is an e_mux
  assign onchip_ram_s1_writedata = cpu_data_master_writedata;

  //mux onchip_ram_s1_clken, which is an e_mux
  assign onchip_ram_s1_clken = 1'b1;

  assign cpu_instruction_master_requests_onchip_ram_s1 = (({cpu_instruction_master_address_to_slave[26 : 12] , 12'b0} == 27'h2000) & (cpu_instruction_master_read)) & cpu_instruction_master_read;
  //cpu/data_master granted onchip_ram/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_data_master_granted_slave_onchip_ram_s1 <= 0;
      else 
        last_cycle_cpu_data_master_granted_slave_onchip_ram_s1 <= cpu_data_master_saved_grant_onchip_ram_s1 ? 1 : (onchip_ram_s1_arbitration_holdoff_internal | ~cpu_data_master_requests_onchip_ram_s1) ? 0 : last_cycle_cpu_data_master_granted_slave_onchip_ram_s1;
    end


  //cpu_data_master_continuerequest continued request, which is an e_mux
  assign cpu_data_master_continuerequest = last_cycle_cpu_data_master_granted_slave_onchip_ram_s1 & cpu_data_master_requests_onchip_ram_s1;

  assign cpu_instruction_master_qualified_request_onchip_ram_s1 = cpu_instruction_master_requests_onchip_ram_s1 & ~((cpu_instruction_master_read & ((1 < cpu_instruction_master_latency_counter) | (|cpu_instruction_master_read_data_valid_sdram_s1_shift_register))) | cpu_data_master_arbiterlock);
  //cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  assign cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register_in = cpu_instruction_master_granted_onchip_ram_s1 & cpu_instruction_master_read & ~onchip_ram_s1_waits_for_read;

  //shift register p1 cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  assign p1_cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register = {cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register, cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register_in};

  //cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register <= 0;
      else 
        cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register <= p1_cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register;
    end


  //local readdatavalid cpu_instruction_master_read_data_valid_onchip_ram_s1, which is an e_mux
  assign cpu_instruction_master_read_data_valid_onchip_ram_s1 = cpu_instruction_master_read_data_valid_onchip_ram_s1_shift_register;

  //allow new arb cycle for onchip_ram/s1, which is an e_assign
  assign onchip_ram_s1_allow_new_arb_cycle = ~cpu_data_master_arbiterlock & ~cpu_instruction_master_arbiterlock;

  //cpu/instruction_master assignment into master qualified-requests vector for onchip_ram/s1, which is an e_assign
  assign onchip_ram_s1_master_qreq_vector[0] = cpu_instruction_master_qualified_request_onchip_ram_s1;

  //cpu/instruction_master grant onchip_ram/s1, which is an e_assign
  assign cpu_instruction_master_granted_onchip_ram_s1 = onchip_ram_s1_grant_vector[0];

  //cpu/instruction_master saved-grant onchip_ram/s1, which is an e_assign
  assign cpu_instruction_master_saved_grant_onchip_ram_s1 = onchip_ram_s1_arb_winner[0] && cpu_instruction_master_requests_onchip_ram_s1;

  //cpu/data_master assignment into master qualified-requests vector for onchip_ram/s1, which is an e_assign
  assign onchip_ram_s1_master_qreq_vector[1] = cpu_data_master_qualified_request_onchip_ram_s1;

  //cpu/data_master grant onchip_ram/s1, which is an e_assign
  assign cpu_data_master_granted_onchip_ram_s1 = onchip_ram_s1_grant_vector[1];

  //cpu/data_master saved-grant onchip_ram/s1, which is an e_assign
  assign cpu_data_master_saved_grant_onchip_ram_s1 = onchip_ram_s1_arb_winner[1] && cpu_data_master_requests_onchip_ram_s1;

  //onchip_ram/s1 chosen-master double-vector, which is an e_assign
  assign onchip_ram_s1_chosen_master_double_vector = {onchip_ram_s1_master_qreq_vector, onchip_ram_s1_master_qreq_vector} & ({~onchip_ram_s1_master_qreq_vector, ~onchip_ram_s1_master_qreq_vector} + onchip_ram_s1_arb_addend);

  //stable onehot encoding of arb winner
  assign onchip_ram_s1_arb_winner = (onchip_ram_s1_allow_new_arb_cycle & | onchip_ram_s1_grant_vector) ? onchip_ram_s1_grant_vector : onchip_ram_s1_saved_chosen_master_vector;

  //saved onchip_ram_s1_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_ram_s1_saved_chosen_master_vector <= 0;
      else if (onchip_ram_s1_allow_new_arb_cycle)
          onchip_ram_s1_saved_chosen_master_vector <= |onchip_ram_s1_grant_vector ? onchip_ram_s1_grant_vector : onchip_ram_s1_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign onchip_ram_s1_grant_vector = {(onchip_ram_s1_chosen_master_double_vector[1] | onchip_ram_s1_chosen_master_double_vector[3]),
    (onchip_ram_s1_chosen_master_double_vector[0] | onchip_ram_s1_chosen_master_double_vector[2])};

  //onchip_ram/s1 chosen master rotated left, which is an e_assign
  assign onchip_ram_s1_chosen_master_rot_left = (onchip_ram_s1_arb_winner << 1) ? (onchip_ram_s1_arb_winner << 1) : 1;

  //onchip_ram/s1's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_ram_s1_arb_addend <= 1;
      else if (|onchip_ram_s1_grant_vector)
          onchip_ram_s1_arb_addend <= onchip_ram_s1_end_xfer? onchip_ram_s1_chosen_master_rot_left : onchip_ram_s1_grant_vector;
    end


  //~onchip_ram_s1_reset assignment, which is an e_assign
  assign onchip_ram_s1_reset = ~reset_n;

  assign onchip_ram_s1_chipselect = cpu_data_master_granted_onchip_ram_s1 | cpu_instruction_master_granted_onchip_ram_s1;
  //onchip_ram_s1_firsttransfer first transaction, which is an e_assign
  assign onchip_ram_s1_firsttransfer = onchip_ram_s1_begins_xfer ? onchip_ram_s1_unreg_firsttransfer : onchip_ram_s1_reg_firsttransfer;

  //onchip_ram_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign onchip_ram_s1_unreg_firsttransfer = ~(onchip_ram_s1_slavearbiterlockenable & onchip_ram_s1_any_continuerequest);

  //onchip_ram_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_ram_s1_reg_firsttransfer <= 1'b1;
      else if (onchip_ram_s1_begins_xfer)
          onchip_ram_s1_reg_firsttransfer <= onchip_ram_s1_unreg_firsttransfer;
    end


  //onchip_ram_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign onchip_ram_s1_beginbursttransfer_internal = onchip_ram_s1_begins_xfer;

  //onchip_ram_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign onchip_ram_s1_arbitration_holdoff_internal = onchip_ram_s1_begins_xfer & onchip_ram_s1_firsttransfer;

  //onchip_ram_s1_write assignment, which is an e_mux
  assign onchip_ram_s1_write = cpu_data_master_granted_onchip_ram_s1 & cpu_data_master_write;

  assign shifted_address_to_onchip_ram_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //onchip_ram_s1_address mux, which is an e_mux
  assign onchip_ram_s1_address = (cpu_data_master_granted_onchip_ram_s1)? (shifted_address_to_onchip_ram_s1_from_cpu_data_master >> 2) :
    (shifted_address_to_onchip_ram_s1_from_cpu_instruction_master >> 2);

  assign shifted_address_to_onchip_ram_s1_from_cpu_instruction_master = cpu_instruction_master_address_to_slave;
  //d1_onchip_ram_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_onchip_ram_s1_end_xfer <= 1;
      else 
        d1_onchip_ram_s1_end_xfer <= onchip_ram_s1_end_xfer;
    end


  //onchip_ram_s1_waits_for_read in a cycle, which is an e_mux
  assign onchip_ram_s1_waits_for_read = onchip_ram_s1_in_a_read_cycle & 0;

  //onchip_ram_s1_in_a_read_cycle assignment, which is an e_assign
  assign onchip_ram_s1_in_a_read_cycle = (cpu_data_master_granted_onchip_ram_s1 & cpu_data_master_read) | (cpu_instruction_master_granted_onchip_ram_s1 & cpu_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = onchip_ram_s1_in_a_read_cycle;

  //onchip_ram_s1_waits_for_write in a cycle, which is an e_mux
  assign onchip_ram_s1_waits_for_write = onchip_ram_s1_in_a_write_cycle & 0;

  //onchip_ram_s1_in_a_write_cycle assignment, which is an e_assign
  assign onchip_ram_s1_in_a_write_cycle = cpu_data_master_granted_onchip_ram_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = onchip_ram_s1_in_a_write_cycle;

  assign wait_for_onchip_ram_s1_counter = 0;
  //onchip_ram_s1_byteenable byte enable port mux, which is an e_mux
  assign onchip_ram_s1_byteenable = (cpu_data_master_granted_onchip_ram_s1)? cpu_data_master_byteenable :
    -1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //onchip_ram/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_granted_onchip_ram_s1 + cpu_instruction_master_granted_onchip_ram_s1 > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_saved_grant_onchip_ram_s1 + cpu_instruction_master_saved_grant_onchip_ram_s1 > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module rdv_fifo_for_cpu_data_master_to_sdram_s1_module (
                                                         // inputs:
                                                          clear_fifo,
                                                          clk,
                                                          data_in,
                                                          read,
                                                          reset_n,
                                                          sync_reset,
                                                          write,

                                                         // outputs:
                                                          data_out,
                                                          empty,
                                                          fifo_contains_ones_n,
                                                          full
                                                       )
;

  output           data_out;
  output           empty;
  output           fifo_contains_ones_n;
  output           full;
  input            clear_fifo;
  input            clk;
  input            data_in;
  input            read;
  input            reset_n;
  input            sync_reset;
  input            write;

  wire             data_out;
  wire             empty;
  reg              fifo_contains_ones_n;
  wire             full;
  reg              full_0;
  reg              full_1;
  reg              full_2;
  reg              full_3;
  reg              full_4;
  reg              full_5;
  wire             full_6;
  reg     [  3: 0] how_many_ones;
  wire    [  3: 0] one_count_minus_one;
  wire    [  3: 0] one_count_plus_one;
  wire             p0_full_0;
  wire             p0_stage_0;
  wire             p1_full_1;
  wire             p1_stage_1;
  wire             p2_full_2;
  wire             p2_stage_2;
  wire             p3_full_3;
  wire             p3_stage_3;
  wire             p4_full_4;
  wire             p4_stage_4;
  wire             p5_full_5;
  wire             p5_stage_5;
  reg              stage_0;
  reg              stage_1;
  reg              stage_2;
  reg              stage_3;
  reg              stage_4;
  reg              stage_5;
  wire    [  3: 0] updated_one_count;
  assign data_out = stage_0;
  assign full = full_5;
  assign empty = !full_0;
  assign full_6 = 0;
  //data_5, which is an e_mux
  assign p5_stage_5 = ((full_6 & ~clear_fifo) == 0)? data_in :
    data_in;

  //data_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_5 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_5))
          if (sync_reset & full_5 & !((full_6 == 0) & read & write))
              stage_5 <= 0;
          else 
            stage_5 <= p5_stage_5;
    end


  //control_5, which is an e_mux
  assign p5_full_5 = ((read & !write) == 0)? full_4 :
    0;

  //control_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_5 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_5 <= 0;
          else 
            full_5 <= p5_full_5;
    end


  //data_4, which is an e_mux
  assign p4_stage_4 = ((full_5 & ~clear_fifo) == 0)? data_in :
    stage_5;

  //data_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_4 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_4))
          if (sync_reset & full_4 & !((full_5 == 0) & read & write))
              stage_4 <= 0;
          else 
            stage_4 <= p4_stage_4;
    end


  //control_4, which is an e_mux
  assign p4_full_4 = ((read & !write) == 0)? full_3 :
    full_5;

  //control_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_4 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_4 <= 0;
          else 
            full_4 <= p4_full_4;
    end


  //data_3, which is an e_mux
  assign p3_stage_3 = ((full_4 & ~clear_fifo) == 0)? data_in :
    stage_4;

  //data_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_3 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_3))
          if (sync_reset & full_3 & !((full_4 == 0) & read & write))
              stage_3 <= 0;
          else 
            stage_3 <= p3_stage_3;
    end


  //control_3, which is an e_mux
  assign p3_full_3 = ((read & !write) == 0)? full_2 :
    full_4;

  //control_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_3 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_3 <= 0;
          else 
            full_3 <= p3_full_3;
    end


  //data_2, which is an e_mux
  assign p2_stage_2 = ((full_3 & ~clear_fifo) == 0)? data_in :
    stage_3;

  //data_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_2 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_2))
          if (sync_reset & full_2 & !((full_3 == 0) & read & write))
              stage_2 <= 0;
          else 
            stage_2 <= p2_stage_2;
    end


  //control_2, which is an e_mux
  assign p2_full_2 = ((read & !write) == 0)? full_1 :
    full_3;

  //control_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_2 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_2 <= 0;
          else 
            full_2 <= p2_full_2;
    end


  //data_1, which is an e_mux
  assign p1_stage_1 = ((full_2 & ~clear_fifo) == 0)? data_in :
    stage_2;

  //data_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_1 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_1))
          if (sync_reset & full_1 & !((full_2 == 0) & read & write))
              stage_1 <= 0;
          else 
            stage_1 <= p1_stage_1;
    end


  //control_1, which is an e_mux
  assign p1_full_1 = ((read & !write) == 0)? full_0 :
    full_2;

  //control_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_1 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_1 <= 0;
          else 
            full_1 <= p1_full_1;
    end


  //data_0, which is an e_mux
  assign p0_stage_0 = ((full_1 & ~clear_fifo) == 0)? data_in :
    stage_1;

  //data_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_0 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_0))
          if (sync_reset & full_0 & !((full_1 == 0) & read & write))
              stage_0 <= 0;
          else 
            stage_0 <= p0_stage_0;
    end


  //control_0, which is an e_mux
  assign p0_full_0 = ((read & !write) == 0)? 1 :
    full_1;

  //control_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_0 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo & ~write)
              full_0 <= 0;
          else 
            full_0 <= p0_full_0;
    end


  assign one_count_plus_one = how_many_ones + 1;
  assign one_count_minus_one = how_many_ones - 1;
  //updated_one_count, which is an e_mux
  assign updated_one_count = ((((clear_fifo | sync_reset) & !write)))? 0 :
    ((((clear_fifo | sync_reset) & write)))? |data_in :
    ((read & (|data_in) & write & (|stage_0)))? how_many_ones :
    ((write & (|data_in)))? one_count_plus_one :
    ((read & (|stage_0)))? one_count_minus_one :
    how_many_ones;

  //counts how many ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          how_many_ones <= 0;
      else if (clear_fifo | sync_reset | read | write)
          how_many_ones <= updated_one_count;
    end


  //this fifo contains ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          fifo_contains_ones_n <= 1;
      else if (clear_fifo | sync_reset | read | write)
          fifo_contains_ones_n <= ~(|updated_one_count);
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module rdv_fifo_for_cpu_instruction_master_to_sdram_s1_module (
                                                                // inputs:
                                                                 clear_fifo,
                                                                 clk,
                                                                 data_in,
                                                                 read,
                                                                 reset_n,
                                                                 sync_reset,
                                                                 write,

                                                                // outputs:
                                                                 data_out,
                                                                 empty,
                                                                 fifo_contains_ones_n,
                                                                 full
                                                              )
;

  output           data_out;
  output           empty;
  output           fifo_contains_ones_n;
  output           full;
  input            clear_fifo;
  input            clk;
  input            data_in;
  input            read;
  input            reset_n;
  input            sync_reset;
  input            write;

  wire             data_out;
  wire             empty;
  reg              fifo_contains_ones_n;
  wire             full;
  reg              full_0;
  reg              full_1;
  reg              full_2;
  reg              full_3;
  reg              full_4;
  reg              full_5;
  wire             full_6;
  reg     [  3: 0] how_many_ones;
  wire    [  3: 0] one_count_minus_one;
  wire    [  3: 0] one_count_plus_one;
  wire             p0_full_0;
  wire             p0_stage_0;
  wire             p1_full_1;
  wire             p1_stage_1;
  wire             p2_full_2;
  wire             p2_stage_2;
  wire             p3_full_3;
  wire             p3_stage_3;
  wire             p4_full_4;
  wire             p4_stage_4;
  wire             p5_full_5;
  wire             p5_stage_5;
  reg              stage_0;
  reg              stage_1;
  reg              stage_2;
  reg              stage_3;
  reg              stage_4;
  reg              stage_5;
  wire    [  3: 0] updated_one_count;
  assign data_out = stage_0;
  assign full = full_5;
  assign empty = !full_0;
  assign full_6 = 0;
  //data_5, which is an e_mux
  assign p5_stage_5 = ((full_6 & ~clear_fifo) == 0)? data_in :
    data_in;

  //data_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_5 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_5))
          if (sync_reset & full_5 & !((full_6 == 0) & read & write))
              stage_5 <= 0;
          else 
            stage_5 <= p5_stage_5;
    end


  //control_5, which is an e_mux
  assign p5_full_5 = ((read & !write) == 0)? full_4 :
    0;

  //control_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_5 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_5 <= 0;
          else 
            full_5 <= p5_full_5;
    end


  //data_4, which is an e_mux
  assign p4_stage_4 = ((full_5 & ~clear_fifo) == 0)? data_in :
    stage_5;

  //data_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_4 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_4))
          if (sync_reset & full_4 & !((full_5 == 0) & read & write))
              stage_4 <= 0;
          else 
            stage_4 <= p4_stage_4;
    end


  //control_4, which is an e_mux
  assign p4_full_4 = ((read & !write) == 0)? full_3 :
    full_5;

  //control_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_4 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_4 <= 0;
          else 
            full_4 <= p4_full_4;
    end


  //data_3, which is an e_mux
  assign p3_stage_3 = ((full_4 & ~clear_fifo) == 0)? data_in :
    stage_4;

  //data_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_3 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_3))
          if (sync_reset & full_3 & !((full_4 == 0) & read & write))
              stage_3 <= 0;
          else 
            stage_3 <= p3_stage_3;
    end


  //control_3, which is an e_mux
  assign p3_full_3 = ((read & !write) == 0)? full_2 :
    full_4;

  //control_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_3 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_3 <= 0;
          else 
            full_3 <= p3_full_3;
    end


  //data_2, which is an e_mux
  assign p2_stage_2 = ((full_3 & ~clear_fifo) == 0)? data_in :
    stage_3;

  //data_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_2 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_2))
          if (sync_reset & full_2 & !((full_3 == 0) & read & write))
              stage_2 <= 0;
          else 
            stage_2 <= p2_stage_2;
    end


  //control_2, which is an e_mux
  assign p2_full_2 = ((read & !write) == 0)? full_1 :
    full_3;

  //control_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_2 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_2 <= 0;
          else 
            full_2 <= p2_full_2;
    end


  //data_1, which is an e_mux
  assign p1_stage_1 = ((full_2 & ~clear_fifo) == 0)? data_in :
    stage_2;

  //data_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_1 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_1))
          if (sync_reset & full_1 & !((full_2 == 0) & read & write))
              stage_1 <= 0;
          else 
            stage_1 <= p1_stage_1;
    end


  //control_1, which is an e_mux
  assign p1_full_1 = ((read & !write) == 0)? full_0 :
    full_2;

  //control_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_1 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_1 <= 0;
          else 
            full_1 <= p1_full_1;
    end


  //data_0, which is an e_mux
  assign p0_stage_0 = ((full_1 & ~clear_fifo) == 0)? data_in :
    stage_1;

  //data_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_0 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_0))
          if (sync_reset & full_0 & !((full_1 == 0) & read & write))
              stage_0 <= 0;
          else 
            stage_0 <= p0_stage_0;
    end


  //control_0, which is an e_mux
  assign p0_full_0 = ((read & !write) == 0)? 1 :
    full_1;

  //control_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_0 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo & ~write)
              full_0 <= 0;
          else 
            full_0 <= p0_full_0;
    end


  assign one_count_plus_one = how_many_ones + 1;
  assign one_count_minus_one = how_many_ones - 1;
  //updated_one_count, which is an e_mux
  assign updated_one_count = ((((clear_fifo | sync_reset) & !write)))? 0 :
    ((((clear_fifo | sync_reset) & write)))? |data_in :
    ((read & (|data_in) & write & (|stage_0)))? how_many_ones :
    ((write & (|data_in)))? one_count_plus_one :
    ((read & (|stage_0)))? one_count_minus_one :
    how_many_ones;

  //counts how many ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          how_many_ones <= 0;
      else if (clear_fifo | sync_reset | read | write)
          how_many_ones <= updated_one_count;
    end


  //this fifo contains ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          fifo_contains_ones_n <= 1;
      else if (clear_fifo | sync_reset | read | write)
          fifo_contains_ones_n <= ~(|updated_one_count);
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sdram_s1_arbitrator (
                             // inputs:
                              clk,
                              cpu_data_master_address_to_slave,
                              cpu_data_master_byteenable,
                              cpu_data_master_dbs_address,
                              cpu_data_master_dbs_write_16,
                              cpu_data_master_no_byte_enables_and_last_term,
                              cpu_data_master_read,
                              cpu_data_master_waitrequest,
                              cpu_data_master_write,
                              cpu_instruction_master_address_to_slave,
                              cpu_instruction_master_dbs_address,
                              cpu_instruction_master_latency_counter,
                              cpu_instruction_master_read,
                              reset_n,
                              sdram_s1_readdata,
                              sdram_s1_readdatavalid,
                              sdram_s1_waitrequest,

                             // outputs:
                              cpu_data_master_byteenable_sdram_s1,
                              cpu_data_master_granted_sdram_s1,
                              cpu_data_master_qualified_request_sdram_s1,
                              cpu_data_master_read_data_valid_sdram_s1,
                              cpu_data_master_read_data_valid_sdram_s1_shift_register,
                              cpu_data_master_requests_sdram_s1,
                              cpu_instruction_master_granted_sdram_s1,
                              cpu_instruction_master_qualified_request_sdram_s1,
                              cpu_instruction_master_read_data_valid_sdram_s1,
                              cpu_instruction_master_read_data_valid_sdram_s1_shift_register,
                              cpu_instruction_master_requests_sdram_s1,
                              d1_sdram_s1_end_xfer,
                              sdram_s1_address,
                              sdram_s1_byteenable_n,
                              sdram_s1_chipselect,
                              sdram_s1_read_n,
                              sdram_s1_readdata_from_sa,
                              sdram_s1_reset_n,
                              sdram_s1_waitrequest_from_sa,
                              sdram_s1_write_n,
                              sdram_s1_writedata
                           )
;

  output  [  1: 0] cpu_data_master_byteenable_sdram_s1;
  output           cpu_data_master_granted_sdram_s1;
  output           cpu_data_master_qualified_request_sdram_s1;
  output           cpu_data_master_read_data_valid_sdram_s1;
  output           cpu_data_master_read_data_valid_sdram_s1_shift_register;
  output           cpu_data_master_requests_sdram_s1;
  output           cpu_instruction_master_granted_sdram_s1;
  output           cpu_instruction_master_qualified_request_sdram_s1;
  output           cpu_instruction_master_read_data_valid_sdram_s1;
  output           cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  output           cpu_instruction_master_requests_sdram_s1;
  output           d1_sdram_s1_end_xfer;
  output  [ 23: 0] sdram_s1_address;
  output  [  1: 0] sdram_s1_byteenable_n;
  output           sdram_s1_chipselect;
  output           sdram_s1_read_n;
  output  [ 15: 0] sdram_s1_readdata_from_sa;
  output           sdram_s1_reset_n;
  output           sdram_s1_waitrequest_from_sa;
  output           sdram_s1_write_n;
  output  [ 15: 0] sdram_s1_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input   [  3: 0] cpu_data_master_byteenable;
  input   [  1: 0] cpu_data_master_dbs_address;
  input   [ 15: 0] cpu_data_master_dbs_write_16;
  input            cpu_data_master_no_byte_enables_and_last_term;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 26: 0] cpu_instruction_master_address_to_slave;
  input   [  1: 0] cpu_instruction_master_dbs_address;
  input            cpu_instruction_master_latency_counter;
  input            cpu_instruction_master_read;
  input            reset_n;
  input   [ 15: 0] sdram_s1_readdata;
  input            sdram_s1_readdatavalid;
  input            sdram_s1_waitrequest;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire    [  1: 0] cpu_data_master_byteenable_sdram_s1;
  wire    [  1: 0] cpu_data_master_byteenable_sdram_s1_segment_0;
  wire    [  1: 0] cpu_data_master_byteenable_sdram_s1_segment_1;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_sdram_s1;
  wire             cpu_data_master_qualified_request_sdram_s1;
  wire             cpu_data_master_rdv_fifo_empty_sdram_s1;
  wire             cpu_data_master_rdv_fifo_output_from_sdram_s1;
  wire             cpu_data_master_read_data_valid_sdram_s1;
  wire             cpu_data_master_read_data_valid_sdram_s1_shift_register;
  wire             cpu_data_master_requests_sdram_s1;
  wire             cpu_data_master_saved_grant_sdram_s1;
  wire             cpu_instruction_master_arbiterlock;
  wire             cpu_instruction_master_arbiterlock2;
  wire             cpu_instruction_master_continuerequest;
  wire             cpu_instruction_master_granted_sdram_s1;
  wire             cpu_instruction_master_qualified_request_sdram_s1;
  wire             cpu_instruction_master_rdv_fifo_empty_sdram_s1;
  wire             cpu_instruction_master_rdv_fifo_output_from_sdram_s1;
  wire             cpu_instruction_master_read_data_valid_sdram_s1;
  wire             cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  wire             cpu_instruction_master_requests_sdram_s1;
  wire             cpu_instruction_master_saved_grant_sdram_s1;
  reg              d1_reasons_to_wait;
  reg              d1_sdram_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_sdram_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_data_master_granted_slave_sdram_s1;
  reg              last_cycle_cpu_instruction_master_granted_slave_sdram_s1;
  wire    [ 23: 0] sdram_s1_address;
  wire             sdram_s1_allgrants;
  wire             sdram_s1_allow_new_arb_cycle;
  wire             sdram_s1_any_bursting_master_saved_grant;
  wire             sdram_s1_any_continuerequest;
  reg     [  1: 0] sdram_s1_arb_addend;
  wire             sdram_s1_arb_counter_enable;
  reg     [  1: 0] sdram_s1_arb_share_counter;
  wire    [  1: 0] sdram_s1_arb_share_counter_next_value;
  wire    [  1: 0] sdram_s1_arb_share_set_values;
  wire    [  1: 0] sdram_s1_arb_winner;
  wire             sdram_s1_arbitration_holdoff_internal;
  wire             sdram_s1_beginbursttransfer_internal;
  wire             sdram_s1_begins_xfer;
  wire    [  1: 0] sdram_s1_byteenable_n;
  wire             sdram_s1_chipselect;
  wire    [  3: 0] sdram_s1_chosen_master_double_vector;
  wire    [  1: 0] sdram_s1_chosen_master_rot_left;
  wire             sdram_s1_end_xfer;
  wire             sdram_s1_firsttransfer;
  wire    [  1: 0] sdram_s1_grant_vector;
  wire             sdram_s1_in_a_read_cycle;
  wire             sdram_s1_in_a_write_cycle;
  wire    [  1: 0] sdram_s1_master_qreq_vector;
  wire             sdram_s1_move_on_to_next_transaction;
  wire             sdram_s1_non_bursting_master_requests;
  wire             sdram_s1_read_n;
  wire    [ 15: 0] sdram_s1_readdata_from_sa;
  wire             sdram_s1_readdatavalid_from_sa;
  reg              sdram_s1_reg_firsttransfer;
  wire             sdram_s1_reset_n;
  reg     [  1: 0] sdram_s1_saved_chosen_master_vector;
  reg              sdram_s1_slavearbiterlockenable;
  wire             sdram_s1_slavearbiterlockenable2;
  wire             sdram_s1_unreg_firsttransfer;
  wire             sdram_s1_waitrequest_from_sa;
  wire             sdram_s1_waits_for_read;
  wire             sdram_s1_waits_for_write;
  wire             sdram_s1_write_n;
  wire    [ 15: 0] sdram_s1_writedata;
  wire    [ 26: 0] shifted_address_to_sdram_s1_from_cpu_data_master;
  wire    [ 26: 0] shifted_address_to_sdram_s1_from_cpu_instruction_master;
  wire             wait_for_sdram_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~sdram_s1_end_xfer;
    end


  assign sdram_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_sdram_s1 | cpu_instruction_master_qualified_request_sdram_s1));
  //assign sdram_s1_readdatavalid_from_sa = sdram_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_s1_readdatavalid_from_sa = sdram_s1_readdatavalid;

  //assign sdram_s1_readdata_from_sa = sdram_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_s1_readdata_from_sa = sdram_s1_readdata;

  assign cpu_data_master_requests_sdram_s1 = ({cpu_data_master_address_to_slave[26 : 25] , 25'b0} == 27'h4000000) & (cpu_data_master_read | cpu_data_master_write);
  //assign sdram_s1_waitrequest_from_sa = sdram_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_s1_waitrequest_from_sa = sdram_s1_waitrequest;

  //sdram_s1_arb_share_counter set values, which is an e_mux
  assign sdram_s1_arb_share_set_values = (cpu_data_master_granted_sdram_s1)? 2 :
    (cpu_instruction_master_granted_sdram_s1)? 2 :
    (cpu_data_master_granted_sdram_s1)? 2 :
    (cpu_instruction_master_granted_sdram_s1)? 2 :
    1;

  //sdram_s1_non_bursting_master_requests mux, which is an e_mux
  assign sdram_s1_non_bursting_master_requests = cpu_data_master_requests_sdram_s1 |
    cpu_instruction_master_requests_sdram_s1 |
    cpu_data_master_requests_sdram_s1 |
    cpu_instruction_master_requests_sdram_s1;

  //sdram_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign sdram_s1_any_bursting_master_saved_grant = 0;

  //sdram_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign sdram_s1_arb_share_counter_next_value = sdram_s1_firsttransfer ? (sdram_s1_arb_share_set_values - 1) : |sdram_s1_arb_share_counter ? (sdram_s1_arb_share_counter - 1) : 0;

  //sdram_s1_allgrants all slave grants, which is an e_mux
  assign sdram_s1_allgrants = (|sdram_s1_grant_vector) |
    (|sdram_s1_grant_vector) |
    (|sdram_s1_grant_vector) |
    (|sdram_s1_grant_vector);

  //sdram_s1_end_xfer assignment, which is an e_assign
  assign sdram_s1_end_xfer = ~(sdram_s1_waits_for_read | sdram_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_sdram_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_sdram_s1 = sdram_s1_end_xfer & (~sdram_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //sdram_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign sdram_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_sdram_s1 & sdram_s1_allgrants) | (end_xfer_arb_share_counter_term_sdram_s1 & ~sdram_s1_non_bursting_master_requests);

  //sdram_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_s1_arb_share_counter <= 0;
      else if (sdram_s1_arb_counter_enable)
          sdram_s1_arb_share_counter <= sdram_s1_arb_share_counter_next_value;
    end


  //sdram_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_s1_slavearbiterlockenable <= 0;
      else if ((|sdram_s1_master_qreq_vector & end_xfer_arb_share_counter_term_sdram_s1) | (end_xfer_arb_share_counter_term_sdram_s1 & ~sdram_s1_non_bursting_master_requests))
          sdram_s1_slavearbiterlockenable <= |sdram_s1_arb_share_counter_next_value;
    end


  //cpu/data_master sdram/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = sdram_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //sdram_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign sdram_s1_slavearbiterlockenable2 = |sdram_s1_arb_share_counter_next_value;

  //cpu/data_master sdram/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = sdram_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //cpu/instruction_master sdram/s1 arbiterlock, which is an e_assign
  assign cpu_instruction_master_arbiterlock = sdram_s1_slavearbiterlockenable & cpu_instruction_master_continuerequest;

  //cpu/instruction_master sdram/s1 arbiterlock2, which is an e_assign
  assign cpu_instruction_master_arbiterlock2 = sdram_s1_slavearbiterlockenable2 & cpu_instruction_master_continuerequest;

  //cpu/instruction_master granted sdram/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_instruction_master_granted_slave_sdram_s1 <= 0;
      else 
        last_cycle_cpu_instruction_master_granted_slave_sdram_s1 <= cpu_instruction_master_saved_grant_sdram_s1 ? 1 : (sdram_s1_arbitration_holdoff_internal | ~cpu_instruction_master_requests_sdram_s1) ? 0 : last_cycle_cpu_instruction_master_granted_slave_sdram_s1;
    end


  //cpu_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_instruction_master_continuerequest = last_cycle_cpu_instruction_master_granted_slave_sdram_s1 & cpu_instruction_master_requests_sdram_s1;

  //sdram_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  assign sdram_s1_any_continuerequest = cpu_instruction_master_continuerequest |
    cpu_data_master_continuerequest;

  assign cpu_data_master_qualified_request_sdram_s1 = cpu_data_master_requests_sdram_s1 & ~((cpu_data_master_read & (~cpu_data_master_waitrequest | (|cpu_data_master_read_data_valid_sdram_s1_shift_register))) | ((~cpu_data_master_waitrequest | cpu_data_master_no_byte_enables_and_last_term | !cpu_data_master_byteenable_sdram_s1) & cpu_data_master_write) | cpu_instruction_master_arbiterlock);
  //unique name for sdram_s1_move_on_to_next_transaction, which is an e_assign
  assign sdram_s1_move_on_to_next_transaction = sdram_s1_readdatavalid_from_sa;

  //rdv_fifo_for_cpu_data_master_to_sdram_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_data_master_to_sdram_s1_module rdv_fifo_for_cpu_data_master_to_sdram_s1
    (
      .clear_fifo           (1'b0),
      .clk                  (clk),
      .data_in              (cpu_data_master_granted_sdram_s1),
      .data_out             (cpu_data_master_rdv_fifo_output_from_sdram_s1),
      .empty                (),
      .fifo_contains_ones_n (cpu_data_master_rdv_fifo_empty_sdram_s1),
      .full                 (),
      .read                 (sdram_s1_move_on_to_next_transaction),
      .reset_n              (reset_n),
      .sync_reset           (1'b0),
      .write                (in_a_read_cycle & ~sdram_s1_waits_for_read)
    );

  assign cpu_data_master_read_data_valid_sdram_s1_shift_register = ~cpu_data_master_rdv_fifo_empty_sdram_s1;
  //local readdatavalid cpu_data_master_read_data_valid_sdram_s1, which is an e_mux
  assign cpu_data_master_read_data_valid_sdram_s1 = (sdram_s1_readdatavalid_from_sa & cpu_data_master_rdv_fifo_output_from_sdram_s1) & ~ cpu_data_master_rdv_fifo_empty_sdram_s1;

  //sdram_s1_writedata mux, which is an e_mux
  assign sdram_s1_writedata = cpu_data_master_dbs_write_16;

  assign cpu_instruction_master_requests_sdram_s1 = (({cpu_instruction_master_address_to_slave[26 : 25] , 25'b0} == 27'h4000000) & (cpu_instruction_master_read)) & cpu_instruction_master_read;
  //cpu/data_master granted sdram/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_data_master_granted_slave_sdram_s1 <= 0;
      else 
        last_cycle_cpu_data_master_granted_slave_sdram_s1 <= cpu_data_master_saved_grant_sdram_s1 ? 1 : (sdram_s1_arbitration_holdoff_internal | ~cpu_data_master_requests_sdram_s1) ? 0 : last_cycle_cpu_data_master_granted_slave_sdram_s1;
    end


  //cpu_data_master_continuerequest continued request, which is an e_mux
  assign cpu_data_master_continuerequest = last_cycle_cpu_data_master_granted_slave_sdram_s1 & cpu_data_master_requests_sdram_s1;

  assign cpu_instruction_master_qualified_request_sdram_s1 = cpu_instruction_master_requests_sdram_s1 & ~((cpu_instruction_master_read & ((cpu_instruction_master_latency_counter != 0) | (1 < cpu_instruction_master_latency_counter))) | cpu_data_master_arbiterlock);
  //rdv_fifo_for_cpu_instruction_master_to_sdram_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_instruction_master_to_sdram_s1_module rdv_fifo_for_cpu_instruction_master_to_sdram_s1
    (
      .clear_fifo           (1'b0),
      .clk                  (clk),
      .data_in              (cpu_instruction_master_granted_sdram_s1),
      .data_out             (cpu_instruction_master_rdv_fifo_output_from_sdram_s1),
      .empty                (),
      .fifo_contains_ones_n (cpu_instruction_master_rdv_fifo_empty_sdram_s1),
      .full                 (),
      .read                 (sdram_s1_move_on_to_next_transaction),
      .reset_n              (reset_n),
      .sync_reset           (1'b0),
      .write                (in_a_read_cycle & ~sdram_s1_waits_for_read)
    );

  assign cpu_instruction_master_read_data_valid_sdram_s1_shift_register = ~cpu_instruction_master_rdv_fifo_empty_sdram_s1;
  //local readdatavalid cpu_instruction_master_read_data_valid_sdram_s1, which is an e_mux
  assign cpu_instruction_master_read_data_valid_sdram_s1 = (sdram_s1_readdatavalid_from_sa & cpu_instruction_master_rdv_fifo_output_from_sdram_s1) & ~ cpu_instruction_master_rdv_fifo_empty_sdram_s1;

  //allow new arb cycle for sdram/s1, which is an e_assign
  assign sdram_s1_allow_new_arb_cycle = ~cpu_data_master_arbiterlock & ~cpu_instruction_master_arbiterlock;

  //cpu/instruction_master assignment into master qualified-requests vector for sdram/s1, which is an e_assign
  assign sdram_s1_master_qreq_vector[0] = cpu_instruction_master_qualified_request_sdram_s1;

  //cpu/instruction_master grant sdram/s1, which is an e_assign
  assign cpu_instruction_master_granted_sdram_s1 = sdram_s1_grant_vector[0];

  //cpu/instruction_master saved-grant sdram/s1, which is an e_assign
  assign cpu_instruction_master_saved_grant_sdram_s1 = sdram_s1_arb_winner[0] && cpu_instruction_master_requests_sdram_s1;

  //cpu/data_master assignment into master qualified-requests vector for sdram/s1, which is an e_assign
  assign sdram_s1_master_qreq_vector[1] = cpu_data_master_qualified_request_sdram_s1;

  //cpu/data_master grant sdram/s1, which is an e_assign
  assign cpu_data_master_granted_sdram_s1 = sdram_s1_grant_vector[1];

  //cpu/data_master saved-grant sdram/s1, which is an e_assign
  assign cpu_data_master_saved_grant_sdram_s1 = sdram_s1_arb_winner[1] && cpu_data_master_requests_sdram_s1;

  //sdram/s1 chosen-master double-vector, which is an e_assign
  assign sdram_s1_chosen_master_double_vector = {sdram_s1_master_qreq_vector, sdram_s1_master_qreq_vector} & ({~sdram_s1_master_qreq_vector, ~sdram_s1_master_qreq_vector} + sdram_s1_arb_addend);

  //stable onehot encoding of arb winner
  assign sdram_s1_arb_winner = (sdram_s1_allow_new_arb_cycle & | sdram_s1_grant_vector) ? sdram_s1_grant_vector : sdram_s1_saved_chosen_master_vector;

  //saved sdram_s1_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_s1_saved_chosen_master_vector <= 0;
      else if (sdram_s1_allow_new_arb_cycle)
          sdram_s1_saved_chosen_master_vector <= |sdram_s1_grant_vector ? sdram_s1_grant_vector : sdram_s1_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign sdram_s1_grant_vector = {(sdram_s1_chosen_master_double_vector[1] | sdram_s1_chosen_master_double_vector[3]),
    (sdram_s1_chosen_master_double_vector[0] | sdram_s1_chosen_master_double_vector[2])};

  //sdram/s1 chosen master rotated left, which is an e_assign
  assign sdram_s1_chosen_master_rot_left = (sdram_s1_arb_winner << 1) ? (sdram_s1_arb_winner << 1) : 1;

  //sdram/s1's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_s1_arb_addend <= 1;
      else if (|sdram_s1_grant_vector)
          sdram_s1_arb_addend <= sdram_s1_end_xfer? sdram_s1_chosen_master_rot_left : sdram_s1_grant_vector;
    end


  //sdram_s1_reset_n assignment, which is an e_assign
  assign sdram_s1_reset_n = reset_n;

  assign sdram_s1_chipselect = cpu_data_master_granted_sdram_s1 | cpu_instruction_master_granted_sdram_s1;
  //sdram_s1_firsttransfer first transaction, which is an e_assign
  assign sdram_s1_firsttransfer = sdram_s1_begins_xfer ? sdram_s1_unreg_firsttransfer : sdram_s1_reg_firsttransfer;

  //sdram_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign sdram_s1_unreg_firsttransfer = ~(sdram_s1_slavearbiterlockenable & sdram_s1_any_continuerequest);

  //sdram_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_s1_reg_firsttransfer <= 1'b1;
      else if (sdram_s1_begins_xfer)
          sdram_s1_reg_firsttransfer <= sdram_s1_unreg_firsttransfer;
    end


  //sdram_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign sdram_s1_beginbursttransfer_internal = sdram_s1_begins_xfer;

  //sdram_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign sdram_s1_arbitration_holdoff_internal = sdram_s1_begins_xfer & sdram_s1_firsttransfer;

  //~sdram_s1_read_n assignment, which is an e_mux
  assign sdram_s1_read_n = ~((cpu_data_master_granted_sdram_s1 & cpu_data_master_read) | (cpu_instruction_master_granted_sdram_s1 & cpu_instruction_master_read));

  //~sdram_s1_write_n assignment, which is an e_mux
  assign sdram_s1_write_n = ~(cpu_data_master_granted_sdram_s1 & cpu_data_master_write);

  assign shifted_address_to_sdram_s1_from_cpu_data_master = {cpu_data_master_address_to_slave >> 2,
    cpu_data_master_dbs_address[1],
    {1 {1'b0}}};

  //sdram_s1_address mux, which is an e_mux
  assign sdram_s1_address = (cpu_data_master_granted_sdram_s1)? (shifted_address_to_sdram_s1_from_cpu_data_master >> 1) :
    (shifted_address_to_sdram_s1_from_cpu_instruction_master >> 1);

  assign shifted_address_to_sdram_s1_from_cpu_instruction_master = {cpu_instruction_master_address_to_slave >> 2,
    cpu_instruction_master_dbs_address[1],
    {1 {1'b0}}};

  //d1_sdram_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_sdram_s1_end_xfer <= 1;
      else 
        d1_sdram_s1_end_xfer <= sdram_s1_end_xfer;
    end


  //sdram_s1_waits_for_read in a cycle, which is an e_mux
  assign sdram_s1_waits_for_read = sdram_s1_in_a_read_cycle & sdram_s1_waitrequest_from_sa;

  //sdram_s1_in_a_read_cycle assignment, which is an e_assign
  assign sdram_s1_in_a_read_cycle = (cpu_data_master_granted_sdram_s1 & cpu_data_master_read) | (cpu_instruction_master_granted_sdram_s1 & cpu_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = sdram_s1_in_a_read_cycle;

  //sdram_s1_waits_for_write in a cycle, which is an e_mux
  assign sdram_s1_waits_for_write = sdram_s1_in_a_write_cycle & sdram_s1_waitrequest_from_sa;

  //sdram_s1_in_a_write_cycle assignment, which is an e_assign
  assign sdram_s1_in_a_write_cycle = cpu_data_master_granted_sdram_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = sdram_s1_in_a_write_cycle;

  assign wait_for_sdram_s1_counter = 0;
  //~sdram_s1_byteenable_n byte enable port mux, which is an e_mux
  assign sdram_s1_byteenable_n = ~((cpu_data_master_granted_sdram_s1)? cpu_data_master_byteenable_sdram_s1 :
    -1);

  assign {cpu_data_master_byteenable_sdram_s1_segment_1,
cpu_data_master_byteenable_sdram_s1_segment_0} = cpu_data_master_byteenable;
  assign cpu_data_master_byteenable_sdram_s1 = ((cpu_data_master_dbs_address[1] == 0))? cpu_data_master_byteenable_sdram_s1_segment_0 :
    cpu_data_master_byteenable_sdram_s1_segment_1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //sdram/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_granted_sdram_s1 + cpu_instruction_master_granted_sdram_s1 > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_saved_grant_sdram_s1 + cpu_instruction_master_saved_grant_sdram_s1 > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module spi_adc_spi_control_port_arbitrator (
                                             // inputs:
                                              clk,
                                              cpu_data_master_address_to_slave,
                                              cpu_data_master_read,
                                              cpu_data_master_write,
                                              cpu_data_master_writedata,
                                              reset_n,
                                              spi_adc_spi_control_port_dataavailable,
                                              spi_adc_spi_control_port_endofpacket,
                                              spi_adc_spi_control_port_irq,
                                              spi_adc_spi_control_port_readdata,
                                              spi_adc_spi_control_port_readyfordata,

                                             // outputs:
                                              cpu_data_master_granted_spi_adc_spi_control_port,
                                              cpu_data_master_qualified_request_spi_adc_spi_control_port,
                                              cpu_data_master_read_data_valid_spi_adc_spi_control_port,
                                              cpu_data_master_requests_spi_adc_spi_control_port,
                                              d1_spi_adc_spi_control_port_end_xfer,
                                              spi_adc_spi_control_port_address,
                                              spi_adc_spi_control_port_chipselect,
                                              spi_adc_spi_control_port_dataavailable_from_sa,
                                              spi_adc_spi_control_port_endofpacket_from_sa,
                                              spi_adc_spi_control_port_irq_from_sa,
                                              spi_adc_spi_control_port_read_n,
                                              spi_adc_spi_control_port_readdata_from_sa,
                                              spi_adc_spi_control_port_readyfordata_from_sa,
                                              spi_adc_spi_control_port_reset_n,
                                              spi_adc_spi_control_port_write_n,
                                              spi_adc_spi_control_port_writedata
                                           )
;

  output           cpu_data_master_granted_spi_adc_spi_control_port;
  output           cpu_data_master_qualified_request_spi_adc_spi_control_port;
  output           cpu_data_master_read_data_valid_spi_adc_spi_control_port;
  output           cpu_data_master_requests_spi_adc_spi_control_port;
  output           d1_spi_adc_spi_control_port_end_xfer;
  output  [  2: 0] spi_adc_spi_control_port_address;
  output           spi_adc_spi_control_port_chipselect;
  output           spi_adc_spi_control_port_dataavailable_from_sa;
  output           spi_adc_spi_control_port_endofpacket_from_sa;
  output           spi_adc_spi_control_port_irq_from_sa;
  output           spi_adc_spi_control_port_read_n;
  output  [ 15: 0] spi_adc_spi_control_port_readdata_from_sa;
  output           spi_adc_spi_control_port_readyfordata_from_sa;
  output           spi_adc_spi_control_port_reset_n;
  output           spi_adc_spi_control_port_write_n;
  output  [ 15: 0] spi_adc_spi_control_port_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;
  input            spi_adc_spi_control_port_dataavailable;
  input            spi_adc_spi_control_port_endofpacket;
  input            spi_adc_spi_control_port_irq;
  input   [ 15: 0] spi_adc_spi_control_port_readdata;
  input            spi_adc_spi_control_port_readyfordata;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_spi_adc_spi_control_port;
  wire             cpu_data_master_qualified_request_spi_adc_spi_control_port;
  wire             cpu_data_master_read_data_valid_spi_adc_spi_control_port;
  wire             cpu_data_master_requests_spi_adc_spi_control_port;
  wire             cpu_data_master_saved_grant_spi_adc_spi_control_port;
  reg              d1_reasons_to_wait;
  reg              d1_spi_adc_spi_control_port_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_spi_adc_spi_control_port;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_spi_adc_spi_control_port_from_cpu_data_master;
  wire    [  2: 0] spi_adc_spi_control_port_address;
  wire             spi_adc_spi_control_port_allgrants;
  wire             spi_adc_spi_control_port_allow_new_arb_cycle;
  wire             spi_adc_spi_control_port_any_bursting_master_saved_grant;
  wire             spi_adc_spi_control_port_any_continuerequest;
  wire             spi_adc_spi_control_port_arb_counter_enable;
  reg     [  1: 0] spi_adc_spi_control_port_arb_share_counter;
  wire    [  1: 0] spi_adc_spi_control_port_arb_share_counter_next_value;
  wire    [  1: 0] spi_adc_spi_control_port_arb_share_set_values;
  wire             spi_adc_spi_control_port_beginbursttransfer_internal;
  wire             spi_adc_spi_control_port_begins_xfer;
  wire             spi_adc_spi_control_port_chipselect;
  wire             spi_adc_spi_control_port_dataavailable_from_sa;
  wire             spi_adc_spi_control_port_end_xfer;
  wire             spi_adc_spi_control_port_endofpacket_from_sa;
  wire             spi_adc_spi_control_port_firsttransfer;
  wire             spi_adc_spi_control_port_grant_vector;
  wire             spi_adc_spi_control_port_in_a_read_cycle;
  wire             spi_adc_spi_control_port_in_a_write_cycle;
  wire             spi_adc_spi_control_port_irq_from_sa;
  wire             spi_adc_spi_control_port_master_qreq_vector;
  wire             spi_adc_spi_control_port_non_bursting_master_requests;
  wire             spi_adc_spi_control_port_read_n;
  wire    [ 15: 0] spi_adc_spi_control_port_readdata_from_sa;
  wire             spi_adc_spi_control_port_readyfordata_from_sa;
  reg              spi_adc_spi_control_port_reg_firsttransfer;
  wire             spi_adc_spi_control_port_reset_n;
  reg              spi_adc_spi_control_port_slavearbiterlockenable;
  wire             spi_adc_spi_control_port_slavearbiterlockenable2;
  wire             spi_adc_spi_control_port_unreg_firsttransfer;
  wire             spi_adc_spi_control_port_waits_for_read;
  wire             spi_adc_spi_control_port_waits_for_write;
  wire             spi_adc_spi_control_port_write_n;
  wire    [ 15: 0] spi_adc_spi_control_port_writedata;
  wire             wait_for_spi_adc_spi_control_port_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~spi_adc_spi_control_port_end_xfer;
    end


  assign spi_adc_spi_control_port_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_spi_adc_spi_control_port));
  //assign spi_adc_spi_control_port_readdata_from_sa = spi_adc_spi_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_adc_spi_control_port_readdata_from_sa = spi_adc_spi_control_port_readdata;

  assign cpu_data_master_requests_spi_adc_spi_control_port = ({cpu_data_master_address_to_slave[26 : 5] , 5'b0} == 27'h3880) & (cpu_data_master_read | cpu_data_master_write);
  //assign spi_adc_spi_control_port_dataavailable_from_sa = spi_adc_spi_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_adc_spi_control_port_dataavailable_from_sa = spi_adc_spi_control_port_dataavailable;

  //assign spi_adc_spi_control_port_readyfordata_from_sa = spi_adc_spi_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_adc_spi_control_port_readyfordata_from_sa = spi_adc_spi_control_port_readyfordata;

  //spi_adc_spi_control_port_arb_share_counter set values, which is an e_mux
  assign spi_adc_spi_control_port_arb_share_set_values = 1;

  //spi_adc_spi_control_port_non_bursting_master_requests mux, which is an e_mux
  assign spi_adc_spi_control_port_non_bursting_master_requests = cpu_data_master_requests_spi_adc_spi_control_port;

  //spi_adc_spi_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  assign spi_adc_spi_control_port_any_bursting_master_saved_grant = 0;

  //spi_adc_spi_control_port_arb_share_counter_next_value assignment, which is an e_assign
  assign spi_adc_spi_control_port_arb_share_counter_next_value = spi_adc_spi_control_port_firsttransfer ? (spi_adc_spi_control_port_arb_share_set_values - 1) : |spi_adc_spi_control_port_arb_share_counter ? (spi_adc_spi_control_port_arb_share_counter - 1) : 0;

  //spi_adc_spi_control_port_allgrants all slave grants, which is an e_mux
  assign spi_adc_spi_control_port_allgrants = |spi_adc_spi_control_port_grant_vector;

  //spi_adc_spi_control_port_end_xfer assignment, which is an e_assign
  assign spi_adc_spi_control_port_end_xfer = ~(spi_adc_spi_control_port_waits_for_read | spi_adc_spi_control_port_waits_for_write);

  //end_xfer_arb_share_counter_term_spi_adc_spi_control_port arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_spi_adc_spi_control_port = spi_adc_spi_control_port_end_xfer & (~spi_adc_spi_control_port_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //spi_adc_spi_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  assign spi_adc_spi_control_port_arb_counter_enable = (end_xfer_arb_share_counter_term_spi_adc_spi_control_port & spi_adc_spi_control_port_allgrants) | (end_xfer_arb_share_counter_term_spi_adc_spi_control_port & ~spi_adc_spi_control_port_non_bursting_master_requests);

  //spi_adc_spi_control_port_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          spi_adc_spi_control_port_arb_share_counter <= 0;
      else if (spi_adc_spi_control_port_arb_counter_enable)
          spi_adc_spi_control_port_arb_share_counter <= spi_adc_spi_control_port_arb_share_counter_next_value;
    end


  //spi_adc_spi_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          spi_adc_spi_control_port_slavearbiterlockenable <= 0;
      else if ((|spi_adc_spi_control_port_master_qreq_vector & end_xfer_arb_share_counter_term_spi_adc_spi_control_port) | (end_xfer_arb_share_counter_term_spi_adc_spi_control_port & ~spi_adc_spi_control_port_non_bursting_master_requests))
          spi_adc_spi_control_port_slavearbiterlockenable <= |spi_adc_spi_control_port_arb_share_counter_next_value;
    end


  //cpu/data_master spi_adc/spi_control_port arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = spi_adc_spi_control_port_slavearbiterlockenable & cpu_data_master_continuerequest;

  //spi_adc_spi_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign spi_adc_spi_control_port_slavearbiterlockenable2 = |spi_adc_spi_control_port_arb_share_counter_next_value;

  //cpu/data_master spi_adc/spi_control_port arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = spi_adc_spi_control_port_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //spi_adc_spi_control_port_any_continuerequest at least one master continues requesting, which is an e_assign
  assign spi_adc_spi_control_port_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_spi_adc_spi_control_port = cpu_data_master_requests_spi_adc_spi_control_port;
  //spi_adc_spi_control_port_writedata mux, which is an e_mux
  assign spi_adc_spi_control_port_writedata = cpu_data_master_writedata;

  //assign spi_adc_spi_control_port_endofpacket_from_sa = spi_adc_spi_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_adc_spi_control_port_endofpacket_from_sa = spi_adc_spi_control_port_endofpacket;

  //master is always granted when requested
  assign cpu_data_master_granted_spi_adc_spi_control_port = cpu_data_master_qualified_request_spi_adc_spi_control_port;

  //cpu/data_master saved-grant spi_adc/spi_control_port, which is an e_assign
  assign cpu_data_master_saved_grant_spi_adc_spi_control_port = cpu_data_master_requests_spi_adc_spi_control_port;

  //allow new arb cycle for spi_adc/spi_control_port, which is an e_assign
  assign spi_adc_spi_control_port_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign spi_adc_spi_control_port_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign spi_adc_spi_control_port_master_qreq_vector = 1;

  //spi_adc_spi_control_port_reset_n assignment, which is an e_assign
  assign spi_adc_spi_control_port_reset_n = reset_n;

  assign spi_adc_spi_control_port_chipselect = cpu_data_master_granted_spi_adc_spi_control_port;
  //spi_adc_spi_control_port_firsttransfer first transaction, which is an e_assign
  assign spi_adc_spi_control_port_firsttransfer = spi_adc_spi_control_port_begins_xfer ? spi_adc_spi_control_port_unreg_firsttransfer : spi_adc_spi_control_port_reg_firsttransfer;

  //spi_adc_spi_control_port_unreg_firsttransfer first transaction, which is an e_assign
  assign spi_adc_spi_control_port_unreg_firsttransfer = ~(spi_adc_spi_control_port_slavearbiterlockenable & spi_adc_spi_control_port_any_continuerequest);

  //spi_adc_spi_control_port_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          spi_adc_spi_control_port_reg_firsttransfer <= 1'b1;
      else if (spi_adc_spi_control_port_begins_xfer)
          spi_adc_spi_control_port_reg_firsttransfer <= spi_adc_spi_control_port_unreg_firsttransfer;
    end


  //spi_adc_spi_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign spi_adc_spi_control_port_beginbursttransfer_internal = spi_adc_spi_control_port_begins_xfer;

  //~spi_adc_spi_control_port_read_n assignment, which is an e_mux
  assign spi_adc_spi_control_port_read_n = ~(cpu_data_master_granted_spi_adc_spi_control_port & cpu_data_master_read);

  //~spi_adc_spi_control_port_write_n assignment, which is an e_mux
  assign spi_adc_spi_control_port_write_n = ~(cpu_data_master_granted_spi_adc_spi_control_port & cpu_data_master_write);

  assign shifted_address_to_spi_adc_spi_control_port_from_cpu_data_master = cpu_data_master_address_to_slave;
  //spi_adc_spi_control_port_address mux, which is an e_mux
  assign spi_adc_spi_control_port_address = shifted_address_to_spi_adc_spi_control_port_from_cpu_data_master >> 2;

  //d1_spi_adc_spi_control_port_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_spi_adc_spi_control_port_end_xfer <= 1;
      else 
        d1_spi_adc_spi_control_port_end_xfer <= spi_adc_spi_control_port_end_xfer;
    end


  //spi_adc_spi_control_port_waits_for_read in a cycle, which is an e_mux
  assign spi_adc_spi_control_port_waits_for_read = spi_adc_spi_control_port_in_a_read_cycle & spi_adc_spi_control_port_begins_xfer;

  //spi_adc_spi_control_port_in_a_read_cycle assignment, which is an e_assign
  assign spi_adc_spi_control_port_in_a_read_cycle = cpu_data_master_granted_spi_adc_spi_control_port & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = spi_adc_spi_control_port_in_a_read_cycle;

  //spi_adc_spi_control_port_waits_for_write in a cycle, which is an e_mux
  assign spi_adc_spi_control_port_waits_for_write = spi_adc_spi_control_port_in_a_write_cycle & spi_adc_spi_control_port_begins_xfer;

  //spi_adc_spi_control_port_in_a_write_cycle assignment, which is an e_assign
  assign spi_adc_spi_control_port_in_a_write_cycle = cpu_data_master_granted_spi_adc_spi_control_port & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = spi_adc_spi_control_port_in_a_write_cycle;

  assign wait_for_spi_adc_spi_control_port_counter = 0;
  //assign spi_adc_spi_control_port_irq_from_sa = spi_adc_spi_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_adc_spi_control_port_irq_from_sa = spi_adc_spi_control_port_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //spi_adc/spi_control_port enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module spi_flash_spi_control_port_arbitrator (
                                               // inputs:
                                                clk,
                                                cpu_data_master_address_to_slave,
                                                cpu_data_master_read,
                                                cpu_data_master_write,
                                                cpu_data_master_writedata,
                                                reset_n,
                                                spi_flash_spi_control_port_dataavailable,
                                                spi_flash_spi_control_port_endofpacket,
                                                spi_flash_spi_control_port_irq,
                                                spi_flash_spi_control_port_readdata,
                                                spi_flash_spi_control_port_readyfordata,

                                               // outputs:
                                                cpu_data_master_granted_spi_flash_spi_control_port,
                                                cpu_data_master_qualified_request_spi_flash_spi_control_port,
                                                cpu_data_master_read_data_valid_spi_flash_spi_control_port,
                                                cpu_data_master_requests_spi_flash_spi_control_port,
                                                d1_spi_flash_spi_control_port_end_xfer,
                                                spi_flash_spi_control_port_address,
                                                spi_flash_spi_control_port_chipselect,
                                                spi_flash_spi_control_port_dataavailable_from_sa,
                                                spi_flash_spi_control_port_endofpacket_from_sa,
                                                spi_flash_spi_control_port_irq_from_sa,
                                                spi_flash_spi_control_port_read_n,
                                                spi_flash_spi_control_port_readdata_from_sa,
                                                spi_flash_spi_control_port_readyfordata_from_sa,
                                                spi_flash_spi_control_port_reset_n,
                                                spi_flash_spi_control_port_write_n,
                                                spi_flash_spi_control_port_writedata
                                             )
;

  output           cpu_data_master_granted_spi_flash_spi_control_port;
  output           cpu_data_master_qualified_request_spi_flash_spi_control_port;
  output           cpu_data_master_read_data_valid_spi_flash_spi_control_port;
  output           cpu_data_master_requests_spi_flash_spi_control_port;
  output           d1_spi_flash_spi_control_port_end_xfer;
  output  [  2: 0] spi_flash_spi_control_port_address;
  output           spi_flash_spi_control_port_chipselect;
  output           spi_flash_spi_control_port_dataavailable_from_sa;
  output           spi_flash_spi_control_port_endofpacket_from_sa;
  output           spi_flash_spi_control_port_irq_from_sa;
  output           spi_flash_spi_control_port_read_n;
  output  [ 15: 0] spi_flash_spi_control_port_readdata_from_sa;
  output           spi_flash_spi_control_port_readyfordata_from_sa;
  output           spi_flash_spi_control_port_reset_n;
  output           spi_flash_spi_control_port_write_n;
  output  [ 15: 0] spi_flash_spi_control_port_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;
  input            spi_flash_spi_control_port_dataavailable;
  input            spi_flash_spi_control_port_endofpacket;
  input            spi_flash_spi_control_port_irq;
  input   [ 15: 0] spi_flash_spi_control_port_readdata;
  input            spi_flash_spi_control_port_readyfordata;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_spi_flash_spi_control_port;
  wire             cpu_data_master_qualified_request_spi_flash_spi_control_port;
  wire             cpu_data_master_read_data_valid_spi_flash_spi_control_port;
  wire             cpu_data_master_requests_spi_flash_spi_control_port;
  wire             cpu_data_master_saved_grant_spi_flash_spi_control_port;
  reg              d1_reasons_to_wait;
  reg              d1_spi_flash_spi_control_port_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_spi_flash_spi_control_port;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_spi_flash_spi_control_port_from_cpu_data_master;
  wire    [  2: 0] spi_flash_spi_control_port_address;
  wire             spi_flash_spi_control_port_allgrants;
  wire             spi_flash_spi_control_port_allow_new_arb_cycle;
  wire             spi_flash_spi_control_port_any_bursting_master_saved_grant;
  wire             spi_flash_spi_control_port_any_continuerequest;
  wire             spi_flash_spi_control_port_arb_counter_enable;
  reg     [  1: 0] spi_flash_spi_control_port_arb_share_counter;
  wire    [  1: 0] spi_flash_spi_control_port_arb_share_counter_next_value;
  wire    [  1: 0] spi_flash_spi_control_port_arb_share_set_values;
  wire             spi_flash_spi_control_port_beginbursttransfer_internal;
  wire             spi_flash_spi_control_port_begins_xfer;
  wire             spi_flash_spi_control_port_chipselect;
  wire             spi_flash_spi_control_port_dataavailable_from_sa;
  wire             spi_flash_spi_control_port_end_xfer;
  wire             spi_flash_spi_control_port_endofpacket_from_sa;
  wire             spi_flash_spi_control_port_firsttransfer;
  wire             spi_flash_spi_control_port_grant_vector;
  wire             spi_flash_spi_control_port_in_a_read_cycle;
  wire             spi_flash_spi_control_port_in_a_write_cycle;
  wire             spi_flash_spi_control_port_irq_from_sa;
  wire             spi_flash_spi_control_port_master_qreq_vector;
  wire             spi_flash_spi_control_port_non_bursting_master_requests;
  wire             spi_flash_spi_control_port_read_n;
  wire    [ 15: 0] spi_flash_spi_control_port_readdata_from_sa;
  wire             spi_flash_spi_control_port_readyfordata_from_sa;
  reg              spi_flash_spi_control_port_reg_firsttransfer;
  wire             spi_flash_spi_control_port_reset_n;
  reg              spi_flash_spi_control_port_slavearbiterlockenable;
  wire             spi_flash_spi_control_port_slavearbiterlockenable2;
  wire             spi_flash_spi_control_port_unreg_firsttransfer;
  wire             spi_flash_spi_control_port_waits_for_read;
  wire             spi_flash_spi_control_port_waits_for_write;
  wire             spi_flash_spi_control_port_write_n;
  wire    [ 15: 0] spi_flash_spi_control_port_writedata;
  wire             wait_for_spi_flash_spi_control_port_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~spi_flash_spi_control_port_end_xfer;
    end


  assign spi_flash_spi_control_port_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_spi_flash_spi_control_port));
  //assign spi_flash_spi_control_port_readdata_from_sa = spi_flash_spi_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_flash_spi_control_port_readdata_from_sa = spi_flash_spi_control_port_readdata;

  assign cpu_data_master_requests_spi_flash_spi_control_port = ({cpu_data_master_address_to_slave[26 : 5] , 5'b0} == 27'h3860) & (cpu_data_master_read | cpu_data_master_write);
  //assign spi_flash_spi_control_port_dataavailable_from_sa = spi_flash_spi_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_flash_spi_control_port_dataavailable_from_sa = spi_flash_spi_control_port_dataavailable;

  //assign spi_flash_spi_control_port_readyfordata_from_sa = spi_flash_spi_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_flash_spi_control_port_readyfordata_from_sa = spi_flash_spi_control_port_readyfordata;

  //spi_flash_spi_control_port_arb_share_counter set values, which is an e_mux
  assign spi_flash_spi_control_port_arb_share_set_values = 1;

  //spi_flash_spi_control_port_non_bursting_master_requests mux, which is an e_mux
  assign spi_flash_spi_control_port_non_bursting_master_requests = cpu_data_master_requests_spi_flash_spi_control_port;

  //spi_flash_spi_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  assign spi_flash_spi_control_port_any_bursting_master_saved_grant = 0;

  //spi_flash_spi_control_port_arb_share_counter_next_value assignment, which is an e_assign
  assign spi_flash_spi_control_port_arb_share_counter_next_value = spi_flash_spi_control_port_firsttransfer ? (spi_flash_spi_control_port_arb_share_set_values - 1) : |spi_flash_spi_control_port_arb_share_counter ? (spi_flash_spi_control_port_arb_share_counter - 1) : 0;

  //spi_flash_spi_control_port_allgrants all slave grants, which is an e_mux
  assign spi_flash_spi_control_port_allgrants = |spi_flash_spi_control_port_grant_vector;

  //spi_flash_spi_control_port_end_xfer assignment, which is an e_assign
  assign spi_flash_spi_control_port_end_xfer = ~(spi_flash_spi_control_port_waits_for_read | spi_flash_spi_control_port_waits_for_write);

  //end_xfer_arb_share_counter_term_spi_flash_spi_control_port arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_spi_flash_spi_control_port = spi_flash_spi_control_port_end_xfer & (~spi_flash_spi_control_port_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //spi_flash_spi_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  assign spi_flash_spi_control_port_arb_counter_enable = (end_xfer_arb_share_counter_term_spi_flash_spi_control_port & spi_flash_spi_control_port_allgrants) | (end_xfer_arb_share_counter_term_spi_flash_spi_control_port & ~spi_flash_spi_control_port_non_bursting_master_requests);

  //spi_flash_spi_control_port_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          spi_flash_spi_control_port_arb_share_counter <= 0;
      else if (spi_flash_spi_control_port_arb_counter_enable)
          spi_flash_spi_control_port_arb_share_counter <= spi_flash_spi_control_port_arb_share_counter_next_value;
    end


  //spi_flash_spi_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          spi_flash_spi_control_port_slavearbiterlockenable <= 0;
      else if ((|spi_flash_spi_control_port_master_qreq_vector & end_xfer_arb_share_counter_term_spi_flash_spi_control_port) | (end_xfer_arb_share_counter_term_spi_flash_spi_control_port & ~spi_flash_spi_control_port_non_bursting_master_requests))
          spi_flash_spi_control_port_slavearbiterlockenable <= |spi_flash_spi_control_port_arb_share_counter_next_value;
    end


  //cpu/data_master spi_flash/spi_control_port arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = spi_flash_spi_control_port_slavearbiterlockenable & cpu_data_master_continuerequest;

  //spi_flash_spi_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign spi_flash_spi_control_port_slavearbiterlockenable2 = |spi_flash_spi_control_port_arb_share_counter_next_value;

  //cpu/data_master spi_flash/spi_control_port arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = spi_flash_spi_control_port_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //spi_flash_spi_control_port_any_continuerequest at least one master continues requesting, which is an e_assign
  assign spi_flash_spi_control_port_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_spi_flash_spi_control_port = cpu_data_master_requests_spi_flash_spi_control_port;
  //spi_flash_spi_control_port_writedata mux, which is an e_mux
  assign spi_flash_spi_control_port_writedata = cpu_data_master_writedata;

  //assign spi_flash_spi_control_port_endofpacket_from_sa = spi_flash_spi_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_flash_spi_control_port_endofpacket_from_sa = spi_flash_spi_control_port_endofpacket;

  //master is always granted when requested
  assign cpu_data_master_granted_spi_flash_spi_control_port = cpu_data_master_qualified_request_spi_flash_spi_control_port;

  //cpu/data_master saved-grant spi_flash/spi_control_port, which is an e_assign
  assign cpu_data_master_saved_grant_spi_flash_spi_control_port = cpu_data_master_requests_spi_flash_spi_control_port;

  //allow new arb cycle for spi_flash/spi_control_port, which is an e_assign
  assign spi_flash_spi_control_port_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign spi_flash_spi_control_port_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign spi_flash_spi_control_port_master_qreq_vector = 1;

  //spi_flash_spi_control_port_reset_n assignment, which is an e_assign
  assign spi_flash_spi_control_port_reset_n = reset_n;

  assign spi_flash_spi_control_port_chipselect = cpu_data_master_granted_spi_flash_spi_control_port;
  //spi_flash_spi_control_port_firsttransfer first transaction, which is an e_assign
  assign spi_flash_spi_control_port_firsttransfer = spi_flash_spi_control_port_begins_xfer ? spi_flash_spi_control_port_unreg_firsttransfer : spi_flash_spi_control_port_reg_firsttransfer;

  //spi_flash_spi_control_port_unreg_firsttransfer first transaction, which is an e_assign
  assign spi_flash_spi_control_port_unreg_firsttransfer = ~(spi_flash_spi_control_port_slavearbiterlockenable & spi_flash_spi_control_port_any_continuerequest);

  //spi_flash_spi_control_port_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          spi_flash_spi_control_port_reg_firsttransfer <= 1'b1;
      else if (spi_flash_spi_control_port_begins_xfer)
          spi_flash_spi_control_port_reg_firsttransfer <= spi_flash_spi_control_port_unreg_firsttransfer;
    end


  //spi_flash_spi_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign spi_flash_spi_control_port_beginbursttransfer_internal = spi_flash_spi_control_port_begins_xfer;

  //~spi_flash_spi_control_port_read_n assignment, which is an e_mux
  assign spi_flash_spi_control_port_read_n = ~(cpu_data_master_granted_spi_flash_spi_control_port & cpu_data_master_read);

  //~spi_flash_spi_control_port_write_n assignment, which is an e_mux
  assign spi_flash_spi_control_port_write_n = ~(cpu_data_master_granted_spi_flash_spi_control_port & cpu_data_master_write);

  assign shifted_address_to_spi_flash_spi_control_port_from_cpu_data_master = cpu_data_master_address_to_slave;
  //spi_flash_spi_control_port_address mux, which is an e_mux
  assign spi_flash_spi_control_port_address = shifted_address_to_spi_flash_spi_control_port_from_cpu_data_master >> 2;

  //d1_spi_flash_spi_control_port_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_spi_flash_spi_control_port_end_xfer <= 1;
      else 
        d1_spi_flash_spi_control_port_end_xfer <= spi_flash_spi_control_port_end_xfer;
    end


  //spi_flash_spi_control_port_waits_for_read in a cycle, which is an e_mux
  assign spi_flash_spi_control_port_waits_for_read = spi_flash_spi_control_port_in_a_read_cycle & spi_flash_spi_control_port_begins_xfer;

  //spi_flash_spi_control_port_in_a_read_cycle assignment, which is an e_assign
  assign spi_flash_spi_control_port_in_a_read_cycle = cpu_data_master_granted_spi_flash_spi_control_port & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = spi_flash_spi_control_port_in_a_read_cycle;

  //spi_flash_spi_control_port_waits_for_write in a cycle, which is an e_mux
  assign spi_flash_spi_control_port_waits_for_write = spi_flash_spi_control_port_in_a_write_cycle & spi_flash_spi_control_port_begins_xfer;

  //spi_flash_spi_control_port_in_a_write_cycle assignment, which is an e_assign
  assign spi_flash_spi_control_port_in_a_write_cycle = cpu_data_master_granted_spi_flash_spi_control_port & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = spi_flash_spi_control_port_in_a_write_cycle;

  assign wait_for_spi_flash_spi_control_port_counter = 0;
  //assign spi_flash_spi_control_port_irq_from_sa = spi_flash_spi_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign spi_flash_spi_control_port_irq_from_sa = spi_flash_spi_control_port_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //spi_flash/spi_control_port enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sys_clk_timer_s1_arbitrator (
                                     // inputs:
                                      clk,
                                      cpu_data_master_address_to_slave,
                                      cpu_data_master_read,
                                      cpu_data_master_waitrequest,
                                      cpu_data_master_write,
                                      cpu_data_master_writedata,
                                      reset_n,
                                      sys_clk_timer_s1_irq,
                                      sys_clk_timer_s1_readdata,

                                     // outputs:
                                      cpu_data_master_granted_sys_clk_timer_s1,
                                      cpu_data_master_qualified_request_sys_clk_timer_s1,
                                      cpu_data_master_read_data_valid_sys_clk_timer_s1,
                                      cpu_data_master_requests_sys_clk_timer_s1,
                                      d1_sys_clk_timer_s1_end_xfer,
                                      sys_clk_timer_s1_address,
                                      sys_clk_timer_s1_chipselect,
                                      sys_clk_timer_s1_irq_from_sa,
                                      sys_clk_timer_s1_readdata_from_sa,
                                      sys_clk_timer_s1_reset_n,
                                      sys_clk_timer_s1_write_n,
                                      sys_clk_timer_s1_writedata
                                   )
;

  output           cpu_data_master_granted_sys_clk_timer_s1;
  output           cpu_data_master_qualified_request_sys_clk_timer_s1;
  output           cpu_data_master_read_data_valid_sys_clk_timer_s1;
  output           cpu_data_master_requests_sys_clk_timer_s1;
  output           d1_sys_clk_timer_s1_end_xfer;
  output  [  2: 0] sys_clk_timer_s1_address;
  output           sys_clk_timer_s1_chipselect;
  output           sys_clk_timer_s1_irq_from_sa;
  output  [ 15: 0] sys_clk_timer_s1_readdata_from_sa;
  output           sys_clk_timer_s1_reset_n;
  output           sys_clk_timer_s1_write_n;
  output  [ 15: 0] sys_clk_timer_s1_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;
  input            sys_clk_timer_s1_irq;
  input   [ 15: 0] sys_clk_timer_s1_readdata;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_sys_clk_timer_s1;
  wire             cpu_data_master_qualified_request_sys_clk_timer_s1;
  wire             cpu_data_master_read_data_valid_sys_clk_timer_s1;
  wire             cpu_data_master_requests_sys_clk_timer_s1;
  wire             cpu_data_master_saved_grant_sys_clk_timer_s1;
  reg              d1_reasons_to_wait;
  reg              d1_sys_clk_timer_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_sys_clk_timer_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_sys_clk_timer_s1_from_cpu_data_master;
  wire    [  2: 0] sys_clk_timer_s1_address;
  wire             sys_clk_timer_s1_allgrants;
  wire             sys_clk_timer_s1_allow_new_arb_cycle;
  wire             sys_clk_timer_s1_any_bursting_master_saved_grant;
  wire             sys_clk_timer_s1_any_continuerequest;
  wire             sys_clk_timer_s1_arb_counter_enable;
  reg     [  1: 0] sys_clk_timer_s1_arb_share_counter;
  wire    [  1: 0] sys_clk_timer_s1_arb_share_counter_next_value;
  wire    [  1: 0] sys_clk_timer_s1_arb_share_set_values;
  wire             sys_clk_timer_s1_beginbursttransfer_internal;
  wire             sys_clk_timer_s1_begins_xfer;
  wire             sys_clk_timer_s1_chipselect;
  wire             sys_clk_timer_s1_end_xfer;
  wire             sys_clk_timer_s1_firsttransfer;
  wire             sys_clk_timer_s1_grant_vector;
  wire             sys_clk_timer_s1_in_a_read_cycle;
  wire             sys_clk_timer_s1_in_a_write_cycle;
  wire             sys_clk_timer_s1_irq_from_sa;
  wire             sys_clk_timer_s1_master_qreq_vector;
  wire             sys_clk_timer_s1_non_bursting_master_requests;
  wire    [ 15: 0] sys_clk_timer_s1_readdata_from_sa;
  reg              sys_clk_timer_s1_reg_firsttransfer;
  wire             sys_clk_timer_s1_reset_n;
  reg              sys_clk_timer_s1_slavearbiterlockenable;
  wire             sys_clk_timer_s1_slavearbiterlockenable2;
  wire             sys_clk_timer_s1_unreg_firsttransfer;
  wire             sys_clk_timer_s1_waits_for_read;
  wire             sys_clk_timer_s1_waits_for_write;
  wire             sys_clk_timer_s1_write_n;
  wire    [ 15: 0] sys_clk_timer_s1_writedata;
  wire             wait_for_sys_clk_timer_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~sys_clk_timer_s1_end_xfer;
    end


  assign sys_clk_timer_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_sys_clk_timer_s1));
  //assign sys_clk_timer_s1_readdata_from_sa = sys_clk_timer_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sys_clk_timer_s1_readdata_from_sa = sys_clk_timer_s1_readdata;

  assign cpu_data_master_requests_sys_clk_timer_s1 = ({cpu_data_master_address_to_slave[26 : 5] , 5'b0} == 27'h3800) & (cpu_data_master_read | cpu_data_master_write);
  //sys_clk_timer_s1_arb_share_counter set values, which is an e_mux
  assign sys_clk_timer_s1_arb_share_set_values = 1;

  //sys_clk_timer_s1_non_bursting_master_requests mux, which is an e_mux
  assign sys_clk_timer_s1_non_bursting_master_requests = cpu_data_master_requests_sys_clk_timer_s1;

  //sys_clk_timer_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign sys_clk_timer_s1_any_bursting_master_saved_grant = 0;

  //sys_clk_timer_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign sys_clk_timer_s1_arb_share_counter_next_value = sys_clk_timer_s1_firsttransfer ? (sys_clk_timer_s1_arb_share_set_values - 1) : |sys_clk_timer_s1_arb_share_counter ? (sys_clk_timer_s1_arb_share_counter - 1) : 0;

  //sys_clk_timer_s1_allgrants all slave grants, which is an e_mux
  assign sys_clk_timer_s1_allgrants = |sys_clk_timer_s1_grant_vector;

  //sys_clk_timer_s1_end_xfer assignment, which is an e_assign
  assign sys_clk_timer_s1_end_xfer = ~(sys_clk_timer_s1_waits_for_read | sys_clk_timer_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_sys_clk_timer_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_sys_clk_timer_s1 = sys_clk_timer_s1_end_xfer & (~sys_clk_timer_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //sys_clk_timer_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign sys_clk_timer_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_sys_clk_timer_s1 & sys_clk_timer_s1_allgrants) | (end_xfer_arb_share_counter_term_sys_clk_timer_s1 & ~sys_clk_timer_s1_non_bursting_master_requests);

  //sys_clk_timer_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sys_clk_timer_s1_arb_share_counter <= 0;
      else if (sys_clk_timer_s1_arb_counter_enable)
          sys_clk_timer_s1_arb_share_counter <= sys_clk_timer_s1_arb_share_counter_next_value;
    end


  //sys_clk_timer_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sys_clk_timer_s1_slavearbiterlockenable <= 0;
      else if ((|sys_clk_timer_s1_master_qreq_vector & end_xfer_arb_share_counter_term_sys_clk_timer_s1) | (end_xfer_arb_share_counter_term_sys_clk_timer_s1 & ~sys_clk_timer_s1_non_bursting_master_requests))
          sys_clk_timer_s1_slavearbiterlockenable <= |sys_clk_timer_s1_arb_share_counter_next_value;
    end


  //cpu/data_master sys_clk_timer/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = sys_clk_timer_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //sys_clk_timer_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign sys_clk_timer_s1_slavearbiterlockenable2 = |sys_clk_timer_s1_arb_share_counter_next_value;

  //cpu/data_master sys_clk_timer/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = sys_clk_timer_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //sys_clk_timer_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign sys_clk_timer_s1_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_sys_clk_timer_s1 = cpu_data_master_requests_sys_clk_timer_s1 & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //sys_clk_timer_s1_writedata mux, which is an e_mux
  assign sys_clk_timer_s1_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_sys_clk_timer_s1 = cpu_data_master_qualified_request_sys_clk_timer_s1;

  //cpu/data_master saved-grant sys_clk_timer/s1, which is an e_assign
  assign cpu_data_master_saved_grant_sys_clk_timer_s1 = cpu_data_master_requests_sys_clk_timer_s1;

  //allow new arb cycle for sys_clk_timer/s1, which is an e_assign
  assign sys_clk_timer_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign sys_clk_timer_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign sys_clk_timer_s1_master_qreq_vector = 1;

  //sys_clk_timer_s1_reset_n assignment, which is an e_assign
  assign sys_clk_timer_s1_reset_n = reset_n;

  assign sys_clk_timer_s1_chipselect = cpu_data_master_granted_sys_clk_timer_s1;
  //sys_clk_timer_s1_firsttransfer first transaction, which is an e_assign
  assign sys_clk_timer_s1_firsttransfer = sys_clk_timer_s1_begins_xfer ? sys_clk_timer_s1_unreg_firsttransfer : sys_clk_timer_s1_reg_firsttransfer;

  //sys_clk_timer_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign sys_clk_timer_s1_unreg_firsttransfer = ~(sys_clk_timer_s1_slavearbiterlockenable & sys_clk_timer_s1_any_continuerequest);

  //sys_clk_timer_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sys_clk_timer_s1_reg_firsttransfer <= 1'b1;
      else if (sys_clk_timer_s1_begins_xfer)
          sys_clk_timer_s1_reg_firsttransfer <= sys_clk_timer_s1_unreg_firsttransfer;
    end


  //sys_clk_timer_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign sys_clk_timer_s1_beginbursttransfer_internal = sys_clk_timer_s1_begins_xfer;

  //~sys_clk_timer_s1_write_n assignment, which is an e_mux
  assign sys_clk_timer_s1_write_n = ~(cpu_data_master_granted_sys_clk_timer_s1 & cpu_data_master_write);

  assign shifted_address_to_sys_clk_timer_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //sys_clk_timer_s1_address mux, which is an e_mux
  assign sys_clk_timer_s1_address = shifted_address_to_sys_clk_timer_s1_from_cpu_data_master >> 2;

  //d1_sys_clk_timer_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_sys_clk_timer_s1_end_xfer <= 1;
      else 
        d1_sys_clk_timer_s1_end_xfer <= sys_clk_timer_s1_end_xfer;
    end


  //sys_clk_timer_s1_waits_for_read in a cycle, which is an e_mux
  assign sys_clk_timer_s1_waits_for_read = sys_clk_timer_s1_in_a_read_cycle & sys_clk_timer_s1_begins_xfer;

  //sys_clk_timer_s1_in_a_read_cycle assignment, which is an e_assign
  assign sys_clk_timer_s1_in_a_read_cycle = cpu_data_master_granted_sys_clk_timer_s1 & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = sys_clk_timer_s1_in_a_read_cycle;

  //sys_clk_timer_s1_waits_for_write in a cycle, which is an e_mux
  assign sys_clk_timer_s1_waits_for_write = sys_clk_timer_s1_in_a_write_cycle & 0;

  //sys_clk_timer_s1_in_a_write_cycle assignment, which is an e_assign
  assign sys_clk_timer_s1_in_a_write_cycle = cpu_data_master_granted_sys_clk_timer_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = sys_clk_timer_s1_in_a_write_cycle;

  assign wait_for_sys_clk_timer_s1_counter = 0;
  //assign sys_clk_timer_s1_irq_from_sa = sys_clk_timer_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sys_clk_timer_s1_irq_from_sa = sys_clk_timer_s1_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //sys_clk_timer/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sysid_control_slave_arbitrator (
                                        // inputs:
                                         clk,
                                         cpu_data_master_address_to_slave,
                                         cpu_data_master_read,
                                         cpu_data_master_write,
                                         reset_n,
                                         sysid_control_slave_readdata,

                                        // outputs:
                                         cpu_data_master_granted_sysid_control_slave,
                                         cpu_data_master_qualified_request_sysid_control_slave,
                                         cpu_data_master_read_data_valid_sysid_control_slave,
                                         cpu_data_master_requests_sysid_control_slave,
                                         d1_sysid_control_slave_end_xfer,
                                         sysid_control_slave_address,
                                         sysid_control_slave_readdata_from_sa,
                                         sysid_control_slave_reset_n
                                      )
;

  output           cpu_data_master_granted_sysid_control_slave;
  output           cpu_data_master_qualified_request_sysid_control_slave;
  output           cpu_data_master_read_data_valid_sysid_control_slave;
  output           cpu_data_master_requests_sysid_control_slave;
  output           d1_sysid_control_slave_end_xfer;
  output           sysid_control_slave_address;
  output  [ 31: 0] sysid_control_slave_readdata_from_sa;
  output           sysid_control_slave_reset_n;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_write;
  input            reset_n;
  input   [ 31: 0] sysid_control_slave_readdata;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_sysid_control_slave;
  wire             cpu_data_master_qualified_request_sysid_control_slave;
  wire             cpu_data_master_read_data_valid_sysid_control_slave;
  wire             cpu_data_master_requests_sysid_control_slave;
  wire             cpu_data_master_saved_grant_sysid_control_slave;
  reg              d1_reasons_to_wait;
  reg              d1_sysid_control_slave_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_sysid_control_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_sysid_control_slave_from_cpu_data_master;
  wire             sysid_control_slave_address;
  wire             sysid_control_slave_allgrants;
  wire             sysid_control_slave_allow_new_arb_cycle;
  wire             sysid_control_slave_any_bursting_master_saved_grant;
  wire             sysid_control_slave_any_continuerequest;
  wire             sysid_control_slave_arb_counter_enable;
  reg     [  1: 0] sysid_control_slave_arb_share_counter;
  wire    [  1: 0] sysid_control_slave_arb_share_counter_next_value;
  wire    [  1: 0] sysid_control_slave_arb_share_set_values;
  wire             sysid_control_slave_beginbursttransfer_internal;
  wire             sysid_control_slave_begins_xfer;
  wire             sysid_control_slave_end_xfer;
  wire             sysid_control_slave_firsttransfer;
  wire             sysid_control_slave_grant_vector;
  wire             sysid_control_slave_in_a_read_cycle;
  wire             sysid_control_slave_in_a_write_cycle;
  wire             sysid_control_slave_master_qreq_vector;
  wire             sysid_control_slave_non_bursting_master_requests;
  wire    [ 31: 0] sysid_control_slave_readdata_from_sa;
  reg              sysid_control_slave_reg_firsttransfer;
  wire             sysid_control_slave_reset_n;
  reg              sysid_control_slave_slavearbiterlockenable;
  wire             sysid_control_slave_slavearbiterlockenable2;
  wire             sysid_control_slave_unreg_firsttransfer;
  wire             sysid_control_slave_waits_for_read;
  wire             sysid_control_slave_waits_for_write;
  wire             wait_for_sysid_control_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~sysid_control_slave_end_xfer;
    end


  assign sysid_control_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_sysid_control_slave));
  //assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata;

  assign cpu_data_master_requests_sysid_control_slave = (({cpu_data_master_address_to_slave[26 : 3] , 3'b0} == 27'h3970) & (cpu_data_master_read | cpu_data_master_write)) & cpu_data_master_read;
  //sysid_control_slave_arb_share_counter set values, which is an e_mux
  assign sysid_control_slave_arb_share_set_values = 1;

  //sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  assign sysid_control_slave_non_bursting_master_requests = cpu_data_master_requests_sysid_control_slave;

  //sysid_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign sysid_control_slave_any_bursting_master_saved_grant = 0;

  //sysid_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign sysid_control_slave_arb_share_counter_next_value = sysid_control_slave_firsttransfer ? (sysid_control_slave_arb_share_set_values - 1) : |sysid_control_slave_arb_share_counter ? (sysid_control_slave_arb_share_counter - 1) : 0;

  //sysid_control_slave_allgrants all slave grants, which is an e_mux
  assign sysid_control_slave_allgrants = |sysid_control_slave_grant_vector;

  //sysid_control_slave_end_xfer assignment, which is an e_assign
  assign sysid_control_slave_end_xfer = ~(sysid_control_slave_waits_for_read | sysid_control_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_sysid_control_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_sysid_control_slave = sysid_control_slave_end_xfer & (~sysid_control_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //sysid_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign sysid_control_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_sysid_control_slave & sysid_control_slave_allgrants) | (end_xfer_arb_share_counter_term_sysid_control_slave & ~sysid_control_slave_non_bursting_master_requests);

  //sysid_control_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sysid_control_slave_arb_share_counter <= 0;
      else if (sysid_control_slave_arb_counter_enable)
          sysid_control_slave_arb_share_counter <= sysid_control_slave_arb_share_counter_next_value;
    end


  //sysid_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sysid_control_slave_slavearbiterlockenable <= 0;
      else if ((|sysid_control_slave_master_qreq_vector & end_xfer_arb_share_counter_term_sysid_control_slave) | (end_xfer_arb_share_counter_term_sysid_control_slave & ~sysid_control_slave_non_bursting_master_requests))
          sysid_control_slave_slavearbiterlockenable <= |sysid_control_slave_arb_share_counter_next_value;
    end


  //cpu/data_master sysid/control_slave arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = sysid_control_slave_slavearbiterlockenable & cpu_data_master_continuerequest;

  //sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign sysid_control_slave_slavearbiterlockenable2 = |sysid_control_slave_arb_share_counter_next_value;

  //cpu/data_master sysid/control_slave arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = sysid_control_slave_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign sysid_control_slave_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_sysid_control_slave = cpu_data_master_requests_sysid_control_slave;
  //master is always granted when requested
  assign cpu_data_master_granted_sysid_control_slave = cpu_data_master_qualified_request_sysid_control_slave;

  //cpu/data_master saved-grant sysid/control_slave, which is an e_assign
  assign cpu_data_master_saved_grant_sysid_control_slave = cpu_data_master_requests_sysid_control_slave;

  //allow new arb cycle for sysid/control_slave, which is an e_assign
  assign sysid_control_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign sysid_control_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign sysid_control_slave_master_qreq_vector = 1;

  //sysid_control_slave_reset_n assignment, which is an e_assign
  assign sysid_control_slave_reset_n = reset_n;

  //sysid_control_slave_firsttransfer first transaction, which is an e_assign
  assign sysid_control_slave_firsttransfer = sysid_control_slave_begins_xfer ? sysid_control_slave_unreg_firsttransfer : sysid_control_slave_reg_firsttransfer;

  //sysid_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign sysid_control_slave_unreg_firsttransfer = ~(sysid_control_slave_slavearbiterlockenable & sysid_control_slave_any_continuerequest);

  //sysid_control_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sysid_control_slave_reg_firsttransfer <= 1'b1;
      else if (sysid_control_slave_begins_xfer)
          sysid_control_slave_reg_firsttransfer <= sysid_control_slave_unreg_firsttransfer;
    end


  //sysid_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign sysid_control_slave_beginbursttransfer_internal = sysid_control_slave_begins_xfer;

  assign shifted_address_to_sysid_control_slave_from_cpu_data_master = cpu_data_master_address_to_slave;
  //sysid_control_slave_address mux, which is an e_mux
  assign sysid_control_slave_address = shifted_address_to_sysid_control_slave_from_cpu_data_master >> 2;

  //d1_sysid_control_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_sysid_control_slave_end_xfer <= 1;
      else 
        d1_sysid_control_slave_end_xfer <= sysid_control_slave_end_xfer;
    end


  //sysid_control_slave_waits_for_read in a cycle, which is an e_mux
  assign sysid_control_slave_waits_for_read = sysid_control_slave_in_a_read_cycle & sysid_control_slave_begins_xfer;

  //sysid_control_slave_in_a_read_cycle assignment, which is an e_assign
  assign sysid_control_slave_in_a_read_cycle = cpu_data_master_granted_sysid_control_slave & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = sysid_control_slave_in_a_read_cycle;

  //sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  assign sysid_control_slave_waits_for_write = sysid_control_slave_in_a_write_cycle & 0;

  //sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  assign sysid_control_slave_in_a_write_cycle = cpu_data_master_granted_sysid_control_slave & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = sysid_control_slave_in_a_write_cycle;

  assign wait_for_sysid_control_slave_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //sysid/control_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module uart_s1_arbitrator (
                            // inputs:
                             clk,
                             cpu_data_master_address_to_slave,
                             cpu_data_master_read,
                             cpu_data_master_write,
                             cpu_data_master_writedata,
                             reset_n,
                             uart_s1_dataavailable,
                             uart_s1_irq,
                             uart_s1_readdata,
                             uart_s1_readyfordata,

                            // outputs:
                             cpu_data_master_granted_uart_s1,
                             cpu_data_master_qualified_request_uart_s1,
                             cpu_data_master_read_data_valid_uart_s1,
                             cpu_data_master_requests_uart_s1,
                             d1_uart_s1_end_xfer,
                             uart_s1_address,
                             uart_s1_begintransfer,
                             uart_s1_chipselect,
                             uart_s1_dataavailable_from_sa,
                             uart_s1_irq_from_sa,
                             uart_s1_read_n,
                             uart_s1_readdata_from_sa,
                             uart_s1_readyfordata_from_sa,
                             uart_s1_reset_n,
                             uart_s1_write_n,
                             uart_s1_writedata
                          )
;

  output           cpu_data_master_granted_uart_s1;
  output           cpu_data_master_qualified_request_uart_s1;
  output           cpu_data_master_read_data_valid_uart_s1;
  output           cpu_data_master_requests_uart_s1;
  output           d1_uart_s1_end_xfer;
  output  [  2: 0] uart_s1_address;
  output           uart_s1_begintransfer;
  output           uart_s1_chipselect;
  output           uart_s1_dataavailable_from_sa;
  output           uart_s1_irq_from_sa;
  output           uart_s1_read_n;
  output  [ 15: 0] uart_s1_readdata_from_sa;
  output           uart_s1_readyfordata_from_sa;
  output           uart_s1_reset_n;
  output           uart_s1_write_n;
  output  [ 15: 0] uart_s1_writedata;
  input            clk;
  input   [ 26: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;
  input            uart_s1_dataavailable;
  input            uart_s1_irq;
  input   [ 15: 0] uart_s1_readdata;
  input            uart_s1_readyfordata;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_uart_s1;
  wire             cpu_data_master_qualified_request_uart_s1;
  wire             cpu_data_master_read_data_valid_uart_s1;
  wire             cpu_data_master_requests_uart_s1;
  wire             cpu_data_master_saved_grant_uart_s1;
  reg              d1_reasons_to_wait;
  reg              d1_uart_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_uart_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 26: 0] shifted_address_to_uart_s1_from_cpu_data_master;
  wire    [  2: 0] uart_s1_address;
  wire             uart_s1_allgrants;
  wire             uart_s1_allow_new_arb_cycle;
  wire             uart_s1_any_bursting_master_saved_grant;
  wire             uart_s1_any_continuerequest;
  wire             uart_s1_arb_counter_enable;
  reg     [  1: 0] uart_s1_arb_share_counter;
  wire    [  1: 0] uart_s1_arb_share_counter_next_value;
  wire    [  1: 0] uart_s1_arb_share_set_values;
  wire             uart_s1_beginbursttransfer_internal;
  wire             uart_s1_begins_xfer;
  wire             uart_s1_begintransfer;
  wire             uart_s1_chipselect;
  wire             uart_s1_dataavailable_from_sa;
  wire             uart_s1_end_xfer;
  wire             uart_s1_firsttransfer;
  wire             uart_s1_grant_vector;
  wire             uart_s1_in_a_read_cycle;
  wire             uart_s1_in_a_write_cycle;
  wire             uart_s1_irq_from_sa;
  wire             uart_s1_master_qreq_vector;
  wire             uart_s1_non_bursting_master_requests;
  wire             uart_s1_read_n;
  wire    [ 15: 0] uart_s1_readdata_from_sa;
  wire             uart_s1_readyfordata_from_sa;
  reg              uart_s1_reg_firsttransfer;
  wire             uart_s1_reset_n;
  reg              uart_s1_slavearbiterlockenable;
  wire             uart_s1_slavearbiterlockenable2;
  wire             uart_s1_unreg_firsttransfer;
  wire             uart_s1_waits_for_read;
  wire             uart_s1_waits_for_write;
  wire             uart_s1_write_n;
  wire    [ 15: 0] uart_s1_writedata;
  wire             wait_for_uart_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~uart_s1_end_xfer;
    end


  assign uart_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_uart_s1));
  //assign uart_s1_readdata_from_sa = uart_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_s1_readdata_from_sa = uart_s1_readdata;

  assign cpu_data_master_requests_uart_s1 = ({cpu_data_master_address_to_slave[26 : 5] , 5'b0} == 27'h3820) & (cpu_data_master_read | cpu_data_master_write);
  //assign uart_s1_dataavailable_from_sa = uart_s1_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_s1_dataavailable_from_sa = uart_s1_dataavailable;

  //assign uart_s1_readyfordata_from_sa = uart_s1_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_s1_readyfordata_from_sa = uart_s1_readyfordata;

  //uart_s1_arb_share_counter set values, which is an e_mux
  assign uart_s1_arb_share_set_values = 1;

  //uart_s1_non_bursting_master_requests mux, which is an e_mux
  assign uart_s1_non_bursting_master_requests = cpu_data_master_requests_uart_s1;

  //uart_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign uart_s1_any_bursting_master_saved_grant = 0;

  //uart_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign uart_s1_arb_share_counter_next_value = uart_s1_firsttransfer ? (uart_s1_arb_share_set_values - 1) : |uart_s1_arb_share_counter ? (uart_s1_arb_share_counter - 1) : 0;

  //uart_s1_allgrants all slave grants, which is an e_mux
  assign uart_s1_allgrants = |uart_s1_grant_vector;

  //uart_s1_end_xfer assignment, which is an e_assign
  assign uart_s1_end_xfer = ~(uart_s1_waits_for_read | uart_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_uart_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_uart_s1 = uart_s1_end_xfer & (~uart_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //uart_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign uart_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_uart_s1 & uart_s1_allgrants) | (end_xfer_arb_share_counter_term_uart_s1 & ~uart_s1_non_bursting_master_requests);

  //uart_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_s1_arb_share_counter <= 0;
      else if (uart_s1_arb_counter_enable)
          uart_s1_arb_share_counter <= uart_s1_arb_share_counter_next_value;
    end


  //uart_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_s1_slavearbiterlockenable <= 0;
      else if ((|uart_s1_master_qreq_vector & end_xfer_arb_share_counter_term_uart_s1) | (end_xfer_arb_share_counter_term_uart_s1 & ~uart_s1_non_bursting_master_requests))
          uart_s1_slavearbiterlockenable <= |uart_s1_arb_share_counter_next_value;
    end


  //cpu/data_master uart/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = uart_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //uart_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign uart_s1_slavearbiterlockenable2 = |uart_s1_arb_share_counter_next_value;

  //cpu/data_master uart/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = uart_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //uart_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign uart_s1_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_uart_s1 = cpu_data_master_requests_uart_s1;
  //uart_s1_writedata mux, which is an e_mux
  assign uart_s1_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_uart_s1 = cpu_data_master_qualified_request_uart_s1;

  //cpu/data_master saved-grant uart/s1, which is an e_assign
  assign cpu_data_master_saved_grant_uart_s1 = cpu_data_master_requests_uart_s1;

  //allow new arb cycle for uart/s1, which is an e_assign
  assign uart_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign uart_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign uart_s1_master_qreq_vector = 1;

  assign uart_s1_begintransfer = uart_s1_begins_xfer;
  //uart_s1_reset_n assignment, which is an e_assign
  assign uart_s1_reset_n = reset_n;

  assign uart_s1_chipselect = cpu_data_master_granted_uart_s1;
  //uart_s1_firsttransfer first transaction, which is an e_assign
  assign uart_s1_firsttransfer = uart_s1_begins_xfer ? uart_s1_unreg_firsttransfer : uart_s1_reg_firsttransfer;

  //uart_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign uart_s1_unreg_firsttransfer = ~(uart_s1_slavearbiterlockenable & uart_s1_any_continuerequest);

  //uart_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_s1_reg_firsttransfer <= 1'b1;
      else if (uart_s1_begins_xfer)
          uart_s1_reg_firsttransfer <= uart_s1_unreg_firsttransfer;
    end


  //uart_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign uart_s1_beginbursttransfer_internal = uart_s1_begins_xfer;

  //~uart_s1_read_n assignment, which is an e_mux
  assign uart_s1_read_n = ~(cpu_data_master_granted_uart_s1 & cpu_data_master_read);

  //~uart_s1_write_n assignment, which is an e_mux
  assign uart_s1_write_n = ~(cpu_data_master_granted_uart_s1 & cpu_data_master_write);

  assign shifted_address_to_uart_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //uart_s1_address mux, which is an e_mux
  assign uart_s1_address = shifted_address_to_uart_s1_from_cpu_data_master >> 2;

  //d1_uart_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_uart_s1_end_xfer <= 1;
      else 
        d1_uart_s1_end_xfer <= uart_s1_end_xfer;
    end


  //uart_s1_waits_for_read in a cycle, which is an e_mux
  assign uart_s1_waits_for_read = uart_s1_in_a_read_cycle & uart_s1_begins_xfer;

  //uart_s1_in_a_read_cycle assignment, which is an e_assign
  assign uart_s1_in_a_read_cycle = cpu_data_master_granted_uart_s1 & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = uart_s1_in_a_read_cycle;

  //uart_s1_waits_for_write in a cycle, which is an e_mux
  assign uart_s1_waits_for_write = uart_s1_in_a_write_cycle & uart_s1_begins_xfer;

  //uart_s1_in_a_write_cycle assignment, which is an e_assign
  assign uart_s1_in_a_write_cycle = cpu_data_master_granted_uart_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = uart_s1_in_a_write_cycle;

  assign wait_for_uart_s1_counter = 0;
  //assign uart_s1_irq_from_sa = uart_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_s1_irq_from_sa = uart_s1_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //uart/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module ESPIER_I_niosII_standard_sopc_reset_clk_domain_synch_module (
                                                                     // inputs:
                                                                      clk,
                                                                      data_in,
                                                                      reset_n,

                                                                     // outputs:
                                                                      data_out
                                                                   )
;

  output           data_out;
  input            clk;
  input            data_in;
  input            reset_n;

  reg              data_in_d1 /* synthesis ALTERA_ATTRIBUTE = "{-from \"*\"} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  reg              data_out /* synthesis ALTERA_ATTRIBUTE = "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_in_d1 <= 0;
      else 
        data_in_d1 <= data_in;
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_out <= 0;
      else 
        data_out <= data_in_d1;
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module ESPIER_I_niosII_standard_sopc (
                                       // 1) global signals:
                                        clk,
                                        reset_n,

                                       // the_beep
                                        out_port_from_the_beep,

                                       // the_epcs_controller
                                        data0_to_the_epcs_controller,
                                        dclk_from_the_epcs_controller,
                                        sce_from_the_epcs_controller,
                                        sdo_from_the_epcs_controller,

                                       // the_key
                                        in_port_to_the_key,

                                       // the_lcd
                                        LCD_E_from_the_lcd,
                                        LCD_RS_from_the_lcd,
                                        LCD_RW_from_the_lcd,
                                        LCD_data_to_and_from_the_lcd,

                                       // the_led
                                        out_port_from_the_led,

                                       // the_sdram
                                        zs_addr_from_the_sdram,
                                        zs_ba_from_the_sdram,
                                        zs_cas_n_from_the_sdram,
                                        zs_cke_from_the_sdram,
                                        zs_cs_n_from_the_sdram,
                                        zs_dq_to_and_from_the_sdram,
                                        zs_dqm_from_the_sdram,
                                        zs_ras_n_from_the_sdram,
                                        zs_we_n_from_the_sdram,

                                       // the_spi_adc
                                        MISO_to_the_spi_adc,
                                        MOSI_from_the_spi_adc,
                                        SCLK_from_the_spi_adc,
                                        SS_n_from_the_spi_adc,

                                       // the_spi_flash
                                        MISO_to_the_spi_flash,
                                        MOSI_from_the_spi_flash,
                                        SCLK_from_the_spi_flash,
                                        SS_n_from_the_spi_flash,

                                       // the_uart
                                        rxd_to_the_uart,
                                        txd_from_the_uart
                                     )
;

  output           LCD_E_from_the_lcd;
  output           LCD_RS_from_the_lcd;
  output           LCD_RW_from_the_lcd;
  inout   [  7: 0] LCD_data_to_and_from_the_lcd;
  output           MOSI_from_the_spi_adc;
  output           MOSI_from_the_spi_flash;
  output           SCLK_from_the_spi_adc;
  output           SCLK_from_the_spi_flash;
  output           SS_n_from_the_spi_adc;
  output           SS_n_from_the_spi_flash;
  output           dclk_from_the_epcs_controller;
  output           out_port_from_the_beep;
  output  [  3: 0] out_port_from_the_led;
  output           sce_from_the_epcs_controller;
  output           sdo_from_the_epcs_controller;
  output           txd_from_the_uart;
  output  [ 12: 0] zs_addr_from_the_sdram;
  output  [  1: 0] zs_ba_from_the_sdram;
  output           zs_cas_n_from_the_sdram;
  output           zs_cke_from_the_sdram;
  output           zs_cs_n_from_the_sdram;
  inout   [ 15: 0] zs_dq_to_and_from_the_sdram;
  output  [  1: 0] zs_dqm_from_the_sdram;
  output           zs_ras_n_from_the_sdram;
  output           zs_we_n_from_the_sdram;
  input            MISO_to_the_spi_adc;
  input            MISO_to_the_spi_flash;
  input            clk;
  input            data0_to_the_epcs_controller;
  input            in_port_to_the_key;
  input            reset_n;
  input            rxd_to_the_uart;

  wire             LCD_E_from_the_lcd;
  wire             LCD_RS_from_the_lcd;
  wire             LCD_RW_from_the_lcd;
  wire    [  7: 0] LCD_data_to_and_from_the_lcd;
  wire             MOSI_from_the_spi_adc;
  wire             MOSI_from_the_spi_flash;
  wire             SCLK_from_the_spi_adc;
  wire             SCLK_from_the_spi_flash;
  wire             SS_n_from_the_spi_adc;
  wire             SS_n_from_the_spi_flash;
  wire    [  1: 0] beep_s1_address;
  wire             beep_s1_chipselect;
  wire    [ 31: 0] beep_s1_readdata;
  wire    [ 31: 0] beep_s1_readdata_from_sa;
  wire             beep_s1_reset_n;
  wire             beep_s1_write_n;
  wire    [ 31: 0] beep_s1_writedata;
  wire             clk_reset_n;
  wire    [ 26: 0] cpu_data_master_address;
  wire    [ 26: 0] cpu_data_master_address_to_slave;
  wire    [  3: 0] cpu_data_master_byteenable;
  wire    [  1: 0] cpu_data_master_byteenable_sdram_s1;
  wire    [  1: 0] cpu_data_master_dbs_address;
  wire    [ 15: 0] cpu_data_master_dbs_write_16;
  wire             cpu_data_master_debugaccess;
  wire             cpu_data_master_granted_beep_s1;
  wire             cpu_data_master_granted_cpu_jtag_debug_module;
  wire             cpu_data_master_granted_epcs_controller_epcs_control_port;
  wire             cpu_data_master_granted_high_res_timer_s1;
  wire             cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_granted_key_s1;
  wire             cpu_data_master_granted_lcd_control_slave;
  wire             cpu_data_master_granted_led_s1;
  wire             cpu_data_master_granted_onchip_ram_s1;
  wire             cpu_data_master_granted_sdram_s1;
  wire             cpu_data_master_granted_spi_adc_spi_control_port;
  wire             cpu_data_master_granted_spi_flash_spi_control_port;
  wire             cpu_data_master_granted_sys_clk_timer_s1;
  wire             cpu_data_master_granted_sysid_control_slave;
  wire             cpu_data_master_granted_uart_s1;
  wire    [ 31: 0] cpu_data_master_irq;
  wire             cpu_data_master_no_byte_enables_and_last_term;
  wire             cpu_data_master_qualified_request_beep_s1;
  wire             cpu_data_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_data_master_qualified_request_epcs_controller_epcs_control_port;
  wire             cpu_data_master_qualified_request_high_res_timer_s1;
  wire             cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_qualified_request_key_s1;
  wire             cpu_data_master_qualified_request_lcd_control_slave;
  wire             cpu_data_master_qualified_request_led_s1;
  wire             cpu_data_master_qualified_request_onchip_ram_s1;
  wire             cpu_data_master_qualified_request_sdram_s1;
  wire             cpu_data_master_qualified_request_spi_adc_spi_control_port;
  wire             cpu_data_master_qualified_request_spi_flash_spi_control_port;
  wire             cpu_data_master_qualified_request_sys_clk_timer_s1;
  wire             cpu_data_master_qualified_request_sysid_control_slave;
  wire             cpu_data_master_qualified_request_uart_s1;
  wire             cpu_data_master_read;
  wire             cpu_data_master_read_data_valid_beep_s1;
  wire             cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_data_master_read_data_valid_epcs_controller_epcs_control_port;
  wire             cpu_data_master_read_data_valid_high_res_timer_s1;
  wire             cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_read_data_valid_key_s1;
  wire             cpu_data_master_read_data_valid_lcd_control_slave;
  wire             cpu_data_master_read_data_valid_led_s1;
  wire             cpu_data_master_read_data_valid_onchip_ram_s1;
  wire             cpu_data_master_read_data_valid_sdram_s1;
  wire             cpu_data_master_read_data_valid_sdram_s1_shift_register;
  wire             cpu_data_master_read_data_valid_spi_adc_spi_control_port;
  wire             cpu_data_master_read_data_valid_spi_flash_spi_control_port;
  wire             cpu_data_master_read_data_valid_sys_clk_timer_s1;
  wire             cpu_data_master_read_data_valid_sysid_control_slave;
  wire             cpu_data_master_read_data_valid_uart_s1;
  wire    [ 31: 0] cpu_data_master_readdata;
  wire             cpu_data_master_requests_beep_s1;
  wire             cpu_data_master_requests_cpu_jtag_debug_module;
  wire             cpu_data_master_requests_epcs_controller_epcs_control_port;
  wire             cpu_data_master_requests_high_res_timer_s1;
  wire             cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_requests_key_s1;
  wire             cpu_data_master_requests_lcd_control_slave;
  wire             cpu_data_master_requests_led_s1;
  wire             cpu_data_master_requests_onchip_ram_s1;
  wire             cpu_data_master_requests_sdram_s1;
  wire             cpu_data_master_requests_spi_adc_spi_control_port;
  wire             cpu_data_master_requests_spi_flash_spi_control_port;
  wire             cpu_data_master_requests_sys_clk_timer_s1;
  wire             cpu_data_master_requests_sysid_control_slave;
  wire             cpu_data_master_requests_uart_s1;
  wire             cpu_data_master_waitrequest;
  wire             cpu_data_master_write;
  wire    [ 31: 0] cpu_data_master_writedata;
  wire    [ 26: 0] cpu_instruction_master_address;
  wire    [ 26: 0] cpu_instruction_master_address_to_slave;
  wire    [  1: 0] cpu_instruction_master_dbs_address;
  wire             cpu_instruction_master_granted_cpu_jtag_debug_module;
  wire             cpu_instruction_master_granted_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_granted_onchip_ram_s1;
  wire             cpu_instruction_master_granted_sdram_s1;
  wire             cpu_instruction_master_latency_counter;
  wire             cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_qualified_request_onchip_ram_s1;
  wire             cpu_instruction_master_qualified_request_sdram_s1;
  wire             cpu_instruction_master_read;
  wire             cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_read_data_valid_onchip_ram_s1;
  wire             cpu_instruction_master_read_data_valid_sdram_s1;
  wire             cpu_instruction_master_read_data_valid_sdram_s1_shift_register;
  wire    [ 31: 0] cpu_instruction_master_readdata;
  wire             cpu_instruction_master_readdatavalid;
  wire             cpu_instruction_master_requests_cpu_jtag_debug_module;
  wire             cpu_instruction_master_requests_epcs_controller_epcs_control_port;
  wire             cpu_instruction_master_requests_onchip_ram_s1;
  wire             cpu_instruction_master_requests_sdram_s1;
  wire             cpu_instruction_master_waitrequest;
  wire    [  8: 0] cpu_jtag_debug_module_address;
  wire             cpu_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_jtag_debug_module_byteenable;
  wire             cpu_jtag_debug_module_chipselect;
  wire             cpu_jtag_debug_module_debugaccess;
  wire    [ 31: 0] cpu_jtag_debug_module_readdata;
  wire    [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  wire             cpu_jtag_debug_module_reset_n;
  wire             cpu_jtag_debug_module_resetrequest;
  wire             cpu_jtag_debug_module_resetrequest_from_sa;
  wire             cpu_jtag_debug_module_write;
  wire    [ 31: 0] cpu_jtag_debug_module_writedata;
  wire             d1_beep_s1_end_xfer;
  wire             d1_cpu_jtag_debug_module_end_xfer;
  wire             d1_epcs_controller_epcs_control_port_end_xfer;
  wire             d1_high_res_timer_s1_end_xfer;
  wire             d1_jtag_uart_avalon_jtag_slave_end_xfer;
  wire             d1_key_s1_end_xfer;
  wire             d1_lcd_control_slave_end_xfer;
  wire             d1_led_s1_end_xfer;
  wire             d1_onchip_ram_s1_end_xfer;
  wire             d1_sdram_s1_end_xfer;
  wire             d1_spi_adc_spi_control_port_end_xfer;
  wire             d1_spi_flash_spi_control_port_end_xfer;
  wire             d1_sys_clk_timer_s1_end_xfer;
  wire             d1_sysid_control_slave_end_xfer;
  wire             d1_uart_s1_end_xfer;
  wire             dclk_from_the_epcs_controller;
  wire    [  8: 0] epcs_controller_epcs_control_port_address;
  wire             epcs_controller_epcs_control_port_chipselect;
  wire             epcs_controller_epcs_control_port_dataavailable;
  wire             epcs_controller_epcs_control_port_dataavailable_from_sa;
  wire             epcs_controller_epcs_control_port_endofpacket;
  wire             epcs_controller_epcs_control_port_endofpacket_from_sa;
  wire             epcs_controller_epcs_control_port_irq;
  wire             epcs_controller_epcs_control_port_irq_from_sa;
  wire             epcs_controller_epcs_control_port_read_n;
  wire    [ 31: 0] epcs_controller_epcs_control_port_readdata;
  wire    [ 31: 0] epcs_controller_epcs_control_port_readdata_from_sa;
  wire             epcs_controller_epcs_control_port_readyfordata;
  wire             epcs_controller_epcs_control_port_readyfordata_from_sa;
  wire             epcs_controller_epcs_control_port_reset_n;
  wire             epcs_controller_epcs_control_port_write_n;
  wire    [ 31: 0] epcs_controller_epcs_control_port_writedata;
  wire    [  2: 0] high_res_timer_s1_address;
  wire             high_res_timer_s1_chipselect;
  wire             high_res_timer_s1_irq;
  wire             high_res_timer_s1_irq_from_sa;
  wire    [ 15: 0] high_res_timer_s1_readdata;
  wire    [ 15: 0] high_res_timer_s1_readdata_from_sa;
  wire             high_res_timer_s1_reset_n;
  wire             high_res_timer_s1_write_n;
  wire    [ 15: 0] high_res_timer_s1_writedata;
  wire             jtag_uart_avalon_jtag_slave_address;
  wire             jtag_uart_avalon_jtag_slave_chipselect;
  wire             jtag_uart_avalon_jtag_slave_dataavailable;
  wire             jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_avalon_jtag_slave_irq;
  wire             jtag_uart_avalon_jtag_slave_irq_from_sa;
  wire             jtag_uart_avalon_jtag_slave_read_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_readdata;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  wire             jtag_uart_avalon_jtag_slave_readyfordata;
  wire             jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  wire             jtag_uart_avalon_jtag_slave_reset_n;
  wire             jtag_uart_avalon_jtag_slave_waitrequest;
  wire             jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  wire             jtag_uart_avalon_jtag_slave_write_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_writedata;
  wire    [  1: 0] key_s1_address;
  wire             key_s1_chipselect;
  wire             key_s1_irq;
  wire             key_s1_irq_from_sa;
  wire    [ 31: 0] key_s1_readdata;
  wire    [ 31: 0] key_s1_readdata_from_sa;
  wire             key_s1_reset_n;
  wire             key_s1_write_n;
  wire    [ 31: 0] key_s1_writedata;
  wire    [  1: 0] lcd_control_slave_address;
  wire             lcd_control_slave_begintransfer;
  wire             lcd_control_slave_read;
  wire    [  7: 0] lcd_control_slave_readdata;
  wire    [  7: 0] lcd_control_slave_readdata_from_sa;
  wire             lcd_control_slave_reset_n;
  wire             lcd_control_slave_wait_counter_eq_0;
  wire             lcd_control_slave_wait_counter_eq_1;
  wire             lcd_control_slave_write;
  wire    [  7: 0] lcd_control_slave_writedata;
  wire    [  2: 0] led_s1_address;
  wire             led_s1_chipselect;
  wire    [ 31: 0] led_s1_readdata;
  wire    [ 31: 0] led_s1_readdata_from_sa;
  wire             led_s1_reset_n;
  wire             led_s1_write_n;
  wire    [ 31: 0] led_s1_writedata;
  wire    [  9: 0] onchip_ram_s1_address;
  wire    [  3: 0] onchip_ram_s1_byteenable;
  wire             onchip_ram_s1_chipselect;
  wire             onchip_ram_s1_clken;
  wire    [ 31: 0] onchip_ram_s1_readdata;
  wire    [ 31: 0] onchip_ram_s1_readdata_from_sa;
  wire             onchip_ram_s1_reset;
  wire             onchip_ram_s1_write;
  wire    [ 31: 0] onchip_ram_s1_writedata;
  wire             out_port_from_the_beep;
  wire    [  3: 0] out_port_from_the_led;
  wire             registered_cpu_data_master_read_data_valid_onchip_ram_s1;
  wire             reset_n_sources;
  wire             sce_from_the_epcs_controller;
  wire             sdo_from_the_epcs_controller;
  wire    [ 23: 0] sdram_s1_address;
  wire    [  1: 0] sdram_s1_byteenable_n;
  wire             sdram_s1_chipselect;
  wire             sdram_s1_read_n;
  wire    [ 15: 0] sdram_s1_readdata;
  wire    [ 15: 0] sdram_s1_readdata_from_sa;
  wire             sdram_s1_readdatavalid;
  wire             sdram_s1_reset_n;
  wire             sdram_s1_waitrequest;
  wire             sdram_s1_waitrequest_from_sa;
  wire             sdram_s1_write_n;
  wire    [ 15: 0] sdram_s1_writedata;
  wire    [  2: 0] spi_adc_spi_control_port_address;
  wire             spi_adc_spi_control_port_chipselect;
  wire             spi_adc_spi_control_port_dataavailable;
  wire             spi_adc_spi_control_port_dataavailable_from_sa;
  wire             spi_adc_spi_control_port_endofpacket;
  wire             spi_adc_spi_control_port_endofpacket_from_sa;
  wire             spi_adc_spi_control_port_irq;
  wire             spi_adc_spi_control_port_irq_from_sa;
  wire             spi_adc_spi_control_port_read_n;
  wire    [ 15: 0] spi_adc_spi_control_port_readdata;
  wire    [ 15: 0] spi_adc_spi_control_port_readdata_from_sa;
  wire             spi_adc_spi_control_port_readyfordata;
  wire             spi_adc_spi_control_port_readyfordata_from_sa;
  wire             spi_adc_spi_control_port_reset_n;
  wire             spi_adc_spi_control_port_write_n;
  wire    [ 15: 0] spi_adc_spi_control_port_writedata;
  wire    [  2: 0] spi_flash_spi_control_port_address;
  wire             spi_flash_spi_control_port_chipselect;
  wire             spi_flash_spi_control_port_dataavailable;
  wire             spi_flash_spi_control_port_dataavailable_from_sa;
  wire             spi_flash_spi_control_port_endofpacket;
  wire             spi_flash_spi_control_port_endofpacket_from_sa;
  wire             spi_flash_spi_control_port_irq;
  wire             spi_flash_spi_control_port_irq_from_sa;
  wire             spi_flash_spi_control_port_read_n;
  wire    [ 15: 0] spi_flash_spi_control_port_readdata;
  wire    [ 15: 0] spi_flash_spi_control_port_readdata_from_sa;
  wire             spi_flash_spi_control_port_readyfordata;
  wire             spi_flash_spi_control_port_readyfordata_from_sa;
  wire             spi_flash_spi_control_port_reset_n;
  wire             spi_flash_spi_control_port_write_n;
  wire    [ 15: 0] spi_flash_spi_control_port_writedata;
  wire    [  2: 0] sys_clk_timer_s1_address;
  wire             sys_clk_timer_s1_chipselect;
  wire             sys_clk_timer_s1_irq;
  wire             sys_clk_timer_s1_irq_from_sa;
  wire    [ 15: 0] sys_clk_timer_s1_readdata;
  wire    [ 15: 0] sys_clk_timer_s1_readdata_from_sa;
  wire             sys_clk_timer_s1_reset_n;
  wire             sys_clk_timer_s1_write_n;
  wire    [ 15: 0] sys_clk_timer_s1_writedata;
  wire             sysid_control_slave_address;
  wire             sysid_control_slave_clock;
  wire    [ 31: 0] sysid_control_slave_readdata;
  wire    [ 31: 0] sysid_control_slave_readdata_from_sa;
  wire             sysid_control_slave_reset_n;
  wire             txd_from_the_uart;
  wire    [  2: 0] uart_s1_address;
  wire             uart_s1_begintransfer;
  wire             uart_s1_chipselect;
  wire             uart_s1_dataavailable;
  wire             uart_s1_dataavailable_from_sa;
  wire             uart_s1_irq;
  wire             uart_s1_irq_from_sa;
  wire             uart_s1_read_n;
  wire    [ 15: 0] uart_s1_readdata;
  wire    [ 15: 0] uart_s1_readdata_from_sa;
  wire             uart_s1_readyfordata;
  wire             uart_s1_readyfordata_from_sa;
  wire             uart_s1_reset_n;
  wire             uart_s1_write_n;
  wire    [ 15: 0] uart_s1_writedata;
  wire    [ 12: 0] zs_addr_from_the_sdram;
  wire    [  1: 0] zs_ba_from_the_sdram;
  wire             zs_cas_n_from_the_sdram;
  wire             zs_cke_from_the_sdram;
  wire             zs_cs_n_from_the_sdram;
  wire    [ 15: 0] zs_dq_to_and_from_the_sdram;
  wire    [  1: 0] zs_dqm_from_the_sdram;
  wire             zs_ras_n_from_the_sdram;
  wire             zs_we_n_from_the_sdram;
  beep_s1_arbitrator the_beep_s1
    (
      .beep_s1_address                           (beep_s1_address),
      .beep_s1_chipselect                        (beep_s1_chipselect),
      .beep_s1_readdata                          (beep_s1_readdata),
      .beep_s1_readdata_from_sa                  (beep_s1_readdata_from_sa),
      .beep_s1_reset_n                           (beep_s1_reset_n),
      .beep_s1_write_n                           (beep_s1_write_n),
      .beep_s1_writedata                         (beep_s1_writedata),
      .clk                                       (clk),
      .cpu_data_master_address_to_slave          (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_beep_s1           (cpu_data_master_granted_beep_s1),
      .cpu_data_master_qualified_request_beep_s1 (cpu_data_master_qualified_request_beep_s1),
      .cpu_data_master_read                      (cpu_data_master_read),
      .cpu_data_master_read_data_valid_beep_s1   (cpu_data_master_read_data_valid_beep_s1),
      .cpu_data_master_requests_beep_s1          (cpu_data_master_requests_beep_s1),
      .cpu_data_master_waitrequest               (cpu_data_master_waitrequest),
      .cpu_data_master_write                     (cpu_data_master_write),
      .cpu_data_master_writedata                 (cpu_data_master_writedata),
      .d1_beep_s1_end_xfer                       (d1_beep_s1_end_xfer),
      .reset_n                                   (clk_reset_n)
    );

  beep the_beep
    (
      .address    (beep_s1_address),
      .chipselect (beep_s1_chipselect),
      .clk        (clk),
      .out_port   (out_port_from_the_beep),
      .readdata   (beep_s1_readdata),
      .reset_n    (beep_s1_reset_n),
      .write_n    (beep_s1_write_n),
      .writedata  (beep_s1_writedata)
    );

  cpu_jtag_debug_module_arbitrator the_cpu_jtag_debug_module
    (
      .clk                                                            (clk),
      .cpu_data_master_address_to_slave                               (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable                                     (cpu_data_master_byteenable),
      .cpu_data_master_debugaccess                                    (cpu_data_master_debugaccess),
      .cpu_data_master_granted_cpu_jtag_debug_module                  (cpu_data_master_granted_cpu_jtag_debug_module),
      .cpu_data_master_qualified_request_cpu_jtag_debug_module        (cpu_data_master_qualified_request_cpu_jtag_debug_module),
      .cpu_data_master_read                                           (cpu_data_master_read),
      .cpu_data_master_read_data_valid_cpu_jtag_debug_module          (cpu_data_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_data_master_requests_cpu_jtag_debug_module                 (cpu_data_master_requests_cpu_jtag_debug_module),
      .cpu_data_master_waitrequest                                    (cpu_data_master_waitrequest),
      .cpu_data_master_write                                          (cpu_data_master_write),
      .cpu_data_master_writedata                                      (cpu_data_master_writedata),
      .cpu_instruction_master_address_to_slave                        (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_granted_cpu_jtag_debug_module           (cpu_instruction_master_granted_cpu_jtag_debug_module),
      .cpu_instruction_master_latency_counter                         (cpu_instruction_master_latency_counter),
      .cpu_instruction_master_qualified_request_cpu_jtag_debug_module (cpu_instruction_master_qualified_request_cpu_jtag_debug_module),
      .cpu_instruction_master_read                                    (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_cpu_jtag_debug_module   (cpu_instruction_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_instruction_master_read_data_valid_sdram_s1_shift_register (cpu_instruction_master_read_data_valid_sdram_s1_shift_register),
      .cpu_instruction_master_requests_cpu_jtag_debug_module          (cpu_instruction_master_requests_cpu_jtag_debug_module),
      .cpu_jtag_debug_module_address                                  (cpu_jtag_debug_module_address),
      .cpu_jtag_debug_module_begintransfer                            (cpu_jtag_debug_module_begintransfer),
      .cpu_jtag_debug_module_byteenable                               (cpu_jtag_debug_module_byteenable),
      .cpu_jtag_debug_module_chipselect                               (cpu_jtag_debug_module_chipselect),
      .cpu_jtag_debug_module_debugaccess                              (cpu_jtag_debug_module_debugaccess),
      .cpu_jtag_debug_module_readdata                                 (cpu_jtag_debug_module_readdata),
      .cpu_jtag_debug_module_readdata_from_sa                         (cpu_jtag_debug_module_readdata_from_sa),
      .cpu_jtag_debug_module_reset_n                                  (cpu_jtag_debug_module_reset_n),
      .cpu_jtag_debug_module_resetrequest                             (cpu_jtag_debug_module_resetrequest),
      .cpu_jtag_debug_module_resetrequest_from_sa                     (cpu_jtag_debug_module_resetrequest_from_sa),
      .cpu_jtag_debug_module_write                                    (cpu_jtag_debug_module_write),
      .cpu_jtag_debug_module_writedata                                (cpu_jtag_debug_module_writedata),
      .d1_cpu_jtag_debug_module_end_xfer                              (d1_cpu_jtag_debug_module_end_xfer),
      .reset_n                                                        (clk_reset_n)
    );

  cpu_data_master_arbitrator the_cpu_data_master
    (
      .beep_s1_readdata_from_sa                                            (beep_s1_readdata_from_sa),
      .clk                                                                 (clk),
      .cpu_data_master_address                                             (cpu_data_master_address),
      .cpu_data_master_address_to_slave                                    (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable_sdram_s1                                 (cpu_data_master_byteenable_sdram_s1),
      .cpu_data_master_dbs_address                                         (cpu_data_master_dbs_address),
      .cpu_data_master_dbs_write_16                                        (cpu_data_master_dbs_write_16),
      .cpu_data_master_granted_beep_s1                                     (cpu_data_master_granted_beep_s1),
      .cpu_data_master_granted_cpu_jtag_debug_module                       (cpu_data_master_granted_cpu_jtag_debug_module),
      .cpu_data_master_granted_epcs_controller_epcs_control_port           (cpu_data_master_granted_epcs_controller_epcs_control_port),
      .cpu_data_master_granted_high_res_timer_s1                           (cpu_data_master_granted_high_res_timer_s1),
      .cpu_data_master_granted_jtag_uart_avalon_jtag_slave                 (cpu_data_master_granted_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_granted_key_s1                                      (cpu_data_master_granted_key_s1),
      .cpu_data_master_granted_lcd_control_slave                           (cpu_data_master_granted_lcd_control_slave),
      .cpu_data_master_granted_led_s1                                      (cpu_data_master_granted_led_s1),
      .cpu_data_master_granted_onchip_ram_s1                               (cpu_data_master_granted_onchip_ram_s1),
      .cpu_data_master_granted_sdram_s1                                    (cpu_data_master_granted_sdram_s1),
      .cpu_data_master_granted_spi_adc_spi_control_port                    (cpu_data_master_granted_spi_adc_spi_control_port),
      .cpu_data_master_granted_spi_flash_spi_control_port                  (cpu_data_master_granted_spi_flash_spi_control_port),
      .cpu_data_master_granted_sys_clk_timer_s1                            (cpu_data_master_granted_sys_clk_timer_s1),
      .cpu_data_master_granted_sysid_control_slave                         (cpu_data_master_granted_sysid_control_slave),
      .cpu_data_master_granted_uart_s1                                     (cpu_data_master_granted_uart_s1),
      .cpu_data_master_irq                                                 (cpu_data_master_irq),
      .cpu_data_master_no_byte_enables_and_last_term                       (cpu_data_master_no_byte_enables_and_last_term),
      .cpu_data_master_qualified_request_beep_s1                           (cpu_data_master_qualified_request_beep_s1),
      .cpu_data_master_qualified_request_cpu_jtag_debug_module             (cpu_data_master_qualified_request_cpu_jtag_debug_module),
      .cpu_data_master_qualified_request_epcs_controller_epcs_control_port (cpu_data_master_qualified_request_epcs_controller_epcs_control_port),
      .cpu_data_master_qualified_request_high_res_timer_s1                 (cpu_data_master_qualified_request_high_res_timer_s1),
      .cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave       (cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_qualified_request_key_s1                            (cpu_data_master_qualified_request_key_s1),
      .cpu_data_master_qualified_request_lcd_control_slave                 (cpu_data_master_qualified_request_lcd_control_slave),
      .cpu_data_master_qualified_request_led_s1                            (cpu_data_master_qualified_request_led_s1),
      .cpu_data_master_qualified_request_onchip_ram_s1                     (cpu_data_master_qualified_request_onchip_ram_s1),
      .cpu_data_master_qualified_request_sdram_s1                          (cpu_data_master_qualified_request_sdram_s1),
      .cpu_data_master_qualified_request_spi_adc_spi_control_port          (cpu_data_master_qualified_request_spi_adc_spi_control_port),
      .cpu_data_master_qualified_request_spi_flash_spi_control_port        (cpu_data_master_qualified_request_spi_flash_spi_control_port),
      .cpu_data_master_qualified_request_sys_clk_timer_s1                  (cpu_data_master_qualified_request_sys_clk_timer_s1),
      .cpu_data_master_qualified_request_sysid_control_slave               (cpu_data_master_qualified_request_sysid_control_slave),
      .cpu_data_master_qualified_request_uart_s1                           (cpu_data_master_qualified_request_uart_s1),
      .cpu_data_master_read                                                (cpu_data_master_read),
      .cpu_data_master_read_data_valid_beep_s1                             (cpu_data_master_read_data_valid_beep_s1),
      .cpu_data_master_read_data_valid_cpu_jtag_debug_module               (cpu_data_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_data_master_read_data_valid_epcs_controller_epcs_control_port   (cpu_data_master_read_data_valid_epcs_controller_epcs_control_port),
      .cpu_data_master_read_data_valid_high_res_timer_s1                   (cpu_data_master_read_data_valid_high_res_timer_s1),
      .cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave         (cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_read_data_valid_key_s1                              (cpu_data_master_read_data_valid_key_s1),
      .cpu_data_master_read_data_valid_lcd_control_slave                   (cpu_data_master_read_data_valid_lcd_control_slave),
      .cpu_data_master_read_data_valid_led_s1                              (cpu_data_master_read_data_valid_led_s1),
      .cpu_data_master_read_data_valid_onchip_ram_s1                       (cpu_data_master_read_data_valid_onchip_ram_s1),
      .cpu_data_master_read_data_valid_sdram_s1                            (cpu_data_master_read_data_valid_sdram_s1),
      .cpu_data_master_read_data_valid_sdram_s1_shift_register             (cpu_data_master_read_data_valid_sdram_s1_shift_register),
      .cpu_data_master_read_data_valid_spi_adc_spi_control_port            (cpu_data_master_read_data_valid_spi_adc_spi_control_port),
      .cpu_data_master_read_data_valid_spi_flash_spi_control_port          (cpu_data_master_read_data_valid_spi_flash_spi_control_port),
      .cpu_data_master_read_data_valid_sys_clk_timer_s1                    (cpu_data_master_read_data_valid_sys_clk_timer_s1),
      .cpu_data_master_read_data_valid_sysid_control_slave                 (cpu_data_master_read_data_valid_sysid_control_slave),
      .cpu_data_master_read_data_valid_uart_s1                             (cpu_data_master_read_data_valid_uart_s1),
      .cpu_data_master_readdata                                            (cpu_data_master_readdata),
      .cpu_data_master_requests_beep_s1                                    (cpu_data_master_requests_beep_s1),
      .cpu_data_master_requests_cpu_jtag_debug_module                      (cpu_data_master_requests_cpu_jtag_debug_module),
      .cpu_data_master_requests_epcs_controller_epcs_control_port          (cpu_data_master_requests_epcs_controller_epcs_control_port),
      .cpu_data_master_requests_high_res_timer_s1                          (cpu_data_master_requests_high_res_timer_s1),
      .cpu_data_master_requests_jtag_uart_avalon_jtag_slave                (cpu_data_master_requests_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_requests_key_s1                                     (cpu_data_master_requests_key_s1),
      .cpu_data_master_requests_lcd_control_slave                          (cpu_data_master_requests_lcd_control_slave),
      .cpu_data_master_requests_led_s1                                     (cpu_data_master_requests_led_s1),
      .cpu_data_master_requests_onchip_ram_s1                              (cpu_data_master_requests_onchip_ram_s1),
      .cpu_data_master_requests_sdram_s1                                   (cpu_data_master_requests_sdram_s1),
      .cpu_data_master_requests_spi_adc_spi_control_port                   (cpu_data_master_requests_spi_adc_spi_control_port),
      .cpu_data_master_requests_spi_flash_spi_control_port                 (cpu_data_master_requests_spi_flash_spi_control_port),
      .cpu_data_master_requests_sys_clk_timer_s1                           (cpu_data_master_requests_sys_clk_timer_s1),
      .cpu_data_master_requests_sysid_control_slave                        (cpu_data_master_requests_sysid_control_slave),
      .cpu_data_master_requests_uart_s1                                    (cpu_data_master_requests_uart_s1),
      .cpu_data_master_waitrequest                                         (cpu_data_master_waitrequest),
      .cpu_data_master_write                                               (cpu_data_master_write),
      .cpu_data_master_writedata                                           (cpu_data_master_writedata),
      .cpu_jtag_debug_module_readdata_from_sa                              (cpu_jtag_debug_module_readdata_from_sa),
      .d1_beep_s1_end_xfer                                                 (d1_beep_s1_end_xfer),
      .d1_cpu_jtag_debug_module_end_xfer                                   (d1_cpu_jtag_debug_module_end_xfer),
      .d1_epcs_controller_epcs_control_port_end_xfer                       (d1_epcs_controller_epcs_control_port_end_xfer),
      .d1_high_res_timer_s1_end_xfer                                       (d1_high_res_timer_s1_end_xfer),
      .d1_jtag_uart_avalon_jtag_slave_end_xfer                             (d1_jtag_uart_avalon_jtag_slave_end_xfer),
      .d1_key_s1_end_xfer                                                  (d1_key_s1_end_xfer),
      .d1_lcd_control_slave_end_xfer                                       (d1_lcd_control_slave_end_xfer),
      .d1_led_s1_end_xfer                                                  (d1_led_s1_end_xfer),
      .d1_onchip_ram_s1_end_xfer                                           (d1_onchip_ram_s1_end_xfer),
      .d1_sdram_s1_end_xfer                                                (d1_sdram_s1_end_xfer),
      .d1_spi_adc_spi_control_port_end_xfer                                (d1_spi_adc_spi_control_port_end_xfer),
      .d1_spi_flash_spi_control_port_end_xfer                              (d1_spi_flash_spi_control_port_end_xfer),
      .d1_sys_clk_timer_s1_end_xfer                                        (d1_sys_clk_timer_s1_end_xfer),
      .d1_sysid_control_slave_end_xfer                                     (d1_sysid_control_slave_end_xfer),
      .d1_uart_s1_end_xfer                                                 (d1_uart_s1_end_xfer),
      .epcs_controller_epcs_control_port_irq_from_sa                       (epcs_controller_epcs_control_port_irq_from_sa),
      .epcs_controller_epcs_control_port_readdata_from_sa                  (epcs_controller_epcs_control_port_readdata_from_sa),
      .high_res_timer_s1_irq_from_sa                                       (high_res_timer_s1_irq_from_sa),
      .high_res_timer_s1_readdata_from_sa                                  (high_res_timer_s1_readdata_from_sa),
      .jtag_uart_avalon_jtag_slave_irq_from_sa                             (jtag_uart_avalon_jtag_slave_irq_from_sa),
      .jtag_uart_avalon_jtag_slave_readdata_from_sa                        (jtag_uart_avalon_jtag_slave_readdata_from_sa),
      .jtag_uart_avalon_jtag_slave_waitrequest_from_sa                     (jtag_uart_avalon_jtag_slave_waitrequest_from_sa),
      .key_s1_irq_from_sa                                                  (key_s1_irq_from_sa),
      .key_s1_readdata_from_sa                                             (key_s1_readdata_from_sa),
      .lcd_control_slave_readdata_from_sa                                  (lcd_control_slave_readdata_from_sa),
      .lcd_control_slave_wait_counter_eq_0                                 (lcd_control_slave_wait_counter_eq_0),
      .lcd_control_slave_wait_counter_eq_1                                 (lcd_control_slave_wait_counter_eq_1),
      .led_s1_readdata_from_sa                                             (led_s1_readdata_from_sa),
      .onchip_ram_s1_readdata_from_sa                                      (onchip_ram_s1_readdata_from_sa),
      .registered_cpu_data_master_read_data_valid_onchip_ram_s1            (registered_cpu_data_master_read_data_valid_onchip_ram_s1),
      .reset_n                                                             (clk_reset_n),
      .sdram_s1_readdata_from_sa                                           (sdram_s1_readdata_from_sa),
      .sdram_s1_waitrequest_from_sa                                        (sdram_s1_waitrequest_from_sa),
      .spi_adc_spi_control_port_irq_from_sa                                (spi_adc_spi_control_port_irq_from_sa),
      .spi_adc_spi_control_port_readdata_from_sa                           (spi_adc_spi_control_port_readdata_from_sa),
      .spi_flash_spi_control_port_irq_from_sa                              (spi_flash_spi_control_port_irq_from_sa),
      .spi_flash_spi_control_port_readdata_from_sa                         (spi_flash_spi_control_port_readdata_from_sa),
      .sys_clk_timer_s1_irq_from_sa                                        (sys_clk_timer_s1_irq_from_sa),
      .sys_clk_timer_s1_readdata_from_sa                                   (sys_clk_timer_s1_readdata_from_sa),
      .sysid_control_slave_readdata_from_sa                                (sysid_control_slave_readdata_from_sa),
      .uart_s1_irq_from_sa                                                 (uart_s1_irq_from_sa),
      .uart_s1_readdata_from_sa                                            (uart_s1_readdata_from_sa)
    );

  cpu_instruction_master_arbitrator the_cpu_instruction_master
    (
      .clk                                                                        (clk),
      .cpu_instruction_master_address                                             (cpu_instruction_master_address),
      .cpu_instruction_master_address_to_slave                                    (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_dbs_address                                         (cpu_instruction_master_dbs_address),
      .cpu_instruction_master_granted_cpu_jtag_debug_module                       (cpu_instruction_master_granted_cpu_jtag_debug_module),
      .cpu_instruction_master_granted_epcs_controller_epcs_control_port           (cpu_instruction_master_granted_epcs_controller_epcs_control_port),
      .cpu_instruction_master_granted_onchip_ram_s1                               (cpu_instruction_master_granted_onchip_ram_s1),
      .cpu_instruction_master_granted_sdram_s1                                    (cpu_instruction_master_granted_sdram_s1),
      .cpu_instruction_master_latency_counter                                     (cpu_instruction_master_latency_counter),
      .cpu_instruction_master_qualified_request_cpu_jtag_debug_module             (cpu_instruction_master_qualified_request_cpu_jtag_debug_module),
      .cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port (cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port),
      .cpu_instruction_master_qualified_request_onchip_ram_s1                     (cpu_instruction_master_qualified_request_onchip_ram_s1),
      .cpu_instruction_master_qualified_request_sdram_s1                          (cpu_instruction_master_qualified_request_sdram_s1),
      .cpu_instruction_master_read                                                (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_cpu_jtag_debug_module               (cpu_instruction_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port   (cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port),
      .cpu_instruction_master_read_data_valid_onchip_ram_s1                       (cpu_instruction_master_read_data_valid_onchip_ram_s1),
      .cpu_instruction_master_read_data_valid_sdram_s1                            (cpu_instruction_master_read_data_valid_sdram_s1),
      .cpu_instruction_master_read_data_valid_sdram_s1_shift_register             (cpu_instruction_master_read_data_valid_sdram_s1_shift_register),
      .cpu_instruction_master_readdata                                            (cpu_instruction_master_readdata),
      .cpu_instruction_master_readdatavalid                                       (cpu_instruction_master_readdatavalid),
      .cpu_instruction_master_requests_cpu_jtag_debug_module                      (cpu_instruction_master_requests_cpu_jtag_debug_module),
      .cpu_instruction_master_requests_epcs_controller_epcs_control_port          (cpu_instruction_master_requests_epcs_controller_epcs_control_port),
      .cpu_instruction_master_requests_onchip_ram_s1                              (cpu_instruction_master_requests_onchip_ram_s1),
      .cpu_instruction_master_requests_sdram_s1                                   (cpu_instruction_master_requests_sdram_s1),
      .cpu_instruction_master_waitrequest                                         (cpu_instruction_master_waitrequest),
      .cpu_jtag_debug_module_readdata_from_sa                                     (cpu_jtag_debug_module_readdata_from_sa),
      .d1_cpu_jtag_debug_module_end_xfer                                          (d1_cpu_jtag_debug_module_end_xfer),
      .d1_epcs_controller_epcs_control_port_end_xfer                              (d1_epcs_controller_epcs_control_port_end_xfer),
      .d1_onchip_ram_s1_end_xfer                                                  (d1_onchip_ram_s1_end_xfer),
      .d1_sdram_s1_end_xfer                                                       (d1_sdram_s1_end_xfer),
      .epcs_controller_epcs_control_port_readdata_from_sa                         (epcs_controller_epcs_control_port_readdata_from_sa),
      .onchip_ram_s1_readdata_from_sa                                             (onchip_ram_s1_readdata_from_sa),
      .reset_n                                                                    (clk_reset_n),
      .sdram_s1_readdata_from_sa                                                  (sdram_s1_readdata_from_sa),
      .sdram_s1_waitrequest_from_sa                                               (sdram_s1_waitrequest_from_sa)
    );

  cpu the_cpu
    (
      .clk                                   (clk),
      .d_address                             (cpu_data_master_address),
      .d_byteenable                          (cpu_data_master_byteenable),
      .d_irq                                 (cpu_data_master_irq),
      .d_read                                (cpu_data_master_read),
      .d_readdata                            (cpu_data_master_readdata),
      .d_waitrequest                         (cpu_data_master_waitrequest),
      .d_write                               (cpu_data_master_write),
      .d_writedata                           (cpu_data_master_writedata),
      .i_address                             (cpu_instruction_master_address),
      .i_read                                (cpu_instruction_master_read),
      .i_readdata                            (cpu_instruction_master_readdata),
      .i_readdatavalid                       (cpu_instruction_master_readdatavalid),
      .i_waitrequest                         (cpu_instruction_master_waitrequest),
      .jtag_debug_module_address             (cpu_jtag_debug_module_address),
      .jtag_debug_module_begintransfer       (cpu_jtag_debug_module_begintransfer),
      .jtag_debug_module_byteenable          (cpu_jtag_debug_module_byteenable),
      .jtag_debug_module_debugaccess         (cpu_jtag_debug_module_debugaccess),
      .jtag_debug_module_debugaccess_to_roms (cpu_data_master_debugaccess),
      .jtag_debug_module_readdata            (cpu_jtag_debug_module_readdata),
      .jtag_debug_module_resetrequest        (cpu_jtag_debug_module_resetrequest),
      .jtag_debug_module_select              (cpu_jtag_debug_module_chipselect),
      .jtag_debug_module_write               (cpu_jtag_debug_module_write),
      .jtag_debug_module_writedata           (cpu_jtag_debug_module_writedata),
      .reset_n                               (cpu_jtag_debug_module_reset_n)
    );

  epcs_controller_epcs_control_port_arbitrator the_epcs_controller_epcs_control_port
    (
      .clk                                                                        (clk),
      .cpu_data_master_address_to_slave                                           (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_epcs_controller_epcs_control_port                  (cpu_data_master_granted_epcs_controller_epcs_control_port),
      .cpu_data_master_qualified_request_epcs_controller_epcs_control_port        (cpu_data_master_qualified_request_epcs_controller_epcs_control_port),
      .cpu_data_master_read                                                       (cpu_data_master_read),
      .cpu_data_master_read_data_valid_epcs_controller_epcs_control_port          (cpu_data_master_read_data_valid_epcs_controller_epcs_control_port),
      .cpu_data_master_requests_epcs_controller_epcs_control_port                 (cpu_data_master_requests_epcs_controller_epcs_control_port),
      .cpu_data_master_write                                                      (cpu_data_master_write),
      .cpu_data_master_writedata                                                  (cpu_data_master_writedata),
      .cpu_instruction_master_address_to_slave                                    (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_granted_epcs_controller_epcs_control_port           (cpu_instruction_master_granted_epcs_controller_epcs_control_port),
      .cpu_instruction_master_latency_counter                                     (cpu_instruction_master_latency_counter),
      .cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port (cpu_instruction_master_qualified_request_epcs_controller_epcs_control_port),
      .cpu_instruction_master_read                                                (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port   (cpu_instruction_master_read_data_valid_epcs_controller_epcs_control_port),
      .cpu_instruction_master_read_data_valid_sdram_s1_shift_register             (cpu_instruction_master_read_data_valid_sdram_s1_shift_register),
      .cpu_instruction_master_requests_epcs_controller_epcs_control_port          (cpu_instruction_master_requests_epcs_controller_epcs_control_port),
      .d1_epcs_controller_epcs_control_port_end_xfer                              (d1_epcs_controller_epcs_control_port_end_xfer),
      .epcs_controller_epcs_control_port_address                                  (epcs_controller_epcs_control_port_address),
      .epcs_controller_epcs_control_port_chipselect                               (epcs_controller_epcs_control_port_chipselect),
      .epcs_controller_epcs_control_port_dataavailable                            (epcs_controller_epcs_control_port_dataavailable),
      .epcs_controller_epcs_control_port_dataavailable_from_sa                    (epcs_controller_epcs_control_port_dataavailable_from_sa),
      .epcs_controller_epcs_control_port_endofpacket                              (epcs_controller_epcs_control_port_endofpacket),
      .epcs_controller_epcs_control_port_endofpacket_from_sa                      (epcs_controller_epcs_control_port_endofpacket_from_sa),
      .epcs_controller_epcs_control_port_irq                                      (epcs_controller_epcs_control_port_irq),
      .epcs_controller_epcs_control_port_irq_from_sa                              (epcs_controller_epcs_control_port_irq_from_sa),
      .epcs_controller_epcs_control_port_read_n                                   (epcs_controller_epcs_control_port_read_n),
      .epcs_controller_epcs_control_port_readdata                                 (epcs_controller_epcs_control_port_readdata),
      .epcs_controller_epcs_control_port_readdata_from_sa                         (epcs_controller_epcs_control_port_readdata_from_sa),
      .epcs_controller_epcs_control_port_readyfordata                             (epcs_controller_epcs_control_port_readyfordata),
      .epcs_controller_epcs_control_port_readyfordata_from_sa                     (epcs_controller_epcs_control_port_readyfordata_from_sa),
      .epcs_controller_epcs_control_port_reset_n                                  (epcs_controller_epcs_control_port_reset_n),
      .epcs_controller_epcs_control_port_write_n                                  (epcs_controller_epcs_control_port_write_n),
      .epcs_controller_epcs_control_port_writedata                                (epcs_controller_epcs_control_port_writedata),
      .reset_n                                                                    (clk_reset_n)
    );

  epcs_controller the_epcs_controller
    (
      .address       (epcs_controller_epcs_control_port_address),
      .chipselect    (epcs_controller_epcs_control_port_chipselect),
      .clk           (clk),
      .data0         (data0_to_the_epcs_controller),
      .dataavailable (epcs_controller_epcs_control_port_dataavailable),
      .dclk          (dclk_from_the_epcs_controller),
      .endofpacket   (epcs_controller_epcs_control_port_endofpacket),
      .irq           (epcs_controller_epcs_control_port_irq),
      .read_n        (epcs_controller_epcs_control_port_read_n),
      .readdata      (epcs_controller_epcs_control_port_readdata),
      .readyfordata  (epcs_controller_epcs_control_port_readyfordata),
      .reset_n       (epcs_controller_epcs_control_port_reset_n),
      .sce           (sce_from_the_epcs_controller),
      .sdo           (sdo_from_the_epcs_controller),
      .write_n       (epcs_controller_epcs_control_port_write_n),
      .writedata     (epcs_controller_epcs_control_port_writedata)
    );

  high_res_timer_s1_arbitrator the_high_res_timer_s1
    (
      .clk                                                 (clk),
      .cpu_data_master_address_to_slave                    (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_high_res_timer_s1           (cpu_data_master_granted_high_res_timer_s1),
      .cpu_data_master_qualified_request_high_res_timer_s1 (cpu_data_master_qualified_request_high_res_timer_s1),
      .cpu_data_master_read                                (cpu_data_master_read),
      .cpu_data_master_read_data_valid_high_res_timer_s1   (cpu_data_master_read_data_valid_high_res_timer_s1),
      .cpu_data_master_requests_high_res_timer_s1          (cpu_data_master_requests_high_res_timer_s1),
      .cpu_data_master_waitrequest                         (cpu_data_master_waitrequest),
      .cpu_data_master_write                               (cpu_data_master_write),
      .cpu_data_master_writedata                           (cpu_data_master_writedata),
      .d1_high_res_timer_s1_end_xfer                       (d1_high_res_timer_s1_end_xfer),
      .high_res_timer_s1_address                           (high_res_timer_s1_address),
      .high_res_timer_s1_chipselect                        (high_res_timer_s1_chipselect),
      .high_res_timer_s1_irq                               (high_res_timer_s1_irq),
      .high_res_timer_s1_irq_from_sa                       (high_res_timer_s1_irq_from_sa),
      .high_res_timer_s1_readdata                          (high_res_timer_s1_readdata),
      .high_res_timer_s1_readdata_from_sa                  (high_res_timer_s1_readdata_from_sa),
      .high_res_timer_s1_reset_n                           (high_res_timer_s1_reset_n),
      .high_res_timer_s1_write_n                           (high_res_timer_s1_write_n),
      .high_res_timer_s1_writedata                         (high_res_timer_s1_writedata),
      .reset_n                                             (clk_reset_n)
    );

  high_res_timer the_high_res_timer
    (
      .address    (high_res_timer_s1_address),
      .chipselect (high_res_timer_s1_chipselect),
      .clk        (clk),
      .irq        (high_res_timer_s1_irq),
      .readdata   (high_res_timer_s1_readdata),
      .reset_n    (high_res_timer_s1_reset_n),
      .write_n    (high_res_timer_s1_write_n),
      .writedata  (high_res_timer_s1_writedata)
    );

  jtag_uart_avalon_jtag_slave_arbitrator the_jtag_uart_avalon_jtag_slave
    (
      .clk                                                           (clk),
      .cpu_data_master_address_to_slave                              (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_jtag_uart_avalon_jtag_slave           (cpu_data_master_granted_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave (cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_read                                          (cpu_data_master_read),
      .cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave   (cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_requests_jtag_uart_avalon_jtag_slave          (cpu_data_master_requests_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_waitrequest                                   (cpu_data_master_waitrequest),
      .cpu_data_master_write                                         (cpu_data_master_write),
      .cpu_data_master_writedata                                     (cpu_data_master_writedata),
      .d1_jtag_uart_avalon_jtag_slave_end_xfer                       (d1_jtag_uart_avalon_jtag_slave_end_xfer),
      .jtag_uart_avalon_jtag_slave_address                           (jtag_uart_avalon_jtag_slave_address),
      .jtag_uart_avalon_jtag_slave_chipselect                        (jtag_uart_avalon_jtag_slave_chipselect),
      .jtag_uart_avalon_jtag_slave_dataavailable                     (jtag_uart_avalon_jtag_slave_dataavailable),
      .jtag_uart_avalon_jtag_slave_dataavailable_from_sa             (jtag_uart_avalon_jtag_slave_dataavailable_from_sa),
      .jtag_uart_avalon_jtag_slave_irq                               (jtag_uart_avalon_jtag_slave_irq),
      .jtag_uart_avalon_jtag_slave_irq_from_sa                       (jtag_uart_avalon_jtag_slave_irq_from_sa),
      .jtag_uart_avalon_jtag_slave_read_n                            (jtag_uart_avalon_jtag_slave_read_n),
      .jtag_uart_avalon_jtag_slave_readdata                          (jtag_uart_avalon_jtag_slave_readdata),
      .jtag_uart_avalon_jtag_slave_readdata_from_sa                  (jtag_uart_avalon_jtag_slave_readdata_from_sa),
      .jtag_uart_avalon_jtag_slave_readyfordata                      (jtag_uart_avalon_jtag_slave_readyfordata),
      .jtag_uart_avalon_jtag_slave_readyfordata_from_sa              (jtag_uart_avalon_jtag_slave_readyfordata_from_sa),
      .jtag_uart_avalon_jtag_slave_reset_n                           (jtag_uart_avalon_jtag_slave_reset_n),
      .jtag_uart_avalon_jtag_slave_waitrequest                       (jtag_uart_avalon_jtag_slave_waitrequest),
      .jtag_uart_avalon_jtag_slave_waitrequest_from_sa               (jtag_uart_avalon_jtag_slave_waitrequest_from_sa),
      .jtag_uart_avalon_jtag_slave_write_n                           (jtag_uart_avalon_jtag_slave_write_n),
      .jtag_uart_avalon_jtag_slave_writedata                         (jtag_uart_avalon_jtag_slave_writedata),
      .reset_n                                                       (clk_reset_n)
    );

  jtag_uart the_jtag_uart
    (
      .av_address     (jtag_uart_avalon_jtag_slave_address),
      .av_chipselect  (jtag_uart_avalon_jtag_slave_chipselect),
      .av_irq         (jtag_uart_avalon_jtag_slave_irq),
      .av_read_n      (jtag_uart_avalon_jtag_slave_read_n),
      .av_readdata    (jtag_uart_avalon_jtag_slave_readdata),
      .av_waitrequest (jtag_uart_avalon_jtag_slave_waitrequest),
      .av_write_n     (jtag_uart_avalon_jtag_slave_write_n),
      .av_writedata   (jtag_uart_avalon_jtag_slave_writedata),
      .clk            (clk),
      .dataavailable  (jtag_uart_avalon_jtag_slave_dataavailable),
      .readyfordata   (jtag_uart_avalon_jtag_slave_readyfordata),
      .rst_n          (jtag_uart_avalon_jtag_slave_reset_n)
    );

  key_s1_arbitrator the_key_s1
    (
      .clk                                      (clk),
      .cpu_data_master_address_to_slave         (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_key_s1           (cpu_data_master_granted_key_s1),
      .cpu_data_master_qualified_request_key_s1 (cpu_data_master_qualified_request_key_s1),
      .cpu_data_master_read                     (cpu_data_master_read),
      .cpu_data_master_read_data_valid_key_s1   (cpu_data_master_read_data_valid_key_s1),
      .cpu_data_master_requests_key_s1          (cpu_data_master_requests_key_s1),
      .cpu_data_master_waitrequest              (cpu_data_master_waitrequest),
      .cpu_data_master_write                    (cpu_data_master_write),
      .cpu_data_master_writedata                (cpu_data_master_writedata),
      .d1_key_s1_end_xfer                       (d1_key_s1_end_xfer),
      .key_s1_address                           (key_s1_address),
      .key_s1_chipselect                        (key_s1_chipselect),
      .key_s1_irq                               (key_s1_irq),
      .key_s1_irq_from_sa                       (key_s1_irq_from_sa),
      .key_s1_readdata                          (key_s1_readdata),
      .key_s1_readdata_from_sa                  (key_s1_readdata_from_sa),
      .key_s1_reset_n                           (key_s1_reset_n),
      .key_s1_write_n                           (key_s1_write_n),
      .key_s1_writedata                         (key_s1_writedata),
      .reset_n                                  (clk_reset_n)
    );

  key the_key
    (
      .address    (key_s1_address),
      .chipselect (key_s1_chipselect),
      .clk        (clk),
      .in_port    (in_port_to_the_key),
      .irq        (key_s1_irq),
      .readdata   (key_s1_readdata),
      .reset_n    (key_s1_reset_n),
      .write_n    (key_s1_write_n),
      .writedata  (key_s1_writedata)
    );

  lcd_control_slave_arbitrator the_lcd_control_slave
    (
      .clk                                                 (clk),
      .cpu_data_master_address_to_slave                    (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable                          (cpu_data_master_byteenable),
      .cpu_data_master_granted_lcd_control_slave           (cpu_data_master_granted_lcd_control_slave),
      .cpu_data_master_qualified_request_lcd_control_slave (cpu_data_master_qualified_request_lcd_control_slave),
      .cpu_data_master_read                                (cpu_data_master_read),
      .cpu_data_master_read_data_valid_lcd_control_slave   (cpu_data_master_read_data_valid_lcd_control_slave),
      .cpu_data_master_requests_lcd_control_slave          (cpu_data_master_requests_lcd_control_slave),
      .cpu_data_master_write                               (cpu_data_master_write),
      .cpu_data_master_writedata                           (cpu_data_master_writedata),
      .d1_lcd_control_slave_end_xfer                       (d1_lcd_control_slave_end_xfer),
      .lcd_control_slave_address                           (lcd_control_slave_address),
      .lcd_control_slave_begintransfer                     (lcd_control_slave_begintransfer),
      .lcd_control_slave_read                              (lcd_control_slave_read),
      .lcd_control_slave_readdata                          (lcd_control_slave_readdata),
      .lcd_control_slave_readdata_from_sa                  (lcd_control_slave_readdata_from_sa),
      .lcd_control_slave_reset_n                           (lcd_control_slave_reset_n),
      .lcd_control_slave_wait_counter_eq_0                 (lcd_control_slave_wait_counter_eq_0),
      .lcd_control_slave_wait_counter_eq_1                 (lcd_control_slave_wait_counter_eq_1),
      .lcd_control_slave_write                             (lcd_control_slave_write),
      .lcd_control_slave_writedata                         (lcd_control_slave_writedata),
      .reset_n                                             (clk_reset_n)
    );

  lcd the_lcd
    (
      .LCD_E         (LCD_E_from_the_lcd),
      .LCD_RS        (LCD_RS_from_the_lcd),
      .LCD_RW        (LCD_RW_from_the_lcd),
      .LCD_data      (LCD_data_to_and_from_the_lcd),
      .address       (lcd_control_slave_address),
      .begintransfer (lcd_control_slave_begintransfer),
      .clk           (clk),
      .read          (lcd_control_slave_read),
      .readdata      (lcd_control_slave_readdata),
      .reset_n       (lcd_control_slave_reset_n),
      .write         (lcd_control_slave_write),
      .writedata     (lcd_control_slave_writedata)
    );

  led_s1_arbitrator the_led_s1
    (
      .clk                                      (clk),
      .cpu_data_master_address_to_slave         (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_led_s1           (cpu_data_master_granted_led_s1),
      .cpu_data_master_qualified_request_led_s1 (cpu_data_master_qualified_request_led_s1),
      .cpu_data_master_read                     (cpu_data_master_read),
      .cpu_data_master_read_data_valid_led_s1   (cpu_data_master_read_data_valid_led_s1),
      .cpu_data_master_requests_led_s1          (cpu_data_master_requests_led_s1),
      .cpu_data_master_waitrequest              (cpu_data_master_waitrequest),
      .cpu_data_master_write                    (cpu_data_master_write),
      .cpu_data_master_writedata                (cpu_data_master_writedata),
      .d1_led_s1_end_xfer                       (d1_led_s1_end_xfer),
      .led_s1_address                           (led_s1_address),
      .led_s1_chipselect                        (led_s1_chipselect),
      .led_s1_readdata                          (led_s1_readdata),
      .led_s1_readdata_from_sa                  (led_s1_readdata_from_sa),
      .led_s1_reset_n                           (led_s1_reset_n),
      .led_s1_write_n                           (led_s1_write_n),
      .led_s1_writedata                         (led_s1_writedata),
      .reset_n                                  (clk_reset_n)
    );

  led the_led
    (
      .address    (led_s1_address),
      .chipselect (led_s1_chipselect),
      .clk        (clk),
      .out_port   (out_port_from_the_led),
      .readdata   (led_s1_readdata),
      .reset_n    (led_s1_reset_n),
      .write_n    (led_s1_write_n),
      .writedata  (led_s1_writedata)
    );

  onchip_ram_s1_arbitrator the_onchip_ram_s1
    (
      .clk                                                            (clk),
      .cpu_data_master_address_to_slave                               (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable                                     (cpu_data_master_byteenable),
      .cpu_data_master_granted_onchip_ram_s1                          (cpu_data_master_granted_onchip_ram_s1),
      .cpu_data_master_qualified_request_onchip_ram_s1                (cpu_data_master_qualified_request_onchip_ram_s1),
      .cpu_data_master_read                                           (cpu_data_master_read),
      .cpu_data_master_read_data_valid_onchip_ram_s1                  (cpu_data_master_read_data_valid_onchip_ram_s1),
      .cpu_data_master_requests_onchip_ram_s1                         (cpu_data_master_requests_onchip_ram_s1),
      .cpu_data_master_waitrequest                                    (cpu_data_master_waitrequest),
      .cpu_data_master_write                                          (cpu_data_master_write),
      .cpu_data_master_writedata                                      (cpu_data_master_writedata),
      .cpu_instruction_master_address_to_slave                        (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_granted_onchip_ram_s1                   (cpu_instruction_master_granted_onchip_ram_s1),
      .cpu_instruction_master_latency_counter                         (cpu_instruction_master_latency_counter),
      .cpu_instruction_master_qualified_request_onchip_ram_s1         (cpu_instruction_master_qualified_request_onchip_ram_s1),
      .cpu_instruction_master_read                                    (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_onchip_ram_s1           (cpu_instruction_master_read_data_valid_onchip_ram_s1),
      .cpu_instruction_master_read_data_valid_sdram_s1_shift_register (cpu_instruction_master_read_data_valid_sdram_s1_shift_register),
      .cpu_instruction_master_requests_onchip_ram_s1                  (cpu_instruction_master_requests_onchip_ram_s1),
      .d1_onchip_ram_s1_end_xfer                                      (d1_onchip_ram_s1_end_xfer),
      .onchip_ram_s1_address                                          (onchip_ram_s1_address),
      .onchip_ram_s1_byteenable                                       (onchip_ram_s1_byteenable),
      .onchip_ram_s1_chipselect                                       (onchip_ram_s1_chipselect),
      .onchip_ram_s1_clken                                            (onchip_ram_s1_clken),
      .onchip_ram_s1_readdata                                         (onchip_ram_s1_readdata),
      .onchip_ram_s1_readdata_from_sa                                 (onchip_ram_s1_readdata_from_sa),
      .onchip_ram_s1_reset                                            (onchip_ram_s1_reset),
      .onchip_ram_s1_write                                            (onchip_ram_s1_write),
      .onchip_ram_s1_writedata                                        (onchip_ram_s1_writedata),
      .registered_cpu_data_master_read_data_valid_onchip_ram_s1       (registered_cpu_data_master_read_data_valid_onchip_ram_s1),
      .reset_n                                                        (clk_reset_n)
    );

  onchip_ram the_onchip_ram
    (
      .address    (onchip_ram_s1_address),
      .byteenable (onchip_ram_s1_byteenable),
      .chipselect (onchip_ram_s1_chipselect),
      .clk        (clk),
      .clken      (onchip_ram_s1_clken),
      .readdata   (onchip_ram_s1_readdata),
      .reset      (onchip_ram_s1_reset),
      .write      (onchip_ram_s1_write),
      .writedata  (onchip_ram_s1_writedata)
    );

  sdram_s1_arbitrator the_sdram_s1
    (
      .clk                                                            (clk),
      .cpu_data_master_address_to_slave                               (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable                                     (cpu_data_master_byteenable),
      .cpu_data_master_byteenable_sdram_s1                            (cpu_data_master_byteenable_sdram_s1),
      .cpu_data_master_dbs_address                                    (cpu_data_master_dbs_address),
      .cpu_data_master_dbs_write_16                                   (cpu_data_master_dbs_write_16),
      .cpu_data_master_granted_sdram_s1                               (cpu_data_master_granted_sdram_s1),
      .cpu_data_master_no_byte_enables_and_last_term                  (cpu_data_master_no_byte_enables_and_last_term),
      .cpu_data_master_qualified_request_sdram_s1                     (cpu_data_master_qualified_request_sdram_s1),
      .cpu_data_master_read                                           (cpu_data_master_read),
      .cpu_data_master_read_data_valid_sdram_s1                       (cpu_data_master_read_data_valid_sdram_s1),
      .cpu_data_master_read_data_valid_sdram_s1_shift_register        (cpu_data_master_read_data_valid_sdram_s1_shift_register),
      .cpu_data_master_requests_sdram_s1                              (cpu_data_master_requests_sdram_s1),
      .cpu_data_master_waitrequest                                    (cpu_data_master_waitrequest),
      .cpu_data_master_write                                          (cpu_data_master_write),
      .cpu_instruction_master_address_to_slave                        (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_dbs_address                             (cpu_instruction_master_dbs_address),
      .cpu_instruction_master_granted_sdram_s1                        (cpu_instruction_master_granted_sdram_s1),
      .cpu_instruction_master_latency_counter                         (cpu_instruction_master_latency_counter),
      .cpu_instruction_master_qualified_request_sdram_s1              (cpu_instruction_master_qualified_request_sdram_s1),
      .cpu_instruction_master_read                                    (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_sdram_s1                (cpu_instruction_master_read_data_valid_sdram_s1),
      .cpu_instruction_master_read_data_valid_sdram_s1_shift_register (cpu_instruction_master_read_data_valid_sdram_s1_shift_register),
      .cpu_instruction_master_requests_sdram_s1                       (cpu_instruction_master_requests_sdram_s1),
      .d1_sdram_s1_end_xfer                                           (d1_sdram_s1_end_xfer),
      .reset_n                                                        (clk_reset_n),
      .sdram_s1_address                                               (sdram_s1_address),
      .sdram_s1_byteenable_n                                          (sdram_s1_byteenable_n),
      .sdram_s1_chipselect                                            (sdram_s1_chipselect),
      .sdram_s1_read_n                                                (sdram_s1_read_n),
      .sdram_s1_readdata                                              (sdram_s1_readdata),
      .sdram_s1_readdata_from_sa                                      (sdram_s1_readdata_from_sa),
      .sdram_s1_readdatavalid                                         (sdram_s1_readdatavalid),
      .sdram_s1_reset_n                                               (sdram_s1_reset_n),
      .sdram_s1_waitrequest                                           (sdram_s1_waitrequest),
      .sdram_s1_waitrequest_from_sa                                   (sdram_s1_waitrequest_from_sa),
      .sdram_s1_write_n                                               (sdram_s1_write_n),
      .sdram_s1_writedata                                             (sdram_s1_writedata)
    );

  sdram the_sdram
    (
      .az_addr        (sdram_s1_address),
      .az_be_n        (sdram_s1_byteenable_n),
      .az_cs          (sdram_s1_chipselect),
      .az_data        (sdram_s1_writedata),
      .az_rd_n        (sdram_s1_read_n),
      .az_wr_n        (sdram_s1_write_n),
      .clk            (clk),
      .reset_n        (sdram_s1_reset_n),
      .za_data        (sdram_s1_readdata),
      .za_valid       (sdram_s1_readdatavalid),
      .za_waitrequest (sdram_s1_waitrequest),
      .zs_addr        (zs_addr_from_the_sdram),
      .zs_ba          (zs_ba_from_the_sdram),
      .zs_cas_n       (zs_cas_n_from_the_sdram),
      .zs_cke         (zs_cke_from_the_sdram),
      .zs_cs_n        (zs_cs_n_from_the_sdram),
      .zs_dq          (zs_dq_to_and_from_the_sdram),
      .zs_dqm         (zs_dqm_from_the_sdram),
      .zs_ras_n       (zs_ras_n_from_the_sdram),
      .zs_we_n        (zs_we_n_from_the_sdram)
    );

  spi_adc_spi_control_port_arbitrator the_spi_adc_spi_control_port
    (
      .clk                                                        (clk),
      .cpu_data_master_address_to_slave                           (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_spi_adc_spi_control_port           (cpu_data_master_granted_spi_adc_spi_control_port),
      .cpu_data_master_qualified_request_spi_adc_spi_control_port (cpu_data_master_qualified_request_spi_adc_spi_control_port),
      .cpu_data_master_read                                       (cpu_data_master_read),
      .cpu_data_master_read_data_valid_spi_adc_spi_control_port   (cpu_data_master_read_data_valid_spi_adc_spi_control_port),
      .cpu_data_master_requests_spi_adc_spi_control_port          (cpu_data_master_requests_spi_adc_spi_control_port),
      .cpu_data_master_write                                      (cpu_data_master_write),
      .cpu_data_master_writedata                                  (cpu_data_master_writedata),
      .d1_spi_adc_spi_control_port_end_xfer                       (d1_spi_adc_spi_control_port_end_xfer),
      .reset_n                                                    (clk_reset_n),
      .spi_adc_spi_control_port_address                           (spi_adc_spi_control_port_address),
      .spi_adc_spi_control_port_chipselect                        (spi_adc_spi_control_port_chipselect),
      .spi_adc_spi_control_port_dataavailable                     (spi_adc_spi_control_port_dataavailable),
      .spi_adc_spi_control_port_dataavailable_from_sa             (spi_adc_spi_control_port_dataavailable_from_sa),
      .spi_adc_spi_control_port_endofpacket                       (spi_adc_spi_control_port_endofpacket),
      .spi_adc_spi_control_port_endofpacket_from_sa               (spi_adc_spi_control_port_endofpacket_from_sa),
      .spi_adc_spi_control_port_irq                               (spi_adc_spi_control_port_irq),
      .spi_adc_spi_control_port_irq_from_sa                       (spi_adc_spi_control_port_irq_from_sa),
      .spi_adc_spi_control_port_read_n                            (spi_adc_spi_control_port_read_n),
      .spi_adc_spi_control_port_readdata                          (spi_adc_spi_control_port_readdata),
      .spi_adc_spi_control_port_readdata_from_sa                  (spi_adc_spi_control_port_readdata_from_sa),
      .spi_adc_spi_control_port_readyfordata                      (spi_adc_spi_control_port_readyfordata),
      .spi_adc_spi_control_port_readyfordata_from_sa              (spi_adc_spi_control_port_readyfordata_from_sa),
      .spi_adc_spi_control_port_reset_n                           (spi_adc_spi_control_port_reset_n),
      .spi_adc_spi_control_port_write_n                           (spi_adc_spi_control_port_write_n),
      .spi_adc_spi_control_port_writedata                         (spi_adc_spi_control_port_writedata)
    );

  spi_adc the_spi_adc
    (
      .MISO          (MISO_to_the_spi_adc),
      .MOSI          (MOSI_from_the_spi_adc),
      .SCLK          (SCLK_from_the_spi_adc),
      .SS_n          (SS_n_from_the_spi_adc),
      .clk           (clk),
      .data_from_cpu (spi_adc_spi_control_port_writedata),
      .data_to_cpu   (spi_adc_spi_control_port_readdata),
      .dataavailable (spi_adc_spi_control_port_dataavailable),
      .endofpacket   (spi_adc_spi_control_port_endofpacket),
      .irq           (spi_adc_spi_control_port_irq),
      .mem_addr      (spi_adc_spi_control_port_address),
      .read_n        (spi_adc_spi_control_port_read_n),
      .readyfordata  (spi_adc_spi_control_port_readyfordata),
      .reset_n       (spi_adc_spi_control_port_reset_n),
      .spi_select    (spi_adc_spi_control_port_chipselect),
      .write_n       (spi_adc_spi_control_port_write_n)
    );

  spi_flash_spi_control_port_arbitrator the_spi_flash_spi_control_port
    (
      .clk                                                          (clk),
      .cpu_data_master_address_to_slave                             (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_spi_flash_spi_control_port           (cpu_data_master_granted_spi_flash_spi_control_port),
      .cpu_data_master_qualified_request_spi_flash_spi_control_port (cpu_data_master_qualified_request_spi_flash_spi_control_port),
      .cpu_data_master_read                                         (cpu_data_master_read),
      .cpu_data_master_read_data_valid_spi_flash_spi_control_port   (cpu_data_master_read_data_valid_spi_flash_spi_control_port),
      .cpu_data_master_requests_spi_flash_spi_control_port          (cpu_data_master_requests_spi_flash_spi_control_port),
      .cpu_data_master_write                                        (cpu_data_master_write),
      .cpu_data_master_writedata                                    (cpu_data_master_writedata),
      .d1_spi_flash_spi_control_port_end_xfer                       (d1_spi_flash_spi_control_port_end_xfer),
      .reset_n                                                      (clk_reset_n),
      .spi_flash_spi_control_port_address                           (spi_flash_spi_control_port_address),
      .spi_flash_spi_control_port_chipselect                        (spi_flash_spi_control_port_chipselect),
      .spi_flash_spi_control_port_dataavailable                     (spi_flash_spi_control_port_dataavailable),
      .spi_flash_spi_control_port_dataavailable_from_sa             (spi_flash_spi_control_port_dataavailable_from_sa),
      .spi_flash_spi_control_port_endofpacket                       (spi_flash_spi_control_port_endofpacket),
      .spi_flash_spi_control_port_endofpacket_from_sa               (spi_flash_spi_control_port_endofpacket_from_sa),
      .spi_flash_spi_control_port_irq                               (spi_flash_spi_control_port_irq),
      .spi_flash_spi_control_port_irq_from_sa                       (spi_flash_spi_control_port_irq_from_sa),
      .spi_flash_spi_control_port_read_n                            (spi_flash_spi_control_port_read_n),
      .spi_flash_spi_control_port_readdata                          (spi_flash_spi_control_port_readdata),
      .spi_flash_spi_control_port_readdata_from_sa                  (spi_flash_spi_control_port_readdata_from_sa),
      .spi_flash_spi_control_port_readyfordata                      (spi_flash_spi_control_port_readyfordata),
      .spi_flash_spi_control_port_readyfordata_from_sa              (spi_flash_spi_control_port_readyfordata_from_sa),
      .spi_flash_spi_control_port_reset_n                           (spi_flash_spi_control_port_reset_n),
      .spi_flash_spi_control_port_write_n                           (spi_flash_spi_control_port_write_n),
      .spi_flash_spi_control_port_writedata                         (spi_flash_spi_control_port_writedata)
    );

  spi_flash the_spi_flash
    (
      .MISO          (MISO_to_the_spi_flash),
      .MOSI          (MOSI_from_the_spi_flash),
      .SCLK          (SCLK_from_the_spi_flash),
      .SS_n          (SS_n_from_the_spi_flash),
      .clk           (clk),
      .data_from_cpu (spi_flash_spi_control_port_writedata),
      .data_to_cpu   (spi_flash_spi_control_port_readdata),
      .dataavailable (spi_flash_spi_control_port_dataavailable),
      .endofpacket   (spi_flash_spi_control_port_endofpacket),
      .irq           (spi_flash_spi_control_port_irq),
      .mem_addr      (spi_flash_spi_control_port_address),
      .read_n        (spi_flash_spi_control_port_read_n),
      .readyfordata  (spi_flash_spi_control_port_readyfordata),
      .reset_n       (spi_flash_spi_control_port_reset_n),
      .spi_select    (spi_flash_spi_control_port_chipselect),
      .write_n       (spi_flash_spi_control_port_write_n)
    );

  sys_clk_timer_s1_arbitrator the_sys_clk_timer_s1
    (
      .clk                                                (clk),
      .cpu_data_master_address_to_slave                   (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_sys_clk_timer_s1           (cpu_data_master_granted_sys_clk_timer_s1),
      .cpu_data_master_qualified_request_sys_clk_timer_s1 (cpu_data_master_qualified_request_sys_clk_timer_s1),
      .cpu_data_master_read                               (cpu_data_master_read),
      .cpu_data_master_read_data_valid_sys_clk_timer_s1   (cpu_data_master_read_data_valid_sys_clk_timer_s1),
      .cpu_data_master_requests_sys_clk_timer_s1          (cpu_data_master_requests_sys_clk_timer_s1),
      .cpu_data_master_waitrequest                        (cpu_data_master_waitrequest),
      .cpu_data_master_write                              (cpu_data_master_write),
      .cpu_data_master_writedata                          (cpu_data_master_writedata),
      .d1_sys_clk_timer_s1_end_xfer                       (d1_sys_clk_timer_s1_end_xfer),
      .reset_n                                            (clk_reset_n),
      .sys_clk_timer_s1_address                           (sys_clk_timer_s1_address),
      .sys_clk_timer_s1_chipselect                        (sys_clk_timer_s1_chipselect),
      .sys_clk_timer_s1_irq                               (sys_clk_timer_s1_irq),
      .sys_clk_timer_s1_irq_from_sa                       (sys_clk_timer_s1_irq_from_sa),
      .sys_clk_timer_s1_readdata                          (sys_clk_timer_s1_readdata),
      .sys_clk_timer_s1_readdata_from_sa                  (sys_clk_timer_s1_readdata_from_sa),
      .sys_clk_timer_s1_reset_n                           (sys_clk_timer_s1_reset_n),
      .sys_clk_timer_s1_write_n                           (sys_clk_timer_s1_write_n),
      .sys_clk_timer_s1_writedata                         (sys_clk_timer_s1_writedata)
    );

  sys_clk_timer the_sys_clk_timer
    (
      .address    (sys_clk_timer_s1_address),
      .chipselect (sys_clk_timer_s1_chipselect),
      .clk        (clk),
      .irq        (sys_clk_timer_s1_irq),
      .readdata   (sys_clk_timer_s1_readdata),
      .reset_n    (sys_clk_timer_s1_reset_n),
      .write_n    (sys_clk_timer_s1_write_n),
      .writedata  (sys_clk_timer_s1_writedata)
    );

  sysid_control_slave_arbitrator the_sysid_control_slave
    (
      .clk                                                   (clk),
      .cpu_data_master_address_to_slave                      (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_sysid_control_slave           (cpu_data_master_granted_sysid_control_slave),
      .cpu_data_master_qualified_request_sysid_control_slave (cpu_data_master_qualified_request_sysid_control_slave),
      .cpu_data_master_read                                  (cpu_data_master_read),
      .cpu_data_master_read_data_valid_sysid_control_slave   (cpu_data_master_read_data_valid_sysid_control_slave),
      .cpu_data_master_requests_sysid_control_slave          (cpu_data_master_requests_sysid_control_slave),
      .cpu_data_master_write                                 (cpu_data_master_write),
      .d1_sysid_control_slave_end_xfer                       (d1_sysid_control_slave_end_xfer),
      .reset_n                                               (clk_reset_n),
      .sysid_control_slave_address                           (sysid_control_slave_address),
      .sysid_control_slave_readdata                          (sysid_control_slave_readdata),
      .sysid_control_slave_readdata_from_sa                  (sysid_control_slave_readdata_from_sa),
      .sysid_control_slave_reset_n                           (sysid_control_slave_reset_n)
    );

  sysid the_sysid
    (
      .address  (sysid_control_slave_address),
      .clock    (sysid_control_slave_clock),
      .readdata (sysid_control_slave_readdata),
      .reset_n  (sysid_control_slave_reset_n)
    );

  uart_s1_arbitrator the_uart_s1
    (
      .clk                                       (clk),
      .cpu_data_master_address_to_slave          (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_uart_s1           (cpu_data_master_granted_uart_s1),
      .cpu_data_master_qualified_request_uart_s1 (cpu_data_master_qualified_request_uart_s1),
      .cpu_data_master_read                      (cpu_data_master_read),
      .cpu_data_master_read_data_valid_uart_s1   (cpu_data_master_read_data_valid_uart_s1),
      .cpu_data_master_requests_uart_s1          (cpu_data_master_requests_uart_s1),
      .cpu_data_master_write                     (cpu_data_master_write),
      .cpu_data_master_writedata                 (cpu_data_master_writedata),
      .d1_uart_s1_end_xfer                       (d1_uart_s1_end_xfer),
      .reset_n                                   (clk_reset_n),
      .uart_s1_address                           (uart_s1_address),
      .uart_s1_begintransfer                     (uart_s1_begintransfer),
      .uart_s1_chipselect                        (uart_s1_chipselect),
      .uart_s1_dataavailable                     (uart_s1_dataavailable),
      .uart_s1_dataavailable_from_sa             (uart_s1_dataavailable_from_sa),
      .uart_s1_irq                               (uart_s1_irq),
      .uart_s1_irq_from_sa                       (uart_s1_irq_from_sa),
      .uart_s1_read_n                            (uart_s1_read_n),
      .uart_s1_readdata                          (uart_s1_readdata),
      .uart_s1_readdata_from_sa                  (uart_s1_readdata_from_sa),
      .uart_s1_readyfordata                      (uart_s1_readyfordata),
      .uart_s1_readyfordata_from_sa              (uart_s1_readyfordata_from_sa),
      .uart_s1_reset_n                           (uart_s1_reset_n),
      .uart_s1_write_n                           (uart_s1_write_n),
      .uart_s1_writedata                         (uart_s1_writedata)
    );

  uart the_uart
    (
      .address       (uart_s1_address),
      .begintransfer (uart_s1_begintransfer),
      .chipselect    (uart_s1_chipselect),
      .clk           (clk),
      .dataavailable (uart_s1_dataavailable),
      .irq           (uart_s1_irq),
      .read_n        (uart_s1_read_n),
      .readdata      (uart_s1_readdata),
      .readyfordata  (uart_s1_readyfordata),
      .reset_n       (uart_s1_reset_n),
      .rxd           (rxd_to_the_uart),
      .txd           (txd_from_the_uart),
      .write_n       (uart_s1_write_n),
      .writedata     (uart_s1_writedata)
    );

  //reset is asserted asynchronously and deasserted synchronously
  ESPIER_I_niosII_standard_sopc_reset_clk_domain_synch_module ESPIER_I_niosII_standard_sopc_reset_clk_domain_synch
    (
      .clk      (clk),
      .data_in  (1'b1),
      .data_out (clk_reset_n),
      .reset_n  (reset_n_sources)
    );

  //reset sources mux, which is an e_mux
  assign reset_n_sources = ~(~reset_n |
    0 |
    cpu_jtag_debug_module_resetrequest_from_sa |
    cpu_jtag_debug_module_resetrequest_from_sa);

  //sysid_control_slave_clock of type clock does not connect to anything so wire it to default (0)
  assign sysid_control_slave_clock = 0;


endmodule


//synthesis translate_off



// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE

// AND HERE WILL BE PRESERVED </ALTERA_NOTE>


// If user logic components use Altsync_Ram with convert_hex2ver.dll,
// set USE_convert_hex2ver in the user comments section above

// `ifdef USE_convert_hex2ver
// `else
// `define NO_PLI 1
// `endif

`include "c:/altera/11.1/quartus/eda/sim_lib/altera_mf.v"
`include "c:/altera/11.1/quartus/eda/sim_lib/220model.v"
`include "c:/altera/11.1/quartus/eda/sim_lib/sgate.v"
`include "uart.v"
`include "sys_clk_timer.v"
`include "led.v"
`include "cpu_test_bench.v"
`include "cpu_mult_cell.v"
`include "cpu_oci_test_bench.v"
`include "cpu_jtag_debug_module_tck.v"
`include "cpu_jtag_debug_module_sysclk.v"
`include "cpu_jtag_debug_module_wrapper.v"
`include "cpu.v"
`include "sysid.v"
`include "sdram.v"
`include "spi_adc.v"
`include "high_res_timer.v"
`include "beep.v"
`include "onchip_ram.v"
`include "key.v"
`include "spi_flash.v"
`include "jtag_uart.v"
`include "lcd.v"
`include "epcs_controller.v"

`timescale 1ns / 1ps

module test_bench 
;


  wire             LCD_E_from_the_lcd;
  wire             LCD_RS_from_the_lcd;
  wire             LCD_RW_from_the_lcd;
  wire    [  7: 0] LCD_data_to_and_from_the_lcd;
  wire             MISO_to_the_spi_adc;
  wire             MISO_to_the_spi_flash;
  wire             MOSI_from_the_spi_adc;
  wire             MOSI_from_the_spi_flash;
  wire             SCLK_from_the_spi_adc;
  wire             SCLK_from_the_spi_flash;
  wire             SS_n_from_the_spi_adc;
  wire             SS_n_from_the_spi_flash;
  reg              clk;
  wire             data0_to_the_epcs_controller;
  wire             dclk_from_the_epcs_controller;
  wire             epcs_controller_epcs_control_port_dataavailable_from_sa;
  wire             epcs_controller_epcs_control_port_endofpacket_from_sa;
  wire             epcs_controller_epcs_control_port_readyfordata_from_sa;
  wire             in_port_to_the_key;
  wire             jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  wire             out_port_from_the_beep;
  wire    [  3: 0] out_port_from_the_led;
  reg              reset_n;
  wire             rxd_to_the_uart;
  wire             sce_from_the_epcs_controller;
  wire             sdo_from_the_epcs_controller;
  wire             spi_adc_spi_control_port_dataavailable_from_sa;
  wire             spi_adc_spi_control_port_endofpacket_from_sa;
  wire             spi_adc_spi_control_port_readyfordata_from_sa;
  wire             spi_flash_spi_control_port_dataavailable_from_sa;
  wire             spi_flash_spi_control_port_endofpacket_from_sa;
  wire             spi_flash_spi_control_port_readyfordata_from_sa;
  wire             sysid_control_slave_clock;
  wire             txd_from_the_uart;
  wire             uart_s1_dataavailable_from_sa;
  wire             uart_s1_readyfordata_from_sa;
  wire    [ 12: 0] zs_addr_from_the_sdram;
  wire    [  1: 0] zs_ba_from_the_sdram;
  wire             zs_cas_n_from_the_sdram;
  wire             zs_cke_from_the_sdram;
  wire             zs_cs_n_from_the_sdram;
  wire    [ 15: 0] zs_dq_to_and_from_the_sdram;
  wire    [  1: 0] zs_dqm_from_the_sdram;
  wire             zs_ras_n_from_the_sdram;
  wire             zs_we_n_from_the_sdram;


// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
//  add your signals and additional architecture here
// AND HERE WILL BE PRESERVED </ALTERA_NOTE>

  //Set us up the Dut
  ESPIER_I_niosII_standard_sopc DUT
    (
      .LCD_E_from_the_lcd            (LCD_E_from_the_lcd),
      .LCD_RS_from_the_lcd           (LCD_RS_from_the_lcd),
      .LCD_RW_from_the_lcd           (LCD_RW_from_the_lcd),
      .LCD_data_to_and_from_the_lcd  (LCD_data_to_and_from_the_lcd),
      .MISO_to_the_spi_adc           (MISO_to_the_spi_adc),
      .MISO_to_the_spi_flash         (MISO_to_the_spi_flash),
      .MOSI_from_the_spi_adc         (MOSI_from_the_spi_adc),
      .MOSI_from_the_spi_flash       (MOSI_from_the_spi_flash),
      .SCLK_from_the_spi_adc         (SCLK_from_the_spi_adc),
      .SCLK_from_the_spi_flash       (SCLK_from_the_spi_flash),
      .SS_n_from_the_spi_adc         (SS_n_from_the_spi_adc),
      .SS_n_from_the_spi_flash       (SS_n_from_the_spi_flash),
      .clk                           (clk),
      .data0_to_the_epcs_controller  (data0_to_the_epcs_controller),
      .dclk_from_the_epcs_controller (dclk_from_the_epcs_controller),
      .in_port_to_the_key            (in_port_to_the_key),
      .out_port_from_the_beep        (out_port_from_the_beep),
      .out_port_from_the_led         (out_port_from_the_led),
      .reset_n                       (reset_n),
      .rxd_to_the_uart               (rxd_to_the_uart),
      .sce_from_the_epcs_controller  (sce_from_the_epcs_controller),
      .sdo_from_the_epcs_controller  (sdo_from_the_epcs_controller),
      .txd_from_the_uart             (txd_from_the_uart),
      .zs_addr_from_the_sdram        (zs_addr_from_the_sdram),
      .zs_ba_from_the_sdram          (zs_ba_from_the_sdram),
      .zs_cas_n_from_the_sdram       (zs_cas_n_from_the_sdram),
      .zs_cke_from_the_sdram         (zs_cke_from_the_sdram),
      .zs_cs_n_from_the_sdram        (zs_cs_n_from_the_sdram),
      .zs_dq_to_and_from_the_sdram   (zs_dq_to_and_from_the_sdram),
      .zs_dqm_from_the_sdram         (zs_dqm_from_the_sdram),
      .zs_ras_n_from_the_sdram       (zs_ras_n_from_the_sdram),
      .zs_we_n_from_the_sdram        (zs_we_n_from_the_sdram)
    );

  initial
    clk = 1'b0;
  always
     if (clk == 1'b1) 
    #10 clk <= ~clk;
     else 
    #11 clk <= ~clk;
  
  initial 
    begin
      reset_n <= 0;
      #210 reset_n <= 1;
    end

endmodule


//synthesis translate_on