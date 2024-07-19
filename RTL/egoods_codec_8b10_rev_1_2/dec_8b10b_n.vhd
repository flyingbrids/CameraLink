----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : dec_8b10b_n.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b decoder (N x words)
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity dec_8b10b_n is

generic ( nw : integer := 4 );  -- number of bytes to decode in parallel

port (

  -- system signals
  clk           : in  std_logic;
  reset         : in  std_logic;

  -- n x 10-bit input
  datain        : in  std_logic_vector(nw * 10 - 1 downto 0);  -- N x 10-bit data in
  datain_val    : in  std_logic;                               -- input data valid

  -- n x 8-bit decoded output
  dataout       : out std_logic_vector(nw * 8 - 1 downto 0);   -- N x 8-bit data out
  dataout_k     : out std_logic_vector(nw - 1 downto 0);       -- N x control flags
  dataout_kerr  : out std_logic_vector(nw - 1 downto 0);       -- N x decoding error flags
  dataout_val   : out std_logic );                             -- output data valid

end entity;


architecture rtl of dec_8b10b_n is


component dec_8b10b

port (

  -- system signals
  clk           : in  std_logic;
  reset         : in  std_logic;

  -- 10-bit input
  datain        : in  std_logic_vector(9 downto 0);
  datain_val    : in  std_logic;

  -- 8-bit decoded output
  dataout       : out std_logic_vector(7 downto 0);
  dataout_k     : out std_logic;
  dataout_kerr  : out std_logic;
  dataout_val   : out std_logic );

end component;


signal  val_tmp  : std_logic_vector(nw - 1 downto 0);


begin


--------------------------------------
-- Wire up N x decoders in parallel --
--------------------------------------

gen_dec:  for i in nw downto 1 generate

  u0_dec_8b10b: dec_8b10b

  port map (

    -- system signals
    clk           => clk,
    reset         => reset,

    -- 10-bit input
    datain        => datain((i * 10) - 1 downto (i - 1) * 10),
    datain_val    => datain_val,

    -- 8-bit decoded output
    dataout       => dataout((i * 8) - 1 downto (i - 1) * 8),
    dataout_k     => dataout_k(i - 1),
    dataout_kerr  => dataout_kerr(i - 1),
    dataout_val   => val_tmp(i - 1) );

end generate gen_dec;


---------------------------------------------------
-- only use one valid output flag others are N/C --
---------------------------------------------------

dataout_val <= val_tmp(nw - 1);


end rtl;
