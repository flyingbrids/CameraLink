----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_link_if_bench.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link Rx/Tx passthrough test bench
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_link_if_bench is
begin
end entity;


architecture behav of cam_link_if_bench is


component cam_model

generic ( config : integer );  -- 0: BASE, 1: MEDIUM, 2: FULL

port (

 -- system reset (async low)
  reset   : in  std_logic;

  -- Camera-link clocks (2up/3down/2up)
  xc_p    : out std_logic;
  xc_n    : out std_logic;
  yc_p    : out std_logic;
  yc_n    : out std_logic;
  zc_p    : out std_logic;
  zc_n    : out std_logic;

  -- Camera-link BASE data lanes 0 to 3
  x0_p    : out std_logic;
  x0_n    : out std_logic;
  x1_p    : out std_logic;
  x1_n    : out std_logic;
  x2_p    : out std_logic;
  x2_n    : out std_logic;
  x3_p    : out std_logic;
  x3_n    : out std_logic;

  -- Camera-link MEDIUM data lanes 0 to 3
  y0_p    : out std_logic;
  y0_n    : out std_logic;
  y1_p    : out std_logic;
  y1_n    : out std_logic;
  y2_p    : out std_logic;
  y2_n    : out std_logic;
  y3_p    : out std_logic;
  y3_n    : out std_logic;

  -- Camera-link FULL data lanes 0 to 3
  z0_p    : out std_logic;
  z0_n    : out std_logic;
  z1_p    : out std_logic;
  z1_n    : out std_logic;
  z2_p    : out std_logic;
  z2_n    : out std_logic;
  z3_p    : out std_logic;
  z3_n    : out std_logic;

  -- delayed versions of signals for debug
  xc_del  : out std_logic;
  x0_del  : out std_logic;
  x1_del  : out std_logic;
  x2_del  : out std_logic;
  x3_del  : out std_logic;

  yc_del  : out std_logic;
  y0_del  : out std_logic;
  y1_del  : out std_logic;
  y2_del  : out std_logic;
  y3_del  : out std_logic;

  zc_del  : out std_logic;
  z0_del  : out std_logic;
  z1_del  : out std_logic;
  z2_del  : out std_logic;
  z3_del  : out std_logic );

end component;


component cam_link_if

generic ( config : integer );  -- 0: BASE, 1: MEDIUM, 2: FULL

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

end component;


signal  rst_n     : std_logic := '0';

signal  rx_xc_p   : std_logic;
signal  rx_xc_n   : std_logic;
signal  rx_yc_p   : std_logic;
signal  rx_yc_n   : std_logic;
signal  rx_zc_p   : std_logic;
signal  rx_zc_n   : std_logic;

signal  rx_x0_p   : std_logic;
signal  rx_x0_n   : std_logic;
signal  rx_x1_p   : std_logic;
signal  rx_x1_n   : std_logic;
signal  rx_x2_p   : std_logic;
signal  rx_x2_n   : std_logic;
signal  rx_x3_p   : std_logic;
signal  rx_x3_n   : std_logic;

signal  rx_y0_p   : std_logic;
signal  rx_y0_n   : std_logic;
signal  rx_y1_p   : std_logic;
signal  rx_y1_n   : std_logic;
signal  rx_y2_p   : std_logic;
signal  rx_y2_n   : std_logic;
signal  rx_y3_p   : std_logic;
signal  rx_y3_n   : std_logic;

signal  rx_z0_p   : std_logic;
signal  rx_z0_n   : std_logic;
signal  rx_z1_p   : std_logic;
signal  rx_z1_n   : std_logic;
signal  rx_z2_p   : std_logic;
signal  rx_z2_n   : std_logic;
signal  rx_z3_p   : std_logic;
signal  rx_z3_n   : std_logic;

signal  tx_xc_p   : std_logic;
signal  tx_xc_n   : std_logic;
signal  tx_yc_p   : std_logic;
signal  tx_yc_n   : std_logic;
signal  tx_zc_p   : std_logic;
signal  tx_zc_n   : std_logic;

signal  tx_x0_p   : std_logic;
signal  tx_x0_n   : std_logic;
signal  tx_x1_p   : std_logic;
signal  tx_x1_n   : std_logic;
signal  tx_x2_p   : std_logic;
signal  tx_x2_n   : std_logic;
signal  tx_x3_p   : std_logic;
signal  tx_x3_n   : std_logic;

signal  tx_y0_p   : std_logic;
signal  tx_y0_n   : std_logic;
signal  tx_y1_p   : std_logic;
signal  tx_y1_n   : std_logic;
signal  tx_y2_p   : std_logic;
signal  tx_y2_n   : std_logic;
signal  tx_y3_p   : std_logic;
signal  tx_y3_n   : std_logic;

signal  tx_z0_p   : std_logic;
signal  tx_z0_n   : std_logic;
signal  tx_z1_p   : std_logic;
signal  tx_z1_n   : std_logic;
signal  tx_z2_p   : std_logic;
signal  tx_z2_n   : std_logic;
signal  tx_z3_p   : std_logic;
signal  tx_z3_n   : std_logic;

signal  err_dval  : std_logic;
signal  err_fval  : std_logic;
signal  err_lval  : std_logic;

signal  xc_del    : std_logic;
signal  x0_del    : std_logic;
signal  x1_del    : std_logic;
signal  x2_del    : std_logic;
signal  x3_del    : std_logic;

signal  yc_del    : std_logic;
signal  y0_del    : std_logic;
signal  y1_del    : std_logic;
signal  y2_del    : std_logic;
signal  y3_del    : std_logic;

signal  zc_del    : std_logic;
signal  z0_del    : std_logic;
signal  z1_del    : std_logic;
signal  z2_del    : std_logic;
signal  z3_del    : std_logic;

signal  xc_cmp    : std_logic;
signal  x0_cmp    : std_logic;
signal  x1_cmp    : std_logic;
signal  x2_cmp    : std_logic;
signal  x3_cmp    : std_logic;

signal  yc_cmp    : std_logic;
signal  y0_cmp    : std_logic;
signal  y1_cmp    : std_logic;
signal  y2_cmp    : std_logic;
signal  y3_cmp    : std_logic;

signal  zc_cmp    : std_logic;
signal  z0_cmp    : std_logic;
signal  z1_cmp    : std_logic;
signal  z2_cmp    : std_logic;
signal  z3_cmp    : std_logic;

signal  xc_err    : std_logic;
signal  x0_err    : std_logic;
signal  x1_err    : std_logic;
signal  x2_err    : std_logic;
signal  x3_err    : std_logic;

signal  yc_err    : std_logic;
signal  y0_err    : std_logic;
signal  y1_err    : std_logic;
signal  y2_err    : std_logic;
signal  y3_err    : std_logic;

signal  zc_err    : std_logic;
signal  z0_err    : std_logic;
signal  z1_err    : std_logic;
signal  z2_err    : std_logic;
signal  z3_err    : std_logic;


---------------------------------------------------------------
-- Set the Camera Link configuation mode for simulation here --
---------------------------------------------------------------

-- constant CONFIG  : integer := 0;  -- BASE
-- constant CONFIG  : integer := 1;  -- MEDIUM
   constant CONFIG  : integer := 2;  -- FULL


begin


------------------------
-- Test bench control --
------------------------

test_bench_control: process

begin

  -- wait a while
  wait for 5 us;

  -- de-assert camera reset
  rst_n <= '1';

  -- run sim for a while longer
  wait for 1 ms;

  -- terminate the sim
  assert false report "SIMULATION FINISHED!" severity failure;

end process test_bench_control;


--------------------------------------------------
-- Camera model generates a random test pattern --
--------------------------------------------------

u0_cam_model: cam_model

generic map ( config => CONFIG )

port map (

  -- system reset (async low)
  reset   => rst_n,

  -- Camera-link clocks (2up/3down/2up)
  xc_p    => rx_xc_p,
  xc_n    => rx_xc_n,
  yc_p    => rx_yc_p,
  yc_n    => rx_yc_n,
  zc_p    => rx_zc_p,
  zc_n    => rx_zc_n,

  -- Camera-link BASE data lanes 0 to 3
  x0_p    => rx_x0_p,
  x0_n    => rx_x0_n,
  x1_p    => rx_x1_p,
  x1_n    => rx_x1_n,
  x2_p    => rx_x2_p,
  x2_n    => rx_x2_n,
  x3_p    => rx_x3_p,
  x3_n    => rx_x3_n,

  -- Camera-link MEDIUM data lanes 0 to 3
  y0_p    => rx_y0_p,
  y0_n    => rx_y0_n,
  y1_p    => rx_y1_p,
  y1_n    => rx_y1_n,
  y2_p    => rx_y2_p,
  y2_n    => rx_y2_n,
  y3_p    => rx_y3_p,
  y3_n    => rx_y3_n,

  -- Camera-link FULL data lanes 0 to 3
  z0_p    => rx_z0_p,
  z0_n    => rx_z0_n,
  z1_p    => rx_z1_p,
  z1_n    => rx_z1_n,
  z2_p    => rx_z2_p,
  z2_n    => rx_z2_n,
  z3_p    => rx_z3_p,
  z3_n    => rx_z3_n,

  -- delayed versions of signals for debug
  xc_del  => xc_del,
  x0_del  => x0_del,
  x1_del  => x1_del,
  x2_del  => x2_del,
  x3_del  => x3_del,

  yc_del  => yc_del,
  y0_del  => y0_del,
  y1_del  => y1_del,
  y2_del  => y2_del,
  y3_del  => y3_del,

  zc_del  => zc_del,
  z0_del  => z0_del,
  z1_del  => z1_del,
  z2_del  => z2_del,
  z3_del  => z3_del  );


------------------------------------------
-- Top-level Camera link combined Rx/Tx --
-- component for testing purposes only  --
------------------------------------------

u0_cam_link_if: cam_link_if

generic map ( config => CONFIG )

port map (

  -- system reset (async low)
  rst_n     => rst_n,

  -- Camera-link input clocks (2up/3down/2up)
  rx_xc_p   => rx_xc_p,
  rx_xc_n   => rx_xc_n,
  rx_yc_p   => rx_yc_p,
  rx_yc_n   => rx_yc_n,
  rx_zc_p   => rx_zc_p,
  rx_zc_n   => rx_zc_n,

  -- Camera-link BASE data lanes 0 to 3
  rx_x0_p   => rx_x0_p,
  rx_x0_n   => rx_x0_n,
  rx_x1_p   => rx_x1_p,
  rx_x1_n   => rx_x1_n,
  rx_x2_p   => rx_x2_p,
  rx_x2_n   => rx_x2_n,
  rx_x3_p   => rx_x3_p,
  rx_x3_n   => rx_x3_n,

  -- Camera-link MEDIUM data lanes 0 to 3
  rx_y0_p   => rx_y0_p,
  rx_y0_n   => rx_y0_n,
  rx_y1_p   => rx_y1_p,
  rx_y1_n   => rx_y1_n,
  rx_y2_p   => rx_y2_p,
  rx_y2_n   => rx_y2_n,
  rx_y3_p   => rx_y3_p,
  rx_y3_n   => rx_y3_n,

  -- Camera-link FULL data lanes 0 to 3
  rx_z0_p   => rx_z0_p,
  rx_z0_n   => rx_z0_n,
  rx_z1_p   => rx_z1_p,
  rx_z1_n   => rx_z1_n,
  rx_z2_p   => rx_z2_p,
  rx_z2_n   => rx_z2_n,
  rx_z3_p   => rx_z3_p,
  rx_z3_n   => rx_z3_n,

  -- Camera-link output clocks (2up/3down/2up)
  tx_xc_p   => tx_xc_p,
  tx_xc_n   => tx_xc_n,
  tx_yc_p   => tx_yc_p,
  tx_yc_n   => tx_yc_n,
  tx_zc_p   => tx_zc_p,
  tx_zc_n   => tx_zc_n,

  -- Camera-link BASE data lanes 0 to 3
  tx_x0_p   => tx_x0_p,
  tx_x0_n   => tx_x0_n,
  tx_x1_p   => tx_x1_p,
  tx_x1_n   => tx_x1_n,
  tx_x2_p   => tx_x2_p,
  tx_x2_n   => tx_x2_n,
  tx_x3_p   => tx_x3_p,
  tx_x3_n   => tx_x3_n,

  -- Camera-link MEDIUM data lanes 0 to 3
  tx_y0_p   => tx_y0_p,
  tx_y0_n   => tx_y0_n,
  tx_y1_p   => tx_y1_p,
  tx_y1_n   => tx_y1_n,
  tx_y2_p   => tx_y2_p,
  tx_y2_n   => tx_y2_n,
  tx_y3_p   => tx_y3_p,
  tx_y3_n   => tx_y3_n,

  -- Camera-link FULL data lanes 0 to 3
  tx_z0_p   => tx_z0_p,
  tx_z0_n   => tx_z0_n,
  tx_z1_p   => tx_z1_p,
  tx_z1_n   => tx_z1_n,
  tx_z2_p   => tx_z2_p,
  tx_z2_n   => tx_z2_n,
  tx_z3_p   => tx_z3_p,
  tx_z3_n   => tx_z3_n,

  -- Alignment error flags
  err_dval  => err_dval,
  err_fval  => err_fval,
  err_lval  => err_lval );


------------------------------------------------------------
-- Convert Tx outputs back to single-ended for comparison --
------------------------------------------------------------

xc_cmp <= tx_xc_p;
x0_cmp <= tx_x0_p;
x1_cmp <= tx_x1_p;
x2_cmp <= tx_x2_p;
x3_cmp <= tx_x3_p;

yc_cmp <= tx_yc_p;
y0_cmp <= tx_y0_p;
y1_cmp <= tx_y1_p;
y2_cmp <= tx_y2_p;
y3_cmp <= tx_y3_p;

zc_cmp <= tx_zc_p;
z0_cmp <= tx_z0_p;
z1_cmp <= tx_z1_p;
z2_cmp <= tx_z2_p;
z3_cmp <= tx_z3_p;


----------------------------------------------------------
-- Generate some error flags if there's a data mismatch --
-- (add inertial delay to stop glitches in simulation)  --
----------------------------------------------------------

xc_err <= inertial (xc_cmp xor xc_del) after 1 ps;
x0_err <= inertial (x0_cmp xor x0_del) after 1 ps;
x1_err <= inertial (x1_cmp xor x1_del) after 1 ps;
x2_err <= inertial (x2_cmp xor x2_del) after 1 ps;
x3_err <= inertial (x3_cmp xor x3_del) after 1 ps;

yc_err <= inertial (yc_cmp xor yc_del) after 1 ps;
y0_err <= inertial (y0_cmp xor y0_del) after 1 ps;
y1_err <= inertial (y1_cmp xor y1_del) after 1 ps;
y2_err <= inertial (y2_cmp xor y2_del) after 1 ps;
y3_err <= inertial (y3_cmp xor y3_del) after 1 ps;

zc_err <= inertial (zc_cmp xor zc_del) after 1 ps;
z0_err <= inertial (z0_cmp xor z0_del) after 1 ps;
z1_err <= inertial (z1_cmp xor z1_del) after 1 ps;
z2_err <= inertial (z2_cmp xor z2_del) after 1 ps;
z3_err <= inertial (z3_cmp xor z3_del) after 1 ps;


end behav;
