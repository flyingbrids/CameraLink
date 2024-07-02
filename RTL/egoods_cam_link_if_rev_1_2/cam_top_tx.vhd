----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_top_tx.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link top-level Tx component
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_top_tx is

generic ( config : integer );  -- 0: BASE, 1: MEDIUM, 2: FULL

port (

  -- system signals
  sys_rst   : in  std_logic;  -- async low
  sys_clk   : in  std_logic;  -- parallel clock
  ser_clk   : in  std_logic;  -- serial clock x 7

  -- Parallel video data in (BASE config)
  pix_a     : in  std_logic_vector(7 downto 0);
  pix_b     : in  std_logic_vector(7 downto 0);
  pix_c     : in  std_logic_vector(7 downto 0);

  -- Parallel video data in (MEDIUM config)
  pix_d     : in  std_logic_vector(7 downto 0);
  pix_e     : in  std_logic_vector(7 downto 0);
  pix_f     : in  std_logic_vector(7 downto 0);

  -- Parallel video data in (FULL config)
  pix_g     : in  std_logic_vector(7 downto 0);
  pix_h     : in  std_logic_vector(7 downto 0);
  pix_i     : in  std_logic_vector(7 downto 0);

  -- Video sync flags
  pix_dval  : in  std_logic;
  pix_fval  : in  std_logic;
  pix_lval  : in  std_logic;

  -- Camera-link output clocks (2up/3down/2up)
  xc_p      : out std_logic;
  xc_n      : out std_logic;
  yc_p      : out std_logic;
  yc_n      : out std_logic;
  zc_p      : out std_logic;
  zc_n      : out std_logic;

  -- Camera-link BASE data lanes 0 to 3
  x0_p      : out std_logic;
  x0_n      : out std_logic;
  x1_p      : out std_logic;
  x1_n      : out std_logic;
  x2_p      : out std_logic;
  x2_n      : out std_logic;
  x3_p      : out std_logic;
  x3_n      : out std_logic;

  -- Camera-link MEDIUM data lanes 0 to 3
  y0_p      : out std_logic;
  y0_n      : out std_logic;
  y1_p      : out std_logic;
  y1_n      : out std_logic;
  y2_p      : out std_logic;
  y2_n      : out std_logic;
  y3_p      : out std_logic;
  y3_n      : out std_logic;

  -- Camera-link FULL data lanes 0 to 3
  z0_p      : out std_logic;
  z0_n      : out std_logic;
  z1_p      : out std_logic;
  z1_n      : out std_logic;
  z2_p      : out std_logic;
  z2_n      : out std_logic;
  z3_p      : out std_logic;
  z3_n      : out std_logic );

end entity;


architecture rtl of cam_top_tx is


component cam_obuf

port (

  di    : in  std_logic;
  do_p  : out std_logic;
  do_n  : out std_logic );

end component;


component cam_full_tx

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

end component;


signal  xc  : std_logic;
signal  x0  : std_logic;
signal  x1  : std_logic;
signal  x2  : std_logic;
signal  x3  : std_logic;

signal  yc  : std_logic;
signal  y0  : std_logic;
signal  y1  : std_logic;
signal  y2  : std_logic;
signal  y3  : std_logic;

signal  zc  : std_logic;
signal  z0  : std_logic;
signal  z1  : std_logic;
signal  z2  : std_logic;
signal  z3  : std_logic;


begin


------------------------------------
-- Cameralink FULL implementation --
------------------------------------

u0_cam_full_tx : cam_full_tx

port map (

  -- system signals
  sys_rst    => sys_rst,  -- active low
  sys_clk    => sys_clk,  -- parallel clock
  ser_clk    => ser_clk,  -- serial clock

  -- parallel video data out (BASE)
  x_vid_a    => pix_a,
  x_vid_b    => pix_b,
  x_vid_c    => pix_c,
  x_vid_nc   => '0',
  x_vid_en   => pix_dval,
  x_vid_vs   => pix_fval,
  x_vid_hs   => pix_lval,

  -- parallel video data out (MEDIUM)
  y_vid_a    => pix_d,
  y_vid_b    => pix_e,
  y_vid_c    => pix_f,
  y_vid_nc   => '0',
  y_vid_en   => pix_dval,
  y_vid_vs   => pix_fval,
  y_vid_hs   => pix_lval,

  -- parallel video data out (FULL)
  z_vid_a    => pix_g,
  z_vid_b    => pix_h,
  z_vid_c    => pix_i,
  z_vid_nc   => '0',
  z_vid_en   => pix_dval,
  z_vid_vs   => pix_fval,
  z_vid_hs   => pix_lval,

  -- BASE data lanes in
  xc         => xc,
  x0         => x0,
  x1         => x1,
  x2         => x2,
  x3         => x3,

  -- MEDIUM data lanes in
  yc         => yc,
  y0         => y0,
  y1         => y1,
  y2         => y2,
  y3         => y3,

  -- FULL data lanes in
  zc         => zc,
  z0         => z0,
  z1         => z1,
  z2         => z2,
  z3         => z3 );


--------------------------------------------------
-- Differential output buffers channel X (BASE) --
--------------------------------------------------

gen_base_config:  if (config = 0) generate

  u00_cam_obuf: cam_obuf port map (di => xc,  do_p => xc_p, do_n => xc_n);
  u01_cam_obuf: cam_obuf port map (di => x0,  do_p => x0_p, do_n => x0_n);
  u02_cam_obuf: cam_obuf port map (di => x1,  do_p => x1_p, do_n => x1_n);
  u03_cam_obuf: cam_obuf port map (di => x2,  do_p => x2_p, do_n => x2_n);
  u04_cam_obuf: cam_obuf port map (di => x3,  do_p => x3_p, do_n => x3_n);

  -- N/C
  u05_cam_obuf: cam_obuf port map (di => '0', do_p => yc_p, do_n => yc_n);
  u06_cam_obuf: cam_obuf port map (di => '0', do_p => y0_p, do_n => y0_n);
  u07_cam_obuf: cam_obuf port map (di => '0', do_p => y1_p, do_n => y1_n);
  u08_cam_obuf: cam_obuf port map (di => '0', do_p => y2_p, do_n => y2_n);
  u09_cam_obuf: cam_obuf port map (di => '0', do_p => y3_p, do_n => y3_n);

  -- N/C
  u10_cam_obuf: cam_obuf port map (di => '0', do_p => zc_p, do_n => zc_n);
  u11_cam_obuf: cam_obuf port map (di => '0', do_p => z0_p, do_n => z0_n);
  u12_cam_obuf: cam_obuf port map (di => '0', do_p => z1_p, do_n => z1_n);
  u13_cam_obuf: cam_obuf port map (di => '0', do_p => z2_p, do_n => z2_n);
  u14_cam_obuf: cam_obuf port map (di => '0', do_p => z3_p, do_n => z3_n);

end generate gen_base_config;


----------------------------------------------------
-- Differential output buffers channel Y (MEDIUM) --
----------------------------------------------------

gen_medium_config:  if (config = 1) generate

  u00_cam_obuf: cam_obuf port map (di => xc,  do_p => xc_p, do_n => xc_n);
  u01_cam_obuf: cam_obuf port map (di => x0,  do_p => x0_p, do_n => x0_n);
  u02_cam_obuf: cam_obuf port map (di => x1,  do_p => x1_p, do_n => x1_n);
  u03_cam_obuf: cam_obuf port map (di => x2,  do_p => x2_p, do_n => x2_n);
  u04_cam_obuf: cam_obuf port map (di => x3,  do_p => x3_p, do_n => x3_n);

  u05_cam_obuf: cam_obuf port map (di => yc,  do_p => yc_p, do_n => yc_n);
  u06_cam_obuf: cam_obuf port map (di => y0,  do_p => y0_p, do_n => y0_n);
  u07_cam_obuf: cam_obuf port map (di => y1,  do_p => y1_p, do_n => y1_n);
  u08_cam_obuf: cam_obuf port map (di => y2,  do_p => y2_p, do_n => y2_n);
  u09_cam_obuf: cam_obuf port map (di => y3,  do_p => y3_p, do_n => y3_n);

  -- N/C
  u10_cam_obuf: cam_obuf port map (di => '0', do_p => zc_p, do_n => zc_n);
  u11_cam_obuf: cam_obuf port map (di => '0', do_p => z0_p, do_n => z0_n);
  u12_cam_obuf: cam_obuf port map (di => '0', do_p => z1_p, do_n => z1_n);
  u13_cam_obuf: cam_obuf port map (di => '0', do_p => z2_p, do_n => z2_n);
  u14_cam_obuf: cam_obuf port map (di => '0', do_p => z3_p, do_n => z3_n);

end generate gen_medium_config;


--------------------------------------------------
-- Differential output buffers channel Z (FULL) --
--------------------------------------------------

gen_full_config:  if (config = 2) generate

  u00_cam_obuf: cam_obuf port map (di => xc,  do_p => xc_p, do_n => xc_n);
  u01_cam_obuf: cam_obuf port map (di => x0,  do_p => x0_p, do_n => x0_n);
  u02_cam_obuf: cam_obuf port map (di => x1,  do_p => x1_p, do_n => x1_n);
  u03_cam_obuf: cam_obuf port map (di => x2,  do_p => x2_p, do_n => x2_n);
  u04_cam_obuf: cam_obuf port map (di => x3,  do_p => x3_p, do_n => x3_n);

  u05_cam_obuf: cam_obuf port map (di => yc,  do_p => yc_p, do_n => yc_n);
  u06_cam_obuf: cam_obuf port map (di => y0,  do_p => y0_p, do_n => y0_n);
  u07_cam_obuf: cam_obuf port map (di => y1,  do_p => y1_p, do_n => y1_n);
  u08_cam_obuf: cam_obuf port map (di => y2,  do_p => y2_p, do_n => y2_n);
  u09_cam_obuf: cam_obuf port map (di => y3,  do_p => y3_p, do_n => y3_n);

  u10_cam_obuf: cam_obuf port map (di => zc,  do_p => zc_p, do_n => zc_n);
  u11_cam_obuf: cam_obuf port map (di => z0,  do_p => z0_p, do_n => z0_n);
  u12_cam_obuf: cam_obuf port map (di => z1,  do_p => z1_p, do_n => z1_n);
  u13_cam_obuf: cam_obuf port map (di => z2,  do_p => z2_p, do_n => z2_n);
  u14_cam_obuf: cam_obuf port map (di => z3,  do_p => z3_p, do_n => z3_n);

end generate gen_full_config;


end rtl;
