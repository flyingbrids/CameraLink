----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_deserializer.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link 1:7 de-serializer
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_deserializer is

port (

  -- system signals
  clk     : in  std_logic;  -- serial clock
  reset   : in  std_logic;  -- active low

  -- serial data in
  rxc_in  : in  std_logic;  -- input clock is: 2up/3down/2up
  rx0_in  : in  std_logic;
  rx1_in  : in  std_logic;
  rx2_in  : in  std_logic;
  rx3_in  : in  std_logic;

  -- parallel data out
  data0   : out std_logic_vector(6 downto 0);
  data1   : out std_logic_vector(6 downto 0);
  data2   : out std_logic_vector(6 downto 0);
  data3   : out std_logic_vector(6 downto 0) );

end entity;


architecture rtl of cam_deserializer is


signal  rxc_reg0       : std_logic;
signal  rx0_reg0       : std_logic;
signal  rx1_reg0       : std_logic;
signal  rx2_reg0       : std_logic;
signal  rx3_reg0       : std_logic;

signal  rxc_reg1       : std_logic;
signal  rx0_reg1       : std_logic;
signal  rx1_reg1       : std_logic;
signal  rx2_reg1       : std_logic;
signal  rx3_reg1       : std_logic;

signal  rxc_shift_reg  : std_logic_vector(6 downto 0);
signal  rx0_shift_reg  : std_logic_vector(6 downto 0);
signal  rx1_shift_reg  : std_logic_vector(6 downto 0);
signal  rx2_shift_reg  : std_logic_vector(6 downto 0);
signal  rx3_shift_reg  : std_logic_vector(6 downto 0);

signal  rxc_sync       : std_logic;


begin


-----------------------------------------------
-- Double-register the input bits for speed  --
-- Note: input registers should be placed    --
-- locally together at the input pads        --
-----------------------------------------------

input_regs: process(clk)

begin

  if clk'event and clk = '1' then
    rxc_reg0 <= rxc_in;
    rx0_reg0 <= rx0_in;
    rx1_reg0 <= rx1_in;
    rx2_reg0 <= rx2_in;
    rx3_reg0 <= rx3_in;

    rxc_reg1 <= rxc_reg0;
    rx0_reg1 <= rx0_reg0;
    rx1_reg1 <= rx1_reg0;
    rx2_reg1 <= rx2_reg0;
    rx3_reg1 <= rx3_reg0;
  end if;

end process input_regs;


---------------------------
-- 7-bit shift registers --
---------------------------

deserial_regs: process(clk)

begin

  if clk'event and clk = '1' then
    rxc_shift_reg(6 downto 1) <= rxc_shift_reg(5 downto 0); rxc_shift_reg(0) <= rxc_reg1;
    rx0_shift_reg(6 downto 1) <= rx0_shift_reg(5 downto 0); rx0_shift_reg(0) <= rx0_reg1;
    rx1_shift_reg(6 downto 1) <= rx1_shift_reg(5 downto 0); rx1_shift_reg(0) <= rx1_reg1;
    rx2_shift_reg(6 downto 1) <= rx2_shift_reg(5 downto 0); rx2_shift_reg(0) <= rx2_reg1;
    rx3_shift_reg(6 downto 1) <= rx3_shift_reg(5 downto 0); rx3_shift_reg(0) <= rx3_reg1;
  end if;

end process deserial_regs;


-------------------------------------------
-- Detect the correct clock sync pattern --
-- to frame the data: 2up | 3down | 2up  --
--          _____          _____         --
--   rxc = |     |________|     |        --
--                                       --
--   rx0 = |B0|A5|A4|A3|A2|A1|A0|        --
--   rx1 = |C1|C0|B5|B4|B3|B2|B1|        --
--   rx2 = |DE|VS|HS|C5|C4|C3|C2|        --
--   rx3 = |NC|C7|C6|B7|B6|A7|A6|        --
--                                       --
-------------------------------------------

rxc_sync <= '1' when (rxc_shift_reg = "1100011") else '0';


--------------------------
-- Parallel output data --
--------------------------

output_regs: process(clk, reset)

begin

  if reset = '0' then
    data0 <= (others => '0');
    data1 <= (others => '0');
    data2 <= (others => '0');
    data3 <= (others => '0');
  elsif clk'event and clk = '1' then
    if (rxc_sync = '1') then
      data0 <= rx0_shift_reg;
      data1 <= rx1_shift_reg;
      data2 <= rx2_shift_reg;
      data3 <= rx3_shift_reg;
    end if;
  end if;

end process output_regs;


end rtl;
