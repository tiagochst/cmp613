LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY cont_int IS
  PORT (clk, en, sclr: IN STD_LOGIC;
        top: IN INTEGER;
        q: OUT INTEGER;
        cout: OUT STD_LOGIC);
END cont_int;

ARCHITECTURE rtl OF cont_int IS
  SIGNAL cont: INTEGER := 0;
BEGIN
  PROCESS (clk, en, sclr) BEGIN
    IF (clk='1' and clk'event) THEN
      IF (sclr = '1') THEN
        cont <= 0;
      ELSIF (en = '1') THEN
        IF (cont + 1 >= top) THEN
          cont <= 0;
        ELSE
          cont <= cont + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  
  cout <= '1' WHEN (cont + 1 >= top and en = '1')
  ELSE '0';

  q <= cont;
END rtl;
