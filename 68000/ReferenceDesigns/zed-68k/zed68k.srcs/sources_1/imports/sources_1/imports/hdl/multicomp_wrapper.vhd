--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
--Date        : Tue Jun 16 17:13:04 2020
--Host        : DESKTOP-ID021MN running 64-bit major release  (build 9200)
--Command     : generate_target multicomp_wrapper.bd
--Design      : multicomp_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity clock_wrapper is
  port (
    clk25 : out STD_LOGIC;
    clk50 : out STD_LOGIC;
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
end clock_wrapper;

architecture STRUCTURE of clock_wrapper is
  component multicomp is
  port (
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    clk25 : out STD_LOGIC;
    clk50 : out STD_LOGIC
  );
  end component multicomp;
begin
multicomp_i: component multicomp
     port map (
      clk25 => clk25,
      clk50 => clk50,
      reset => reset,
      sys_clock => sys_clock
    );
end STRUCTURE;
