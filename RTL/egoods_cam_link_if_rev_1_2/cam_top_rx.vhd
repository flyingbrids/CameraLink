----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_top_rx.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link top-level Rx component
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_top_rx is

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

end entity;


architecture rtl of cam_top_rx is


component cam_ibuf

port (

  di_p  : in  std_logic;
  di_n  : in  std_logic;
  do    : out std_logic );

end component;


component cam_pll

port (

  -- Status and control signals
  reset     : in  std_logic;
  locked    : out std_logic;

  -- Clock in ports
  clk_in1   : in  std_logic;

  -- Clock out ports
  clk_out1  : out std_logic;    -- clock x 1
  clk_out2  : out std_logic;    -- clock x 7 (phase shift 0)
  clk_out3  : out std_logic;    -- clock x 7 (phase shift 90)
  clk_out4  : out std_logic;    -- clock x 7 (phase shift 180)
  clk_out5  : out std_logic );  -- clock x 7 (phase shift 270)

end component;


component cam_reset_retime

port (

  clk      : in  std_logic;   -- PLL clock
  locked   : in  std_logic;   -- PLL locked flag
  reset_n  : out std_logic ); -- retimed reset out (active low)

end component;


component cam_pulse_ext

generic ( pwidth : integer ); -- max 16777215 (24-bit)

port (

  clk        : in  std_logic;
  reset      : in  std_logic;    -- active low
  pulse_in   : in  std_logic;    -- input pulse
  pulse_out  : out std_logic );  -- extended pulse

end component;


component cam_full_rx

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

end component;


signal  pll_reset   : std_logic;
signal  pll_locked  : std_logic;

signal  sys_clk     : std_logic;
signal  ser_clk     : std_logic;
signal  sys_rst     : std_logic;

signal  xc          : std_logic;
signal  x0          : std_logic;
signal  x1          : std_logic;
signal  x2          : std_logic;
signal  x3          : std_logic;

signal  yc          : std_logic;
signal  y0          : std_logic;
signal  y1          : std_logic;
signal  y2          : std_logic;
signal  y3          : std_logic;

signal  zc          : std_logic;
signal  z0          : std_logic;
signal  z1          : std_logic;
signal  z2          : std_logic;
signal  z3          : std_logic;

signal  x_vid_a    : std_logic_vector(7 downto 0);
signal  x_vid_b    : std_logic_vector(7 downto 0);
signal  x_vid_c    : std_logic_vector(7 downto 0);
signal  x_vid_nc   : std_logic;
signal  x_vid_en   : std_logic;
signal  x_vid_vs   : std_logic;
signal  x_vid_hs   : std_logic;

signal  y_vid_a    : std_logic_vector(7 downto 0);
signal  y_vid_b    : std_logic_vector(7 downto 0);
signal  y_vid_c    : std_logic_vector(7 downto 0);
signal  y_vid_nc   : std_logic;
signal  y_vid_en   : std_logic;
signal  y_vid_vs   : std_logic;
signal  y_vid_hs   : std_logic;

signal  z_vid_a    : std_logic_vector(7 downto 0);
signal  z_vid_b    : std_logic_vector(7 downto 0);
signal  z_vid_c    : std_logic_vector(7 downto 0);
signal  z_vid_nc   : std_logic;
signal  z_vid_en   : std_logic;
signal  z_vid_vs   : std_logic;
signal  z_vid_hs   : std_logic;

signal  err_en      : std_logic;
signal  err_vs      : std_logic;
signal  err_hs      : std_logic;


begin


------------------------------------------
-- Differential input buffers channel X --
------------------------------------------

gen_base_config:  if (config = 0) generate

  u00_cam_ibuf: cam_ibuf port map (di_p => xc_p, di_n => xc_n, do => xc);
  u01_cam_ibuf: cam_ibuf port map (di_p => x0_p, di_n => x0_n, do => x0);
  u02_cam_ibuf: cam_ibuf port map (di_p => x1_p, di_n => x1_n, do => x1);
  u03_cam_ibuf: cam_ibuf port map (di_p => x2_p, di_n => x2_n, do => x2);
  u04_cam_ibuf: cam_ibuf port map (di_p => x3_p, di_n => x3_n, do => x3);

  -- N/C
  yc <= '0';
  y0 <= '0';
  y1 <= '0';
  y2 <= '0';
  y3 <= '0';

  -- N/C
  zc <= '0';
  z0 <= '0';
  z1 <= '0';
  z2 <= '0';
  z3 <= '0';

end generate gen_base_config;


------------------------------------------
-- Differential input buffers channel Y --
------------------------------------------

gen_medium_config:  if (config = 1) generate

  u00_cam_ibuf: cam_ibuf port map (di_p => xc_p, di_n => xc_n, do => xc);
  u01_cam_ibuf: cam_ibuf port map (di_p => x0_p, di_n => x0_n, do => x0);
  u02_cam_ibuf: cam_ibuf port map (di_p => x1_p, di_n => x1_n, do => x1);
  u03_cam_ibuf: cam_ibuf port map (di_p => x2_p, di_n => x2_n, do => x2);
  u04_cam_ibuf: cam_ibuf port map (di_p => x3_p, di_n => x3_n, do => x3);

  u05_cam_ibuf: cam_ibuf port map (di_p => yc_p, di_n => yc_n, do => yc);
  u06_cam_ibuf: cam_ibuf port map (di_p => y0_p, di_n => y0_n, do => y0);
  u07_cam_ibuf: cam_ibuf port map (di_p => y1_p, di_n => y1_n, do => y1);
  u08_cam_ibuf: cam_ibuf port map (di_p => y2_p, di_n => y2_n, do => y2);
  u09_cam_ibuf: cam_ibuf port map (di_p => y3_p, di_n => y3_n, do => y3);

  -- N/C
  zc <= '0';
  z0 <= '0';
  z1 <= '0';
  z2 <= '0';
  z3 <= '0';

end generate gen_medium_config;


------------------------------------------
-- Differential input buffers channel Z --
------------------------------------------

gen_full_config:  if (config = 2) generate

  u00_cam_ibuf: cam_ibuf port map (di_p => xc_p, di_n => xc_n, do => xc);
  u01_cam_ibuf: cam_ibuf port map (di_p => x0_p, di_n => x0_n, do => x0);
  u02_cam_ibuf: cam_ibuf port map (di_p => x1_p, di_n => x1_n, do => x1);
  u03_cam_ibuf: cam_ibuf port map (di_p => x2_p, di_n => x2_n, do => x2);
  u04_cam_ibuf: cam_ibuf port map (di_p => x3_p, di_n => x3_n, do => x3);

  u05_cam_ibuf: cam_ibuf port map (di_p => yc_p, di_n => yc_n, do => yc);
  u06_cam_ibuf: cam_ibuf port map (di_p => y0_p, di_n => y0_n, do => y0);
  u07_cam_ibuf: cam_ibuf port map (di_p => y1_p, di_n => y1_n, do => y1);
  u08_cam_ibuf: cam_ibuf port map (di_p => y2_p, di_n => y2_n, do => y2);
  u09_cam_ibuf: cam_ibuf port map (di_p => y3_p, di_n => y3_n, do => y3);

  u10_cam_ibuf: cam_ibuf port map (di_p => zc_p, di_n => zc_n, do => zc);
  u11_cam_ibuf: cam_ibuf port map (di_p => z0_p, di_n => z0_n, do => z0);
  u12_cam_ibuf: cam_ibuf port map (di_p => z1_p, di_n => z1_n, do => z1);
  u13_cam_ibuf: cam_ibuf port map (di_p => z2_p, di_n => z2_n, do => z2);
  u14_cam_ibuf: cam_ibuf port map (di_p => z3_p, di_n => z3_n, do => z3);

end generate gen_full_config;


------------------------------
-- PLL reset is active high --
------------------------------

pll_reset <= not rst_n;


-------------------------------------------
-- PLL                                   --
--                                       --
-- Note: please select the desired phase --
-- shift for the serial clock output by  --
-- connecting the relevant clock output  --
-- Either: clk_out_2,3,4 or 5            --
-------------------------------------------

u0_cam_pll: cam_pll

port map (

  -- Status and control signals
  reset     => pll_reset,   -- active high
  locked    => pll_locked,

  -- Clock in ports
  clk_in1   => xc,          -- only xclk used

  -- Clock out ports
  clk_out1  => sys_clk,     -- clock x 1
  clk_out2  => open,        -- clock x 7 (phase shift 0)   (FAILS in sim)
  clk_out3  => open,        -- clock x 7 (phase shift 90)  (WORKS in sim)
  clk_out4  => ser_clk,     -- clock x 7 (phase shift 180) (WORKS in sim)
  clk_out5  => open );      -- clock x 7 (phase shift 270) (WORKS in sim)


-------------------------------
-- Retime the internal reset --
-------------------------------

u0_cam_reset_retime: cam_reset_retime

port map (

  clk      => sys_clk,
  locked   => pll_locked,
  reset_n  => sys_rst ); -- active low


--------------------------------------------
-- Forward the parallel and serial clocks --
--------------------------------------------

sys_rst_f <= sys_rst;
sys_clk_f <= sys_clk;
ser_clk_f <= ser_clk;


------------------------------------
-- Cameralink FULL implementation --
------------------------------------

u0_cam_full_rx : cam_full_rx

port map (

  -- system signals
  sys_rst    => sys_rst,  -- active low
  sys_clk    => sys_clk,  -- parallel clock
  ser_clk    => ser_clk,  -- serial clock

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
  z3         => z3,

  -- parallel video data out (BASE)
  x_vid_a    => x_vid_a,
  x_vid_b    => x_vid_b,
  x_vid_c    => x_vid_c,
  x_vid_nc   => x_vid_nc,
  x_vid_en   => x_vid_en,
  x_vid_vs   => x_vid_vs,
  x_vid_hs   => x_vid_hs,

  -- parallel video data out (MEDIUM)
  y_vid_a    => y_vid_a,
  y_vid_b    => y_vid_b,
  y_vid_c    => y_vid_c,
  y_vid_nc   => y_vid_nc,
  y_vid_en   => y_vid_en,
  y_vid_vs   => y_vid_vs,
  y_vid_hs   => y_vid_hs,

  -- parallel video data out (FULL)
  z_vid_a    => z_vid_a,
  z_vid_b    => z_vid_b,
  z_vid_c    => z_vid_c,
  z_vid_nc   => z_vid_nc,
  z_vid_en   => z_vid_en,
  z_vid_vs   => z_vid_vs,
  z_vid_hs   => z_vid_hs );


-----------------------------------
-- Wire up the top-level outputs --
-----------------------------------

pix_a    <= x_vid_a;
pix_b    <= x_vid_b;
pix_c    <= x_vid_c;

pix_d    <= y_vid_a;
pix_e    <= y_vid_b;
pix_f    <= y_vid_c;

pix_g    <= z_vid_a;
pix_h    <= z_vid_b;
pix_i    <= z_vid_c;

pix_dval <= x_vid_en;
pix_fval <= x_vid_vs;
pix_lval <= x_vid_hs;


---------------------------------------------------------------
-- Check for a mis-alignment between BASE/MED/FULL streams   --
-- We can do this by checking that en, vs and hs are exactly --
-- the same for each data stream.  If they're not then       --
-- assert an error flag active high.                         --
--                                                           --
-- These error flags must be modified depedning on whether   --
-- we're running a BASE, MEDIUM or FULL configuration        --
---------------------------------------------------------------

gen_base_err_config:  if (config = 0) generate

  err_en <= '0';
  err_vs <= '0';
  err_hs <= '0';

end generate gen_base_err_config;


gen_medium_err_config:  if (config = 1) generate

  err_en <= '0' when (x_vid_en = '0' and y_vid_en = '0') or
                     (x_vid_en = '1' and y_vid_en = '1') else '1';

  err_vs <= '0' when (x_vid_vs = '0' and y_vid_vs = '0') or
                     (x_vid_vs = '1' and y_vid_vs = '1') else '1';

  err_hs <= '0' when (x_vid_hs = '0' and y_vid_hs = '0') or
                     (x_vid_hs = '1' and y_vid_hs = '1') else '1';

end generate gen_medium_err_config;


gen_full_err_config:  if (config = 2) generate

  err_en <= '0' when (x_vid_en = '0' and y_vid_en = '0' and z_vid_en = '0') or
                     (x_vid_en = '1' and y_vid_en = '1' and z_vid_en = '1') else '1';

  err_vs <= '0' when (x_vid_vs = '0' and y_vid_vs = '0' and z_vid_vs = '0') or
                     (x_vid_vs = '1' and y_vid_vs = '1' and z_vid_vs = '1') else '1';

  err_hs <= '0' when (x_vid_hs = '0' and y_vid_hs = '0' and z_vid_hs = '0') or
                     (x_vid_hs = '1' and y_vid_hs = '1' and z_vid_hs = '1') else '1';

end generate gen_full_err_config;


--------------------------------
-- Extend the DVAL error flag --
--------------------------------

u0_cam_pulse_ext: cam_pulse_ext

generic map ( pwidth => 32 )  --  32 system cycles

port map (

  clk        => sys_clk,
  reset      => sys_rst,
  pulse_in   => err_en,
  pulse_out  => err_dval );


--------------------------------
-- Extend the FVAL error flag --
--------------------------------

u1_cam_pulse_ext: cam_pulse_ext

generic map ( pwidth => 32 )  --  32 system cycles

port map (

  clk        => sys_clk,
  reset      => sys_rst,
  pulse_in   => err_vs,
  pulse_out  => err_fval );


--------------------------------
-- Extend the LVAL error flag --
--------------------------------

u2_cam_pulse_ext: cam_pulse_ext

generic map ( pwidth => 32 )  --  32 system cycles

port map (

  clk        => sys_clk,
  reset      => sys_rst,
  pulse_in   => err_hs,
  pulse_out  => err_lval );


end rtl;
