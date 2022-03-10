-- **********************************************************
-- *			eP16 Microprocessor CPU Core				*
-- *========================================================*
-- * FPGA Project:		16-Bit CPU in Altera SOPC Builder	*
-- * File:				ep16.vhd							*
-- * Author:			C.H.Ting							*
-- * Description:		ep16 CPU Block						*
-- *														*
-- * Revision History:										*
-- * Date		By Who		Modification					*
-- * 06/06/05	C.H. Ting	Convert EP24 to 32-bits.		*
-- * 06/10/05	Robyn King	Made compatible with Altera SOPC*
-- *							Builder.					*
-- * 06/27/05	C.H. Ting	Removed Line Drawing Engine.	*
-- * 07/27/05	Robyn King	Cleaned up code.				*
-- * 08/07/10	C.H. Ting	Return to eP32p					*
-- * 11/18/10	C.H. Ting	Port to LatticeXP2 Brevia Kit	*
-- * 02/29/12	 Chen-Hanson Ting Back to eP16			   	  *
-- **********************************************************
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;


entity ep16 is 
	generic(width: integer := 16);
	port(
		-- input port
		clk:		in	std_logic;
		clr:		in	std_logic;
		interrupt:	in	std_logic_vector(4 downto 0);
		data_i:		in	std_logic_vector(width-1 downto 0);
		intack:		out	std_logic;
		read:		out	std_logic;
		write:		out	std_logic;
		addr:		out	std_logic_vector(width-1 downto 0);
		data_o:		out	std_logic_vector(width-1 downto 0)
  	);
end entity ep16;

architecture behavioral of ep16 is
	type   stack is
	array(31 downto 0) of std_logic_vector(width downto 0);
	signal s_stack,r_stack: stack;
	signal slot: integer range 0 to 5;
	signal sp,sp1,rp,rp1: std_logic_vector(4 downto 0); 
	signal t,s,sum: std_logic_vector(width downto 0);
	signal a,r: std_logic_vector(width downto 0);
	signal t_in,r_in,a_in: std_logic_vector(width downto 0);
	signal code: std_logic_vector(4 downto 0);
	signal t_sel: std_logic_vector(3 downto 0);
	signal p_sel: std_logic_vector(2 downto 0);	
	signal a_sel: std_logic_vector(2 downto 0);
	signal r_sel: std_logic_vector(1 downto 0);
	signal addr_sel: std_logic;
	signal spush,spopp,rpush,rpopp,inten,intload,intset,
		tload,rload,aload,pload,iload,reset,z: std_logic;
	signal r_z,int_z: std_logic;
	signal i,p,p_in: std_logic_vector(width-1 downto 0);
-- machine instructions selected by code
	constant bra : std_logic_vector(4 downto 0) :="00000";
	constant ret : std_logic_vector(4 downto 0) :="00001";
	constant bz  : std_logic_vector(4 downto 0) :="00010";
	constant bc  : std_logic_vector(4 downto 0) :="00011";
	
	constant nxt : std_logic_vector(4 downto 0) :="00101";
	constant ei  : std_logic_vector(4 downto 0) :="00110";
	constant ldp : std_logic_vector(4 downto 0) :="01001";
	constant ldi : std_logic_vector(4 downto 0) :="01010";
	constant ld  : std_logic_vector(4 downto 0) :="01011";
	constant stp : std_logic_vector(4 downto 0) :="01101";
	constant rr8 : std_logic_vector(4 downto 0) :="01110";
	constant st  : std_logic_vector(4 downto 0) :="01111";
	constant com : std_logic_vector(4 downto 0) :="10000";
	constant shl : std_logic_vector(4 downto 0) :="10001";
	constant shr : std_logic_vector(4 downto 0) :="10010";
	constant mul : std_logic_vector(4 downto 0) :="10011";
	constant xorr: std_logic_vector(4 downto 0) :="10100";
	constant andd: std_logic_vector(4 downto 0) :="10101";
	constant div : std_logic_vector(4 downto 0) :="10110";
	constant addd: std_logic_vector(4 downto 0) :="10111";
	constant popr: std_logic_vector(4 downto 0) :="11000";
	constant lda : std_logic_vector(4 downto 0) :="11001";
	constant dup : std_logic_vector(4 downto 0) :="11010";
	constant over: std_logic_vector(4 downto 0) :="11011";
	constant pushr:std_logic_vector(4 downto 0) :="11100";
	constant sta : std_logic_vector(4 downto 0) :="11101";
	constant nop : std_logic_vector(4 downto 0) :="11110";
	constant drop: std_logic_vector(4 downto 0) :="11111";
-- mux to t register, selected by t_sel
	constant not_t: 	std_logic_vector :="0000";
	constant s_xor_t: 	std_logic_vector :="0001";
	constant s_and_t: 	std_logic_vector :="0010";
	constant s_or_t: 	std_logic_vector :="0011";
	constant sum_t: 	std_logic_vector :="0100";
	constant shr_sum: 	std_logic_vector :="0101";
	constant shr_t: 	std_logic_vector :="0110";
	constant shr_t_t: 	std_logic_vector :="0111";
	constant shl_sum_a_t: std_logic_vector :="1000";
	constant shl_t_a_t: std_logic_vector :="1001";
	constant shl_t: 	std_logic_vector :="1010";
	constant s_t: 		std_logic_vector :="1011";
	constant a_t: 		std_logic_vector :="1100";
	constant r_t: 		std_logic_vector :="1101";
	constant data_t: 	std_logic_vector :="1110";
	constant rr8_t: 	std_logic_vector :="1111";
-- mux to a register, selected by a_sel
	constant t_a: 		std_logic_vector :="001";
	constant a1_a: 		std_logic_vector :="010";
	constant shr_sum_a: std_logic_vector :="011";
	constant shr_t_a: 	std_logic_vector :="100";
	constant shl_sum_a: std_logic_vector :="101";
-- mux to r register, selected by r_sel
	constant rout_r: 	std_logic_vector :="00";
	constant t_r: 		std_logic_vector :="01";
	constant r1_r: 		std_logic_vector :="10";
	constant p_r: 		std_logic_vector :="11";
-- mux to p register, selected by p_sel
	constant i_p: 		std_logic_vector :="000";
	constant pi_p: 		std_logic_vector :="001";
	constant p1_p: 		std_logic_vector :="010";
	constant r_p: 		std_logic_vector :="011";
	constant int_p: 	std_logic_vector :="100";
-- mux to memory bus, selected by addr_sel
	constant p_addr: 	std_logic :='0';
	constant a_addr: 	std_logic :='1';

begin
	data_o<= t(width-1 downto 0);
	intack <= inten;			
	s <= s_stack(conv_integer(sp));
	sum<=(('0'&t(width-1 downto 0)) +
		('0'&s(width-1 downto 0)));
	with t_sel select
	t_in <= (not t) when not_t,
		(t xor s) when s_xor_t,
		(t and s) when s_and_t,
		sum when sum_t,
		(t(width-1 downto 0) & '0') when shl_t,
		(t(width-1 downto 0) & a(width-1)) when shl_t_a_t,
		(sum(width-1 downto 0)&a(width-1)) when shl_sum_a_t,
		('0'&sum(width downto 1)) when shr_sum,
		('0'&t(width-1)&t(width-1 downto 1)) when shr_t,
		("00"&t(width-1 downto 1)) when shr_t_t,
		s when s_t,
		a when a_t,
		r when r_t,
		t(width)&t(7 downto 0)&t(width-1 downto 8)when rr8_t, 
		'0'&data_i(width-1 downto 0) when others;
	with slot select
	code <= i(14 downto 10) when 1,
		i(9 downto 5) when 2,
		i(4 downto 0) when 3,
		nop when others;
	with a_sel select
	a_in <= a+1 when a1_a ,
		('0'&t(0)&a(width-1 downto 1)) when shr_t_a ,
		('0'&sum(0)&a(width-1 downto 1)) when shr_sum_a ,
		('0'&a(width-2 downto 0)&sum(width)) when shl_sum_a,
		t when others;
	with r_sel select
	r_in <= r-1 when r1_r ,
		'0'&p when p_r ,
		r_stack(conv_integer(rp)) when rout_r ,
		t when others;
	with p_sel select
	p_in <= (p(width-1) & i(width-2 downto 0)) when i_p ,
		(p(width-1 downto width-6) & i(width-7 downto 0)) when pi_p ,
		r(width-1 downto 0) when r_p ,
		("00000000000"&interrupt(4 downto 0)) when int_p ,
		p+1 when others;
	with addr_sel select
	addr <= a(width-1 downto 0) when a_addr ,
		p(width-1 downto 0) when others;
	z <= not(t(15) or t(14) or t(13) or t(12)
		or t(11) or t(10) or t(9) or t(8)
		or t(7) or t(6) or t(5) or t(4)
		or t(3) or t(2) or t(1) or t(0));
	r_z <= not(r(15) or r(14) or r(13) or r(12)
		or r(11) or r(10) or r(9) or r(8)
		or r(7) or r(6) or r(5) or r(4)
		or r(3) or r(2) or r(1) or r(0));
	int_z <= interrupt(0) or interrupt(1) or interrupt(2)
			or interrupt(3) or interrupt(4) ;

-- sequential assignments, with slot and code
	decode: process(code,a,z,r_z,int_z,t,slot,sum,inten)
	begin
		t_sel<="0000"; 
		a_sel<="000";
		p_sel<="000";
		r_sel<="00";
		addr_sel<='0'; 
		spush<='0'; 
		spopp<='0';
		rpush<='0'; 
		rpopp<='0'; 
		tload<='0'; 
		aload<='0';
		pload<='0'; 
		rload<='0'; 
		write<='0'; 
		read<='0'; 
		iload<='0';
		reset<='0';
		intload<='0';
		intset<='0';
	if slot=0 then
		if (int_z='1' and inten='1') then
			pload<='1';
			p_sel<=int_p;--process interrupts
			rpush<='1'; 
			r_sel<=p_r;
			rload<='1';
			reset<='1';		
		else	iload<='1';
			p_sel<=p1_p;--fetch next word
			pload<='1';
			read<='1'; 
		end if;
    elsif slot=1 and i(width-1)='0' then
		pload<='1';
		p_sel<=i_p;--process call
		rpush<='1'; 
		r_sel<=p_r;
		rload<='1';
		reset<='1';
	else
	case code is
		when bra =>
			pload<='1';
			p_sel<=pi_p;
			reset<='1';
		when ret => pload<='1'; 
			p_sel<=r_p;
			rpopp<='1';
			r_sel<=rout_r;
			rload<='1';
			reset<='1';
			intset<='0';
			intload<='1';
		when bz => 
			if z='1' then
				pload<='1';
				p_sel<=pi_p;
			end if;
			tload<='1';
			t_sel<=s_t; 
			spopp<='1'; 
			reset<='1';
		when bc => 
			if t(width)='1' then
				pload<='1';
				p_sel<=pi_p;
			end if;
			tload<='1';
			t_sel<=s_t; 
			spopp<='1'; 
			reset<='1';
		when nxt => 
			if r_z='0' then
				p_sel<=pi_p;
				pload<='1';
				r_sel<=r1_r;
			else	
				r_sel<=rout_r;
				rpopp<='1';
			end if;
			rload<='1';
			reset<='1';
		when ei =>
			intset<='1';
			intload<='1';
		when ldp => addr_sel<=a_addr; 
			a_sel<=a1_a;
			aload<='1'; 
			tload<='1';
			t_sel<=data_t; 
			spush<='1'; 
			read<='1'; 
		when ldi => pload<='1'; 
			p_sel<=p1_p;
			tload<='1';
			t_sel<=data_t; 
			spush<='1'; 
			read<='1'; 
		when ld => addr_sel<=a_addr; 
			tload<='1';
			t_sel<=data_t; 
			spush<='1'; 
			read<='1'; 
		when stp => addr_sel<=a_addr; 
			aload<='1'; 
			a_sel<=a1_a;
			tload<='1';
			t_sel<=s_t; 
			spopp<='1'; 
			write<='1'; 
		when st => addr_sel<=a_addr; 
			tload<='1';
			t_sel<=s_t; 
			spopp<='1'; 
			write<='1'; 
		when rr8 => 
			tload<='1';
			t_sel<=rr8_t; 
		when com => 
			tload<='1';
			t_sel<=not_t; 
		when shl => 
			tload<='1';
			t_sel<=shl_t; 
		when shr => 
			tload<='1';
			t_sel<=shr_t; 
		when mul => 
			aload<='1';
			tload<='1';
			if a(0)='1' then
				t_sel<=shr_sum;
				a_sel<=shr_sum_a;
			else	t_sel<=shr_t_t;
				a_sel<=shr_t_a;
			end if;
		when xorr => 
			tload<='1';
			t_sel<=s_xor_t; 
			spopp<='1';
		when andd => 
			tload<='1';
			t_sel<=s_and_t; 
			spopp<='1';
		when div => 
			aload<='1';
			tload<='1';
			a_sel<=shl_sum_a;
			if sum(width)='1' then
				t_sel<=shl_sum_a_t;
			else	t_sel<=shl_t_a_t;
			end if;
		when addd => 
			tload<='1';
			t_sel<=sum_t; 
			spopp<='1';
		when popr => 
			tload<='1';
			t_sel<=r_t; 
			spush<='1';
			r_sel<=rout_r;
			rload<='1';
			rpopp<='1';
		when lda => 
			tload<='1';
			t_sel<=a_t; 
			spush<='1';
		when dup => 
			spush<='1';
		when over => 
			spush<='1';
			tload<='1';
			t_sel<=s_t;
		when pushr => 
			tload<='1';
			t_sel<=s_t; 
			rpush<='1';
			r_sel<=t_r;
			rload<='1';
			spopp<='1';
		when sta => 
			tload<='1';
			t_sel<=s_t; 
			a_sel<=t_a;
			aload<='1'; 
			spopp<='1';
		when nop => reset<='1';
		when drop => 
			tload<='1';
			t_sel<=s_t; 
			spopp<='1';
		when others => null;
	end case;
	end if;
	end process decode;

-- finite state machine, processor control unit	
	sync: process(clk,clr)
	begin
		if clr='1' then -- master reset
			inten <='0';
			slot <= 0;
			sp  <= "00000";
			sp1 <= "00001";
			rp  <= "00000";
			rp1 <= "00001";
			t <= (others => '0');
			r <= (others => '0');			
			a <= (others => '0');
			p <= (others => '0');
			i <= (others => '0');
			for ii in s_stack'range loop
				s_stack(ii) <= (others => '0');
				r_stack(ii) <= (others => '0');
			end loop;
		elsif (clk'event and clk='1') then
			if reset='1' or slot=3 then
				slot <= 0;
			else	slot <= slot+1;
			end if;
			if intload='1' then
				inten <= intset;
			end if;
			if iload='1' then
				i <= data_i(width-1 downto 0);
			end if;
			if pload='1' then
				p <= p_in;
			end if;
			if tload='1' then
				t <= t_in;
			end if;
			if rload='1' then
				r <= r_in;
			end if;
			if aload='1' then
				a <= a_in;
			end if;
			if spush='1' then
				s_stack(conv_integer(sp1)) <= t;
				sp <= sp+1;
				sp1 <= sp1+1;
			elsif spopp='1' then
				sp <= sp-1;
				sp1 <= sp1-1;
			end if;
			if rpush='1' then
				r_stack(conv_integer(rp1)) <= r;
				rp <= rp+1;
				rp1 <= rp1+1;
			elsif rpopp='1' then
				rp <= rp-1;
				rp1 <= rp1-1;
			end if;
		end if;
	end process sync;

end behavioral;
