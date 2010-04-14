LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ff_jk IS --com entrada assincronas
                --de clear e preset
	PORT (clk, j, k, clr, pr: IN STD_LOGIC;
	      q, notq: BUFFER STD_LOGIC);
END ff_jk;

ARCHITECTURE rtl OF ff_jk IS
BEGIN
	PROCESS (clk, clr, pr) BEGIN
		IF (clr='1') THEN
			q <= '0';
		ELSIF (pr='1') THEN
			q <= '1';
		ELSIF (clk'event and clk='1') THEN
			q <= (j and not q) or (not k and q);
		END IF;
	END PROCESS;
	
	notq<=not q;
END rtl;
