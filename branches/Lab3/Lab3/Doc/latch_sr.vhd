Library ieee;
USE ieee.std_logic_1164.all;

ENTITY latch_sr IS
  PORT(en,reset,set: IN STD_LOGIC;
       q, notq: OUT STD_LOGIC);
END latch_sr;

ARCHITECTURE rtl OF latch_sr IS
BEGIN
  PROCESS(en,reset,set)
  BEGIN
    IF (en = '1' and (set='1' or reset='1')) THEN
      q <= set;
      notq <= reset;
    END IF;
  END PROCESS;
END rtl;  
