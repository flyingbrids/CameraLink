----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2020
--
--    Filename            : enc_8b10b_lut.vhd
--
--    Author              : sjd
--    Date last modified  : 01.09.2020
--    Revision number     : 1.2
--
--    Description         : 8b/10b encoding table
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity enc_8b10b_lut is

port (

  rdin  : in  std_logic;
  addr  : in  std_logic_vector(7 downto 0);
  dout  : out std_logic_vector(9 downto 0);
  rdout : out std_logic );

end entity;


architecture rtl of enc_8b10b_lut is


type rom_type is array (0 to 255) of std_logic_vector(20 downto 0);

-----------------------------------------------------------------------
-- 8bit/10bit encoding table.  Input 8-bit value 'HGFEDCBA' makes up --
-- the LUT address.  This address gets mapped to either the upper or --
-- lower 10-bits of data depending on the current running disparity  --
-- The MSB is the next RD state.  0 = same, 1 = flip                 --
-- Note that the output data mapping is in the order: abcdeifghj     --
-----------------------------------------------------------------------

constant lut_rom : rom_type :=

(

"1001110100" & "0110001011" & '0',
"0111010100" & "1000101011" & '0',
"1011010100" & "0100101011" & '0',
"1100011011" & "1100010100" & '1',
"1101010100" & "0010101011" & '0',
"1010011011" & "1010010100" & '1',
"0110011011" & "0110010100" & '1',
"1110001011" & "0001110100" & '1',
"1110010100" & "0001101011" & '0',
"1001011011" & "1001010100" & '1',
"0101011011" & "0101010100" & '1',
"1101001011" & "1101000100" & '1',
"0011011011" & "0011010100" & '1',
"1011001011" & "1011000100" & '1',
"0111001011" & "0111000100" & '1',
"0101110100" & "1010001011" & '0',
"0110110100" & "1001001011" & '0',
"1000111011" & "1000110100" & '1',
"0100111011" & "0100110100" & '1',
"1100101011" & "1100100100" & '1',
"0010111011" & "0010110100" & '1',
"1010101011" & "1010100100" & '1',
"0110101011" & "0110100100" & '1',
"1110100100" & "0001011011" & '0',
"1100110100" & "0011001011" & '0',
"1001101011" & "1001100100" & '1',
"0101101011" & "0101100100" & '1',
"1101100100" & "0010011011" & '0',
"0011101011" & "0011100100" & '1',
"1011100100" & "0100011011" & '0',
"0111100100" & "1000011011" & '0',
"1010110100" & "0101001011" & '0',
"1001111001" & "0110001001" & '1',
"0111011001" & "1000101001" & '1',
"1011011001" & "0100101001" & '1',
"1100011001" & "1100011001" & '0',
"1101011001" & "0010101001" & '1',
"1010011001" & "1010011001" & '0',
"0110011001" & "0110011001" & '0',
"1110001001" & "0001111001" & '0',
"1110011001" & "0001101001" & '1',
"1001011001" & "1001011001" & '0',
"0101011001" & "0101011001" & '0',
"1101001001" & "1101001001" & '0',
"0011011001" & "0011011001" & '0',
"1011001001" & "1011001001" & '0',
"0111001001" & "0111001001" & '0',
"0101111001" & "1010001001" & '1',
"0110111001" & "1001001001" & '1',
"1000111001" & "1000111001" & '0',
"0100111001" & "0100111001" & '0',
"1100101001" & "1100101001" & '0',
"0010111001" & "0010111001" & '0',
"1010101001" & "1010101001" & '0',
"0110101001" & "0110101001" & '0',
"1110101001" & "0001011001" & '1',
"1100111001" & "0011001001" & '1',
"1001101001" & "1001101001" & '0',
"0101101001" & "0101101001" & '0',
"1101101001" & "0010011001" & '1',
"0011101001" & "0011101001" & '0',
"1011101001" & "0100011001" & '1',
"0111101001" & "1000011001" & '1',
"1010111001" & "0101001001" & '1',
"1001110101" & "0110000101" & '1',
"0111010101" & "1000100101" & '1',
"1011010101" & "0100100101" & '1',
"1100010101" & "1100010101" & '0',
"1101010101" & "0010100101" & '1',
"1010010101" & "1010010101" & '0',
"0110010101" & "0110010101" & '0',
"1110000101" & "0001110101" & '0',
"1110010101" & "0001100101" & '1',
"1001010101" & "1001010101" & '0',
"0101010101" & "0101010101" & '0',
"1101000101" & "1101000101" & '0',
"0011010101" & "0011010101" & '0',
"1011000101" & "1011000101" & '0',
"0111000101" & "0111000101" & '0',
"0101110101" & "1010000101" & '1',
"0110110101" & "1001000101" & '1',
"1000110101" & "1000110101" & '0',
"0100110101" & "0100110101" & '0',
"1100100101" & "1100100101" & '0',
"0010110101" & "0010110101" & '0',
"1010100101" & "1010100101" & '0',
"0110100101" & "0110100101" & '0',
"1110100101" & "0001010101" & '1',
"1100110101" & "0011000101" & '1',
"1001100101" & "1001100101" & '0',
"0101100101" & "0101100101" & '0',
"1101100101" & "0010010101" & '1',
"0011100101" & "0011100101" & '0',
"1011100101" & "0100010101" & '1',
"0111100101" & "1000010101" & '1',
"1010110101" & "0101000101" & '1',
"1001110011" & "0110001100" & '1',
"0111010011" & "1000101100" & '1',
"1011010011" & "0100101100" & '1',
"1100011100" & "1100010011" & '0',
"1101010011" & "0010101100" & '1',
"1010011100" & "1010010011" & '0',
"0110011100" & "0110010011" & '0',
"1110001100" & "0001110011" & '0',
"1110010011" & "0001101100" & '1',
"1001011100" & "1001010011" & '0',
"0101011100" & "0101010011" & '0',
"1101001100" & "1101000011" & '0',
"0011011100" & "0011010011" & '0',
"1011001100" & "1011000011" & '0',
"0111001100" & "0111000011" & '0',
"0101110011" & "1010001100" & '1',
"0110110011" & "1001001100" & '1',
"1000111100" & "1000110011" & '0',
"0100111100" & "0100110011" & '0',
"1100101100" & "1100100011" & '0',
"0010111100" & "0010110011" & '0',
"1010101100" & "1010100011" & '0',
"0110101100" & "0110100011" & '0',
"1110100011" & "0001011100" & '1',
"1100110011" & "0011001100" & '1',
"1001101100" & "1001100011" & '0',
"0101101100" & "0101100011" & '0',
"1101100011" & "0010011100" & '1',
"0011101100" & "0011100011" & '0',
"1011100011" & "0100011100" & '1',
"0111100011" & "1000011100" & '1',
"1010110011" & "0101001100" & '1',
"1001110010" & "0110001101" & '0',
"0111010010" & "1000101101" & '0',
"1011010010" & "0100101101" & '0',
"1100011101" & "1100010010" & '1',
"1101010010" & "0010101101" & '0',
"1010011101" & "1010010010" & '1',
"0110011101" & "0110010010" & '1',
"1110001101" & "0001110010" & '1',
"1110010010" & "0001101101" & '0',
"1001011101" & "1001010010" & '1',
"0101011101" & "0101010010" & '1',
"1101001101" & "1101000010" & '1',
"0011011101" & "0011010010" & '1',
"1011001101" & "1011000010" & '1',
"0111001101" & "0111000010" & '1',
"0101110010" & "1010001101" & '0',
"0110110010" & "1001001101" & '0',
"1000111101" & "1000110010" & '1',
"0100111101" & "0100110010" & '1',
"1100101101" & "1100100010" & '1',
"0010111101" & "0010110010" & '1',
"1010101101" & "1010100010" & '1',
"0110101101" & "0110100010" & '1',
"1110100010" & "0001011101" & '0',
"1100110010" & "0011001101" & '0',
"1001101101" & "1001100010" & '1',
"0101101101" & "0101100010" & '1',
"1101100010" & "0010011101" & '0',
"0011101101" & "0011100010" & '1',
"1011100010" & "0100011101" & '0',
"0111100010" & "1000011101" & '0',
"1010110010" & "0101001101" & '0',
"1001111010" & "0110001010" & '1',
"0111011010" & "1000101010" & '1',
"1011011010" & "0100101010" & '1',
"1100011010" & "1100011010" & '0',
"1101011010" & "0010101010" & '1',
"1010011010" & "1010011010" & '0',
"0110011010" & "0110011010" & '0',
"1110001010" & "0001111010" & '0',
"1110011010" & "0001101010" & '1',
"1001011010" & "1001011010" & '0',
"0101011010" & "0101011010" & '0',
"1101001010" & "1101001010" & '0',
"0011011010" & "0011011010" & '0',
"1011001010" & "1011001010" & '0',
"0111001010" & "0111001010" & '0',
"0101111010" & "1010001010" & '1',
"0110111010" & "1001001010" & '1',
"1000111010" & "1000111010" & '0',
"0100111010" & "0100111010" & '0',
"1100101010" & "1100101010" & '0',
"0010111010" & "0010111010" & '0',
"1010101010" & "1010101010" & '0',
"0110101010" & "0110101010" & '0',
"1110101010" & "0001011010" & '1',
"1100111010" & "0011001010" & '1',
"1001101010" & "1001101010" & '0',
"0101101010" & "0101101010" & '0',
"1101101010" & "0010011010" & '1',
"0011101010" & "0011101010" & '0',
"1011101010" & "0100011010" & '1',
"0111101010" & "1000011010" & '1',
"1010111010" & "0101001010" & '1',
"1001110110" & "0110000110" & '1',
"0111010110" & "1000100110" & '1',
"1011010110" & "0100100110" & '1',
"1100010110" & "1100010110" & '0',
"1101010110" & "0010100110" & '1',
"1010010110" & "1010010110" & '0',
"0110010110" & "0110010110" & '0',
"1110000110" & "0001110110" & '0',
"1110010110" & "0001100110" & '1',
"1001010110" & "1001010110" & '0',
"0101010110" & "0101010110" & '0',
"1101000110" & "1101000110" & '0',
"0011010110" & "0011010110" & '0',
"1011000110" & "1011000110" & '0',
"0111000110" & "0111000110" & '0',
"0101110110" & "1010000110" & '1',
"0110110110" & "1001000110" & '1',
"1000110110" & "1000110110" & '0',
"0100110110" & "0100110110" & '0',
"1100100110" & "1100100110" & '0',
"0010110110" & "0010110110" & '0',
"1010100110" & "1010100110" & '0',
"0110100110" & "0110100110" & '0',
"1110100110" & "0001010110" & '1',
"1100110110" & "0011000110" & '1',
"1001100110" & "1001100110" & '0',
"0101100110" & "0101100110" & '0',
"1101100110" & "0010010110" & '1',
"0011100110" & "0011100110" & '0',
"1011100110" & "0100010110" & '1',
"0111100110" & "1000010110" & '1',
"1010110110" & "0101000110" & '1',
"1001110001" & "0110001110" & '0',
"0111010001" & "1000101110" & '0',
"1011010001" & "0100101110" & '0',
"1100011110" & "1100010001" & '1',
"1101010001" & "0010101110" & '0',
"1010011110" & "1010010001" & '1',
"0110011110" & "0110010001" & '1',
"1110001110" & "0001110001" & '1',
"1110010001" & "0001101110" & '0',
"1001011110" & "1001010001" & '1',
"0101011110" & "0101010001" & '1',
"1101001110" & "1101001000" & '1',
"0011011110" & "0011010001" & '1',
"1011001110" & "1011001000" & '1',
"0111001110" & "0111001000" & '1',
"0101110001" & "1010001110" & '0',
"0110110001" & "1001001110" & '0',
"1000110111" & "1000110001" & '1',
"0100110111" & "0100110001" & '1',
"1100101110" & "1100100001" & '1',
"0010110111" & "0010110001" & '1',
"1010101110" & "1010100001" & '1',
"0110101110" & "0110100001" & '1',
"1110100001" & "0001011110" & '0',
"1100110001" & "0011001110" & '0',
"1001101110" & "1001100001" & '1',
"0101101110" & "0101100001" & '1',
"1101100001" & "0010011110" & '0',
"0011101110" & "0011100001" & '1',
"1011100001" & "0100011110" & '0',
"0111100001" & "1000011110" & '0',
"1010110001" & "0101001110" & '0' );


signal  lut_tmp  : std_logic_vector(20 downto 0);

signal  rd0_a    : std_logic;
signal  rd0_b    : std_logic;
signal  rd0_c    : std_logic;
signal  rd0_d    : std_logic;
signal  rd0_e    : std_logic;
signal  rd0_i    : std_logic;
signal  rd0_f    : std_logic;
signal  rd0_g    : std_logic;
signal  rd0_h    : std_logic;
signal  rd0_j    : std_logic;

signal  rd1_a    : std_logic;
signal  rd1_b    : std_logic;
signal  rd1_c    : std_logic;
signal  rd1_d    : std_logic;
signal  rd1_e    : std_logic;
signal  rd1_i    : std_logic;
signal  rd1_f    : std_logic;
signal  rd1_g    : std_logic;
signal  rd1_h    : std_logic;
signal  rd1_j    : std_logic;

signal  rd_flip  : std_logic;


begin


--------------------------------------------------
-- decode the address (8-bit to 10-bit mapping) --
--------------------------------------------------

lut_tmp <= lut_rom(conv_integer(addr));


----------------------------------
-- reorder the RD- bit mappings --
----------------------------------

rd0_a <= lut_tmp(20);
rd0_b <= lut_tmp(19);
rd0_c <= lut_tmp(18);
rd0_d <= lut_tmp(17);
rd0_e <= lut_tmp(16);
rd0_i <= lut_tmp(15);
rd0_f <= lut_tmp(14);
rd0_g <= lut_tmp(13);
rd0_h <= lut_tmp(12);
rd0_j <= lut_tmp(11);


----------------------------------
-- reorder the RD+ bit mappings --
----------------------------------

rd1_a <= lut_tmp(10);
rd1_b <= lut_tmp(9);
rd1_c <= lut_tmp(8);
rd1_d <= lut_tmp(7);
rd1_e <= lut_tmp(6);
rd1_i <= lut_tmp(5);
rd1_f <= lut_tmp(4);
rd1_g <= lut_tmp(3);
rd1_h <= lut_tmp(2);
rd1_j <= lut_tmp(1);


--------------------------------
-- next running disparity bit --
--------------------------------

rd_flip <= lut_tmp(0);


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