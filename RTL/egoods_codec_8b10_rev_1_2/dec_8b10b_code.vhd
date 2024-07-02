----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : dec_8b10b_code.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b decoding table (symbols)
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity dec_8b10b_code is

port (

  code  : in  std_logic_vector(9 downto 0);
  dout  : out std_logic_vector(7 downto 0);
  derr  : out std_logic );

end entity;


architecture rtl of dec_8b10b_code is


----------------------------------------------------
-- 10bit/8bit decoding table.  Input 10-bit value --
-- abcdeifghj is mapped to 'HGFEDCBA' output      --
----------------------------------------------------

constant  K28_0A   : std_logic_vector(9 downto 0) := "0011110100";
constant  K28_1A   : std_logic_vector(9 downto 0) := "0011111001";
constant  K28_2A   : std_logic_vector(9 downto 0) := "0011110101";
constant  K28_3A   : std_logic_vector(9 downto 0) := "0011110011";
constant  K28_4A   : std_logic_vector(9 downto 0) := "0011110010";
constant  K28_5A   : std_logic_vector(9 downto 0) := "0011111010";
constant  K28_6A   : std_logic_vector(9 downto 0) := "0011110110";
constant  K28_7A   : std_logic_vector(9 downto 0) := "0011111000";
constant  K23_7A   : std_logic_vector(9 downto 0) := "1110101000";
constant  K27_7A   : std_logic_vector(9 downto 0) := "1101101000";
constant  K29_7A   : std_logic_vector(9 downto 0) := "1011101000";
constant  K30_7A   : std_logic_vector(9 downto 0) := "0111101000";

constant  K28_0B   : std_logic_vector(9 downto 0) := "1100001011";
constant  K28_1B   : std_logic_vector(9 downto 0) := "1100000110";
constant  K28_2B   : std_logic_vector(9 downto 0) := "1100001010";
constant  K28_3B   : std_logic_vector(9 downto 0) := "1100001100";
constant  K28_4B   : std_logic_vector(9 downto 0) := "1100001101";
constant  K28_5B   : std_logic_vector(9 downto 0) := "1100000101";
constant  K28_6B   : std_logic_vector(9 downto 0) := "1100001001";
constant  K28_7B   : std_logic_vector(9 downto 0) := "1100000111";
constant  K23_7B   : std_logic_vector(9 downto 0) := "0001010111";
constant  K27_7B   : std_logic_vector(9 downto 0) := "0010010111";
constant  K29_7B   : std_logic_vector(9 downto 0) := "0100010111";
constant  K30_7B   : std_logic_vector(9 downto 0) := "1000010111";


signal  code_swap  : std_logic_vector(9 downto 0);
signal  code_tmp   : std_logic_vector(7 downto 0);


begin


---------------------------------
-- redorder the code bits from --
-- abcdeifghj to jhgfiedcba    --
---------------------------------

code_swap <= code(0) & code(1) & code(2) & code(3) & code(4) &
             code(5) & code(6) & code(7) & code(8) & code(9);


-------------------------------
-- Check for an invalid code --
-------------------------------

derr <=

  '0' when (code_swap = K28_0A) or (code_swap = K28_0B) else
  '0' when (code_swap = K28_1A) or (code_swap = K28_1B) else
  '0' when (code_swap = K28_2A) or (code_swap = K28_2B) else
  '0' when (code_swap = K28_3A) or (code_swap = K28_3B) else
  '0' when (code_swap = K28_4A) or (code_swap = K28_4B) else
  '0' when (code_swap = K28_5A) or (code_swap = K28_5B) else
  '0' when (code_swap = K28_6A) or (code_swap = K28_6B) else
  '0' when (code_swap = K28_7A) or (code_swap = K28_7B) else
  '0' when (code_swap = K23_7A) or (code_swap = K23_7B) else
  '0' when (code_swap = K27_7A) or (code_swap = K27_7B) else
  '0' when (code_swap = K29_7A) or (code_swap = K29_7B) else
  '0' when (code_swap = K30_7A) or (code_swap = K30_7B) else
  '1'; -- error, code not recognized!


-----------------------------------------------
-- Look up the correct 10-bit/8-bit mapping  --
-- depending on the input code word          --
-----------------------------------------------

code_tmp <=

  "00011100" when (code_swap = K28_0A) or (code_swap = K28_0B) else
  "00111100" when (code_swap = K28_1A) or (code_swap = K28_1B) else
  "01011100" when (code_swap = K28_2A) or (code_swap = K28_2B) else
  "01111100" when (code_swap = K28_3A) or (code_swap = K28_3B) else
  "10011100" when (code_swap = K28_4A) or (code_swap = K28_4B) else
  "10111100" when (code_swap = K28_5A) or (code_swap = K28_5B) else
  "11011100" when (code_swap = K28_6A) or (code_swap = K28_6B) else
  "11111100" when (code_swap = K28_7A) or (code_swap = K28_7B) else
  "11110111" when (code_swap = K23_7A) or (code_swap = K23_7B) else
  "11111011" when (code_swap = K27_7A) or (code_swap = K27_7B) else
  "11111101" when (code_swap = K29_7A) or (code_swap = K29_7B) else
  "11111110" when (code_swap = K30_7A) or (code_swap = K30_7B) else
  "00000000"; -- error, code not recognized!


-------------------------------------
-- output the 8-bit re-mapped data --
-------------------------------------

dout <= code_tmp;


end rtl;
