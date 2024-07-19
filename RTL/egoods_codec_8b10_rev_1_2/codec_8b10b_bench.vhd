----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : codec_8b10b_bench.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b encoder/decoder testbench
--
----------------------------------------------------------------------------------------


use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity codec_8b10b_bench is
begin
end codec_8b10b_bench;


architecture behav of codec_8b10b_bench is


component enc_8b10b_n

generic ( nb : integer );

port (

  -- system signals
  clk           : in  std_logic;
  reset         : in  std_logic;

  -- n x 8-bit input
  datain        : in  std_logic_vector(nb * 8 - 1 downto 0);
  datain_k      : in  std_logic_vector(nb - 1 downto 0);
  datain_val    : in  std_logic;

  -- n x 10-bit encoded output
  dataout       : out std_logic_vector(nb * 10 - 1 downto 0);
  dataout_kerr  : out std_logic_vector(nb - 1 downto 0);
  dataout_rd    : out std_logic;
  dataout_val   : out std_logic );

end component;


component dec_8b10b_n

generic ( nw : integer );

port (

  -- system signals
  clk           : in  std_logic;
  reset         : in  std_logic;

  -- n x 10-bit input
  datain        : in  std_logic_vector(nw * 10 - 1 downto 0);
  datain_val    : in  std_logic;

  -- n x 8-bit decoded output
  dataout       : out std_logic_vector(nw * 8 - 1 downto 0);
  dataout_k     : out std_logic_vector(nw - 1 downto 0);
  dataout_kerr  : out std_logic_vector(nw - 1 downto 0);
  dataout_val   : out std_logic );

end component;


constant  K28_0       : std_logic_vector(7 downto 0) := "00011100";
constant  K28_1       : std_logic_vector(7 downto 0) := "00111100";
constant  K28_2       : std_logic_vector(7 downto 0) := "01011100";
constant  K28_3       : std_logic_vector(7 downto 0) := "01111100";
constant  K28_4       : std_logic_vector(7 downto 0) := "10011100";
constant  K28_5       : std_logic_vector(7 downto 0) := "10111100";
constant  K28_6       : std_logic_vector(7 downto 0) := "11011100";
constant  K28_7       : std_logic_vector(7 downto 0) := "11111100";
constant  K23_7       : std_logic_vector(7 downto 0) := "11110111";
constant  K27_7       : std_logic_vector(7 downto 0) := "11111011";
constant  K29_7       : std_logic_vector(7 downto 0) := "11111101";
constant  K30_7       : std_logic_vector(7 downto 0) := "11111110";
constant  KXX_0       : std_logic_vector(7 downto 0) := "00000001"; -- dummy bad code #0
constant  KXX_1       : std_logic_vector(7 downto 0) := "00000010"; -- dummy bad code #1
constant  KXX_2       : std_logic_vector(7 downto 0) := "00000100"; -- dummy bad code #2
constant  KXX_3       : std_logic_vector(7 downto 0) := "00001000"; -- dummy bad code #3

signal  clk           : std_logic := '0';
signal  reset         : std_logic := '0';
signal  capture       : std_logic := '0';

signal  rand0         : std_logic_vector(31 downto 0);
signal  rand1         : std_logic_vector(31 downto 0);
signal  rand2         : std_logic_vector(31 downto 0);
signal  rand3         : std_logic_vector(31 downto 0);
signal  rand4         : std_logic_vector(31 downto 0);
signal  rand5         : std_logic_vector(31 downto 0);
signal  rand6         : std_logic_vector(31 downto 0);

signal  code          : std_logic_vector(7 downto 0);

signal  datain        : std_logic_vector(31 downto 0);
signal  datain_k      : std_logic_vector(3 downto 0);
signal  datain_val    : std_logic;

signal  datatmp       : std_logic_vector(39 downto 0);
signal  datatmp_kerr  : std_logic_vector(3 downto 0);
signal  datatmp_rd    : std_logic;
signal  datatmp_val   : std_logic;

signal  dataout       : std_logic_vector(31 downto 0);
signal  dataout_k     : std_logic_vector(3 downto 0);
signal  dataout_kerr  : std_logic_vector(3 downto 0);
signal  dataout_val   : std_logic;


begin


---------------------------
-- Generate a 100MHz clk --
---------------------------

clk <= not clk after 5 ns;


------------------------
-- Test bench control --
------------------------

test_bench_control: process

begin

  -- start of test
  wait for 1 us;
  wait until clk'event and clk = '1';

  -- bring out of reset
  reset <= '1';

  -- start capturing I/O
  capture <= '1';

  -- run sim for a while
  wait for 1 ms;
  wait until clk'event and clk = '1';

  -- stop capturing I/O
  capture <= '0';

  -- wait for all data to flush
  wait for 100 us;

  wait until clk'event and clk = '1';
  assert false report "SIMULATION FINISHED!" severity failure;

end process test_bench_control;


---------------------------------------------------------------
-- LFSR polynomial: x^32 + x^7 + x^5 + x^3 + x^2 + x^1 + x^0 --
-- Pseudo-random sequence repeated every 2^32-1 iterations   --
---------------------------------------------------------------

lfsr_regs: process(clk, reset)

begin

  if reset = '0' then
    rand0 <= "00011011100011100010000100000110";
    rand1 <= "11101010101000010101110101010001";
    rand2 <= "11101111011010100000000000001110";
    rand3 <= "10101010000101010001010101111100";
    rand4 <= "01000101111111010000100000101011";
    rand5 <= "10101010111110101000101010111010";
    rand6 <= "10101010111110101000101010111010";
  elsif clk'event and clk = '1' then
    -- shift left
    rand0(31 downto 1) <= rand0(30 downto 0);
    rand1(31 downto 1) <= rand1(30 downto 0);
    rand2(31 downto 1) <= rand2(30 downto 0);
    rand3(31 downto 1) <= rand3(30 downto 0);
    rand4(31 downto 1) <= rand4(30 downto 0);
    rand5(31 downto 1) <= rand5(30 downto 0);
    rand6(31 downto 1) <= rand6(30 downto 0);
    -- Feedback ...
    rand0(0) <= rand0(31) xor rand0(6) xor rand0(4) xor rand0(2) xor rand0(1) xor rand0(0);
    rand1(0) <= rand1(31) xor rand1(6) xor rand1(4) xor rand1(2) xor rand1(1) xor rand1(0);
    rand2(0) <= rand2(31) xor rand2(6) xor rand2(4) xor rand2(2) xor rand2(1) xor rand2(0);
    rand3(0) <= rand3(31) xor rand3(6) xor rand3(4) xor rand3(2) xor rand3(1) xor rand3(0);
    rand4(0) <= rand4(31) xor rand4(6) xor rand4(4) xor rand4(2) xor rand4(1) xor rand4(0);
    rand5(0) <= rand5(31) xor rand5(6) xor rand5(4) xor rand5(2) xor rand5(1) xor rand5(0);
    rand6(0) <= rand6(31) xor rand6(6) xor rand6(4) xor rand6(2) xor rand6(1) xor rand6(0);
  end if;

end process lfsr_regs;


--------------------------------------------------------------
-- Generate randomized input data and control word stimulus --
--------------------------------------------------------------

datain_val  <= rand0(0) and capture;

datain_k(0) <= rand1(0);
datain_k(1) <= rand2(0);
datain_k(2) <= rand3(0);
datain_k(3) <= rand4(0);

datain(7  downto 0)  <= rand5(7  downto 0)  when (datain_k(0) = '0') else code;
datain(15 downto 8)  <= rand5(15 downto 8)  when (datain_k(1) = '0') else code;
datain(23 downto 16) <= rand5(23 downto 16) when (datain_k(2) = '0') else code;
datain(31 downto 24) <= rand5(31 downto 24) when (datain_k(3) = '0') else code;


----------------
-- code words --
----------------

code <= K28_0 when (rand6(3 downto 0) = "0000") else
        K28_1 when (rand6(3 downto 0) = "0001") else
        K28_2 when (rand6(3 downto 0) = "0010") else
        K28_3 when (rand6(3 downto 0) = "0011") else
        K28_4 when (rand6(3 downto 0) = "0100") else
        K28_5 when (rand6(3 downto 0) = "0101") else
        K28_6 when (rand6(3 downto 0) = "0110") else
        K28_7 when (rand6(3 downto 0) = "0111") else
        K23_7 when (rand6(3 downto 0) = "1000") else
        K27_7 when (rand6(3 downto 0) = "1001") else
        K29_7 when (rand6(3 downto 0) = "1010") else
        K30_7;


-------------
-- ENCODER --
-------------

u0_enc_8b10b_n: enc_8b10b_n

generic map ( nb => 4 ) -- encode 4 bytes in parallel

port map (

  -- system signals
  clk            => clk,
  reset          => reset,

  -- n x 8-bit input
  datain         => datain,
  datain_k       => datain_k,
  datain_val     => datain_val,

  -- n x 10-bit encoded output
  dataout        => datatmp,
  dataout_kerr   => datatmp_kerr,
  dataout_rd     => datatmp_rd,
  dataout_val    => datatmp_val );


-------------
-- DECODER --
-------------

u0_dec_8b10b_n: dec_8b10b_n

generic map ( nw => 4 ) -- decode 4 bytes in parallel

port map (

  -- system signals
  clk           => clk,
  reset         => reset,

  -- n x 10-bit input
  datain        => datatmp,
  datain_val    => datatmp_val,

  -- n x 8-bit decoded output
  dataout       => dataout,
  dataout_k     => dataout_k,
  dataout_kerr  => dataout_kerr,
  dataout_val   => dataout_val );


------------------------
-- Capture input data --
------------------------

grab_data_in: process (clk)

  file      terminal    : text open write_mode is "data_in.txt";
  variable  resoutline  : line;

begin

  if clk'event and clk = '1' then
    if capture = '1' and datain_val = '1' then
      hwrite(resoutline, datain);
      writeline(terminal, resoutline);
    end if;
  end if;

end process grab_data_in;


-------------------------
-- Capture output data --
-------------------------

grab_data_out: process (clk)

  file      terminal    : text open write_mode is "data_out.txt";
  variable  resoutline  : line;

begin

  if clk'event and clk = '1' then
    if capture = '1' and dataout_val = '1' then
      hwrite(resoutline, dataout);
      writeline(terminal, resoutline);
    end if;
  end if;

end process grab_data_out;


end behav;
