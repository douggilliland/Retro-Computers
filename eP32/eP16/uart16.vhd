-- **********************************************************
-- *			UART Serial Interface					.	*
-- *========================================================*
-- * Project:			FG in PROASIC						*
-- * File:				uart.vhd							*
-- * Author:			Chien-Chia Wu						*
-- * Description:		UART								*
-- *														*
-- * Hierarchy:parent:										*
-- *		child :											* 
-- *														*
-- * Revision History:										*
-- * Date		By Who		Modification					*
-- * 02/13/03	Chien-Chia Wu   Reference uart statements t	*
-- * 02/14/03	Chien-Chia Wu   (1)Copy from bpchip, 		*
-- *							(2)Modify as 32-bits 	.   * 
-- *							(3)Swap the cts and rts .   *
-- * 02/29/12	 Chen-Hanson Ting Back to eP16			   	  *
-- **********************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity uart is
	port(
		-- input
		clk_i:		in		std_logic;
		rst_i:		in		std_logic;
		ce_i:		in		std_logic;
		read_i:		in		std_logic;
		write_i:	in		std_logic;
		addr_i:		in		std_logic_vector(1 downto 0);
		data_i:		in		std_logic_vector(15 downto 0);
		-- output
		data_o:		out		std_logic_vector(15 downto 0);
		rx_empty_o: out		std_logic;
		rx_irq_o:   out		std_logic;
		tx_irq_o:   out		std_logic;
		-- external interface
		rxd_i:		in		std_logic;
		txd_o:		out		std_logic;
		cts_i:		in		std_logic;
		rts_o:		out		std_logic
	);
end uart;
	
architecture behavioral of uart is
	signal baudrate_reg:	std_logic_vector(15 downto 0);
	signal hw_xonoff_ff:	std_logic;

	signal tx_shift_reg:	std_logic_vector(10 downto 0);
	signal tx_shift_en:		std_logic;
	signal tx_en:			std_logic;
	signal tx_rq:			std_logic; 
	signal tx_counter:		std_logic_vector(15 downto 0);
	signal tx_bitcnt:		std_logic_vector(3 downto 0); 
	
	signal rx_shift_reg:	std_logic_vector(7 downto 0);
	signal rx_buffer_reg:	std_logic_vector(7 downto 0);
	signal rxb_full:		std_logic;
	signal rx_full:			std_logic;
	signal rx_en:			std_logic;	
	signal rx_counter:		std_logic_vector(15 downto 0);
	signal rx_bitcnt:		std_logic_vector(3 downto 0);
	signal rxd_ff:			std_logic; 
begin

	rts_o <= hw_xonoff_ff and (not(rx_full));
	rx_empty_o <= rx_full nor rxb_full;

-- ********************************************************   
--			Uart Register Circuit for Read
-- ********************************************************   
  uart_register_file_read:
  process(read_i, ce_i, addr_i, baudrate_reg, tx_en, cts_i, 
		hw_xonoff_ff, rxb_full, rx_buffer_reg)
	begin 
	if (read_i='1' and ce_i='1') then 
		case addr_i is
		when "00"   => data_o <= baudrate_reg;
		when "01"   => data_o <=	-- read TX ready flag  
				"0000000" &
				((not tx_en)and(cts_i or(not hw_xonoff_ff)))
				& "00000000";	
		when "10"   => data_o <= --only cleared by rxb read
				"0000000" & rxb_full & 
				"0000000" & hw_xonoff_ff;
		when others => data_o <= -- read&clear rxb_full flag
				"00000000" & rx_buffer_reg;
		end case;					
	else
		data_o <= (others=>'1');  
	end if;
	end process uart_register_file_read;  
  
-- **********************************************************   
--			Uart Register File Process for Write
-- **********************************************************   
  uart_register_file_write : process (rst_i, clk_i)
	begin
	if ( rst_i='1' ) then
		baudrate_reg<="0000000110101111";
			-- 50 MHz, 115.2Kbps 
		tx_shift_reg <= (others=>'0');
		tx_rq <= '0'; 
		hw_xonoff_ff <= '0';  
	elsif (clk_i'event and clk_i='1') then
		if (tx_en='0') then
		if (write_i='1' and ce_i='1') then
			case addr_i is 
			when "00"=>baudrate_reg<=data_i;
			when "01"=>
				tx_shift_reg<="11"&data_i(7 downto 0)&'0'; 
				tx_rq<='1'; 
			when "10"=>hw_xonoff_ff<=data_i(0);--flow Control
			when others => null;
			end case;
		end if;	
		else
			tx_rq <= '0';
			if (tx_shift_en='1') then
				tx_shift_reg<='1'&tx_shift_reg(10 downto 1);
			end if;  
		end if;
	end if;	
	end process uart_register_file_write;

-- **********************************************************   
--			Uart TX Core Process
-- **********************************************************   
  uart_tx_core : process ( rst_i, clk_i) 
	begin
	if (rst_i='1') then
		tx_counter <= (others=>'0');
		tx_bitcnt <= (others=>'0');
		txd_o <= '1';
		tx_en <= '0';
		tx_shift_en <= '0';
		tx_irq_o <= '0';
	elsif ( clk_i'event and clk_i='1' ) then
		tx_shift_en <='0';
		tx_irq_o <= '0';
		if (tx_en='0') and (tx_rq='1') and
			(cts_i='1' or hw_xonoff_ff='0') then
			tx_counter <= baudrate_reg;
			tx_bitcnt <= "1011";
			tx_en <= '1';
		elsif (tx_en='1') then  
		if (tx_counter/="0000000000000000")
			then	tx_counter <= tx_counter-1;
		elsif (tx_bitcnt/="0000") then
			tx_bitcnt <= tx_bitcnt-1;
			txd_o <= tx_shift_reg(0);
			tx_shift_en <= '1';
			tx_counter <= baudrate_reg;
		else
			txd_o <= '1';		-- mark-high=stop-bit
			tx_irq_o  <= '1';	-- transmitter empty
			tx_en<='0';		-- closed
		end if;  
		end if;
	end if;  
	end process uart_tx_core;
	
-- **********************************************************   
--			Uart RX Core Process
-- **********************************************************   
  uart_rx_core : process ( rst_i, clk_i) 
	begin
	if (rst_i='1') then
		rx_full <= '0';
		rxb_full <= '0';
		rx_irq_o <= '0';
		rx_buffer_reg <= (others=>'0');
		rx_counter <= (others=>'0');
		rx_bitcnt <= (others=>'0');
		rx_en <= '0';
		rx_shift_reg <= (others=>'0');
		rxd_ff <= '0';
	elsif ( clk_i'event and clk_i='1' ) then
		rx_irq_o <= '0'; 
		rxd_ff <= rxd_i;
		if (rx_full='1') then
		if (rxb_full='0') or
			(read_i='1' and ce_i='1' and addr_i="11") then
			rx_buffer_reg <= rx_shift_reg;
			rxb_full <= '1';
			rx_full <= '0';
		end if;
		else
		if (read_i='1' and ce_i='1' and addr_i="11") then
			rxb_full <= '0';
		end if;
		if (rx_en='0') and (rxd_ff='0') then
			rx_counter <= '0' & baudrate_reg(15 downto 1);
			rx_bitcnt <= "1001";
			rx_en <= '1';
		elsif (rx_en='1') then
			if(rx_counter/="0000000000000000")
				then   -- bit-T-counting
				rx_counter <= rx_counter-1;
			elsif (rx_bitcnt/="0000") then
				-- last bit has been received
				rx_bitcnt <= rx_bitcnt-1;
				rx_shift_reg<=rxd_ff&rx_shift_reg(7 downto 1);
				rx_counter <= baudrate_reg;
				else  
					rx_irq_o <= '1';--flag for generate pulse
					rx_full <= '1';
					rx_en <= '0';
				end if;  
			end if;
		end if;  
	end if;  
	end process uart_rx_core;
end behavioral;
							
