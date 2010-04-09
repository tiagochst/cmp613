LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY q3 IS
	PORT (clk, r_sh, l_sh: IN STD_LOGIC; --sincronas
	      x_sr, ld: IN STD_LOGIC;
	      x_pl: IN STD_LOGIC_VECTOR(3 downto 0); --entr paralela
	      q: BUFFER STD_LOGIC_VECTOR(3 downto 0));
END q3;

ARCHITECTURE struct OF q3 IS
	SIGNAL data, data2: STD_LOGIC_VECTOR(3 downto 0) := "0000";
COMPONENT ff_jk IS
	PORT (clk, j, k: IN STD_LOGIC;
	      q, notq: BUFFER STD_LOGIC);
END COMPONENT ff_jk;
BEGIN
	ff0: COMPONENT ff_jk
		PORT MAP (clk, data2(0), not data2(0), data(0));
	ff1: COMPONENT ff_jk
		PORT MAP (clk, data2(1), not data2(1), data(1));
	ff2: COMPONENT ff_jk
		PORT MAP (clk, data2(2), not data2(2), data(2));
	ff3: COMPONENT ff_jk
		PORT MAP (clk, data2(3), not data2(3), data(3));

	PROCESS (clk, r_sh, l_sh)
	BEGIN
		IF (clk'event and clk='1') THEN
			--realiza o deslocamento
			IF (r_sh = '1') THEN
				data2(0):=data(1);
				data2(1):=data(2);
				data2(2):=data(3);
				data2(3):=x_sr;
			END IF;
			IF (l_sh = '1') THEN
				data2(3):=data(2);
				data2(2):=data(1);
				data2(1):=data(0);
				data2(0):=x_sr;
			END IF;
		END IF;
	END PROCESS;
	
	q<=data2;
END struct;
