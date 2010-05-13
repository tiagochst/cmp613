--------------------------------------
--Contador sincrono de 1 a 6 
--------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY cnt6 is
  port (clk : in std_logic;
        num : out std_logic_vector (2 downto 0));
END cnt6;

architecture rtl of cnt6 is
  SIGNAL cont: std_logic_vector(2 downto 0):="001";

BEGIN
   PROCESS (clk) BEGIN
      IF (clk='1' and clk'event) THEN
            IF (cont + "1" > 6) THEN
               cont <= "001";
            ELSE
               cont <= cont + "1";
            END IF;
         END IF;
   END PROCESS;
   
   num <= cont;
END rtl;
