library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

--___________________________________________________________________________________________________________________________________________________
-- SEGMON has some pretty tight code - it was work of three true artists
-- CEG is the last initial of the three original developers
-- George Chkiantz, Richard Elen and George Graves
-- MON is monitor
-- CEGMON manual is at: http://uk101.sourceforge.net/docs/pdf/cegmon.pdf
-- Disassembled source with some labels is at: 
--	https://github.com/douggilliland/MultiComp/blob/master/MultiComp_On_Cyclone%20IV%20VGA%20Card/UK101_16K_64x32_Video/Components/ROMs/cegmon.s
--___________________________________________________________________________________________________________________________________________________
-- The story of the original SEGMON development is recorded at: http://weblog.tetradian.com/2014/03/16/cegmon-a-blast-from-the-past/
-- Click on the link on George's page to donate a couple of British pounds if you've gotten something out of his code
-- One of the three original authors of CEGMON, Tom G (the G from ceGmon) gave me the following pointers to the code
-- Three points:
--	The boot-loader for the disk occupies its own 256-byte block of the ROM, and is not 6502-code – hence complete gibberish to a 6502-disassembler. 
--		I said above that it was at #0700-07FF, but it’s more likely to have been at #0300-03FF (i.e. last block of the original 1kb ROM, not our extended 2kb EPROM).
-- 	Other than the boot-loader, and that #434547 ‘CEG’ signature-string’, everything else is real code. 
--		(Okay, I guess there must be a handful of text-strings, for the code-monitor etc, but you’d be able to work those out from the manual?) 
--		The overall functionality should be clear enough from the manual or the initial screen, I’d hope, 
--		so that should give some pointers as to how and where to start the structure-logic for the disassembly.
--	A useful trick to remember is that those OSI machines made hefty use of the very first few bytes of usable RAM. 
--		The 6502 reserves #0000-00FF for its own use (‘page-zero’ opcodes), and there was something special about #0100-01FF that I now can’t remember. 
--		So we had to use later in the RAM for our own registers, hence there were a lot of references in CEGMON to the #0200-023F range, 
--		where we stored pointers to things like current window-origin, width and depth (for the simple windowing system), 
--		and the current positions of the two cursors (pointer/copy-from cursor and copy-to cursor). 
--		If you look in the disassembly for single-bytes or more often byte-pairs in that range, 
--		you should be able to work out what each of those registers does from there. (
--		The screen-space is directly-addressable memory, as I remember, so those two cursor would have to point to there, for example.) 
--		Also, if I remember correctly, the first code-instructions at #0200 were a jump to the start of the first user-code, 
--		so one thing that the boot-prom would have to do is set up that jump.
--___________________________________________________________________________________________________________________________________________________
-- CEGMON dissassembled code is at: https://github.com/jefftranter/6502/blob/master/asm/OSI/cegmon.s
-- Grant's mods to this code is at: http://searle.hostei.com/grant/uk101FPGA/index.html#Modification3
-- Grant already patched some of the values to support 48x16 lines which is why they are different the the CEGMON defaults (noted below)
--	cpuDataIn <=
    -- CEGMON PATCH FOR 64x32 SCREEN
--    x"3F" when cpuAddress = x"FBBC" else -- CEGMON SWIDTH (was $47) - This doesn't match the original code below which had x"2F" (48 chars - 1)
--    x"00" when cpuAddress = x"FBBD" else -- CEGMON TOP L (was $0C (1st line) or $8C (3rd line))
--    x"BF" when cpuAddress = x"FBBF" else -- CEGMON BASE L (was $CC)
--    x"D7" when cpuAddress = x"FBC0" else -- CEGMON BASE H (was $D3)
--    x"00" when cpuAddress = x"FBC2" else -- CEGMON STARTUP TOP L (was $0C (1st line) or $8C (3rd line))
--    x"00" when cpuAddress = x"FBC5" else -- CEGMON STARTUP TOP L (was $0C (1st line) or $8C (3rd line))
--    x"00" when cpuAddress = x"FBCB" else -- CEGMON STARTUP TOP L (was $0C (1st line) or $8C (3rd line))
--    x"10" when cpuAddress = x"FE62" else -- CEGMON CLR SCREEN SIZE (was $08) - doesn't match the original code below which had x"04"
--    x"D8" when cpuAddress = x"FB8B" else -- CEGMON SCREEN BOTTOM H (was $D4) - Part of CTRL-F code
--    x"D7" when cpuAddress = x"FE3B" else -- CEGMON SCREEN BOTTOM H - 1 (was $D3) - Part of CTRL-A code

ENTITY CegmonRom IS

	PORT
	(
		address : in std_logic_vector(10 downto 0);
		q : out std_logic_vector(7 downto 0)
	);
END CegmonRom;

architecture behavior of CegmonRom is
type romtable is array (0 to 2047) of std_logic_vector(7 downto 0);
constant romdata : romtable :=
(
x"A5",x"0E",x"F0",x"06",x"C6",x"0E",x"F0",x"02",x"C6",x"0E",x"A9",x"20",x"8D",x"01",x"02",x"20",x"8F",x"FF",x"10",x"19",x"38",x"AD",x"2B",x"02",x"E9",x"40",x"8D",x"2B",x"02",x"AD",x"2C",x"02",	-- F800
x"E9",x"00",x"8D",x"2C",x"02",x"20",x"CF",x"FB",x"B0",x"03",x"20",x"D1",x"FF",x"8E",x"00",x"02",x"20",x"88",x"FF",x"4C",x"D2",x"F8",x"8D",x"02",x"02",x"48",x"8A",x"48",x"98",x"48",x"AD",x"02",	-- F820
x"02",x"D0",x"03",x"4C",x"D2",x"F8",x"AC",x"06",x"02",x"F0",x"03",x"20",x"E1",x"FC",x"C9",x"5F",x"F0",x"AE",x"C9",x"0C",x"D0",x"0B",x"20",x"8C",x"FF",x"20",x"D1",x"FF",x"8E",x"00",x"02",x"F0",	-- F840
x"6E",x"C9",x"0A",x"F0",x"27",x"C9",x"1E",x"F0",x"77",x"C9",x"0B",x"F0",x"10",x"C9",x"1A",x"F0",x"67",x"C9",x"0D",x"D0",x"05",x"20",x"6D",x"FF",x"D0",x"58",x"8D",x"01",x"02",x"20",x"8C",x"FF",	-- F860
x"EE",x"00",x"02",x"E8",x"EC",x"22",x"02",x"30",x"46",x"20",x"70",x"FF",x"20",x"8C",x"FF",x"A0",x"02",x"20",x"D2",x"FB",x"B0",x"08",x"A2",x"03",x"20",x"EE",x"FD",x"4C",x"CF",x"F8",x"20",x"28",	-- F880
x"FE",x"20",x"D1",x"FF",x"20",x"EE",x"FD",x"AE",x"22",x"02",x"20",x"27",x"02",x"10",x"FB",x"E8",x"20",x"EE",x"FD",x"A2",x"03",x"20",x"EE",x"FD",x"20",x"CF",x"FB",x"90",x"ED",x"A9",x"20",x"20",	-- F8A0
x"2A",x"02",x"10",x"FB",x"A2",x"01",x"BD",x"23",x"02",x"9D",x"28",x"02",x"CA",x"10",x"F7",x"20",x"75",x"FF",x"68",x"A8",x"68",x"AA",x"68",x"60",x"20",x"59",x"FE",x"8D",x"01",x"02",x"F0",x"24",	-- F8C0
x"A9",x"20",x"20",x"8F",x"FF",x"20",x"D1",x"FF",x"AE",x"22",x"02",x"A9",x"20",x"20",x"2A",x"02",x"10",x"FB",x"8D",x"01",x"02",x"A0",x"02",x"20",x"D2",x"FB",x"B0",x"08",x"A2",x"03",x"20",x"EE",	-- F8E0
x"FD",x"4C",x"E8",x"F8",x"20",x"D1",x"FF",x"8E",x"00",x"02",x"F0",x"C6",x"20",x"A6",x"F9",x"20",x"F5",x"FB",x"20",x"B6",x"FE",x"20",x"E6",x"FB",x"20",x"E0",x"FB",x"A2",x"08",x"86",x"FD",x"20",	-- F900
x"E6",x"FB",x"20",x"F0",x"FE",x"20",x"EB",x"FB",x"B0",x"51",x"20",x"F9",x"FE",x"C6",x"FD",x"D0",x"EE",x"F0",x"DC",x"20",x"BD",x"FF",x"20",x"E4",x"FD",x"B0",x"43",x"A6",x"E4",x"9A",x"A5",x"E6",	-- F920
x"48",x"A5",x"E5",x"48",x"A5",x"E3",x"48",x"A5",x"E0",x"A6",x"E1",x"A4",x"E2",x"40",x"A2",x"03",x"BD",x"4B",x"FA",x"9D",x"BF",x"01",x"CA",x"D0",x"F7",x"20",x"8D",x"FE",x"20",x"B5",x"F9",x"B1",	-- F940
x"FE",x"85",x"E7",x"98",x"91",x"FE",x"F0",x"16",x"4C",x"7E",x"FA",x"C6",x"FB",x"D0",x"79",x"F0",x"9B",x"60",x"A5",x"FB",x"D0",x"FB",x"A9",x"3F",x"20",x"EE",x"FF",x"A2",x"28",x"9A",x"20",x"F5",	-- F960
x"FB",x"A0",x"00",x"84",x"FB",x"20",x"E0",x"FB",x"20",x"8D",x"FE",x"C9",x"4D",x"F0",x"A4",x"C9",x"52",x"F0",x"A8",x"C9",x"5A",x"F0",x"B7",x"C9",x"53",x"F0",x"CD",x"C9",x"4C",x"F0",x"CC",x"C9",	-- F980
x"55",x"D0",x"33",x"6C",x"33",x"02",x"20",x"8D",x"FE",x"20",x"B5",x"F9",x"20",x"E3",x"FB",x"A2",x"00",x"20",x"8D",x"FE",x"2C",x"A2",x"05",x"20",x"C0",x"F9",x"20",x"8D",x"FE",x"2C",x"A2",x"03",	-- F9A0
x"20",x"C6",x"F9",x"20",x"8D",x"FE",x"C9",x"2E",x"F0",x"BE",x"C9",x"2F",x"F0",x"1A",x"20",x"93",x"FE",x"30",x"9F",x"4C",x"DA",x"FE",x"C9",x"54",x"F0",x"95",x"20",x"B5",x"F9",x"A9",x"2F",x"20",	-- F9C0
x"EE",x"FF",x"20",x"F0",x"FE",x"20",x"E6",x"FB",x"20",x"8D",x"FE",x"C9",x"47",x"D0",x"03",x"6C",x"FE",x"00",x"C9",x"2C",x"D0",x"06",x"20",x"F9",x"FE",x"4C",x"E8",x"F9",x"C9",x"0A",x"F0",x"16",	-- F9E0
x"C9",x"0D",x"F0",x"17",x"C9",x"5E",x"F0",x"19",x"C9",x"27",x"F0",x"2E",x"20",x"BE",x"F9",x"A5",x"FC",x"91",x"FE",x"4C",x"E8",x"F9",x"A9",x"0D",x"20",x"EE",x"FF",x"20",x"F9",x"FE",x"4C",x"31",	-- FA00
x"FA",x"38",x"A5",x"FE",x"E9",x"01",x"85",x"FE",x"A5",x"FF",x"E9",x"00",x"85",x"FF",x"20",x"F5",x"FB",x"20",x"B6",x"FE",x"4C",x"DD",x"F9",x"20",x"F7",x"FE",x"20",x"8D",x"FE",x"C9",x"27",x"D0",	-- FA20
x"05",x"20",x"E3",x"FB",x"D0",x"CD",x"C9",x"0D",x"F0",x"E4",x"D0",x"EB",x"4C",x"4F",x"FA",x"85",x"E0",x"68",x"48",x"29",x"10",x"D0",x"03",x"A5",x"E0",x"40",x"86",x"E1",x"84",x"E2",x"68",x"85",	-- FA40
x"E3",x"D8",x"38",x"68",x"E9",x"02",x"85",x"E5",x"68",x"E9",x"00",x"85",x"E6",x"BA",x"86",x"E4",x"A0",x"00",x"A5",x"E7",x"91",x"E5",x"A9",x"E0",x"85",x"FE",x"84",x"FF",x"D0",x"B0",x"20",x"BD",	-- FA60
x"FF",x"20",x"F7",x"FF",x"20",x"E9",x"FE",x"20",x"EE",x"FF",x"20",x"E3",x"FF",x"A9",x"2F",x"20",x"EE",x"FF",x"D0",x"03",x"20",x"F9",x"FE",x"20",x"F0",x"FE",x"A9",x"0D",x"20",x"B1",x"FC",x"20",	-- FA80
x"EB",x"FB",x"90",x"F0",x"A5",x"E4",x"A6",x"E5",x"85",x"FE",x"86",x"FF",x"20",x"E3",x"FF",x"A9",x"47",x"20",x"EE",x"FF",x"20",x"AC",x"FF",x"8C",x"05",x"02",x"4C",x"7E",x"F9",x"8A",x"48",x"98",	-- FAA0
x"48",x"AD",x"04",x"02",x"10",x"59",x"AC",x"2F",x"02",x"AD",x"31",x"02",x"85",x"E4",x"AD",x"32",x"02",x"85",x"E5",x"B1",x"E4",x"8D",x"30",x"02",x"A9",x"A1",x"91",x"E4",x"20",x"00",x"FD",x"AD",	-- FAC0
x"30",x"02",x"91",x"E4",x"AD",x"15",x"02",x"C9",x"11",x"F0",x"28",x"C9",x"01",x"F0",x"1E",x"C9",x"04",x"F0",x"14",x"C9",x"13",x"F0",x"0A",x"C9",x"06",x"D0",x"27",x"20",x"7C",x"FB",x"4C",x"C6",	-- FAE0
x"FA",x"20",x"28",x"FE",x"4C",x"C6",x"FA",x"20",x"6B",x"FB",x"4C",x"C6",x"FA",x"20",x"19",x"FE",x"4C",x"C6",x"FA",x"AD",x"30",x"02",x"8D",x"15",x"02",x"20",x"6B",x"FB",x"4C",x"43",x"FB",x"20",	-- FB00
x"00",x"FD",x"C9",x"05",x"D0",x"1D",x"AD",x"04",x"02",x"49",x"FF",x"8D",x"04",x"02",x"10",x"EF",x"AD",x"2B",x"02",x"8D",x"31",x"02",x"AD",x"2C",x"02",x"8D",x"32",x"02",x"A2",x"00",x"8E",x"2F",	-- FB20
x"02",x"F0",x"83",x"4C",x"D3",x"FD",x"2C",x"03",x"02",x"10",x"1D",x"A9",x"FD",x"8D",x"00",x"DF",x"A9",x"10",x"2C",x"00",x"DF",x"F0",x"0A",x"AD",x"00",x"F0",x"4A",x"90",x"EE",x"AD",x"01",x"F0",	-- FB40
x"60",x"A9",x"00",x"85",x"FB",x"8D",x"03",x"02",x"4C",x"BD",x"FA",x"AE",x"22",x"02",x"EC",x"2F",x"02",x"F0",x"04",x"EE",x"2F",x"02",x"60",x"A2",x"00",x"8E",x"2F",x"02",x"18",x"AD",x"31",x"02",	-- FB60
x"69",x"40",x"8D",x"31",x"02",x"AD",x"32",x"02",x"69",x"00",x"C9",x"D8",x"D0",x"02",x"A9",x"D0",x"8D",x"32",x"02",x"60",x"AD",x"12",x"02",x"D0",x"FA",x"A9",x"FE",x"8D",x"00",x"DF",x"2C",x"00",	-- FB80 (patched)
x"DF",x"70",x"F0",x"A9",x"FB",x"8D",x"00",x"DF",x"2C",x"00",x"DF",x"70",x"E6",x"A9",x"03",x"4C",x"36",x"A6",x"46",x"FB",x"9B",x"FF",x"94",x"FB",x"70",x"FE",x"7B",x"FE",x"3F",x"00",x"D0",x"BF",	-- FBA0 (patched)
x"D7",x"BD",x"00",x"D0",x"9D",x"00",x"D0",x"CA",x"60",x"00",x"20",x"00",x"D0",x"88",x"F9",x"AE",x"22",x"02",x"38",x"AD",x"2B",x"02",x"F9",x"23",x"02",x"AD",x"2C",x"02",x"F9",x"24",x"02",x"60",	-- FBC0 (patched)
x"A9",x"3E",x"2C",x"A9",x"2C",x"2C",x"A9",x"20",x"4C",x"EE",x"FF",x"38",x"A5",x"FE",x"E5",x"F9",x"A5",x"FF",x"E5",x"FA",x"60",x"A9",x"0D",x"20",x"EE",x"FF",x"A9",x"0A",x"4C",x"EE",x"FF",x"40",	-- FBE0
x"20",x"0C",x"FC",x"6C",x"FD",x"00",x"20",x"0C",x"FC",x"4C",x"00",x"FE",x"A0",x"00",x"8C",x"01",x"C0",x"8C",x"00",x"C0",x"A2",x"04",x"8E",x"01",x"C0",x"8C",x"03",x"C0",x"88",x"8C",x"02",x"C0",	-- FC00
x"8E",x"03",x"C0",x"8C",x"02",x"C0",x"A9",x"FB",x"D0",x"09",x"A9",x"02",x"2C",x"00",x"C0",x"F0",x"1C",x"A9",x"FF",x"8D",x"02",x"C0",x"20",x"A5",x"FC",x"29",x"F7",x"8D",x"02",x"C0",x"20",x"A5",	-- FC20
x"FC",x"09",x"08",x"8D",x"02",x"C0",x"A2",x"18",x"20",x"91",x"FC",x"F0",x"DD",x"A2",x"7F",x"8E",x"02",x"C0",x"20",x"91",x"FC",x"AD",x"00",x"C0",x"30",x"FB",x"AD",x"00",x"C0",x"10",x"FB",x"A9",	-- FC40
x"03",x"8D",x"10",x"C0",x"A9",x"58",x"8D",x"10",x"C0",x"20",x"9C",x"FC",x"85",x"FE",x"AA",x"20",x"9C",x"FC",x"85",x"FD",x"20",x"9C",x"FC",x"85",x"FF",x"A0",x"00",x"20",x"9C",x"FC",x"91",x"FD",	-- FC60
x"C8",x"D0",x"F8",x"E6",x"FE",x"C6",x"FF",x"D0",x"F2",x"86",x"FE",x"A9",x"FF",x"8D",x"02",x"C0",x"60",x"A0",x"F8",x"88",x"D0",x"FD",x"55",x"FF",x"CA",x"D0",x"F6",x"60",x"AD",x"10",x"C0",x"4A",	-- FC80
x"90",x"FA",x"AD",x"11",x"C0",x"60",x"A9",x"03",x"8D",x"00",x"F0",x"A9",x"11",x"8D",x"00",x"F0",x"60",x"48",x"AD",x"00",x"F0",x"4A",x"4A",x"90",x"F9",x"68",x"8D",x"01",x"F0",x"60",x"49",x"FF",	-- FCA0
x"8D",x"00",x"DF",x"49",x"FF",x"60",x"48",x"20",x"CF",x"FC",x"AA",x"68",x"CA",x"E8",x"60",x"AD",x"00",x"DF",x"49",x"FF",x"60",x"C9",x"5F",x"F0",x"03",x"4C",x"74",x"A3",x"4C",x"4B",x"A3",x"A0",	-- FCC0
x"10",x"A2",x"40",x"CA",x"D0",x"FD",x"88",x"D0",x"F8",x"60",x"43",x"45",x"47",x"4D",x"4F",x"4E",x"28",x"43",x"29",x"31",x"39",x"38",x"30",x"20",x"44",x"2F",x"43",x"2F",x"57",x"2F",x"4D",x"3F",	-- FCE0
x"8A",x"48",x"98",x"48",x"A9",x"80",x"20",x"BE",x"FC",x"20",x"C6",x"FC",x"D0",x"05",x"4A",x"D0",x"F5",x"F0",x"27",x"4A",x"90",x"09",x"8A",x"29",x"20",x"F0",x"1F",x"A9",x"1B",x"D0",x"31",x"20",	-- FD00
x"86",x"FE",x"98",x"8D",x"15",x"02",x"0A",x"0A",x"0A",x"38",x"ED",x"15",x"02",x"8D",x"15",x"02",x"8A",x"4A",x"0A",x"20",x"86",x"FE",x"F0",x"0F",x"A9",x"00",x"8D",x"16",x"02",x"8D",x"13",x"02",	-- FD20
x"A9",x"02",x"8D",x"14",x"02",x"D0",x"BD",x"18",x"98",x"6D",x"15",x"02",x"A8",x"B9",x"3B",x"FF",x"CD",x"13",x"02",x"D0",x"E8",x"CE",x"14",x"02",x"F0",x"05",x"20",x"DF",x"FC",x"F0",x"A5",x"A2",	-- FD40
x"64",x"CD",x"16",x"02",x"D0",x"02",x"A2",x"0F",x"8E",x"14",x"02",x"8D",x"16",x"02",x"C9",x"21",x"30",x"5E",x"C9",x"5F",x"F0",x"5A",x"A9",x"01",x"20",x"BE",x"FC",x"20",x"CF",x"FC",x"8D",x"15",	-- FD60
x"02",x"29",x"01",x"AA",x"AD",x"15",x"02",x"29",x"06",x"D0",x"17",x"2C",x"13",x"02",x"50",x"2B",x"8A",x"49",x"01",x"29",x"01",x"F0",x"24",x"A9",x"20",x"2C",x"15",x"02",x"50",x"25",x"A9",x"C0",	-- FD80
x"D0",x"21",x"2C",x"13",x"02",x"50",x"03",x"8A",x"F0",x"11",x"AC",x"13",x"02",x"C0",x"31",x"90",x"08",x"C0",x"3C",x"B0",x"04",x"A9",x"F0",x"D0",x"02",x"A9",x"10",x"2C",x"15",x"02",x"50",x"03",	-- FDA0
x"18",x"69",x"C0",x"18",x"6D",x"13",x"02",x"29",x"7F",x"2C",x"15",x"02",x"10",x"02",x"09",x"80",x"8D",x"15",x"02",x"68",x"A8",x"68",x"AA",x"AD",x"15",x"02",x"60",x"20",x"F9",x"FE",x"E6",x"E4",	-- FDC0
x"D0",x"02",x"E6",x"E5",x"B1",x"FE",x"91",x"E4",x"20",x"EB",x"FB",x"90",x"EE",x"60",x"18",x"A9",x"40",x"7D",x"28",x"02",x"9D",x"28",x"02",x"A9",x"00",x"7D",x"29",x"02",x"9D",x"29",x"02",x"60",	-- FDE0
x"A2",x"28",x"9A",x"D8",x"20",x"A6",x"FC",x"20",x"40",x"FE",x"EA",x"EA",x"20",x"59",x"FE",x"8D",x"01",x"02",x"84",x"FE",x"84",x"FF",x"4C",x"7E",x"F9",x"AE",x"2F",x"02",x"F0",x"04",x"CE",x"2F",	-- FE00
x"02",x"60",x"AE",x"22",x"02",x"8E",x"2F",x"02",x"38",x"AD",x"31",x"02",x"E9",x"40",x"8D",x"31",x"02",x"AD",x"32",x"02",x"E9",x"00",x"C9",x"CF",x"D0",x"02",x"A9",x"D7",x"8D",x"32",x"02",x"60",	-- FE20 (patched)
x"A0",x"1C",x"B9",x"B2",x"FB",x"99",x"18",x"02",x"88",x"10",x"F7",x"A0",x"07",x"A9",x"00",x"8D",x"12",x"02",x"99",x"FF",x"01",x"88",x"D0",x"FA",x"60",x"A0",x"00",x"84",x"F9",x"A9",x"D0",x"85",	-- FE40
x"FA",x"A2",x"10",x"A9",x"20",x"91",x"F9",x"C8",x"D0",x"FB",x"E6",x"FA",x"CA",x"D0",x"F6",x"60",x"48",x"CE",x"03",x"02",x"A9",x"00",x"8D",x"05",x"02",x"68",x"60",x"48",x"A9",x"01",x"D0",x"F6",	-- FE60 (patched)
x"20",x"57",x"FB",x"29",x"7F",x"60",x"A0",x"08",x"88",x"0A",x"90",x"FC",x"60",x"20",x"E9",x"FE",x"4C",x"EE",x"FF",x"C9",x"30",x"30",x"12",x"C9",x"3A",x"30",x"0B",x"C9",x"41",x"30",x"0A",x"C9",	-- FE80
x"47",x"10",x"06",x"38",x"E9",x"07",x"29",x"0F",x"60",x"A9",x"80",x"60",x"20",x"B6",x"FE",x"EA",x"EA",x"20",x"E6",x"FB",x"D0",x"07",x"A2",x"03",x"20",x"BF",x"FE",x"CA",x"2C",x"A2",x"00",x"B5",	-- FEA0
x"FC",x"4A",x"4A",x"4A",x"4A",x"20",x"CA",x"FE",x"B5",x"FC",x"29",x"0F",x"09",x"30",x"C9",x"3A",x"30",x"03",x"18",x"69",x"07",x"4C",x"EE",x"FF",x"EA",x"EA",x"A0",x"04",x"0A",x"0A",x"0A",x"0A",	-- FEC0
x"2A",x"36",x"F9",x"36",x"FA",x"88",x"D0",x"F8",x"60",x"A5",x"FB",x"D0",x"93",x"4C",x"00",x"FD",x"B1",x"FE",x"85",x"FC",x"4C",x"BD",x"FE",x"91",x"FE",x"E6",x"FE",x"D0",x"02",x"E6",x"FF",x"60",	-- FEE0
x"D8",x"A2",x"28",x"9A",x"20",x"A6",x"FC",x"20",x"40",x"FE",x"20",x"59",x"FE",x"8C",x"00",x"02",x"B9",x"EA",x"FC",x"20",x"EE",x"FF",x"C8",x"C0",x"16",x"D0",x"F5",x"20",x"EB",x"FF",x"29",x"DF",	-- FF00
x"C9",x"44",x"D0",x"03",x"4C",x"00",x"FC",x"C9",x"4D",x"D0",x"03",x"4C",x"00",x"FE",x"C9",x"57",x"D0",x"03",x"4C",x"00",x"00",x"C9",x"43",x"D0",x"C7",x"4C",x"11",x"BD",x"50",x"3B",x"2F",x"20",	-- FF20
x"5A",x"41",x"51",x"2C",x"4D",x"4E",x"42",x"56",x"43",x"58",x"4B",x"4A",x"48",x"47",x"46",x"44",x"53",x"49",x"55",x"59",x"54",x"52",x"45",x"57",x"00",x"00",x"0D",x"0A",x"4F",x"4C",x"2E",x"00",	-- FF40
x"5F",x"2D",x"3A",x"30",x"39",x"38",x"37",x"36",x"35",x"34",x"33",x"32",x"31",x"20",x"8C",x"FF",x"A2",x"00",x"8E",x"00",x"02",x"AE",x"00",x"02",x"A9",x"BD",x"8D",x"2A",x"02",x"20",x"2A",x"02",	-- FF60
x"8D",x"01",x"02",x"A9",x"9D",x"8D",x"2A",x"02",x"A9",x"5F",x"D0",x"03",x"AD",x"01",x"02",x"AE",x"00",x"02",x"4C",x"2A",x"02",x"20",x"2D",x"BF",x"4C",x"9E",x"FF",x"20",x"36",x"F8",x"48",x"AD",	-- FF80
x"05",x"02",x"F0",x"17",x"68",x"20",x"B1",x"FC",x"C9",x"0D",x"D0",x"10",x"48",x"8A",x"48",x"A2",x"0A",x"A9",x"00",x"20",x"B1",x"FC",x"CA",x"D0",x"FA",x"68",x"AA",x"68",x"60",x"20",x"A6",x"F9",	-- FFA0
x"20",x"E0",x"FB",x"A2",x"03",x"20",x"B1",x"F9",x"A5",x"FC",x"A6",x"FD",x"85",x"E4",x"86",x"E5",x"60",x"A2",x"02",x"BD",x"22",x"02",x"9D",x"27",x"02",x"9D",x"2A",x"02",x"CA",x"D0",x"F4",x"60",	-- FFC0
x"CC",x"2F",x"00",x"A9",x"2E",x"20",x"EE",x"FF",x"4C",x"B6",x"FE",x"6C",x"18",x"02",x"6C",x"1A",x"02",x"6C",x"1C",x"02",x"6C",x"1E",x"02",x"6C",x"20",x"02",x"30",x"01",x"00",x"FF",x"C0",x"01"		-- FFE0
);
begin
process (address)
begin
q <= romdata (to_integer(unsigned(address)));
end process;
end behavior;

