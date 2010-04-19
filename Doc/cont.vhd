LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cont IS
	PORT (clk, reset: IN STD_LOGIC;
	      q: BUFFER STD_LOGIC_VECTOR(2 downto 0));
END cont;
ARCHITECTURE rtl OF cont IS
BEGIN
	--contador sincrono com entrada reset assincrona
	--sequencia: 1, 3, 5, 7, 6, 4, 2
	PROCESS (reset, clk) BEGIN
		IF (reset = '0') THEN --pino ativo baixo
			q <= "001";
		ELSIF (clk'event and clk = '1') THEN
			q(0) <= not q(2) or (not q(1) and q(0));
			q(1) <= not q(1) or (q(2) and q(0));
			q(2) <= (q(2) and (q(0) or q(1))) or (q(1) and q(0));
		END IF;
	END PROCESS;
END rtl;
	