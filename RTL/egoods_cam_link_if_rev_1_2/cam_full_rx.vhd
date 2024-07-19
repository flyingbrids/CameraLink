----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_full_rx.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link FULL Rx component
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_full_rx is

port (

  -- system signals
  sys_rst    : in  std_logic;  -- active low
  sys_clk    : in  std_logic;  -- parallel clock
  ser_clk    : in  std_logic;  -- serial clock

  -- BASE data lanes in
  xc         : in  std_logic;
  x0         : in  std_logic;
  x1         : in  std_logic;
  x2         : in  std_logic;
  x3         : in  std_logic;

  -- MEDIUM data lanes in
  yc         : in  std_logic;
  y0         : in  std_logic;
  y1         : in  std_logic;
  y2         : in  std_logic;
  y3         : in  std_logic;

  -- FULL data lanes in
  zc         : in  std_logic;
  z0         : in  std_logic;
  z1         : in  std_logic;
  z2         : in  std_logic;
  z3         : in  std_logic;

  -- parallel video data out (BASE)
  x_vid_a    : out std_logic_vector(7 downto 0);  -- A bits
  x_vid_b    : out std_logic_vector(7 downto 0);  -- B bits
  x_vid_c    : out std_logic_vector(7 downto 0);  -- C bits
  x_vid_nc   : out std_logic;                     -- reserved bit
  x_vid_en   : out std_logic;                     -- same as DVAL
  x_vid_vs   : out std_logic;                     -- same as FVAL
  x_vid_hs   : out std_logic;                     -- same as LVAL

  -- parallel video data out (MEDIUM)
  y_vid_a    : out std_logic_vector(7 downto 0);  -- A bits
  y_vid_b    : out std_logic_vector(7 downto 0);  -- B bits
  y_vid_c    : out std_logic_vector(7 downto 0);  -- C bits
  y_vid_nc   : out std_logic;                     -- reserved bit
  y_vid_en   : out std_logic;                     -- same as DVAL
  y_vid_vs   : out std_logic;                     -- same as FVAL
  y_vid_hs   : out std_logic;                     -- same as LVAL

  -- parallel video data out (FULL)
  z_vid_a    : out std_logic_vector(7 downto 0);  -- A bits
  z_vid_b    : out std_logic_vector(7 downto 0);  -- B bits
  z_vid_c    : out std_logic_vector(7 downto 0);  -- C bits
  z_vid_nc   : out std_logic;                     -- reserved bit
  z_vid_en   : out std_logic;                     -- same as DVAL
  z_vid_vs   : out std_logic;                     -- same as FVAL
  z_vid_hs   : out std_logic );                   -- same as LVAL

end entity;


architecture rtl of cam_full_rx is


component cam_base_rx

port (

  -- system signals
  sys_rst    : in  std_logic;  -- active low
  sys_clk    : in  std_logic;  -- parallel clock
  ser_clk    : in  std_logic;  -- serial clock

  -- single-ended serial inputs
  rxc        : in  std_logic;
  rx0        : in  std_logic;
  rx1        : in  std_logic;
  rx2        : in  std_logic;
  rx3        : in  std_logic;

  -- parallel video data out
  vid_a      : out std_logic_vector(7 downto 0);  -- A bits
  vid_b      : out std_logic_vector(7 downto 0);  -- B bits
  vid_c      : out std_logic_vector(7 downto 0);  -- C bits
  vid_nc     : out std_logic;                     -- reserved bit
  vid_en     : out std_logic;                     -- same as DVAL
  vid_vs     : out std_logic;                     -- same as FVAL
  vid_hs     : out std_logic );                   -- same as LVAL

end component;


begin


----------------------------
-- Cameralink BASE config --
----------------------------

u0_cam_base_rx: cam_base_rx

port map (

  -- system signals
  sys_rst    => sys_rst,
  sys_clk    => sys_clk,
  ser_clk    => ser_clk,

  -- single-ended serial inputs
  rxc        => xc,
  rx0        => x0,
  rx1        => x1,
  rx2        => x2,
  rx3        => x3,

  -- parallel video data out
  vid_a      => x_vid_a,
  vid_b      => x_vid_b,
  vid_c      => x_vid_c,
  vid_nc     => x_vid_nc,
  vid_en     => x_vid_en,
  vid_vs     => x_vid_vs,
  vid_hs     => x_vid_hs );


------------------------------
-- Cameralink MEDIUM config --
------------------------------

u1_cam_base_rx: cam_base_rx

port map (

  -- system signals
  sys_rst    => sys_rst,
  sys_clk    => sys_clk,
  ser_clk    => ser_clk,

  -- single-ended serial inputs
  rxc        => yc,
  rx0        => y0,
  rx1        => y1,
  rx2        => y2,
  rx3        => y3,

  -- parallel video data out
  vid_a      => y_vid_a,
  vid_b      => y_vid_b,
  vid_c      => y_vid_c,
  vid_nc     => y_vid_nc,
  vid_en     => y_vid_en,
  vid_vs     => y_vid_vs,
  vid_hs     => y_vid_hs );


----------------------------
-- Cameralink FULL config --
----------------------------

u2_cam_base_rx: cam_base_rx

port map (

  -- system signals
  sys_rst    => sys_rst,
  sys_clk    => sys_clk,
  ser_clk    => ser_clk,

  -- single-ended serial inputs
  rxc        => zc,
  rx0        => z0,
  rx1        => z1,
  rx2        => z2,
  rx3        => z3,

  -- parallel video data out
  vid_a      => z_vid_a,
  vid_b      => z_vid_b,
  vid_c      => z_vid_c,
  vid_nc     => z_vid_nc,
  vid_en     => z_vid_en,
  vid_vs     => z_vid_vs,
  vid_hs     => z_vid_hs );


end rtl;
