----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : dec_8b10b.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b decoder
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity dec_8b10b is

port (

  -- system signals
  clk           : in  std_logic;
  reset         : in  std_logic;

  -- 10-bit input
  datain        : in  std_logic_vector(9 downto 0);  -- 10-bit data in
  datain_val    : in  std_logic;                     -- input data valid

  -- 8-bit decoded output
  dataout       : out std_logic_vector(7 downto 0);  -- 8-bit data out
  dataout_k     : out std_logic;                     -- 0 = data, 1 = control
  dataout_kerr  : out std_logic;                     -- decoding error flag
  dataout_val   : out std_logic );                   -- output data valid

end entity;


architecture rtl of dec_8b10b is


component dec_8b10b_lut

port (

  addr  : in  std_logic_vector(9 downto 0);
  dout  : out std_logic_vector(7 downto 0);
  derr  : out std_logic );

end component;


component dec_8b10b_code

port (

  code  : in  std_logic_vector(9 downto 0);
  dout  : out std_logic_vector(7 downto 0);
  derr  : out std_logic );

end component;


signal  dataout_lut      : std_logic_vector(7 downto 0);
signal  dataout_code     : std_logic_vector(7 downto 0);
signal  dataout_mux      : std_logic_vector(7 downto 0);

signal  dataout_lbad     : std_logic;
signal  dataout_cbad     : std_logic;
signal  dataout_k_mux    : std_logic;
signal  dataout_bad_mux  : std_logic;


begin


------------------------------------------
-- 10-bit to 8-bit mapping of data word --
------------------------------------------

u0_dec_8b10b_lut: dec_8b10b_lut

port map (

  addr  => datain,
  dout  => dataout_lut,
  derr  => dataout_lbad );


---------------------------------------------
-- 10-bit to 8-bit mapping of control word --
---------------------------------------------

u0_dec_8b10b_code: dec_8b10b_code

port map (

  code  => datain,
  dout  => dataout_code,
  derr  => dataout_cbad );


-------------------------------
-- mux the data/code outputs --
-------------------------------

dataout_mux <= dataout_lut  when (dataout_lbad = '0') else
               dataout_code;


-----------------------------------
-- control word detection signal --
-----------------------------------

dataout_k_mux <= '0' when (dataout_lbad = '0') else
                 '1' when (dataout_cbad = '0') else '0';


----------------------------------------
-- Generate error flag only when data --
-- word and control word are both bad --
----------------------------------------

dataout_bad_mux <= dataout_lbad and dataout_cbad;


-------------------------------------
-- Register data and error outputs --
-------------------------------------

out_reg: process (clk, reset)

begin

  if reset = '0' then
    dataout      <= (others => '0');
    dataout_k    <= '0';
    dataout_kerr <= '0';
  elsif clk'event and clk = '1' then
    if datain_val = '1' then
      dataout      <= dataout_mux;
      dataout_k    <= dataout_k_mux;
      dataout_kerr <= dataout_bad_mux;
    end if;
  end if;

end process out_reg;


-------------------------
-- Register data valid --
-------------------------

val_reg: process (clk, reset)

begin

  if reset = '0' then
    dataout_val <= '0';
  elsif clk'event and clk = '1' then
    dataout_val <= datain_val;
  end if;

end process val_reg;


end rtl;
