LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY freq_div IS
  PORT (clk: IN STD_LOGIC;
        ratio: IN INTEGER;
        clk_out: BUFFER STD_LOGIC);
END freq_div;

ARCHITECTURE struct OF freq_div IS
  SIGNAL cont: INTEGER := 0;
BEGIN
  PROCESS (clk) BEGIN
    IF (clk'event AND clk='1') THEN
      IF (cont < ratio/2) THEN
        cont <= cont + 1;
      ELSE
        cont <= 0;
        clk_out <= not(clk_out);
      END IF;
    END IF;
  END PROCESS;
END;
