----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_full_tx.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link FULL Tx component
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_full_tx is

port (

  -- system signals
  sys_rst    : in  std_logic;  -- active low
  sys_clk    : in  std_logic;  -- parallel clock
  ser_clk    : in  std_logic;  -- serial clock

  -- parallel video data in (BASE)
  x_vid_a    : in  std_logic_vector(7 downto 0);  -- A bits
  x_vid_b    : in  std_logic_vector(7 downto 0);  -- B bits
  x_vid_c    : in  std_logic_vector(7 downto 0);  -- C bits
  x_vid_nc   : in  std_logic;                     -- reserved bit
  x_vid_en   : in  std_logic;                     -- same as DVAL
  x_vid_vs   : in  std_logic;                     -- same as FVAL
  x_vid_hs   : in  std_logic;                     -- same as LVAL

  -- parallel video data in (MEDIUM)
  y_vid_a    : in  std_logic_vector(7 downto 0);  -- A bits
  y_vid_b    : in  std_logic_vector(7 downto 0);  -- B bits
  y_vid_c    : in  std_logic_vector(7 downto 0);  -- C bits
  y_vid_nc   : in  std_logic;                     -- reserved bit
  y_vid_en   : in  std_logic;                     -- same as DVAL
  y_vid_vs   : in  std_logic;                     -- same as FVAL
  y_vid_hs   : in  std_logic;                     -- same as LVAL

  -- parallel video data in (FULL)
  z_vid_a    : in  std_logic_vector(7 downto 0);  -- A bits
  z_vid_b    : in  std_logic_vector(7 downto 0);  -- B bits
  z_vid_c    : in  std_logic_vector(7 downto 0);  -- C bits
  z_vid_nc   : in  std_logic;                     -- reserved bit
  z_vid_en   : in  std_logic;                     -- same as DVAL
  z_vid_vs   : in  std_logic;                     -- same as FVAL
  z_vid_hs   : in  std_logic;                     -- same as LVAL

  -- BASE data lanes out
  xc         : out std_logic;
  x0         : out std_logic;
  x1         : out std_logic;
  x2         : out std_logic;
  x3         : out std_logic;

  -- MEDIUM data lanes in
  yc         : out std_logic;
  y0         : out std_logic;
  y1         : out std_logic;
  y2         : out std_logic;
  y3         : out std_logic;

  -- FULL data lanes in
  zc         : out std_logic;
  z0         : out std_logic;
  z1         : out std_logic;
  z2         : out std_logic;
  z3         : out std_logic );

end entity;


architecture rtl of cam_full_tx is


component cam_base_tx

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

end component;


begin


----------------------------
-- Cameralink BASE config --
----------------------------

u0_cam_base_tx: cam_base_tx

port map (

  -- system signals
  sys_rst  => sys_rst,
  sys_clk  => sys_clk,
  ser_clk  => ser_clk,

  -- parallel video data in
  vid_a    => x_vid_a,
  vid_b    => x_vid_b,
  vid_c    => x_vid_c,
  vid_nc   => x_vid_nc,
  vid_en   => x_vid_en,
  vid_vs   => x_vid_vs,
  vid_hs   => x_vid_hs,

  -- single-ended serial outputs
  txc      => xc,
  tx0      => x0,
  tx1      => x1,
  tx2      => x2,
  tx3      => x3 );


------------------------------
-- Cameralink MEDIUM config --
------------------------------

u1_cam_base_tx: cam_base_tx

port map (

  -- system signals
  sys_rst  => sys_rst,
  sys_clk  => sys_clk,
  ser_clk  => ser_clk,

  -- parallel video data in
  vid_a    => y_vid_a,
  vid_b    => y_vid_b,
  vid_c    => y_vid_c,
  vid_nc   => y_vid_nc,
  vid_en   => y_vid_en,
  vid_vs   => y_vid_vs,
  vid_hs   => y_vid_hs,

  -- single-ended serial outputs
  txc      => yc,
  tx0      => y0,
  tx1      => y1,
  tx2      => y2,
  tx3      => y3 );


----------------------------
-- Cameralink FULL config --
----------------------------

u2_cam_base_tx: cam_base_tx

port map (

  -- system signals
  sys_rst  => sys_rst,
  sys_clk  => sys_clk,
  ser_clk  => ser_clk,

  -- parallel video data in
  vid_a    => z_vid_a,
  vid_b    => z_vid_b,
  vid_c    => z_vid_c,
  vid_nc   => z_vid_nc,
  vid_en   => z_vid_en,
  vid_vs   => z_vid_vs,
  vid_hs   => z_vid_hs,

  -- single-ended serial outputs
  txc      => zc,
  tx0      => z0,
  tx1      => z1,
  tx2      => z2,
  tx3      => z3 );


end rtl;
