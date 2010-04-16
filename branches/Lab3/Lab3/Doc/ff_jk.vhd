LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ff_jk IS
  PORT (clk, j, k: IN STD_LOGIC;
        q, notq: BUFFER STD_LOGIC);
END ff_jk;

ARCHITECTURE rtl OF ff_jk IS
BEGIN
  PROCESS (clk) BEGIN
    IF (clk'event and clk='1') THEN
      q<=(j and not q) or (not k and q);
    END IF;
  END PROCESS;
  
  notq<=not q;
END rtl;
