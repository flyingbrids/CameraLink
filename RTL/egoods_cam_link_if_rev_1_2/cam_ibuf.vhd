----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_ibuf.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Differential input buffer
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


entity cam_ibuf is

port (

  di_p  : in  std_logic;
  di_n  : in  std_logic;
  do    : out std_logic );

end entity;


architecture rtl of cam_ibuf is


begin


-----------------------
-- Diff input buffer --
-----------------------

u0_ibufds: IBUFDS

port map (

  I  => di_p,
  IB => di_n,
  O  => do );


end rtl;
