----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : enc_8b10b_n.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b encoder (N x bytes)
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity enc_8b10b_n is

generic ( nb : integer := 4 );  -- number of bytes to encode in parallel

port (

  -- system signals
  clk           : in  std_logic;
  reset         : in  std_logic;

  -- n x 8-bit input
  datain        : in  std_logic_vector(nb * 8 - 1 downto 0);   -- N x 8-bit data in
  datain_k      : in  std_logic_vector(nb - 1 downto 0);       -- N x control flags
  datain_val    : in  std_logic;                               -- input data valid

  -- n x 10-bit encoded output
  dataout       : out std_logic_vector(nb * 10 - 1 downto 0);  -- N x 10-bit data out
  dataout_kerr  : out std_logic_vector(nb - 1 downto 0);       -- N x encoding error flags
  dataout_rd    : out std_logic;                               -- output running disparity
  dataout_val   : out std_logic );                             -- output data valid

end entity;


architecture rtl of enc_8b10b_n is


component enc_8b10b

port (

  -- system signals
  clk            : in  std_logic;
  reset          : in  std_logic;

  -- 8-bit input
  datain         : in  std_logic_vector(7 downto 0);
  datain_k       : in  std_logic;
  datain_rd      : in  std_logic;
  datain_val     : in  std_logic;

  -- 10-bit encoded output
  dataout        : out std_logic_vector(9 downto 0);
  dataout_rd     : out std_logic;
  dataout_rdreg  : out std_logic;
  dataout_kerr   : out std_logic;
  dataout_val    : out std_logic );

end component;


signal  rd_cmb   : std_logic_vector(nb - 1 downto 0);
signal  rd_reg   : std_logic_vector(nb - 1 downto 0);
signal  val_tmp  : std_logic_vector(nb - 1 downto 0);


begin


-----------------------------------------------------------------------------
-- Wire up N x encoders in parallel with cascaded running disparity.  Note --
-- that the combinatorial RD runs in series between encoders with the last --
-- registered RD passing back to the input of the first encoder            --
-----------------------------------------------------------------------------

gen_enc:  for i in nb downto 1 generate

  -------------------------------
  -- Wire up the first encoder --
  -------------------------------

  gen_enc_first:  if (i = nb) generate

    u0_enc_8b10b: enc_8b10b

    port map (

      -- system signals
      clk            => clk,
      reset          => reset,

      -- 8-bit input
      datain         => datain((i * 8) - 1 downto (i - 1) * 8),
      datain_k       => datain_k(i - 1),
      datain_rd      => rd_reg(0), -- registered RD from last encoder
      datain_val     => datain_val,

      -- 10-bit encoded output
      dataout        => dataout((i * 10) - 1 downto (i - 1) * 10),
      dataout_rd     => rd_cmb(i - 1),
      dataout_rdreg  => rd_reg(i - 1),
      dataout_kerr   => dataout_kerr(i - 1),
      dataout_val    => val_tmp(i - 1) );

  end generate gen_enc_first;


  ------------------------------------
  -- Wire up the remaining encoders --
  ------------------------------------

  gen_enc_rest:  if (i /= nb) generate

    u0_enc_8b10b: enc_8b10b

    port map (

      -- system signals
      clk            => clk,
      reset          => reset,

      -- 8-bit input
      datain         => datain((i * 8) - 1 downto (i - 1) * 8),
      datain_k       => datain_k(i - 1),
      datain_rd      => rd_cmb(i), -- combinatorial RD from the previous encoder
      datain_val     => datain_val,

      -- 10-bit encoded output
      dataout        => dataout((i * 10) - 1 downto (i - 1) * 10),
      dataout_rd     => rd_cmb(i - 1),
      dataout_rdreg  => rd_reg(i - 1),
      dataout_kerr   => dataout_kerr(i - 1),
      dataout_val    => val_tmp(i - 1) );

  end generate gen_enc_rest;


end generate gen_enc;


--------------------------------------------
-- Output the Running Disparity (RD) flag --
--------------------------------------------

dataout_rd <= rd_reg(nb - 1);


---------------------------------------------------
-- only use one valid output flag others are N/C --
---------------------------------------------------

dataout_val <= val_tmp(nb - 1);


end rtl;
