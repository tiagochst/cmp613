LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY cont4 IS
  PORT (clk, en, sclr: IN STD_LOGIC;
        top: IN STD_LOGIC_VECTOR(3 downto 0);
        q: OUT STD_LOGIC_VECTOR(3 downto 0);
        cout: OUT STD_LOGIC);
END cont4;

ARCHITECTURE rtl OF cont4 IS
  SIGNAL cont: STD_LOGIC_VECTOR(3 downto 0):="0000";
BEGIN
  PROCESS (clk, en, sclr) BEGIN
    IF (clk='1' and clk'event) THEN
      IF (sclr = '1') THEN
        cont <= "0000";
      ELSIF (en = '1') THEN
        IF (cont + "1" >= top) THEN
          cont <= "0000";
        ELSE
          cont <= cont + "1";
        END IF;
      END IF;
    END IF;
  END PROCESS;
  
  cout <= '1' WHEN (cont + "1" >= top and en = '1') 
  ELSE '0';

  q <= cont;
END rtl;
