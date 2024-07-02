----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : enc_8b10b.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b encoder
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity enc_8b10b is

port (

  -- system signals
  clk            : in  std_logic;
  reset          : in  std_logic;

  -- 8-bit input
  datain         : in  std_logic_vector(7 downto 0);  -- 8-bit data in
  datain_k       : in  std_logic;                     -- 0 = data, 1 = control
  datain_rd      : in  std_logic;                     -- running disparity in
  datain_val     : in  std_logic;                     -- input data valid

  -- 10-bit encoded output
  dataout        : out std_logic_vector(9 downto 0);  -- 10-bit data out
  dataout_rd     : out std_logic;                     -- running disparity out
  dataout_rdreg  : out std_logic;                     -- running disparity out (registered)
  dataout_kerr   : out std_logic;                     -- encoding error flag
  dataout_val    : out std_logic );                   -- output data valid

end entity;


architecture rtl of enc_8b10b is


component enc_8b10b_lut

port (

  rdin  : in  std_logic;
  addr  : in  std_logic_vector(7 downto 0);
  dout  : out std_logic_vector(9 downto 0);
  rdout : out std_logic );

end component;


component enc_8b10b_code

port (

  rdin  : in  std_logic;
  code  : in  std_logic_vector(7 downto 0);
  dout  : out std_logic_vector(9 downto 0);
  rdout : out std_logic;
  err   : out std_logic );

end component;


signal  dataout_lut      : std_logic_vector(9 downto 0);
signal  dataout_code     : std_logic_vector(9 downto 0);
signal  dataout_mux      : std_logic_vector(9 downto 0);
signal  dataout_rd_lut   : std_logic;
signal  dataout_rd_code  : std_logic;
signal  dataout_rd_mux   : std_logic;
signal  dataout_err      : std_logic;
signal  dataout_err_mux  : std_logic;


begin


------------------------------------------
-- 8-bit to 10-bit mapping of data word --
------------------------------------------

u0_enc_8b10b_lut: enc_8b10b_lut

port map (

  rdin  => datain_rd,
  addr  => datain,
  dout  => dataout_lut,
  rdout => dataout_rd_lut );


---------------------------------------------
-- 8-bit to 10-bit mapping of control word --
---------------------------------------------

u0_enc_8b10b_code: enc_8b10b_code

port map (

  rdin  => datain_rd,
  code  => datain,
  dout  => dataout_code,
  rdout => dataout_rd_code,
  err   => dataout_err );


-------------------------------------
-- mux the combinatorial rd output --
-------------------------------------

dataout_rd_mux <= dataout_rd_lut when (datain_k = '0') else dataout_rd_code;


----------------------------------------
-- export the combinatorial rd output --
----------------------------------------

dataout_rd <= dataout_rd_mux;


------------------------------
-- mux the data/code output --
------------------------------

dataout_mux <= dataout_lut when (datain_k = '0') else dataout_code;


----------------------------------
-- mux the code word error flag --
----------------------------------

dataout_err_mux <= '0' when (datain_k = '0') else dataout_err;


----------------------------------
-- Register data and rd outputs --
----------------------------------

out_reg: process (clk, reset)

begin

  if reset = '0' then
    dataout       <= (others => '0');
    dataout_rdreg <= '0';
    dataout_kerr  <= '0';
  elsif clk'event and clk = '1' then
    if datain_val = '1' then
      dataout       <= dataout_mux;
      dataout_rdreg <= dataout_rd_mux;
      dataout_kerr  <= dataout_err_mux;
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
