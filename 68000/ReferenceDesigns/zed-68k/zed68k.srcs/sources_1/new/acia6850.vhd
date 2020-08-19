--===========================================================================-- 
--                                                                           -- 
--                  Synthesizable 6850 compatible ACIA                       -- 
--                                                                           -- 
--===========================================================================-- 
-- 
--  File name      : acia6850.vhd 
-- 
--  Entity name    : acia6850 
-- 
--  Purpose        : Implements a RS232 6850 compatible 
--                   Asynchronous Communications Interface Adapter (ACIA) 
-- 
--  Dependencies   : ieee.std_logic_1164 
--                   ieee.numeric_std 
--                   ieee.std_logic_unsigned 
-- 
--  Author         : John E. Kent 
-- 
--  Email          : dilbert57 at the domain opencores.org 
-- 
--  Web            : http://opencores.org/project,system09 
-- 
--  Origins        : miniUART written by Ovidiu Lupas olupas at the domain opencores.org 
-- 
--  Registers      : 
-- 
--  IO address + 0 Read - Status Register 
-- 
--     Bit[7] - Interrupt Request Flag 
--     Bit[6] - Receive Parity Error (parity bit does not match) 
--     Bit[5] - Receive Overrun Error (new character received before last read) 
--     Bit[4] - Receive Framing Error (bad stop bit) 
--     Bit[3] - Clear To Send level 
--     Bit[2] - Data Carrier Detect (lost modem carrier) 
--     Bit[1] - Transmit Buffer Empty (ready to accept next transmit character) 
--     Bit[0] - Receive Data Ready (character received) 
-- 
--  IO address + 0 Write - Control Register 
-- 
--     Bit[7]     - Rx Interupt Enable 
--          0     - disabled 
--          1     - enabled 
--     Bits[6..5] - Transmit Control 
--        0 0     - TX interrupt disabled, RTS asserted 
--        0 1     - TX interrupt enabled,  RTS asserted 
--        1 0     - TX interrupt disabled, RTS cleared 
--        1 1     - TX interrupt disabled, RTS asserted, Send Break 
--     Bits[4..2] - Word Control 
--      0 0 0     - 7 data, even parity, 2 stop 
--      0 0 1     - 7 data, odd  parity, 2 stop 
--      0 1 0     - 7 data, even parity, 1 stop 
--      0 1 1     - 7 data, odd  parity, 1 stop 
--      1 0 0     - 8 data, no   parity, 2 stop 
--      1 0 1     - 8 data, no   parity, 1 stop 
--      1 1 0     - 8 data, even parity, 1 stop 
--      1 1 1     - 8 data, odd  parity, 1 stop 
--     Bits[1..0] - Baud Control 
--        0 0     - Baud Clk divide by 1 
--        0 1     - Baud Clk divide by 16 
--        1 0     - Baud Clk divide by 64 
--        1 1     - Reset 
-- 
--  IO address + 1 Read - Receive Data Register 
-- 
--     Read when Receive Data Ready bit set 
--     Read resets Receive Data Ready bit 
-- 
--  IO address + 1 Write - Transmit Data Register 
-- 
--     Write when Transmit Buffer Empty bit set 
--     Write resets Transmit Buffer Empty Bit 
-- 
-- 
--  Copyright (C) 2002 - 2010 John Kent 
-- 
--  This program is free software: you can redistribute it and/or modify 
--  it under the terms of the GNU General Public License as published by 
--  the Free Software Foundation, either version 3 of the License, or 
--  (at your option) any later version. 
-- 
--  This program is distributed in the hope that it will be useful, 
--  but WITHOUT ANY WARRANTY; without even the implied warranty of 
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
--  GNU General Public License for more details. 
-- 
--  You should have received a copy of the GNU General Public License 
--  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
-- 
--===========================================================================-- 
--                                                                           -- 
--                              Revision  History                            -- 
--                                                                           -- 
--===========================================================================-- 
-- 
-- Version Author        Date         Changes 
-- 
-- 0.1     Ovidiu Lupas  2000-01-15   New model 
-- 1.0     Ovidiu Lupas  2000-01      Synthesis optimizations 
-- 2.0     Ovidiu Lupas  2000-04      Bugs removed - the RSBusCtrl did not 
--                                    process all possible situations 
-- 
-- 3.0     John Kent     2002-10      Changed Status bits to match MC6805 
--                                    Added CTS, RTS, Baud rate control & Software Reset 
-- 3.1     John Kent     2003-01-05   Added Word Format control a'la mc6850 
-- 3.2     John Kent     2003-07-19   Latched Data input to UART 
-- 3.3     John Kent     2004-01-16   Integrated clkunit in rxunit & txunit 
--                                    TX / RX Baud Clock now external 
--                                    also supports x1 clock and DCD. 
-- 3.4     John Kent     2005-09-13   Removed LoadCS signal. 
--                                    Fixed ReadCS and Read 
--                                    in miniuart_DCD_Init process 
-- 3.5     John Kent     2006-11-28   Cleaned up code. 
-- 
-- 4.0     John Kent     2007-02-03   Renamed ACIA6850 
-- 4.1     John Kent     2007-02-06   Made software reset synchronous 
-- 4.2     John Kent     2007-02-25   Changed sensitivity lists 
--                                    Rearranged Reset process. 
-- 4.3     John Kent     2010-06-17   Updated header 
-- 4.4     John Kent     2010-08-27   Combined with ACIA_RX & ACIA_TX 
--                                    Renamed to acia6850 
-- 
 
library ieee; 
  use ieee.std_logic_1164.all; 
  use ieee.numeric_std.all; 
  use ieee.std_logic_unsigned.all; 
--library unisim; 
--  use unisim.vcomponents.all; 
 
----------------------------------------------------------------------- 
-- Entity for ACIA_6850                                              -- 
----------------------------------------------------------------------- 
 
--* @brief Synthesizable 6850 compatible ACIA 
--* 
--* @author John E. Kent 
--* @version 4.4 from 2010-08-27 
 
entity acia6850 is 
  port ( 
    -- 
    -- CPU Interface signals 
    -- 
    clk      : in  std_logic;                     -- System Clock 
    rst      : in  std_logic;                     -- Reset input (active high) 
    cs       : in  std_logic;                     -- miniUART Chip Select 
    addr     : in  std_logic;                     -- Register Select 
    rw       : in  std_logic;                     -- Read / Not Write 
    data_in  : in  std_logic_vector(7 downto 0);  -- Data Bus In 
    data_out : out std_logic_vector(7 downto 0);  -- Data Bus Out 
    irq      : out std_logic;                     -- Interrupt Request out 
    -- 
    -- RS232 Interface Signals 
    -- 
    RxC   : in  std_logic;              -- Receive Baud Clock 
    TxC   : in  std_logic;              -- Transmit Baud Clock 
    RxD   : in  std_logic;              -- Receive Data 
    TxD   : out std_logic;              -- Transmit Data 
    DCD_n : in  std_logic;              -- Data Carrier Detect 
    CTS_n : in  std_logic;              -- Clear To Send 
    RTS_n : out std_logic               -- Request To send 
    ); 
end acia6850;  --================== End of entity ==============================-- 
 
------------------------------------------------------------------------------- 
-- Architecture for ACIA_6850 Interface registees 
------------------------------------------------------------------------------- 
 
--*   Implements a RS232 6850 compatible 
--*                   Asynchronous Communications Interface Adapter (ACIA). 
--* 
--* @author John E. Kent 
--* @version 4.4 from 2010-08-27 
 
architecture rtl of acia6850 is 
 
  type DCD_State_Type is (DCD_State_Idle, DCD_State_Int, DCD_State_Reset); 
 
  ----------------------------------------------------------------------------- 
  -- Signals 
  ----------------------------------------------------------------------------- 
  -- 
  -- Reset signals 
  -- 
  signal ac_rst   : std_logic;          -- Reset (Software & Hardware) 
  signal rx_rst   : std_logic;          -- Receive Reset (Software & Hardware) 
  signal tx_rst   : std_logic;          -- Transmit Reset (Software & Hardware) 
 
  -------------------------------------------------------------------- 
  --  Status Register: StatReg 
  ---------------------------------------------------------------------- 
  -- 
  -- IO address + 0 Read 
  -- 
  -----------+--------+-------+--------+--------+--------+--------+--------+ 
  --  Irq    | PErr   | OErr  | FErr   |  CTS   |  DCD   | TxRdy  | RxRdy  | 
  -----------+--------+-------+--------+--------+--------+--------+--------+ 
  -- 
  -- Irq   - Bit[7] - Interrupt request 
  -- PErr  - Bit[6] - Receive Parity error (parity bit does not match) 
  -- OErr  - Bit[5] - Receive Overrun error (new character received before last read) 
  -- FErr  - Bit[4] - Receive Framing Error (bad stop bit) 
  -- CTS   - Bit[3] - Clear To Send level 
  -- DCD   - Bit[2] - Data Carrier Detect (lost modem carrier) 
  -- TxRdy - Bit[1] - Transmit Buffer Empty (ready to accept next transmit character) 
  -- RxRdy - Bit[0] - Receive Data Ready (character received) 
  -- 
 
  signal StatReg : std_logic_vector(7 downto 0) := (others => '0'); -- status register 
 
  ---------------------------------------------------------------------- 
  --  Control Register: CtrlReg 
  ---------------------------------------------------------------------- 
  -- 
  -- IO address + 0 Write 
  -- 
  -----------+--------+--------+--------+--------+--------+--------+--------+ 
  --   RxIE  |TxCtl(1)|TxCtl(0)|WdFmt(2)|WdFmt(1)|WdFmt(0)|BdCtl(1)|BdCtl(0)| 
  -----------+--------+--------+--------+--------+--------+--------+--------+ 
  -- RxIEnb - Bit[7] 
  -- 0       - Rx Interrupt disabled 
  -- 1       - Rx Interrupt enabled 
  -- TxCtl - Bits[6..5] 
  -- 0 1     - Tx Interrupt Enable 
  -- 1 0     - RTS high 
  -- WdFmt - Bits[4..2] 
  -- 0 0 0   - 7 data, even parity, 2 stop 
  -- 0 0 1   - 7 data, odd  parity, 2 stop 
  -- 0 1 0   - 7 data, even parity, 1 stop 
  -- 0 1 1   - 7 data, odd  parity, 1 stop 
  -- 1 0 0   - 8 data, no   parity, 2 stop 
  -- 1 0 1   - 8 data, no   parity, 1 stop 
  -- 1 1 0   - 8 data, even parity, 1 stop 
  -- 1 1 1   - 8 data, odd  parity, 1 stop 
  -- BdCtl - Bits[1..0] 
  -- 0 0     - Baud Clk divide by 1 
  -- 0 1     - Baud Clk divide by 16 
  -- 1 0     - Baud Clk divide by 64 
  -- 1 1     - reset 
  signal CtrlReg : std_logic_vector(7 downto 0) := (others => '0'); -- control register 
 
  ---------------------------------------------------------------------- 
  -- Receive Register 
  ---------------------------------------------------------------------- 
  -- 
  -- IO address + 1     Read 
  -- 
  signal RxReg : std_logic_vector(7 downto 0) := (others => '0'); 
 
  ---------------------------------------------------------------------- 
  -- Transmit Register 
  ---------------------------------------------------------------------- 
  -- 
  -- IO address + 1     Write 
  -- 
  signal TxReg    : std_logic_vector(7 downto 0) := (others => '0'); 
 
  signal TxDat    : std_logic := '1';   -- Transmit data bit 
  signal TxRdy    : std_logic := '0';   -- Transmit buffer empty 
  signal RxRdy    : std_logic := '0';   -- Receive Data ready 
 -- 
  signal FErr     : std_logic := '0';   -- Frame error 
  signal OErr     : std_logic := '0';   -- Output error 
  signal PErr     : std_logic := '0';   -- Parity Error 
  -- 
  signal TxIE     : std_logic := '0';   -- Transmit interrupt enable 
  signal RxIE     : std_logic := '0';   -- Receive interrupt enable 
  -- 
  signal RxRd     : std_logic := '0';   -- Read receive buffer 
  signal TxWr     : std_logic := '0';   -- Write Transmit buffer 
  signal StRd     : std_logic := '0';   -- Read status register 
  -- 
  signal DCDState : DCD_State_Type;     -- DCD Reset state sequencer 
  signal DCDDel   : std_logic := '0';   -- Delayed DCD_n 
  signal DCDEdge  : std_logic := '0';   -- Rising DCD_N Edge Pulse 
  signal DCDInt   : std_logic := '0';   -- DCD Interrupt 
 
  signal BdFmt    : std_logic_vector(1 downto 0) := "00";   -- Baud Clock Format 
  signal WdFmt    : std_logic_vector(2 downto 0) := "000";  -- Data Word Format 
 
  --* RX Signals 
  --* 
  type RxStateType is ( RxState_Wait, RxState_Data, RxState_Parity, RxState_Stop ); 
 
  signal RxState    : RxStateType;                  -- receive bit state 
 
  signal RxDatDel0  : Std_Logic := '0';             -- Delayed Rx Data 
  signal RxDatDel1  : Std_Logic := '0';             -- Delayed Rx Data 
  signal RxDatDel2  : Std_Logic := '0';             -- Delayed Rx Data 
  signal RxDatEdge  : Std_Logic := '0';             -- Rx Data Edge pulse 
 
  signal RxClkDel   : Std_Logic := '0';             -- Delayed Rx Input Clock 
  signal RxClkEdge  : Std_Logic := '0';             -- Rx Input Clock Edge pulse 
  signal RxStart    : Std_Logic := '0';             -- Rx Start request 
  signal RxEnable   : Std_Logic := '0';             -- Rx Enabled 
  signal RxClkCnt   : Std_Logic_Vector(5 downto 0) := (others => '0'); -- Rx Baud Clock Counter 
  signal RxBdClk    : Std_Logic := '0';             -- Rx Baud Clock 
  signal RxBdDel    : Std_Logic := '0';             -- Delayed Rx Baud Clock 
 
  signal RxReq      : Std_Logic := '0';             -- Rx Data Valid 
  signal RxAck      : Std_Logic := '0';             -- Rx Data Valid 
  signal RxParity   : Std_Logic := '0';             -- Calculated RX parity bit 
  signal RxBitCount : Std_Logic_Vector(2 downto 0) := (others => '0');  -- Rx Bit counter 
  signal RxShiftReg : Std_Logic_Vector(7 downto 0) := (others => '0');  -- Shift Register 
 
  --* TX Signals 
  type TxStateType is ( TxState_Idle, TxState_Start, TxState_Data, TxState_Parity, TxState_Stop ); 
 
  signal TxState     : TxStateType;                   -- Transmitter state 
 
  signal TxClkDel    : Std_Logic := '0';              -- Delayed Tx Input Clock 
  signal TxClkEdge   : Std_Logic := '0';              -- Tx Input Clock Edge pulse 
  signal TxClkCnt    : Std_Logic_Vector(5 downto 0) := (others => '0');  -- Tx Baud Clock Counter 
  signal TxBdClk     : Std_Logic := '0';              -- Tx Baud Clock 
  signal TxBdDel     : Std_Logic := '0';              -- Delayed Tx Baud Clock 
 
  signal TxReq       : std_logic := '0';              -- Request transmit start 
  signal TxAck       : std_logic := '0';              -- Acknowledge transmit start 
  signal TxParity    : Std_logic := '0';              -- Parity Bit 
  signal TxBitCount  : Std_Logic_Vector(2 downto 0) := (others => '0');  -- Data Bit Counter 
  signal TxShiftReg  : Std_Logic_Vector(7 downto 0) := (others => '0');  -- Transmit shift register 
 
begin 
 
  --* ACIA Reset may be hardware or software 
  acia_reset : process( clk, rst, ac_rst, dcd_n ) 
  begin 
    -- 
    -- ACIA reset Synchronous 
    -- Includes software reset 
    -- 
    if falling_edge(clk) then 
      ac_rst <= (CtrlReg(1) and CtrlReg(0)) or rst; 
    end if; 
    -- Receiver reset 
    rx_rst <= ac_rst or DCD_n; 
    -- Transmitter reset 
    tx_rst <= ac_rst; 
 
  end process; 
 
 
  --* Generate Read / Write strobes. 
  --* 
  acia_read_write : process(clk, ac_rst) 
  begin 
    if falling_edge(clk) then 
      if rst = '1' then 
        CtrlReg(1 downto 0) <= "11"; 
        CtrlReg(7 downto 2) <= (others => '0'); 
        TxReg   <= (others => '0'); 
        RxRd  <= '0'; 
        TxWr  <= '0'; 
        StRd  <= '0'; 
      else 
        RxRd  <= '0'; 
        TxWr  <= '0'; 
        StRd  <= '0'; 
        if cs = '1' then 
          if Addr = '0' then              -- Control / Status register 
            if rw = '0' then              -- write control register 
              CtrlReg <= data_in; 
            else                          -- read status register 
              StRd <= '1'; 
            end if; 
          else                            -- Data Register 
            if rw = '0' then              -- write transmiter register 
              TxReg <= data_in; 
              TxWr  <= '1'; 
            else                          -- read receiver register 
              RxRd <= '1'; 
            end if; 
          end if; 
        end if; 
      end if; 
    end if; 
  end process; 
 
  --* ACIA Status Register 
  --* 
  acia_status : process( clk ) 
  begin 
    if falling_edge( clk ) then 
      StatReg(0) <= RxRdy;                 -- Receive Data Ready 
      StatReg(1) <= TxRdy and (not CTS_n); -- Transmit Buffer Empty 
      StatReg(2) <= DCDInt;                -- Data Carrier Detect 
      StatReg(3) <= CTS_n;                 -- Clear To Send 
      StatReg(4) <= FErr;                  -- Framing error 
      StatReg(5) <= OErr;                  -- Overrun error 
      StatReg(6) <= PErr;                  -- Parity error 
      StatReg(7) <= (RxIE and RxRdy) or 
                    (RxIE and DCDInt) or 
                    (TxIE and TxRdy); 
    end if; 
  end process; 
 
 
  --* ACIA Transmit Control 
  --* 
  acia_control : process(CtrlReg, TxDat) 
  begin 
    case CtrlReg(6 downto 5) is 
      when "00" =>                      -- Disable TX Interrupts, Assert RTS 
        TxD   <= TxDat; 
        TxIE  <= '0'; 
        RTS_n <= '0'; 
      when "01" =>                      -- Enable TX interrupts, Assert RTS 
        TxD   <= TxDat; 
        TxIE  <= '1'; 
        RTS_n <= '0'; 
      when "10" =>                      -- Disable Tx Interrupts, Clear RTS 
        TxD   <= TxDat; 
        TxIE  <= '0'; 
        RTS_n <= '1'; 
      when "11" =>                      -- Disable Tx interrupts, Assert RTS, send break 
        TxD   <= '0'; 
        TxIE  <= '0'; 
        RTS_n <= '0'; 
      when others => 
        null; 
    end case; 
 
    RxIE  <= CtrlReg(7); 
    WdFmt <= CtrlReg(4 downto 2); 
    BdFmt <= CtrlReg(1 downto 0); 
  end process; 
 
  --* Set Data Output Multiplexer 
  --* 
  acia_data_mux : process(Addr, RxReg, StatReg) 
  begin 
    if Addr = '1' then 
      data_out <= RxReg;               -- read receiver register 
    else 
      data_out <= StatReg;               -- read status register 
    end if; 
  end process; 
 
  irq <= StatReg(7); 
 
  --* Data Carrier Detect Edge rising edge detect 
  acia_dcd_edge : process( clk, ac_rst ) 
  begin 
    if falling_edge(clk) then 
      if ac_rst = '1' then 
        DCDDel  <= '0'; 
        DCDEdge <= '0'; 
      else 
        DCDDel  <= DCD_n; 
        DCDEdge <= DCD_n and (not DCDDel); 
      end if; 
    end if; 
  end process; 
 
 
  --* Data Carrier Detect Interrupt 
  --* If Data Carrier is lost, an interrupt is generated 
  --* To clear the interrupt, first read the status register 
  --* then read the data receive register 
  --* 
  acia_dcd_int : process( clk, ac_rst ) 
  begin 
    if falling_edge(clk) then 
      if ac_rst = '1' then 
        DCDInt   <= '0'; 
        DCDState <= DCD_State_Idle; 
      else 
        case DCDState is 
        when DCD_State_Idle => 
          -- DCD Edge activates interrupt 
          if DCDEdge = '1' then 
            DCDInt   <= '1'; 
            DCDState <= DCD_State_Int; 
          end if; 
        when DCD_State_Int => 
          -- To reset DCD interrupt, 
          -- First read status 
          if StRd = '1' then 
            DCDState <= DCD_State_Reset; 
          end if; 
        when DCD_State_Reset => 
          -- Then read receive register 
          if RxRd = '1' then 
            DCDInt   <= '0'; 
            DCDState <= DCD_State_Idle; 
          end if; 
        when others => 
          null; 
        end case; 
      end if; 
    end if; 
  end process; 
 
 
  --* Receiver Clock Edge Detection 
  --* A rising edge will produce a one clock cycle pulse 
  acia_rx_clock_edge : process( clk, rx_rst ) 
  begin 
    if falling_edge(clk) then 
      if rx_rst = '1' then 
        RxClkDel  <= '0'; 
        RxClkEdge <= '0'; 
      else 
        RxClkDel  <= RxC; 
        RxClkEdge <= (not RxClkDel) and RxC; 
      end if; 
    end if; 
  end process; 
 
  --* Receiver Data Edge Detection 
  --* A falling edge will produce a pulse on RxClk wide 
  acia_rx_data_edge : process( clk, rx_rst ) 
  begin 
    if falling_edge(clk) then 
      if rx_rst = '1' then 
        RxDatDel0 <= '0'; 
        RxDatDel1 <= '0'; 
        RxDatDel2 <= '0'; 
        RxDatEdge <= '0'; 
      else 
        RxDatDel0 <= RxD; 
        RxDatDel1 <= RxDatDel0; 
        RxDatDel2 <= RxDatDel1; 
        RxDatEdge <= RxDatDel0 and (not RxD); 
      end if; 
    end if; 
  end process; 
 
  --* Receiver Start / Stop 
  --* Enable the receive clock on detection of a start bit 
  --* Disable the receive clock after a byte is received. 
  acia_rx_start_stop : process( clk, rx_rst ) 
  begin 
    if falling_edge(clk) then 
      if rx_rst = '1' then 
        RxEnable <= '0'; 
        RxStart  <= '0'; 
      elsif (RxEnable = '0') and (RxDatEdge = '1') then 
        -- Data Edge detected 
        RxStart  <= '1';                    -- Request Start and 
        RxEnable <= '1';                    -- Enable Receive Clock 
      elsif (RxStart = '1') and (RxAck = '1') then 
        -- Data is being received 
        RxStart <= '0';                     -- Reset Start Request 
      elsif (RxStart = '0') and (RxAck = '0') then 
        -- Data has now been received 
        RxEnable <= '0';                    -- Disable Receiver until next Start Bit 
      end if; 
    end if; 
  end process; 
 
  --* Receiver Clock Divider 
  --* Hold the Rx Clock divider in reset when the receiver is disabled 
  --* Advance the count only on a rising Rx clock edge 
  acia_rx_clock_divide : process( clk, rx_rst ) 
  begin 
    if falling_edge(clk) then 
      if rx_rst = '1' then 
        RxClkCnt  <= (others => '0'); 
      elsif RxDatEdge = '1' then 
        -- reset on falling data edge 
        RxClkCnt <= (others => '0'); 
      elsif RxClkEdge = '1' then 
        -- increment count on Clock edge 
        RxClkCnt <= RxClkCnt + "000001"; 
      end if; 
    end if; 
  end process; 
 
  --* Receiver Baud Clock Selector 
  --* BdFmt 
  --* 0 0     - Baud Clk divide by 1 
  --* 0 1     - Baud Clk divide by 16 
  --* 1 0     - Baud Clk divide by 64 
  --* 1 1     - Reset 
  acia_rx_baud_clock_select : process( BdFmt, RxC, RxClkCnt ) 
  begin 
    case BdFmt is 
      when "00" =>	                        -- Div by 1 
        RxBdClk <= RxC; 
      when "01" =>	                        -- Div by 16 
        RxBdClk <= RxClkCnt(3); 
      when "10" =>	                        -- Div by 64 
        RxBdClk <= RxClkCnt(5); 
      when others =>                         -- Software Reset 
        RxBdClk <= '0'; 
    end case; 
  end process; 
 
  --* Receiver process 
  --* WdFmt - Bits[4..2] 
  --* 0 0 0   - 7 data, even parity, 2 stop 
  --* 0 0 1   - 7 data, odd  parity, 2 stop 
  --* 0 1 0   - 7 data, even parity, 1 stop 
  --* 0 1 1   - 7 data, odd  parity, 1 stop 
  --* 1 0 0   - 8 data, no   parity, 2 stop 
  --* 1 0 1   - 8 data, no   parity, 1 stop 
  --* 1 1 0   - 8 data, even parity, 1 stop 
  --* 1 1 1   - 8 data, odd  parity, 1 stop 
  acia_rx_receive : process( clk, rst ) 
  begin 
    if falling_edge( clk ) then 
      if rx_rst = '1' then 
        FErr       <= '0'; 
        OErr       <= '0'; 
        PErr       <= '0'; 
        RxShiftReg <= (others => '0');       -- Reset Shift register 
        RxReg      <= (others => '0'); 
        RxParity   <= '0';                   -- reset Parity bit 
        RxAck      <= '0';                   -- Receiving data 
        RxBitCount <= (others => '0'); 
        RxState    <= RxState_Wait; 
      else 
        RxBdDel      <= RxBdClk; 
        if RxBdDel = '0' and RxBdClk = '1' then 
          case RxState is 
          when RxState_Wait => 
            RxShiftReg <= (others => '0');   -- Reset Shift register 
            RxParity   <= '0';               -- Reset Parity bit 
            if WdFmt(2) = '0' then           -- WdFmt(2) = '0' => 7 data bits 
              RxBitCount <= "110"; 
            else                             -- WdFmt(2) = '1' => 8 data bits 
              RxBitCount <= "111"; 
            end if; 
            if RxDatDel2 = '0' then          -- look for start bit 
              RxState <= RxState_Data;       -- if low, start reading data 
            end if; 
 
          when RxState_Data =>               -- Receiving data bits 
            RxShiftReg <= RxDatDel2 & RxShiftReg(7 downto 1); 
            RxParity   <= RxParity xor RxDatDel2; 
            RxAck      <= '1';               -- Flag receive in progress 
            RxBitCount <= RxBitCount - "001"; 
            if RxBitCount = "000" then 
              if WdFmt(2) = '0' then         -- WdFmt(2) = '0' => 7 data 
                RxState <= RxState_Parity;   -- 7 bits always has parity 
              elsif WdFmt(1) = '0' then      -- WdFmt(2) = '1' => 8 data 
                RxState <= RxState_Stop;     -- WdFmt(1) = '0' => no parity 
                PErr <= '0';               -- Reset Parity Error 
              else 
                RxState <= RxState_Parity;   -- WdFmt(1) = '1' => 8 data + parity 
              end if; 
            end if; 
 
          when RxState_Parity =>             -- Receive Parity bit 
            if WdFmt(2) = '0' then           -- if 7 data bits, shift parity into MSB 
              RxShiftReg <= RxDatDel2 & RxShiftReg(7 downto 1); -- 7 data + parity 
            end if; 
            if RxParity = (RxDatDel2 xor WdFmt(0)) then 
              PErr <= '1';                 -- If parity not the same flag error 
            else 
              PErr <= '0'; 
            end if; 
            RxState <= RxState_Stop; 
 
          when RxState_Stop =>             -- stop bit (Only one required for RX) 
            RxAck  <= '0';                 -- Flag Receive Complete 
            RxReg <= RxShiftReg; 
            if RxDatDel2 = '1' then        -- stop bit expected 
              FErr <= '0';                 -- yes, no framing error 
            else 
              FErr <= '1';                 -- no, framing error 
            end if; 
            if RxRdy = '1' then            -- Has previous data been read ? 
              OErr <= '1';                 -- no, overrun error 
            else 
              OErr <= '0';                 -- yes, no over run error 
            end if; 
            RxState <= RxState_Wait; 
 
          when others => 
            RxAck   <= '0';                -- Flag Receive Complete 
            RxState <= RxState_Wait; 
          end case; 
        end if; 
      end if; 
    end if; 
 
  end process; 
 
  --* Receiver Read process 
  acia_rx_read : process( clk, rst, RxRdy ) 
  begin 
    if falling_edge(clk) then 
      if rx_rst = '1' then 
        RxRdy <= '0'; 
        RxReq <= '0'; 
      elsif RxRd = '1' then 
        -- Data was read, 
        RxRdy <= '0';                        -- Reset receive full 
        RxReq <= '1';                        -- Request more data 
      elsif RxReq = '1' and RxAck = '1' then 
        -- Data is being received 
        RxReq <= '0';                        -- reset receive request 
      elsif RxReq = '0' and RxAck = '0' then 
        -- Data now received 
        RxRdy <= '1';                        -- Flag RxRdy and read Shift Register 
      end if; 
    end if; 
  end process; 
 
 
  --* Transmit Clock Edge Detection 
  --* A falling edge will produce a one clock cycle pulse 
  --* 
  acia_tx_clock_edge : process( Clk, tx_rst ) 
  begin 
    if falling_edge(clk) then 
      if tx_rst = '1' then 
        TxClkDel  <= '0'; 
        TxClkEdge <= '0'; 
      else 
        TxClkDel  <= TxC; 
        TxClkEdge <= TxClkDel and (not TxC); 
      end if; 
    end if; 
  end process; 
 
  --* Transmit Clock Divider 
  --* Advance the count only on an input clock pulse 
  --* 
  acia_tx_clock_divide : process( clk, tx_rst ) 
  begin 
    if falling_edge(clk) then 
      if tx_rst = '1' then 
        TxClkCnt <= (others=>'0'); 
      elsif TxClkEdge = '1' then 
        TxClkCnt <= TxClkCnt + "000001"; 
      end if; 
    end if; 
  end process; 
 
  --* Transmit Baud Clock Selector 
  acia_tx_baud_clock_select : process( BdFmt, TxClkCnt, TxC ) 
  begin 
    -- BdFmt 
    -- 0 0     - Baud Clk divide by 1 
    -- 0 1     - Baud Clk divide by 16 
    -- 1 0     - Baud Clk divide by 64 
    -- 1 1     - reset 
    case BdFmt is 
      when "00" =>	                         -- Div by 1 
        TxBdClk <= TxC; 
      when "01" =>	                         -- Div by 16 
        TxBdClk <= TxClkCnt(3); 
      when "10" =>	                         -- Div by 64 
        TxBdClk <= TxClkCnt(5); 
      when others =>                          -- Software reset 
        TxBdClk <= '0'; 
    end case; 
  end process; 
 
  --* Implements the Tx unit 
  --* WdFmt - Bits[4..2] 
  --* 0 0 0   - 7 data, even parity, 2 stop 
  --* 0 0 1   - 7 data, odd  parity, 2 stop 
  --* 0 1 0   - 7 data, even parity, 1 stop 
  --* 0 1 1   - 7 data, odd  parity, 1 stop 
  --* 1 0 0   - 8 data, no   parity, 2 stop 
  --* 1 0 1   - 8 data, no   parity, 1 stop 
  --* 1 1 0   - 8 data, even parity, 1 stop 
  --* 1 1 1   - 8 data, odd  parity, 1 stop 
  acia_tx_transmit : process( clk, tx_rst) 
  begin 
    if falling_edge(clk) then 
      if tx_rst = '1' then 
        TxDat      <= '1'; 
        TxShiftReg <= (others=>'0'); 
        TxParity   <= '0'; 
        TxBitCount <= (others=>'0'); 
        TxAck      <= '0'; 
        TxState    <= TxState_Idle; 
      else 
 
        TxBdDel <= TxBdClk; 
        -- On rising edge of baud clock, run the state machine 
        if TxBdDel = '0' and TxBdClk = '1' then 
 
          case TxState is 
          when TxState_Idle => 
            TxDat <= '1'; 
            if TxReq = '1' then 
              TxShiftReg <= TxReg;              -- Load Shift reg with Tx Data 
              TxAck      <= '1'; 
              TxState    <= TxState_Start; 
            end if; 
 
          when TxState_Start => 
            TxDat    <= '0';                    -- Start bit 
            TxParity <= '0'; 
            if WdFmt(2) = '0' then 
              TxBitCount <= "110";              -- 7 data + parity 
            else 
              TxBitCount <= "111";              -- 8 data 
            end if; 
            TxState <= TxState_Data; 
 
          when TxState_Data => 
            TxDat      <= TxShiftReg(0); 
            TxShiftReg <= '1' & TxShiftReg(7 downto 1); 
            TxParity   <= TxParity xor TxShiftReg(0); 
            TxBitCount <= TxBitCount - "001"; 
            if TxBitCount = "000" then 
              if (WdFmt(2) = '1') and (WdFmt(1) = '0') then 
                if WdFmt(0) = '0' then        -- 8 data bits 
                  TxState <= TxState_Stop;    -- 2 stops 
                else 
                  TxAck   <= '0'; 
                  TxState <= TxState_Idle;    -- 1 stop 
                end if; 
              else 
                TxState <= TxState_Parity;    -- parity 
              end if; 
            end if; 
 
          when TxState_Parity =>              -- 7/8 data + parity bit 
            if WdFmt(0) = '0' then 
              TxDat <= not(TxParity);         -- even parity 
            else 
              TxDat <= TxParity;              -- odd parity 
            end if; 
            if WdFmt(1) = '0' then 
              TxState <= TxState_Stop;        -- 2 stops 
            else 
              TxAck   <= '0'; 
              TxState <= TxState_Idle;        -- 1 stop 
            end if; 
 
          when TxState_Stop =>                -- first of two stop bits 
            TxDat   <= '1'; 
            TxAck   <= '0'; 
            TxState <= TxState_Idle; 
 
          end case; 
        end if; 
      end if; 
    end if; 
  end process; 
 
  --* Transmitter Write process 
  --* 
  acia_tx_write : process( clk, tx_rst, TxWr, TxReq, TxAck ) 
  begin 
    if falling_edge(clk) then 
      if tx_rst = '1' then 
        TxRdy <= '0'; 
        TxReq <= '0'; 
      elsif TxWr = '1' then 
        -- Data was read, 
        TxRdy <= '0';                        -- Reset transmit empty 
        TxReq <= '1';                        -- Request data transmit 
      elsif TxReq = '1' and TxAck = '1' then -- Data is being transmitted 
        TxReq <= '0';                        -- reset transmit request 
      elsif TxReq = '0' and TxAck = '0' then -- Data transmitted 
        TxRdy <= '1';                        -- Flag TxRdy 
      end if; 
    end if; 
  end process; 
 
end rtl; 
 