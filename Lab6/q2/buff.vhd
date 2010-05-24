LIBRARY ieee;
USE ieee.std_logic_1164.all;
	      
ENTITY buff IS
	PORT (clk, d: IN STD_LOGIC;
	      q: OUT STD_LOGIC);
END buff;
--Essa entidade implementa uma verificação síncrona
--da mudança de um botão (d). A saída é '1' quando
--o botão muda de low para high e '0' caso contrário.

ARCHITECTURE rtl OF buff IS
	TYPE state_type IS (st_wait, st_high);
	SIGNAL state: state_type;
BEGIN
	PROCESS (clk) BEGIN
		IF (clk'event and clk = '1') THEN
			CASE state IS
				WHEN st_wait =>
					IF (d = '1') THEN
						state <= st_high;
					ELSE
						state <= st_wait;
					END IF;
				WHEN st_high =>
					IF (d = '0') THEN
						state <= st_wait;
					ELSE
						state <= st_high;
					END IF;
			END CASE;
		END IF;
	END PROCESS;

	PROCESS (state, d) BEGIN
		CASE state IS
			WHEN st_wait =>
				IF (d = '1') THEN
					q <= '1';
				ELSE
					q <= '0';
				END IF;
			WHEN st_high =>
				q <= '0';
		END CASE;
	END PROCESS;
END rtl;
