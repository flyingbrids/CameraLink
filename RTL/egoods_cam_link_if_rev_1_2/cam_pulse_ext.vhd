----------------------------------------------------------------------------------------
--
--    USE OF THIS VHDL SOURCE CODE IS STRICTLY SUBJECT TO THE TERMS AND
--    CONDITIONS SET FORTH IN THE ZIPCORES IP CORE LICENSING AGREEMENT
--
--    ----------------------------------------------------------------------------------
--
--    Copyright (c) www.zipcores.com 2022
--
--    Filename            : cam_pulse_ext.vhd
--
--    Author              : sjd
--    Date last modified  : 20.12.2022
--    Revision number     : 1.2
--
--    Description         : Programmable pulse extender
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity cam_pulse_ext is

generic ( pwidth : integer ); -- max 16777215 (24-bit)

port (

  clk        : in  std_logic;
  reset      : in  std_logic;    -- active low
  pulse_in   : in  std_logic;    -- input pulse
  pulse_out  : out std_logic );  -- extended pulse

end entity;


architecture rtl of cam_pulse_ext is


type    pulse_state is (idle, check, extend);

signal  state       : pulse_state := idle;
signal  next_state  : pulse_state := idle;

signal  count       : integer range 0 to 16777215 := 0;  -- 24-bit
signal  count_max   : integer range 0 to 16777215 := 0;  -- 24-bit
signal  count_en    : std_logic := '0';
signal  count_end   : std_logic := '0';


begin


---------------------------
-- maximum counter value --
---------------------------

count_max <= pwidth;


------------------------------
-- controller state machine --
------------------------------

pulse_fsm: process(state, pulse_in, count_end)

begin

  case state is

    when idle => -- do nothing ...

      count_en   <= '0';
      next_state <= check;

    when check =>  -- detect an active high pulse

      count_en <= '0';

      if (pulse_in = '1') then
        next_state <= extend;
      else
        next_state <= check;
      end if;

    when others => -- extend the pulse

      count_en <= '1';

      if (count_end = '1') then
        next_state <= idle;
      else
        next_state <= extend;
      end if;

  end case;

end process pulse_fsm;


--------------------
-- state fsm regs --
--------------------

pulse_fsm_regs: process (clk, reset)

begin

  if reset = '0' then
    state <= idle;
  elsif clk'event and clk = '1' then
    state <= next_state;
  end if;

end process pulse_fsm_regs;


----------------------------
-- Pulse extender counter --
----------------------------

count_regs: process (clk, reset)

begin

  if reset = '0' then
    count <= 0;
  elsif clk'event and clk = '1' then
    if (count_en = '1') then
      count <= count + 1;
    else
      count <= 0;
    end if;
  end if;

end process count_regs;


---------------------
-- End of sequence --
---------------------

count_end <= '1' when (count = count_max) else '0';


----------------------------------------
-- register the extended output pulse --
----------------------------------------

out_reg: process (clk, reset)

begin

  if reset = '0' then
    pulse_out <= '0';
  elsif clk'event and clk = '1' then
    pulse_out <= count_en;
  end if;

end process out_reg;


end rtl;
