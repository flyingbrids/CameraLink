----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : enc_8b10b_code.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b encoding table (symbols)
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity enc_8b10b_code is

port (

  rdin  : in  std_logic;
  code  : in  std_logic_vector(7 downto 0);
  dout  : out std_logic_vector(9 downto 0);
  rdout : out std_logic;
  err   : out std_logic );

end entity;


architecture rtl of enc_8b10b_code is


-------------------------------------------------------------------
-- 8bit/10bit encoding table for the control code charaters      --
-- Note that the output data mapping is in the order: abcdeifghj --
-------------------------------------------------------------------

constant  K28_0   : std_logic_vector(20 downto 0) := "0011110100" & "1100001011" & '0';
constant  K28_1   : std_logic_vector(20 downto 0) := "0011111001" & "1100000110" & '1';
constant  K28_2   : std_logic_vector(20 downto 0) := "0011110101" & "1100001010" & '1';
constant  K28_3   : std_logic_vector(20 downto 0) := "0011110011" & "1100001100" & '1';
constant  K28_4   : std_logic_vector(20 downto 0) := "0011110010" & "1100001101" & '0';
constant  K28_5   : std_logic_vector(20 downto 0) := "0011111010" & "1100000101" & '1';
constant  K28_6   : std_logic_vector(20 downto 0) := "0011110110" & "1100001001" & '1';
constant  K28_7   : std_logic_vector(20 downto 0) := "0011111000" & "1100000111" & '0';
constant  K23_7   : std_logic_vector(20 downto 0) := "1110101000" & "0001010111" & '0';
constant  K27_7   : std_logic_vector(20 downto 0) := "1101101000" & "0010010111" & '0';
constant  K29_7   : std_logic_vector(20 downto 0) := "1011101000" & "0100010111" & '0';
constant  K30_7   : std_logic_vector(20 downto 0) := "0111101000" & "1000010111" & '0';
constant  KXX_X   : std_logic_vector(20 downto 0) := "0000000000" & "0000000000" & '0';

signal  code_tmp  : std_logic_vector(20 downto 0);

signal  rd0_a     : std_logic;
signal  rd0_b     : std_logic;
signal  rd0_c     : std_logic;
signal  rd0_d     : std_logic;
signal  rd0_e     : std_logic;
signal  rd0_i     : std_logic;
signal  rd0_f     : std_logic;
signal  rd0_g     : std_logic;
signal  rd0_h     : std_logic;
signal  rd0_j     : std_logic;

signal  rd1_a     : std_logic;
signal  rd1_b     : std_logic;
signal  rd1_c     : std_logic;
signal  rd1_d     : std_logic;
signal  rd1_e     : std_logic;
signal  rd1_i     : std_logic;
signal  rd1_f     : std_logic;
signal  rd1_g     : std_logic;
signal  rd1_h     : std_logic;
signal  rd1_j     : std_logic;

signal  rd_flip   : std_logic;


begin


-------------------------------
-- Check for an invalid code --
-------------------------------

err <=

  '0' when (code = "00011100") else
  '0' when (code = "00111100") else
  '0' when (code = "01011100") else
  '0' when (code = "01111100") else
  '0' when (code = "10011100") else
  '0' when (code = "10111100") else
  '0' when (code = "11011100") else
  '0' when (code = "11111100") else
  '0' when (code = "11110111") else
  '0' when (code = "11111011") else
  '0' when (code = "11111101") else
  '0' when (code = "11111110") else
  '1'; -- error, code not recognized!


-----------------------------------------------
-- Look up the correct 8-bit/10-bit mapping  --
-- depending on the input code word          --
-----------------------------------------------

code_tmp <=

  K28_0 when (code = "00011100") else
  K28_1 when (code = "00111100") else
  K28_2 when (code = "01011100") else
  K28_3 when (code = "01111100") else
  K28_4 when (code = "10011100") else
  K28_5 when (code = "10111100") else
  K28_6 when (code = "11011100") else
  K28_7 when (code = "11111100") else
  K23_7 when (code = "11110111") else
  K27_7 when (code = "11111011") else
  K29_7 when (code = "11111101") else
  K30_7 when (code = "11111110") else
  KXX_X; -- error, code not recognized!


--------------------------
-- reorder the RD- bits --
--------------------------

rd0_a <= code_tmp(20);
rd0_b <= code_tmp(19);
rd0_c <= code_tmp(18);
rd0_d <= code_tmp(17);
rd0_e <= code_tmp(16);
rd0_i <= code_tmp(15);
rd0_f <= code_tmp(14);
rd0_g <= code_tmp(13);
rd0_h <= code_tmp(12);
rd0_j <= code_tmp(11);


--------------------------
-- reorder the RD+ bits --
--------------------------

rd1_a <= code_tmp(10);
rd1_b <= code_tmp(9);
rd1_c <= code_tmp(8);
rd1_d <= code_tmp(7);
rd1_e <= code_tmp(6);
rd1_i <= code_tmp(5);
rd1_f <= code_tmp(4);
rd1_g <= code_tmp(3);
rd1_h <= code_tmp(2);
rd1_j <= code_tmp(1);


--------------------------------
-- next running disparity bit --
--------------------------------

rd_flip <= code_tmp(0);


---------------------------------------------------------------------------------
-- select the correct 10-bit mappings depending on the running disparity input --
---------------------------------------------------------------------------------

dout <= rd0_j & rd0_h & rd0_g & rd0_f & rd0_i & rd0_e & rd0_d & rd0_c & rd0_b & rd0_a when (rdin = '0') else
        rd1_j & rd1_h & rd1_g & rd1_f & rd1_i & rd1_e & rd1_d & rd1_c & rd1_b & rd1_a;


------------------------------
-- work out the next rd bit --
------------------------------

rdout <= rdin xor rd_flip;


end rtl;
