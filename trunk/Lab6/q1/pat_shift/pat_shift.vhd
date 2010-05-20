LIBRARY ieee;
USE ieee.std_logic_1164.all;
	      
ENTITY pat_shift IS
	GENERIC (
		PATT: STD_LOGIC_VECTOR(0 to 7) := "10110001"
	);
	PORT (clk, rstn: IN STD_LOGIC;
	      pb0, pb1: IN STD_LOGIC;
	      shreg: OUT STD_LOGIC_VECTOR(7 downto 0);
	      ok: OUT STD_LOGIC);
END pat_shift;

ARCHITECTURE behav OF pat_shift IS
	SIGNAL zero, um: STD_LOGIC; --sinais síncronos
	
	SIGNAL qb: INTEGER range 0 to 8 := 0;
	SIGNAL x: STD_LOGIC_VECTOR(0 to 7) := "00000000";
	--dados lidos são deslocados em x
	
	COMPONENT buff IS
		PORT (clk, d: IN STD_LOGIC;
			  q: OUT STD_LOGIC);
	END COMPONENT buff;
BEGIN
	bf0: COMPONENT buff
		PORT MAP (clk, not pb0, zero);
	bf1: COMPONENT buff
		PORT MAP (clk, not pb1, um);
		
	PROCESS (clk, rstn)
	BEGIN
		IF (rstn = '0') THEN
			qb <= 0;
			x  <= "00000000";
		ELSIF (rising_edge(clk)) THEN
			--desloca os bits caso uma entrada esteja ativa
			IF (zero = '1') THEN
				x(0 to 6) <= x(1 to 7);
				x(7) <= '0';
			ELSIF (um = '1') THEN
				x(0 to 6) <= x(1 to 7);
				x(7) <= '1';
			END IF;
			
			IF ((zero = '1' or um = '1') and (qb < 8)) THEN
				qb <= qb + 1; --incr número de bits lidos
			END IF;
		END IF;
	END PROCESS;
	
	shreg <= x;
		
	ok <= '1' WHEN (x = PATT and qb = 8)
	ELSE '0';
END behav;
