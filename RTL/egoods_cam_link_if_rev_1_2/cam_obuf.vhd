----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_obuf.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Differential output buffer
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


entity cam_obuf is

port (

  di    : in  std_logic;
  do_p  : out std_logic;
  do_n  : out std_logic );

end entity;


architecture rtl of cam_obuf is


begin


------------------------
-- Diff output buffer --
------------------------

u0_obufds: OBUFDS

port map (

  I  => di,
  O  => do_p,
  OB => do_n );


end rtl;
