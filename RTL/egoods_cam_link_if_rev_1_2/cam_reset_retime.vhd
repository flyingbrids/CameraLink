----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_reset_retime.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Async reset retimer
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity cam_reset_retime is

port (

  clk      : in  std_logic;   -- PLL clock
  locked   : in  std_logic;   -- PLL locked flag
  reset_n  : out std_logic ); -- retimed reset out (active low)

end entity;


architecture rtl of cam_reset_retime is


signal  rst_reg0  : std_logic;
signal  rst_reg1  : std_logic;


begin


-----------------------------------
-- Retime the reset to the clock --
-----------------------------------

reset_retime: process (clk, locked)

begin

  if locked = '0' then
    rst_reg0 <= '0';
    rst_reg1 <= '0';
  elsif clk'event and clk = '1' then
    rst_reg0 <= '1';
    rst_reg1 <= rst_reg0;
  end if;

end process reset_retime;


-----------------------------
-- output reset active low --
-----------------------------

reset_n <= rst_reg1;


end rtl;
