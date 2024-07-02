----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_model.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Camera link dummy camera model for testing
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_model is

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

end entity;


architecture behav of cam_model is


component cam_obuf

port (

  di    : in  std_logic;
  do_p  : out std_logic;
  do_n  : out std_logic );

end component;


signal  clk     : std_logic := '0';

signal  count   : integer;

signal  rand_a  : std_logic_vector(31 downto 0);
signal  rand_b  : std_logic_vector(31 downto 0);
signal  rand_c  : std_logic_vector(31 downto 0);
signal  rand_d  : std_logic_vector(31 downto 0);
signal  rand_e  : std_logic_vector(31 downto 0);
signal  rand_f  : std_logic_vector(31 downto 0);
signal  rand_g  : std_logic_vector(31 downto 0);
signal  rand_h  : std_logic_vector(31 downto 0);
signal  rand_i  : std_logic_vector(31 downto 0);
signal  rand_j  : std_logic_vector(31 downto 0);
signal  rand_k  : std_logic_vector(31 downto 0);
signal  rand_l  : std_logic_vector(31 downto 0);
signal  rand_m  : std_logic_vector(31 downto 0);
signal  rand_n  : std_logic_vector(31 downto 0);
signal  rand_o  : std_logic_vector(31 downto 0);

signal  xc      : std_logic;
signal  x0      : std_logic;
signal  x1      : std_logic;
signal  x2      : std_logic;
signal  x3      : std_logic;

signal  yc      : std_logic;
signal  y0      : std_logic;
signal  y1      : std_logic;
signal  y2      : std_logic;
signal  y3      : std_logic;

signal  zc      : std_logic;
signal  z0      : std_logic;
signal  z1      : std_logic;
signal  z2      : std_logic;
signal  z3      : std_logic;

signal  dval    : std_logic;
signal  fval    : std_logic;
signal  lval    : std_logic;

signal  xc_reg  : std_logic_vector(31 downto 0);
signal  x0_reg  : std_logic_vector(31 downto 0);
signal  x1_reg  : std_logic_vector(31 downto 0);
signal  x2_reg  : std_logic_vector(31 downto 0);
signal  x3_reg  : std_logic_vector(31 downto 0);

signal  yc_reg  : std_logic_vector(31 downto 0);
signal  y0_reg  : std_logic_vector(31 downto 0);
signal  y1_reg  : std_logic_vector(31 downto 0);
signal  y2_reg  : std_logic_vector(31 downto 0);
signal  y3_reg  : std_logic_vector(31 downto 0);

signal  zc_reg  : std_logic_vector(31 downto 0);
signal  z0_reg  : std_logic_vector(31 downto 0);
signal  z1_reg  : std_logic_vector(31 downto 0);
signal  z2_reg  : std_logic_vector(31 downto 0);
signal  z3_reg  : std_logic_vector(31 downto 0);


begin


-----------------------------------
-- Generate a local serial clock --
-----------------------------------

clk <= not clk after 2.2321 ns;  -- 224 MHz


-----------------
-- Bit counter --
-----------------

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


-------------------------------------------
-- 32-bit (LFSR) random number generator --
-------------------------------------------

lfsr_regs: process(clk, reset)

begin

  if reset = '0' then
    rand_a <= X"25DDE443";
	rand_b <= X"965E13B0";
	rand_c <= X"E81A4811";
	rand_d <= X"3C9DE374";
    rand_e <= X"28EAFEC4";
	rand_f <= X"BD0AA017";
	rand_g <= X"302C46E0";
	rand_h <= X"8DA0C6BC";
    rand_i <= X"C7BF8FE3";
	rand_j <= X"EBA7C28E";
	rand_k <= X"2EE670DA";
	rand_l <= X"A1B1C1D8";
	rand_m <= X"89D6887D";
	rand_n <= X"264AF3FA";
	rand_o <= X"499B487D";
  elsif clk'event and clk = '1' then
    rand_a(31 downto 1) <= rand_a(30 downto 0); rand_a(0) <= rand_a(31) xor rand_a(6) xor rand_a(4) xor rand_a(2) xor rand_a(1) xor rand_a(0);
	rand_b(31 downto 1) <= rand_b(30 downto 0); rand_b(0) <= rand_b(31) xor rand_b(6) xor rand_b(4) xor rand_b(2) xor rand_b(1) xor rand_b(0);
	rand_c(31 downto 1) <= rand_c(30 downto 0); rand_c(0) <= rand_c(31) xor rand_c(6) xor rand_c(4) xor rand_c(2) xor rand_c(1) xor rand_c(0);
	rand_d(31 downto 1) <= rand_d(30 downto 0); rand_d(0) <= rand_d(31) xor rand_d(6) xor rand_d(4) xor rand_d(2) xor rand_d(1) xor rand_d(0);
	rand_e(31 downto 1) <= rand_e(30 downto 0); rand_e(0) <= rand_e(31) xor rand_e(6) xor rand_e(4) xor rand_e(2) xor rand_e(1) xor rand_e(0);
	rand_f(31 downto 1) <= rand_f(30 downto 0); rand_f(0) <= rand_f(31) xor rand_f(6) xor rand_f(4) xor rand_f(2) xor rand_f(1) xor rand_f(0);
	rand_g(31 downto 1) <= rand_g(30 downto 0); rand_g(0) <= rand_g(31) xor rand_g(6) xor rand_g(4) xor rand_g(2) xor rand_g(1) xor rand_g(0);
	rand_h(31 downto 1) <= rand_h(30 downto 0); rand_h(0) <= rand_h(31) xor rand_h(6) xor rand_h(4) xor rand_h(2) xor rand_h(1) xor rand_h(0);
    rand_i(31 downto 1) <= rand_i(30 downto 0); rand_i(0) <= rand_i(31) xor rand_i(6) xor rand_i(4) xor rand_i(2) xor rand_i(1) xor rand_i(0);
	rand_j(31 downto 1) <= rand_j(30 downto 0); rand_j(0) <= rand_j(31) xor rand_j(6) xor rand_j(4) xor rand_j(2) xor rand_j(1) xor rand_j(0);
	rand_k(31 downto 1) <= rand_k(30 downto 0); rand_k(0) <= rand_k(31) xor rand_k(6) xor rand_k(4) xor rand_k(2) xor rand_k(1) xor rand_k(0);
	rand_l(31 downto 1) <= rand_l(30 downto 0); rand_l(0) <= rand_l(31) xor rand_l(6) xor rand_l(4) xor rand_l(2) xor rand_l(1) xor rand_l(0);
	rand_m(31 downto 1) <= rand_m(30 downto 0); rand_m(0) <= rand_m(31) xor rand_m(6) xor rand_m(4) xor rand_m(2) xor rand_m(1) xor rand_m(0);
	rand_n(31 downto 1) <= rand_n(30 downto 0); rand_n(0) <= rand_n(31) xor rand_n(6) xor rand_n(4) xor rand_n(2) xor rand_n(1) xor rand_n(0);
	rand_o(31 downto 1) <= rand_o(30 downto 0); rand_o(0) <= rand_o(31) xor rand_o(6) xor rand_o(4) xor rand_o(2) xor rand_o(1) xor rand_o(0);
  end if;

end process lfsr_regs;


--------------------------
-- Randomized sync bits --
--------------------------

dval <= rand_m(0);
fval <= rand_n(0);
lval <= rand_o(0);


-------------------------------------
-- Assign random bits to channel X --
-------------------------------------

gen_base_config:  if (config = 0) generate

  -- BASE
  x0 <= rand_a(0);
  x1 <= rand_b(0);
  x2 <= dval when (count = 0) else  -- DVAL
        fval when (count = 1) else  -- FVAL
    	lval when (count = 2) else  -- LVAL
  	    rand_c(0);
  x3 <= '0'  when (count = 0) else  -- RES
        rand_d(0);

  -- MEDIUM N/C
  y0 <= '0';
  y1 <= '0';
  y2 <= '0';
  y3 <= '0';

  -- FULL N/C
  z0 <= '0';
  z1 <= '0';
  z2 <= '0';
  z3 <= '0';

  -- Clocks are: 2-up/3-down/2-up
  xc <= '0' when (count > 1) and (count < 5) else '1';
  yc <= '0';
  zc <= '0';

end generate gen_base_config;


---------------------------------------
-- Assign random bits to channel X,Y --
---------------------------------------

gen_medium_config:  if (config = 1) generate

  -- BASE
  x0 <= rand_a(0);
  x1 <= rand_b(0);
  x2 <= dval when (count = 0) else  -- DVAL
        fval when (count = 1) else  -- FVAL
    	lval when (count = 2) else  -- LVAL
  	    rand_c(0);
  x3 <= '0'  when (count = 0) else  -- RES
        rand_d(0);

  -- MEDIUM
  y0 <= rand_e(0);
  y1 <= rand_f(0);
  y2 <= dval when (count = 0) else  -- DVAL
        fval when (count = 1) else  -- FVAL
  	    lval when (count = 2) else  -- LVAL
  	    rand_g(0);
  y3 <= '0'  when (count = 0) else  -- RES
        rand_h(0);

  -- FULL N/C
  z0 <= '0';
  z1 <= '0';
  z2 <= '0';
  z3 <= '0';

  -- Clocks are: 2-up/3-down/2-up
  xc <= '0' when (count > 1) and (count < 5) else '1';
  yc <= '0' when (count > 1) and (count < 5) else '1';
  zc <= '0';

end generate gen_medium_config;


-----------------------------------------
-- Assign random bits to channel X,Y,Z --
-----------------------------------------

gen_full_config:  if (config = 2) generate

  -- BASE
  x0 <= rand_a(0);
  x1 <= rand_b(0);
  x2 <= dval when (count = 0) else  -- DVAL
        fval when (count = 1) else  -- FVAL
    	lval when (count = 2) else  -- LVAL
  	    rand_c(0);
  x3 <= '0'  when (count = 0) else  -- RES
        rand_d(0);

  -- MEDIUM
  y0 <= rand_e(0);
  y1 <= rand_f(0);
  y2 <= dval when (count = 0) else  -- DVAL
        fval when (count = 1) else  -- FVAL
  	    lval when (count = 2) else  -- LVAL
  	    rand_g(0);
  y3 <= '0'  when (count = 0) else  -- RES
        rand_h(0);

  -- FULL
  z0 <= rand_i(0);
  z1 <= rand_j(0);
  z2 <= dval when (count = 0) else  -- DVAL
        fval when (count = 1) else  -- FVAL
  	    lval when (count = 2) else  -- LVAL
  	    rand_k(0);
  z3 <= '0'  when (count = 0) else  -- RES
        rand_l(0);

  -- Clocks are: 2-up/3-down/2-up
  xc <= '0' when (count > 1) and (count < 5) else '1';
  yc <= '0' when (count > 1) and (count < 5) else '1';
  zc <= '0' when (count > 1) and (count < 5) else '1';

end generate gen_full_config;


--------------------------------------------------
-- Differential output buffers channel X (BASE) --
--------------------------------------------------

u00_cam_obuf: cam_obuf port map (di => xc, do_p => xc_p, do_n => xc_n);
u01_cam_obuf: cam_obuf port map (di => x0, do_p => x0_p, do_n => x0_n);
u02_cam_obuf: cam_obuf port map (di => x1, do_p => x1_p, do_n => x1_n);
u03_cam_obuf: cam_obuf port map (di => x2, do_p => x2_p, do_n => x2_n);
u04_cam_obuf: cam_obuf port map (di => x3, do_p => x3_p, do_n => x3_n);


----------------------------------------------------
-- Differential output buffers channel Y (MEDIUM) --
----------------------------------------------------

u05_cam_obuf: cam_obuf port map (di => yc, do_p => yc_p, do_n => yc_n);
u06_cam_obuf: cam_obuf port map (di => y0, do_p => y0_p, do_n => y0_n);
u07_cam_obuf: cam_obuf port map (di => y1, do_p => y1_p, do_n => y1_n);
u08_cam_obuf: cam_obuf port map (di => y2, do_p => y2_p, do_n => y2_n);
u09_cam_obuf: cam_obuf port map (di => y3, do_p => y3_p, do_n => y3_n);


--------------------------------------------------
-- Differential output buffers channel Z (FULL) --
--------------------------------------------------

u10_cam_obuf: cam_obuf port map (di => zc, do_p => zc_p, do_n => zc_n);
u11_cam_obuf: cam_obuf port map (di => z0, do_p => z0_p, do_n => z0_n);
u12_cam_obuf: cam_obuf port map (di => z1, do_p => z1_p, do_n => z1_n);
u13_cam_obuf: cam_obuf port map (di => z2, do_p => z2_p, do_n => z2_n);
u14_cam_obuf: cam_obuf port map (di => z3, do_p => z3_p, do_n => z3_n);


--------------------------------------------------------------
-- Delayed versions of the bits for debug and to compensate --
-- for the latency of the full camera link Rx/Tx            --
--------------------------------------------------------------

shift_regs: process(clk, reset)

begin

  if reset = '0' then
    xc_reg <= (others => '0');
    x0_reg <= (others => '0');
    x1_reg <= (others => '0');
    x2_reg <= (others => '0');
    x3_reg <= (others => '0');

	yc_reg <= (others => '0');
    y0_reg <= (others => '0');
    y1_reg <= (others => '0');
    y2_reg <= (others => '0');
    y3_reg <= (others => '0');

	zc_reg <= (others => '0');
    z0_reg <= (others => '0');
    z1_reg <= (others => '0');
    z2_reg <= (others => '0');
    z3_reg <= (others => '0');

  --elsif clk'event and clk = '1' then -- +ve edge
  elsif clk'event and clk = '0' then -- -ve egde
    xc_reg(27 downto 1) <= xc_reg(26 downto 0); xc_reg(0) <= xc;
    x0_reg(27 downto 1) <= x0_reg(26 downto 0); x0_reg(0) <= x0;
    x1_reg(27 downto 1) <= x1_reg(26 downto 0); x1_reg(0) <= x1;
    x2_reg(27 downto 1) <= x2_reg(26 downto 0); x2_reg(0) <= x2;
    x3_reg(27 downto 1) <= x3_reg(26 downto 0); x3_reg(0) <= x3;

	yc_reg(27 downto 1) <= yc_reg(26 downto 0); yc_reg(0) <= yc;
    y0_reg(27 downto 1) <= y0_reg(26 downto 0); y0_reg(0) <= y0;
    y1_reg(27 downto 1) <= y1_reg(26 downto 0); y1_reg(0) <= y1;
    y2_reg(27 downto 1) <= y2_reg(26 downto 0); y2_reg(0) <= y2;
    y3_reg(27 downto 1) <= y3_reg(26 downto 0); y3_reg(0) <= y3;

	zc_reg(27 downto 1) <= zc_reg(26 downto 0); zc_reg(0) <= zc;
    z0_reg(27 downto 1) <= z0_reg(26 downto 0); z0_reg(0) <= z0;
    z1_reg(27 downto 1) <= z1_reg(26 downto 0); z1_reg(0) <= z1;
    z2_reg(27 downto 1) <= z2_reg(26 downto 0); z2_reg(0) <= z2;
    z3_reg(27 downto 1) <= z3_reg(26 downto 0); z3_reg(0) <= z3;
  end if;

end process shift_regs;


--------------------------
-- Wire up delayed bits --
--------------------------

xc_del <= xc_reg(27);
x0_del <= x0_reg(27);
x1_del <= x1_reg(27);
x2_del <= x2_reg(27);
x3_del <= x3_reg(27);

yc_del <= yc_reg(27);
y0_del <= y0_reg(27);
y1_del <= y1_reg(27);
y2_del <= y2_reg(27);
y3_del <= y3_reg(27);

zc_del <= zc_reg(27);
z0_del <= z0_reg(27);
z1_del <= z1_reg(27);
z2_del <= z2_reg(27);
z3_del <= z3_reg(27);


end behav;
