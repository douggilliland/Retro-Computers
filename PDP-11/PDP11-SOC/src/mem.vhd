
--=================================================================
-- MEM.VHD  ::  8Kx16 RAM model loaded with Hex Format 
--
-- (c) Scott L. Baker, Sierra Circuit Design
--=================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;
use std.textio.all;


entity RAM is
    port(
        RADDR     : in    std_logic_vector(12 downto 0);
        WADDR     : in    std_logic_vector(12 downto 0);
        DATA_IN   : in    std_logic_vector(15 downto 0);
        DATA_OUT  : out   std_logic_vector(15 downto 0);
        BYTEOP    : in    std_logic; -- byte operation
        REN       : in    std_logic; -- read  enable
        WEN       : in    std_logic; -- write enable
        WCLK      : in    std_logic;
        RCLK      : in    std_logic
    );

end RAM;


architecture BEHAVIORAL of RAM is

    type Memtype is array (integer range 0 to 16383) of std_logic_vector(7 downto 0);

    file     progfile     : TEXT OPEN read_mode is "mem.hex";
    signal   Rd_Addr      : integer range 16383 downto 0;
    signal   Wr_Addr      : integer range 16383 downto 0;
    signal   Initialized  : boolean := FALSE; 

    --==========================================
    -- character to integer conversion function
    --==========================================
    function char_to_int(ch : character ) return integer is
         variable result  : integer := 0;
    begin
         case ch is
             when '0'    => result := 0;
             when '1'    => result := 1;
             when '2'    => result := 2;
             when '3'    => result := 3;
             when '4'    => result := 4;
             when '5'    => result := 5;
             when '6'    => result := 6;
             when '7'    => result := 7;
             when '8'    => result := 8;
             when '9'    => result := 9;
             when 'a'    => result := 10;
             when 'b'    => result := 11;
             when 'c'    => result := 12;
             when 'd'    => result := 13;
             when 'e'    => result := 14;
             when 'f'    => result := 15;
             when 'A'    => result := 10;
             when 'B'    => result := 11;
             when 'C'    => result := 12;
             when 'D'    => result := 13;
             when 'E'    => result := 14;
             when 'F'    => result := 15;
             when others => result := 0;
         end case;
         return result;
    end function char_to_int;


begin

    Rd_Addr <= conv_integer(RADDR(12 downto 1) & '0');
    Wr_Addr <= conv_integer(WADDR(12 downto 1) & '0');

    --==========================================
    -- Configurable Memory Model
    --==========================================   
    MEMORY:
    process (DATA_IN, Rd_Addr, Wr_Addr, RCLK, WCLK)
    
        variable DATA         : Memtype;
        variable L            : line;
        variable ch           : character;
        variable rec_type     : character;
        variable digit        : integer;
        variable byte         : integer;
        variable byte_no      : integer;
        variable num_bytes    : integer;
        variable address      : integer;
        variable offset       : integer;
        variable end_of_data  : boolean;
        variable line_num     : integer;
      
    begin

        -- Init from file
        if not Initialized then

            Initialized <= TRUE;
            line_num    := 0;
            offset      := 0;
            end_of_data := FALSE;

            while not (endfile(progfile) or end_of_data) loop
                -- Reset the variables for the line
                address := 0;
                line_num := line_num + 1;
                readline(progfile, L);

                -- Read in the : character
                read(L, ch);
                if ch /= ':' then
                    next;  -- get the next character
                end if;
 
                -- Read in the number of bytes
                read(L, ch);  -- msb
                digit := char_to_int(ch);
                read(L, ch);  -- lsb
                num_bytes := digit*16 + char_to_int(ch);
 
                -- Read in the address
                for k in 3 downto 0 loop
                    read(L, ch);
                    digit := char_to_int(ch);
                    address := address + digit * 16**k;
                end loop;

                -- Read in the record type
                read(L,ch);
                ASSERT ch = '0'
                    REPORT "Illegal record on line " & INTEGER'IMAGE(line_num);
                read(L,rec_type);
 
                -- If it is a line of all zeros, then it is the end of data.
                if (num_bytes = 0) and (address = 0) then
                    end_of_data := TRUE;

                -- If it is normal data, then read in all of the bytes to program_mem
                elsif rec_type = '0' then  -- it has normal data
                    byte_no := 0;
                    for byte_no in 0 to num_bytes-1 loop
                         read(L,ch);
                         digit := char_to_int(ch);
                         read(L,ch);
                         byte := digit*16 + char_to_int(ch);
                         DATA(offset + address + byte_no) := conv_std_logic_vector(byte, 8);
--                       REPORT "writing data " & INTEGER'IMAGE(byte) & " to address " &
--                               INTEGER'IMAGE(offset + address + byte_no);
                    end loop;

                -- If it is an end of file record, then set end_of_data true
                elsif rec_type = '1' then -- it is an end of file record
                    end_of_data := true;

                -- If is an address-offset record update offset
                elsif rec_type = '2' then
                    offset := 0;
                    for k in 3 downto 0 loop
                        read(l, ch);
                        digit := char_to_int(ch);
                        offset := offset + digit*16**k;
                    end loop;
                    offset := offset *16;
                end if;

            end loop;

        else

            -- Synchronous Read
            if (RCLK = '1' and RCLK'event) then
                if (REN = '1') then
                    DATA_OUT <= DATA(Rd_Addr+1) & DATA(Rd_Addr);
                end if;
            end if;

            -- Synchronous Write
            if (WCLK = '1' and WCLK'event) then
                if (WEN = '1') then
                    if (BYTEOP = '1') then
                        if (WADDR(0) = '1') then
                            DATA(Wr_Addr+1) := DATA_IN(15 downto 8);
                        else
                            DATA(Wr_Addr)   := DATA_IN( 7 downto 0);
                        end if;
                    else
                        DATA(Wr_Addr+1) := DATA_IN(15 downto 8);
                        DATA(Wr_Addr)   := DATA_IN( 7 downto 0);
                    end if;
                end if;
            end if;

        end if;
    
     end process;
 
end BEHAVIORAL;

