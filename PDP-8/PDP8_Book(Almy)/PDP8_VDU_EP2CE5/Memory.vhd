----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:24:33 04/19/2014 
-- Design Name: 
-- Module Name:    Memory - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 1.0 Buffering added to better represent interface to external memory so I can make the switch. 7/25/2014
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Memory is
    Port ( clk				: in  STD_LOGIC;
			  reset			: in STD_LOGIC;
           address		: in  STD_LOGIC_VECTOR (11 downto 0);
           write_data	: in  STD_LOGIC_VECTOR (11 downto 0);
           read_data		: out  STD_LOGIC_VECTOR (11 downto 0);
           write_enable : in  STD_LOGIC;	-- start write memory cycle, address and write data are valid
           read_enable	: in  STD_LOGIC;	-- start read cycle, address is valid
           mem_finished : out  STD_LOGIC	-- memory cycle is done OK to latch read data
-- Note that read_enable and write_enable may be asserted over many clock cycles but must
-- be released when mem_finished occurs. The address and write data are latched on the first
-- active clock edge when the enable is asserted. 
-- Mem_finished only lasts through one active clock edge.
-- 
-- The registering slows things way down (adds two clock periods to the access time) however
-- this change will make going to an external RAM much simpler.
			  );
end Memory;

architecture Behavioral of Memory is

 COMPONENT InternalSRAM_4KW 
	PORT (
		address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q			: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
END COMPONENT;

type STATES is (S0, S1, S1A, S2, S3, S3A);
signal curr_state		: STATES := S0;
signal next_state		: STATES;

signal wea				: std_logic;
signal load_rdata		: std_logic;
signal addr_buf, wdata_buf, rdata_buf : std_logic_vector (11 downto 0) := (others => '0');

--attribute syn_keep: boolean;
--attribute syn_keep of wea			: signal is true;
--attribute syn_keep of addr_buf	: signal is true;
--attribute syn_keep of wdata_buf	: signal is true;
--attribute syn_keep of rdata_buf	: signal is true;

begin

process (clk) begin -- current state register
	if rising_edge(clk) then
		if reset = '1' then
			curr_state <= S0;
		else
			curr_state <= next_state;
		end if;
	end if;
end process;

process (clk) begin -- address and write data buffers
	if rising_edge(clk) then
		if (read_enable = '1' or write_enable = '1') and curr_state = S0 then
			addr_buf		<= address;
			wdata_buf	<= write_data;
		end if;
	end if;
end process;

process (clk) begin -- read data buffer
	if rising_edge(clk) then
		if load_rdata = '1' then
			read_data <= rdata_buf;
		end if;
	end if;
end process;

-- Read/Write state machine
-- Read states  S0 > S1 > S1A > S2 -> S0
-- Write states S0 > S3 > S3A > S0
process (read_enable, write_enable, curr_state) begin -- state machine combinatorial logic
	next_state 		<= curr_state; -- set defaults
	wea 				<= '0';
	mem_finished 	<= '0';
	load_rdata 		<= '0';
	case curr_state is
		when S0 => if read_enable = '1' then next_state <= S1; -- start read cycle
					elsif write_enable = '1' then next_state <= S3;
					end if;
		when S1 => next_state		<= S1A; -- delay for operation
		when S1A => load_rdata		<= '1'; next_state <= S2;
		when S2 => mem_finished		<= '1'; next_state <= S0;
		when S3 => wea 				<= '1'; next_state <= S3A;
		when S3A => mem_finished	<= '1'; next_state <= S0;
		when others => next_state	<= S0;
	end case;
end process;

mySRAM : InternalSRAM_4KW
	PORT MAP
	(
		clock		=> clk,	
		wren		=> wea,
		address	=> addr_buf,
		data		=> wdata_buf,
		q			=> rdata_buf
	);
  
-- INST_TAG_END ------ End INSTANTIATION Template ------------


end Behavioral;

