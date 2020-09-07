library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.DMACache_Config.all;


package DMACache_pkg is
	constant DMACache_MaxCacheBit : integer :=5;

	type DMAChannel_FromHost is record
		addr : std_logic_vector(31 downto 0);
		setaddr : std_logic;
		reqlen : unsigned(15 downto 0);
		setreqlen : std_logic;
		req : std_logic;
	end record;

	type DMAChannel_ToHost is record
		valid : std_logic;
	end record;

	type DMAChannels_FromHost is array (DMACache_MaxChannel downto 0) of DMAChannel_FromHost;
	type DMAChannels_ToHost is array (DMACache_MaxChannel downto 0) of DMAChannel_ToHost;

end package;
