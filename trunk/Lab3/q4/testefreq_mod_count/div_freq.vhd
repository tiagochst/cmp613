LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY div_freq IS
  PORT (clk: IN STD_LOGIC;
  clk_out: OUT STD_LOGIC);
END div_freq;

ARCHITECTURE struct OF div_freq IS
  SIGNAL cont: integer range 0 to 24000000:= 0;
  
  BEGIN
    PROCESS (clk,cont) BEGIN
      IF (clk'event AND clk='1') THEN
        cont<=cont+1;
      END IF;

      IF cont=24000000 then
        clk_out <= '1';
        cont<=0;
      else
        clk_out <='0';
      end if;
    END PROCESS;
END;

