----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_serializer.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link 7:1 serializer
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_serializer is

port (

  -- system signals
  clk      : in  std_logic;  -- serial clock
  reset    : in  std_logic;  -- active low

  -- parallel data in
  data0    : in  std_logic_vector(6 downto 0);
  data1    : in  std_logic_vector(6 downto 0);
  data2    : in  std_logic_vector(6 downto 0);
  data3    : in  std_logic_vector(6 downto 0);

  -- serial data out
  txc_out  : out std_logic;  -- output clock is: 2up/3down/2up
  tx0_out  : out std_logic;
  tx1_out  : out std_logic;
  tx2_out  : out std_logic;
  tx3_out  : out std_logic );

end entity;


architecture rtl of cam_serializer is


signal  txc_shift_reg  : std_logic_vector(6 downto 0);
signal  tx0_shift_reg  : std_logic_vector(6 downto 0);
signal  tx1_shift_reg  : std_logic_vector(6 downto 0);
signal  tx2_shift_reg  : std_logic_vector(6 downto 0);
signal  tx3_shift_reg  : std_logic_vector(6 downto 0);

signal  txc_reg        : std_logic;
signal  tx0_reg        : std_logic;
signal  tx1_reg        : std_logic;
signal  tx2_reg        : std_logic;
signal  tx3_reg        : std_logic;

signal  txc_sync       : std_logic;

signal  count          : integer range 0 to 7;


begin


-----------------------------------------------------
-- Free running counter generates the clock-enable --
-- every 7th bit for the correct serialization of  --
-- the parallel input data                         --
-----------------------------------------------------

count_regs: process(clk, reset)

begin

  if reset = '0' then
    count <= 0;
  elsif clk'event and clk = '1' then
    if count = 6 then
      count <= 0;
	else
	  count <= count + 1;
	end if;
  end if;

end process count_regs;


---------------------------------------------------
-- Generate the sync flag for parallel data load --
---------------------------------------------------

txc_sync <= '1' when (count = 6) else '0';


------------------------------------------
-- 7-bit shift registers with parallel  --
-- load and serial out.  Output data is --
-- framed as follows:                   --
--          _____          _____        --
--   txc = |     |________|     |       --
--                                      --
--   tx0 = |B0|A5|A4|A3|A2|A1|A0|       --
--   tx1 = |C1|C0|B5|B4|B3|B2|B1|       --
--   tx2 = |DE|VS|HS|C5|C4|C3|C2|       --
--   tx3 = |NC|C7|C6|B7|B6|A7|A6|       --
--                                      --
------------------------------------------

serial_regs: process(clk)

begin

  if clk'event and clk = '1' then
    if txc_sync = '1' then
	  -- parallel load
	  txc_shift_reg <= "1100011";
	  tx0_shift_reg <= data0;
	  tx1_shift_reg <= data1;
	  tx2_shift_reg <= data2;
	  tx3_shift_reg <= data3;
	else
	  -- shift left
      txc_shift_reg(6 downto 1) <= txc_shift_reg(5 downto 0);
      tx0_shift_reg(6 downto 1) <= tx0_shift_reg(5 downto 0);
      tx1_shift_reg(6 downto 1) <= tx1_shift_reg(5 downto 0);
      tx2_shift_reg(6 downto 1) <= tx2_shift_reg(5 downto 0);
      tx3_shift_reg(6 downto 1) <= tx3_shift_reg(5 downto 0);
	end if;
  end if;

end process serial_regs;


-----------------------------------------------
-- Double-register the output bits for speed --
-- Note: output registers should be placed   --
-- locally together at the output pads       --
-----------------------------------------------

output_regs: process(clk)

begin

  if clk'event and clk = '1' then
    txc_reg <= txc_shift_reg(6);
    tx0_reg <= tx0_shift_reg(6);
    tx1_reg <= tx1_shift_reg(6);
    tx2_reg <= tx2_shift_reg(6);
    tx3_reg <= tx3_shift_reg(6);

    txc_out <= txc_reg;
    tx0_out <= tx0_reg;
    tx1_out <= tx1_reg;
    tx2_out <= tx2_reg;
    tx3_out <= tx3_reg;
  end if;

end process output_regs;


end rtl;
