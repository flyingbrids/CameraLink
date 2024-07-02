----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_link_if.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link Rx/Tx passthrough for testing
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_link_if is

generic ( config : integer := 2 );  -- 0: BASE, 1: MEDIUM, 2: FULL

port (

  -- system reset (async low)
  rst_n     : in  std_logic;

  -- Camera-link input clocks (2up/3down/2up)
  rx_xc_p   : in  std_logic;
  rx_xc_n   : in  std_logic;
  rx_yc_p   : in  std_logic;
  rx_yc_n   : in  std_logic;
  rx_zc_p   : in  std_logic;
  rx_zc_n   : in  std_logic;

  -- Camera-link BASE data lanes 0 to 3
  rx_x0_p   : in  std_logic;
  rx_x0_n   : in  std_logic;
  rx_x1_p   : in  std_logic;
  rx_x1_n   : in  std_logic;
  rx_x2_p   : in  std_logic;
  rx_x2_n   : in  std_logic;
  rx_x3_p   : in  std_logic;
  rx_x3_n   : in  std_logic;

  -- Camera-link MEDIUM data lanes 0 to 3
  rx_y0_p   : in  std_logic;
  rx_y0_n   : in  std_logic;
  rx_y1_p   : in  std_logic;
  rx_y1_n   : in  std_logic;
  rx_y2_p   : in  std_logic;
  rx_y2_n   : in  std_logic;
  rx_y3_p   : in  std_logic;
  rx_y3_n   : in  std_logic;

  -- Camera-link FULL data lanes 0 to 3
  rx_z0_p   : in  std_logic;
  rx_z0_n   : in  std_logic;
  rx_z1_p   : in  std_logic;
  rx_z1_n   : in  std_logic;
  rx_z2_p   : in  std_logic;
  rx_z2_n   : in  std_logic;
  rx_z3_p   : in  std_logic;
  rx_z3_n   : in  std_logic;

  -- Camera-link output clocks (2up/3down/2up)
  tx_xc_p   : out std_logic;
  tx_xc_n   : out std_logic;
  tx_yc_p   : out std_logic;
  tx_yc_n   : out std_logic;
  tx_zc_p   : out std_logic;
  tx_zc_n   : out std_logic;

  -- Camera-link BASE data lanes 0 to 3
  tx_x0_p   : out std_logic;
  tx_x0_n   : out std_logic;
  tx_x1_p   : out std_logic;
  tx_x1_n   : out std_logic;
  tx_x2_p   : out std_logic;
  tx_x2_n   : out std_logic;
  tx_x3_p   : out std_logic;
  tx_x3_n   : out std_logic;

  -- Camera-link MEDIUM data lanes 0 to 3
  tx_y0_p   : out std_logic;
  tx_y0_n   : out std_logic;
  tx_y1_p   : out std_logic;
  tx_y1_n   : out std_logic;
  tx_y2_p   : out std_logic;
  tx_y2_n   : out std_logic;
  tx_y3_p   : out std_logic;
  tx_y3_n   : out std_logic;

  -- Camera-link FULL data lanes 0 to 3
  tx_z0_p   : out std_logic;
  tx_z0_n   : out std_logic;
  tx_z1_p   : out std_logic;
  tx_z1_n   : out std_logic;
  tx_z2_p   : out std_logic;
  tx_z2_n   : out std_logic;
  tx_z3_p   : out std_logic;
  tx_z3_n   : out std_logic;

  -- Alignment error flags
  err_dval  : out std_logic;
  err_fval  : out std_logic;
  err_lval  : out std_logic );

end entity;


architecture rtl of cam_link_if is


component cam_top_rx

generic ( config : integer );  -- 0: BASE, 1: MEDIUM, 2: FULL

port (

  -- system reset (async low)
  rst_n        : in  std_logic;

  -- Camera-link input clocks (2up/3down/2up)
  xc_p         : in  std_logic;
  xc_n         : in  std_logic;
  yc_p         : in  std_logic;
  yc_n         : in  std_logic;
  zc_p         : in  std_logic;
  zc_n         : in  std_logic;

  -- Camera-link BASE data lanes 0 to 3
  x0_p         : in  std_logic;
  x0_n         : in  std_logic;
  x1_p         : in  std_logic;
  x1_n         : in  std_logic;
  x2_p         : in  std_logic;
  x2_n         : in  std_logic;
  x3_p         : in  std_logic;
  x3_n         : in  std_logic;

  -- Camera-link MEDIUM data lanes 0 to 3
  y0_p         : in  std_logic;
  y0_n         : in  std_logic;
  y1_p         : in  std_logic;
  y1_n         : in  std_logic;
  y2_p         : in  std_logic;
  y2_n         : in  std_logic;
  y3_p         : in  std_logic;
  y3_n         : in  std_logic;

  -- Camera-link FULL data lanes 0 to 3
  z0_p         : in  std_logic;
  z0_n         : in  std_logic;
  z1_p         : in  std_logic;
  z1_n         : in  std_logic;
  z2_p         : in  std_logic;
  z2_n         : in  std_logic;
  z3_p         : in  std_logic;
  z3_n         : in  std_logic;

  -- Forward the clocks (from PLL) and system reset
  sys_rst_f    : out std_logic;  -- async low
  sys_clk_f    : out std_logic;  -- parallel clock
  ser_clk_f    : out std_logic;  -- serial clock x 7

  -- Parallel video data out (BASE config)
  pix_a        : out std_logic_vector(7 downto 0);
  pix_b        : out std_logic_vector(7 downto 0);
  pix_c        : out std_logic_vector(7 downto 0);

  -- Parallel video data out (MEDIUM config)
  pix_d        : out std_logic_vector(7 downto 0);
  pix_e        : out std_logic_vector(7 downto 0);
  pix_f        : out std_logic_vector(7 downto 0);

  -- Parallel video data out (FULL config)
  pix_g        : out std_logic_vector(7 downto 0);
  pix_h        : out std_logic_vector(7 downto 0);
  pix_i        : out std_logic_vector(7 downto 0);

  -- Video sync flags
  pix_dval     : out std_logic;
  pix_fval     : out std_logic;
  pix_lval     : out std_logic;

  -- Alignment error flags
  err_dval     : out std_logic;
  err_fval     : out std_logic;
  err_lval     : out std_logic );

end component;


component cam_top_tx

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

end component;


signal  sys_rst   : std_logic;
signal  sys_clk   : std_logic;
signal  ser_clk   : std_logic;

signal  pix_a     : std_logic_vector(7 downto 0);
signal  pix_b     : std_logic_vector(7 downto 0);
signal  pix_c     : std_logic_vector(7 downto 0);

signal  pix_d     : std_logic_vector(7 downto 0);
signal  pix_e     : std_logic_vector(7 downto 0);
signal  pix_f     : std_logic_vector(7 downto 0);

signal  pix_g     : std_logic_vector(7 downto 0);
signal  pix_h     : std_logic_vector(7 downto 0);
signal  pix_i     : std_logic_vector(7 downto 0);

signal  pix_dval  : std_logic;
signal  pix_fval  : std_logic;
signal  pix_lval  : std_logic;


begin


------------------------------------
-- Top-level camera link receiver --
------------------------------------

u0_cam_top_rx: cam_top_rx

generic map ( config => config )

port map (

  -- system reset (async low)
  rst_n        => rst_n,

  -- Camera-link input clocks (2up/3down/2up)
  xc_p         => rx_xc_p,
  xc_n         => rx_xc_n,
  yc_p         => rx_yc_p,
  yc_n         => rx_yc_n,
  zc_p         => rx_zc_p,
  zc_n         => rx_zc_n,

  -- Camera-link BASE data lanes 0 to 3
  x0_p         => rx_x0_p,
  x0_n         => rx_x0_n,
  x1_p         => rx_x1_p,
  x1_n         => rx_x1_n,
  x2_p         => rx_x2_p,
  x2_n         => rx_x2_n,
  x3_p         => rx_x3_p,
  x3_n         => rx_x3_n,

  -- Camera-link MEDIUM data lanes 0 to 3
  y0_p         => rx_y0_p,
  y0_n         => rx_y0_n,
  y1_p         => rx_y1_p,
  y1_n         => rx_y1_n,
  y2_p         => rx_y2_p,
  y2_n         => rx_y2_n,
  y3_p         => rx_y3_p,
  y3_n         => rx_y3_n,

  -- Camera-link FULL data lanes 0 to 3
  z0_p         => rx_z0_p,
  z0_n         => rx_z0_n,
  z1_p         => rx_z1_p,
  z1_n         => rx_z1_n,
  z2_p         => rx_z2_p,
  z2_n         => rx_z2_n,
  z3_p         => rx_z3_p,
  z3_n         => rx_z3_n,

  -- Forward the clocks (from PLL) and system reset
  sys_rst_f    => sys_rst,
  sys_clk_f    => sys_clk,
  ser_clk_f    => ser_clk,

  -- Parallel video data out (BASE config)
  pix_a        => pix_a,
  pix_b        => pix_b,
  pix_c        => pix_c,

  -- Parallel video data out (MEDIUM config)
  pix_d        => pix_d,
  pix_e        => pix_e,
  pix_f        => pix_f,

  -- Parallel video data out (FULL config)
  pix_g        => pix_g,
  pix_h        => pix_h,
  pix_i        => pix_i,

  -- Video sync flags
  pix_dval     => pix_dval,
  pix_fval     => pix_fval,
  pix_lval     => pix_lval,

  -- Alignment error flags
  err_dval     => err_dval,
  err_fval     => err_fval,
  err_lval     => err_lval );


---------------------------------------
-- Top-level camera link transmitter --
---------------------------------------

u0_cam_top_tx: cam_top_tx

generic map ( config => config )

port map (

  -- system signals
  sys_rst   => sys_rst,
  sys_clk   => sys_clk,
  ser_clk   => ser_clk,

  -- Parallel video data in (BASE config)
  pix_a     => pix_a,
  pix_b     => pix_b,
  pix_c     => pix_c,

  -- Parallel video data in (MEDIUM config)
  pix_d     => pix_d,
  pix_e     => pix_e,
  pix_f     => pix_f,

  -- Parallel video data in (FULL config)
  pix_g     => pix_g,
  pix_h     => pix_h,
  pix_i     => pix_i,

  -- Video sync flags
  pix_dval  => pix_dval,
  pix_fval  => pix_fval,
  pix_lval  => pix_lval,

  -- Camera-link output clocks (2up/3down/2up)
  xc_p      => tx_xc_p,
  xc_n      => tx_xc_n,
  yc_p      => tx_yc_p,
  yc_n      => tx_yc_n,
  zc_p      => tx_zc_p,
  zc_n      => tx_zc_n,

  -- Camera-link BASE data lanes 0 to 3
  x0_p      => tx_x0_p,
  x0_n      => tx_x0_n,
  x1_p      => tx_x1_p,
  x1_n      => tx_x1_n,
  x2_p      => tx_x2_p,
  x2_n      => tx_x2_n,
  x3_p      => tx_x3_p,
  x3_n      => tx_x3_n,

  -- Camera-link MEDIUM data lanes 0 to 3
  y0_p      => tx_y0_p,
  y0_n      => tx_y0_n,
  y1_p      => tx_y1_p,
  y1_n      => tx_y1_n,
  y2_p      => tx_y2_p,
  y2_n      => tx_y2_n,
  y3_p      => tx_y3_p,
  y3_n      => tx_y3_n,

  -- Camera-link FULL data lanes 0 to 3
  z0_p      => tx_z0_p,
  z0_n      => tx_z0_n,
  z1_p      => tx_z1_p,
  z1_n      => tx_z1_n,
  z2_p      => tx_z2_p,
  z2_n      => tx_z2_n,
  z3_p      => tx_z3_p,
  z3_n      => tx_z3_n );


end rtl;
