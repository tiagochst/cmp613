LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY div_freq IS
	PORT (clk: IN STD_LOGIC;
	      ratio: IN INTEGER;
	      clk_out: BUFFER STD_LOGIC);
END div_freq;

ARCHITECTURE struct OF div_freq  IS
	CONSTANT MAX_RATIO: INTEGER := 27000000;
	SIGNAL cont: INTEGER range 0 to MAX_RATIO := 0;
BEGIN
	PROCESS (clk) BEGIN
		IF (clk'event AND clk='1') THEN
			cont<=cont+1;
			
			IF (cont < ratio/2) THEN
				clk_out <= '0';
			ELSE
				clk_out <= '1';
			END IF;
			
			IF (cont = ratio) THEN
				cont <= 0;
			END IF;
		END IF;
	END PROCESS;
END;