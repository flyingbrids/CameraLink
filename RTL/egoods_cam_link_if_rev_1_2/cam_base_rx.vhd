----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_base_rx.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link BASE Rx component
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_base_rx is

port (

  -- system signals
  sys_rst  : in  std_logic;  -- active low
  sys_clk  : in  std_logic;  -- parallel clock
  ser_clk  : in  std_logic;  -- serial clock

  -- single-ended serial inputs
  rxc      : in  std_logic;
  rx0      : in  std_logic;
  rx1      : in  std_logic;
  rx2      : in  std_logic;
  rx3      : in  std_logic;

  -- parallel video data out
  vid_a    : out std_logic_vector(7 downto 0);  -- A bits
  vid_b    : out std_logic_vector(7 downto 0);  -- B bits
  vid_c    : out std_logic_vector(7 downto 0);  -- C bits
  vid_nc   : out std_logic;                     -- reserved bit
  vid_en   : out std_logic;                     -- same as DVAL
  vid_vs   : out std_logic;                     -- same as FVAL
  vid_hs   : out std_logic );                   -- same as LVAL

end entity;


architecture rtl of cam_base_rx is


component cam_deserializer

port (

  -- system signals
  clk       : in  std_logic;  -- serial clock
  reset     : in  std_logic;  -- active low

  -- data in
  rxc_in    : in  std_logic;  -- input clock is: 2up/3down/2up
  rx0_in    : in  std_logic;
  rx1_in    : in  std_logic;
  rx2_in    : in  std_logic;
  rx3_in    : in  std_logic;

  -- parallel data out
  data0     : out std_logic_vector(6 downto 0);
  data1     : out std_logic_vector(6 downto 0);
  data2     : out std_logic_vector(6 downto 0);
  data3     : out std_logic_vector(6 downto 0) );

end component;


signal  data0           : std_logic_vector(6 downto 0);
signal  data1           : std_logic_vector(6 downto 0);
signal  data2           : std_logic_vector(6 downto 0);
signal  data3           : std_logic_vector(6 downto 0);

signal  pix_a           : std_logic_vector(7 downto 0);
signal  pix_b           : std_logic_vector(7 downto 0);
signal  pix_c           : std_logic_vector(7 downto 0);
signal  pix_nc          : std_logic;
signal  pix_en          : std_logic;
signal  pix_vs          : std_logic;
signal  pix_hs          : std_logic;

signal  pix_a_reg       : std_logic_vector(7 downto 0);
signal  pix_b_reg       : std_logic_vector(7 downto 0);
signal  pix_c_reg       : std_logic_vector(7 downto 0);
signal  pix_nc_reg      : std_logic;
signal  pix_en_reg      : std_logic;
signal  pix_vs_reg      : std_logic;
signal  pix_hs_reg      : std_logic;


begin


-----------------------
-- Bit de-serializer --
-----------------------

u0_cam_deserializer: cam_deserializer

port map (

  -- system signals
  clk       => ser_clk,
  reset     => sys_rst,

  -- data in
  rxc_in    => rxc,
  rx0_in    => rx0,
  rx1_in    => rx1,
  rx2_in    => rx2,
  rx3_in    => rx3,

  -- parallel data out
  data0     => data0,
  data1     => data1,
  data2     => data2,
  data3     => data3 );


-------------------------------------
-- Lanes are decoded as follows:   --
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
pix_b(0) <= data0(6);
pix_a(5) <= data0(5);
pix_a(4) <= data0(4);
pix_a(3) <= data0(3);
pix_a(2) <= data0(2);
pix_a(1) <= data0(1);
pix_a(0) <= data0(0);

-- lane 1
pix_c(1) <= data1(6);
pix_c(0) <= data1(5);
pix_b(5) <= data1(4);
pix_b(4) <= data1(3);
pix_b(3) <= data1(2);
pix_b(2) <= data1(1);
pix_b(1) <= data1(0);

-- lane 2
pix_en   <= data2(6);
pix_vs   <= data2(5);
pix_hs   <= data2(4);
pix_c(5) <= data2(3);
pix_c(4) <= data2(2);
pix_c(3) <= data2(1);
pix_c(2) <= data2(0);

-- lane 3
pix_nc   <= data3(6);
pix_c(7) <= data3(5);
pix_c(6) <= data3(4);
pix_b(7) <= data3(3);
pix_b(6) <= data3(2);
pix_a(7) <= data3(1);
pix_a(6) <= data3(0);


------------------------------------------------------------
-- Register the output signals in the system clock domain --
------------------------------------------------------------

output_regs: process (sys_clk)

begin

  if sys_clk'event and sys_clk = '1' then

    pix_a_reg  <= pix_a;
    pix_b_reg  <= pix_b;
    pix_c_reg  <= pix_c;
    pix_nc_reg <= pix_nc;
    pix_en_reg <= pix_en;
    pix_vs_reg <= pix_vs;
    pix_hs_reg <= pix_hs;

  end if;

end process output_regs;


-------------------------------
-- Wire up the video outputs --
-------------------------------

vid_a  <= pix_a_reg;
vid_b  <= pix_b_reg;
vid_c  <= pix_c_reg;
vid_nc <= pix_nc_reg;
vid_en <= pix_en_reg;
vid_vs <= pix_vs_reg;
vid_hs <= pix_hs_reg;


end rtl;
