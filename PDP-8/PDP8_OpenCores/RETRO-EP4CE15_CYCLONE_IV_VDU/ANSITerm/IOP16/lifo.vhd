--
-- Last-In-First-Out (LIFO
-- https://github.com/dominiksalvet/vhdl-collection/blob/master/rtl/lifo.vhdl
--
--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:	independent
--------------------------------------------------------------------------------
-- Description:
--	 This file represents a generic LIFO structure (also known as stack). It
--	 is possible to setup it's capacity and stored data's bit width.
--------------------------------------------------------------------------------
-- Notes:
--	 1. If both write and read operations are enabled at the same time,
--		only write will be performed. In this case it is needed to be careful
--		when LIFO is full as write will be performed anyway.
--	 2. The final internal LIFO capacity is equal to 2^g_INDEX_WIDTH only. It
--		is not possible to choose another capacity.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lifo is	
	generic (
		g_INDEX_WIDTH : positive := 2; -- internal index bit width affecting the LIFO capacity
		g_DATA_WIDTH  : positive := 8 -- bit width of stored data
	);
	port (
		i_clk : in std_logic; -- clock signal
		i_rst : in std_logic; -- reset signal
		
		i_we   : in  std_logic; -- write enable (push)
		i_data : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- written data
		o_full : out std_logic; -- full LIFO indicator
		
		i_re	: in  std_logic; -- read enable (pop)
		o_data  : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- read data
		o_empty : out std_logic -- empty LIFO indicator
	);
end entity lifo;


architecture rtl of lifo is
	
	-- output buffers
	signal b_full  : std_logic;
	signal b_empty : std_logic;
	
	-- definition of internal memory type
	type t_MEM is array(0 to integer((2 ** g_INDEX_WIDTH) - 1)) of
		std_logic_vector(g_DATA_WIDTH - 1 downto 0);
	signal r_mem : t_MEM; -- accessible internal memory signal
	
	signal r_wr_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current write index
	signal w_rd_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current read index
	
begin
	
	o_full <= b_full;
	
	o_empty <= b_empty;
	
	w_rd_index <= r_wr_index - 1; -- read index is always less by 1 than write index
	
	-- Description:
	--	 Internal memory read and write mechanism description.
	mem_access : process (i_clk)
	begin
		if (rising_edge(i_clk)) then -- synchronous reset
			if (i_rst = '1') then
				b_full	 <= '0';
				b_empty	<= '1';
				r_wr_index <= to_unsigned(0, r_wr_index'length);
			else
				
				if (i_we = '1') then -- write mechanism
					-- the LIFO is never empty after write and no read
					b_empty					   <= '0';
					r_mem(to_integer(r_wr_index)) <= i_data;
					r_wr_index					<= r_wr_index + 1;
					
					if (r_wr_index = (2 ** g_INDEX_WIDTH) - 1) then -- full LIFO check
						b_full <= '1';
					end if;
				elsif (i_re = '1') then -- read mechanism
					b_full	 <= '0'; -- the LIFO is never full after read and no write
					o_data	 <= r_mem(to_integer(w_rd_index));
					r_wr_index <= w_rd_index;
					
					if (w_rd_index = 0) then -- empty LIFO check
						b_empty <= '1';
					end if;
				end if;
				
			end if;
		end if;
	end process mem_access;
	
	-- rtl_synthesis off
--	input_prevention : process (i_clk) is
--	begin
--		if (rising_edge(i_clk)) then
--			assert (not (b_full = '1' and i_we = '1'))
--				report "Writing when full has caused overflow and get the module into undefined " &
--				"state!"
--				severity failure;
--			
--			assert (not (b_empty = '1' and i_re = '1' and i_we = '0'))
--				report "Reading without writing when empty has caused underflow and get the " &
--				"module into undefined state!"
--				severity failure;
--		end if;
--	end process input_prevention;
	-- rtl_synthesis on
	
end architecture rtl;