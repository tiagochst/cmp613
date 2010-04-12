LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY div_freq IS
	PORT (clk: IN STD_LOGIC;
	      clk_out: BUFFER STD_LOGIC);
END div_freq;

ARCHITECTURE struct OF div_freq  IS
	CONSTANT DRAT: integer := 27000000;
	SIGNAL cont: integer range 0 to DRAT:= 0;
BEGIN
	PROCESS (clk) BEGIN
		IF (clk'event AND clk='1') THEN
			cont<=cont+1;
			IF (cont=DRAT/2) THEN
				clk_out <= not clk_out;
			ELSIF (cont=DRAT) THEN
				clk_out <= not clk_out;
				cont<=0;
			END IF;
		END IF;
	END PROCESS;
END;