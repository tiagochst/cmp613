LIBRARY ieee ;
USE ieee.std_logic_1164.all;

--divisor de frequencia que gera saida com spike
--ou seja, apenas ativa durante um periodo do clk
--de entrada (duty cycle desproporcional)
ENTITY freq_div_sp IS
	PORT (clk: IN STD_LOGIC;
	      ratio: IN INTEGER;
	      tc: BUFFER STD_LOGIC);
END freq_div_sp;

ARCHITECTURE struct OF freq_div_sp IS
	SIGNAL cont: INTEGER := 0;
BEGIN
	PROCESS (clk) BEGIN
		IF (clk'event AND clk='1') THEN
			IF (cont < ratio) THEN
				cont <= cont + 1;
				tc <= '0';
			ELSE
				cont <= 0;
				tc <= '1';
			END IF;
		END IF;
	END PROCESS;
END;