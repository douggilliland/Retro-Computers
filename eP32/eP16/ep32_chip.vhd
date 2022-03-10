-- ************************************************************
-- *		 (C) Copyright 2002, eForth Technology Inc.		  *
-- *					 ALL RIGHTS RESERVED				  *
-- *==========================================================*
-- * Project:			 FG in PROASIC					   	  *
-- * File:				 ep32_chip.vhd						  *
-- * Author:			 Chien-Chia Wu						  *
-- * Description:		 Top level block					  *
-- *														  *
-- * Hierarchy:parent:										  *
-- *		   child :										  *  
-- *														  *
-- * Revision History:										  *
-- * Date		 By Who		  Modification					  *
-- * 09/19/02	 Chien-Chia Wu   Branch from ep16a.			  *
-- * 01/02/03	 Chien-Chia Wu   Add SDI.					  *
-- * 01/29/03	 Chien-Chia Wu   Add Boot.					  *
-- * 02/24/03	 Chien-Chia Wu   Modify the module as 32-bits * 
-- *							  version.					  * 
-- * 02/27/03	 Chien-Chia Wu   Modify SDRAM byte-assecable  *
-- * 03/02/03	 Chien-Chia Wu   Add internal SRAM module.    *
-- * 06/29/06	 Chen-Hanson Ting Add HMPP/Shifter/Controller *
-- * 11/18/10	 Chen-Hanson Ting LatticeXP2 Brevia Kit   	  *
-- ************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity ep32_chip is 
port(
	-- input port
	aclk:			in		std_logic; 
	arst:			in		std_logic;
	interrupt_i:	in		std_logic_vector(4 downto 0);
	uart_i:			in		std_logic;
	-- output port
	uart_o:			out		std_logic;
	acknowledge_o:	out		std_logic;
	-- GPIO Interface
	ioport:			inout 	std_logic_vector(15 downto 0)
	);
end entity ep32_chip;


architecture behavioral of ep32_chip is
  -- component declaration
  component ep32 is 
	port(
		-- input port
		clk:		in		std_logic;
		clr:		in		std_logic;
		interrupt:  in		std_logic_vector(4 downto 0);
		data_i:		in		std_logic_vector(31 downto 0);
		intack:		out		std_logic;
		read:		out		std_logic;
		write:		out		std_logic;
		addr:		out		std_logic_vector(31 downto 0);
		data_o:		out		std_logic_vector(31 downto 0)
	);
  end component;

  component uart is
	port(
		-- input
		clk_i:		in		std_logic;
		rst_i:		in		std_logic;
		ce_i:		in		std_logic;
		read_i:		in		std_logic;
		write_i:	in		std_logic;
		addr_i:		in		std_logic_vector(1 downto 0);
		data_i:		in		std_logic_vector(31 downto 0);
		-- output   	
		data_o:		out		std_logic_vector(31 downto 0);
		rx_empty_o:	out		std_logic;
		rx_irq_o:  	out		std_logic;
		tx_irq_o: 	out		std_logic;
		-- external interface
		rxd_i:		in		std_logic;
		txd_o:		out		std_logic;
		cts_i:		in		std_logic;
		rts_o:		out		std_logic
	);
  end component;


component ram_memory
	port (
		Clock: 		in  	std_logic;
		ClockEn: 	in  	std_logic; 
		Reset: 		in  	std_logic;
		WE: 		in  	std_logic; 
		Address: 	in  	std_logic_vector(11 downto 0); 
		Data: 		in  	std_logic_vector(31 downto 0); 
		Q: 			out  	std_logic_vector(31 downto 0));
end component;

component gpio
	port(
		-- input port
		clr: 		in		std_logic;
		clk: 		in		std_logic;
		write: 		in		std_logic;
		read: 		in		std_logic;
		ce: 		in		std_logic;
		addr: 		in		std_logic_vector(1 downto 0);
		data_in: 	in		std_logic_vector(31 downto 0);
		gpio_in: 	in		std_logic_vector(15 downto 0); 
		-- output port
		data_out: 	out		std_logic_vector(31 downto 0);
		gpio_out: 	out		std_logic_vector(15 downto 0);
		gpio_dir: 	out		std_logic_vector(15 downto 0)
	);
end component;

-- interal globle signal
	signal m_rst:			std_logic;
	signal m_clk:			std_logic;
	signal memory_data_o:	std_logic_vector(31 downto 0);
	signal memory_data_i:	std_logic_vector(31 downto 0);
	signal memory_addr:		std_logic_vector(11 downto 0);

-- internal signal for system bus
	signal system_addr:		std_logic_vector(31 downto 0);
	signal system_data_o:	std_logic_vector(31 downto 0);
	signal system_read:		std_logic;
	signal system_write:	std_logic;
	signal system_ack:		std_logic;  
  
-- internal signal for cpu
	signal cpu_data_i:		std_logic_vector(31 downto 0);
	signal cpu_addr_o:		std_logic_vector(31 downto 0);
	signal cpu_data_o:		std_logic_vector(31 downto 0);
	signal cpu_m_read:		std_logic;
	signal cpu_m_write:		std_logic;
	signal cpu_intack:		std_logic;
	signal cpu_ready_i:		std_logic;
	signal cpu_ack_o:		std_logic;
 
-- internal signal for uart
	signal uart_ce:			std_logic; 
	signal uart_addr:		std_logic_vector(1 downto 0);
	signal uart_data_i:		std_logic_vector(31 downto 0);
	signal uart_data_o:		std_logic_vector(31 downto 0);
	signal uart_rx_empty:	std_logic;
	signal uart_rx_irq:		std_logic;
	signal uart_tx_irq:		std_logic;
	signal uart_rxd:		std_logic;
	signal uart_txd:		std_logic;
	signal uart_cts:		std_logic;
	signal uart_rts:		std_logic;

-- internal signal for gpio
	signal gpio_ce:			std_logic;
	signal gpio_addr:		std_logic_vector(1 downto 0);
	signal gpio_data_i:		std_logic_vector(31 downto 0);
	signal gpio_in:			std_logic_vector(15 downto 0); 
	signal gpio_data_o:		std_logic_vector(31 downto 0);
	signal gpio_out:		std_logic_vector(15 downto 0);
	signal gpio_dir:		std_logic_vector(15 downto 0);
 
begin
-- ************************************************************   
--			Component Binding
-- ************************************************************   
-- ========================= CPU Block ========================	
	cpu1: ep32 
		port map (
		-- input port
		clk => aclk,
		clr => m_rst,
		interrupt => interrupt_i,
		data_i => cpu_data_i,
		intack => acknowledge_o,
		read => cpu_m_read,
		write => cpu_m_write,
		addr => cpu_addr_o,
		data_o => cpu_data_o
		);

-- ************************************************************   
--			Internal Globle Signal Circuit
-- ************************************************************   

	m_rst <= not arst;
	m_clk <= not aclk;
	system_addr <= cpu_addr_o;
	system_read <= cpu_m_read;
	system_write <= cpu_m_write;
	system_ack <= cpu_ack_o;
	cpu_ready_i <= '1';

	cpu_data_i <= system_data_o;

	system_data_o <=  cpu_data_o when (system_write='1')
		else 
		memory_data_o when(system_addr(31 downto 28)="0000")
		else
		uart_data_o when (system_addr(31 downto 28)="1000")
		else
		gpio_data_o when (system_addr(31 downto 28)="1110")
		else (others => 'Z');

-- ========================= UART Block =======================	
  uart1 : uart
	port map (
		-- input
		clk_i => aclk,
		rst_i => m_rst,
		ce_i => uart_ce,
		read_i => system_read,
		write_i => system_write,
		addr_i => uart_addr,
		data_i => uart_data_i,
		-- output
		data_o => uart_data_o,
		rx_empty_o => uart_rx_empty,
		rx_irq_o => uart_rx_irq,
		tx_irq_o => uart_tx_irq,
		-- external interface
		rxd_i => uart_rxd,
		txd_o => uart_txd,
		cts_i => uart_cts,
		rts_o => uart_rts
	);
	uart_ce <= '1' when (system_addr(31 downto 28)="1000")
  		else '0';
	uart_addr <= system_addr(1 downto 0);
	uart_data_i <= system_data_o;
	uart_rxd <= uart_i;
	uart_o <= uart_txd;
 
-- ========================= RAM Block ========================	
ram_memory_0 : ram_memory
	PORT MAP (
		Address	=> memory_addr,
		Clock	=> m_clk,
		ClockEn	=> '1',
		Reset	=> '0',
		Data	=> memory_data_i,
		WE	=> system_write,
		Q		=> memory_data_o
	);

  memory_addr <= cpu_addr_o(11 downto 0);
  memory_data_i <= cpu_data_o ;

-- ========================= GPIO Block =======================	
  gpio1 : gpio
   port map (
		-- input port
		clr => m_rst,
		clk => aclk,
		write => system_write,
		read => system_read,
		ce => gpio_ce,
		addr => gpio_addr,
		data_in => gpio_data_i,
		gpio_in => gpio_in, 
		-- output port
		data_out => gpio_data_o,
		gpio_out => gpio_out,
		gpio_dir => gpio_dir
	);
	gpio_ce <= '1' when (system_addr(31 downto 28)="1110")
		else '0';
	gpio_addr <= system_addr(1 downto 0);
	gpio_data_i <= system_data_o;
	gpio_in <= ioport;
	ioport(0)  <= gpio_out(0)  when gpio_dir(0)='1'  else 'Z';
	ioport(1)  <= gpio_out(1)  when gpio_dir(1)='1'  else 'Z';
	ioport(2)  <= gpio_out(2)  when gpio_dir(2)='1'  else 'Z';
	ioport(3)  <= gpio_out(3)  when gpio_dir(3)='1'  else 'Z';
	ioport(4)  <= gpio_out(4)  when gpio_dir(4)='1'  else 'Z';
	ioport(5)  <= gpio_out(5)  when gpio_dir(5)='1'  else 'Z';
	ioport(6)  <= gpio_out(6)  when gpio_dir(6)='1'  else 'Z';
	ioport(7)  <= gpio_out(7)  when gpio_dir(7)='1'  else 'Z';
	ioport(8)  <= gpio_out(8)  when gpio_dir(8)='1'  else 'Z';
	ioport(9)  <= gpio_out(9)  when gpio_dir(9)='1'  else 'Z';
	ioport(10) <= gpio_out(10) when gpio_dir(10)='1' else 'Z';
	ioport(11) <= gpio_out(11) when gpio_dir(11)='1' else 'Z';
	ioport(12) <= gpio_out(12) when gpio_dir(12)='1' else 'Z';
	ioport(13) <= gpio_out(13) when gpio_dir(13)='1' else 'Z';
	ioport(14) <= gpio_out(14) when gpio_dir(14)='1' else 'Z';
	ioport(15) <= gpio_out(15) when gpio_dir(15)='1' else 'Z';

  end behavioral;
