Library ieee;
use ieee.std_logic_1164.all;

ENTITY latch_d IS
  PORT(en, d: IN STD_LOGIC;
       q, notq: OUT STD_LOGIC);
END latch_d;

ARCHITECTURE rtl OF latch_d IS
COMPONENT latch_sr IS
  PORT(en,reset,set: IN STD_LOGIC;
         q, notq: OUT STD_LOGIC);
END COMPONENT latch_sr;
BEGIN
  sr: COMPONENT latch_sr
    PORT MAP (en, not d, d, q, notq); 
END rtl;
