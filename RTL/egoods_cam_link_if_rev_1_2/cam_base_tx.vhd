----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_base_tx.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link BASE Tx component
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_base_tx is

port (

  -- system signals
  sys_rst  : in  std_logic;  -- active low
  sys_clk  : in  std_logic;  -- parallel clock
  ser_clk  : in  std_logic;  -- serial clock

  -- parallel video data in
  vid_a    : in  std_logic_vector(7 downto 0);  -- A bits
  vid_b    : in  std_logic_vector(7 downto 0);  -- B bits
  vid_c    : in  std_logic_vector(7 downto 0);  -- C bits
  vid_nc   : in  std_logic;                     -- reserved bit
  vid_en   : in  std_logic;                     -- same as DVAL
  vid_vs   : in  std_logic;                     -- same as FVAL
  vid_hs   : in  std_logic;                     -- same as LVAL

  -- single-ended serial outputs
  txc      : out std_logic;
  tx0      : out std_logic;
  tx1      : out std_logic;
  tx2      : out std_logic;
  tx3      : out std_logic );

end entity;


architecture rtl of cam_base_tx is


component cam_serializer

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

end component;


signal  pix_a_reg       : std_logic_vector(7 downto 0);
signal  pix_b_reg       : std_logic_vector(7 downto 0);
signal  pix_c_reg       : std_logic_vector(7 downto 0);
signal  pix_nc_reg      : std_logic;
signal  pix_en_reg      : std_logic;
signal  pix_vs_reg      : std_logic;
signal  pix_hs_reg      : std_logic;

signal  data0           : std_logic_vector(6 downto 0);
signal  data1           : std_logic_vector(6 downto 0);
signal  data2           : std_logic_vector(6 downto 0);
signal  data3           : std_logic_vector(6 downto 0);


begin


-----------------------------------------------------------
-- Register the input signals in the system clock domain --
-----------------------------------------------------------

input_regs: process (sys_clk)

begin

  if sys_clk'event and sys_clk = '1' then

    pix_a_reg  <= vid_a;
    pix_b_reg  <= vid_b;
    pix_c_reg  <= vid_c;
    pix_nc_reg <= vid_nc;
    pix_en_reg <= vid_en;
    pix_vs_reg <= vid_vs;
    pix_hs_reg <= vid_hs;

  end if;

end process input_regs;


-------------------------------------
-- Lanes are encoded as follows:   --
--                                 --
-- Bit:        6, 5, 4, 3, 2, 1, 0 --
--                                 --
-- lane 0:    B0,A5,A4,A3,A2,A1,A0 --
-- lane 1:    C1,C0,B5,B4,B3,B2,B1 --
-- lane 2:    DE,VS,HS,C5,C4,C3,C2 --
-- lane 3:    NC,C7,C6,B7,B6,A7,A6 --
--                                 --
-------------------------------------


-- lane 0
data0(6) <= pix_b_reg(0);
data0(5) <= pix_a_reg(5);
data0(4) <= pix_a_reg(4);
data0(3) <= pix_a_reg(3);
data0(2) <= pix_a_reg(2);
data0(1) <= pix_a_reg(1);
data0(0) <= pix_a_reg(0);

-- lane 1
data1(6) <= pix_c_reg(1);
data1(5) <= pix_c_reg(0);
data1(4) <= pix_b_reg(5);
data1(3) <= pix_b_reg(4);
data1(2) <= pix_b_reg(3);
data1(1) <= pix_b_reg(2);
data1(0) <= pix_b_reg(1);

-- lane 2
data2(6) <= pix_en_reg;
data2(5) <= pix_vs_reg;
data2(4) <= pix_hs_reg;
data2(3) <= pix_c_reg(5);
data2(2) <= pix_c_reg(4);
data2(1) <= pix_c_reg(3);
data2(0) <= pix_c_reg(2);

-- lane 3
data3(6) <= pix_nc_reg;
data3(5) <= pix_c_reg(7);
data3(4) <= pix_c_reg(6);
data3(3) <= pix_b_reg(7);
data3(2) <= pix_b_reg(6);
data3(1) <= pix_a_reg(7);
data3(0) <= pix_a_reg(6);


--------------------
-- Bit serializer --
--------------------

u0_cam_serializer: cam_serializer

port map (

  -- system signals
  clk      => ser_clk,
  reset    => sys_rst,

  -- parallel data in
  data0    => data0,
  data1    => data1,
  data2    => data2,
  data3    => data3,

  -- serial data out
  txc_out  => txc,
  tx0_out  => tx0,
  tx1_out  => tx1,
  tx2_out  => tx2,
  tx3_out  => tx3 );


end rtl;
