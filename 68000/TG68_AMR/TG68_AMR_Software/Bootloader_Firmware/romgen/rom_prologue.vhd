library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soc_firmware is
generic
	(
		maxAddrBitBRAM : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(maxAddrBitBRAM downto 0);
	q : out std_logic_vector(15 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(15 downto 0) := X"0000";
	we_n : in std_logic := '1';
	uds_n : in std_logic := '1';
	lds_n : in std_logic := '1'
);
end soc_firmware;

architecture arch of soc_firmware is

type ram_type is array(natural range 0 to (2**(maxAddrBitBRAM+1)-1)) of std_logic_vector(7 downto 0);

shared variable ram : ram_type :=
(
