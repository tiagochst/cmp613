LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY my74181 IS
	PORT (a0, b0, s0	: IN STD_LOGIC_VECTOR(3 downto 0);
	      m, cn 	   	: IN STD_LOGIC;
	      f0			: OUT STD_LOGIC_VECTOR(3 downto 0);
	      p, g      	: OUT STD_LOGIC;
	      aeqb, cn4 	: OUT STD_LOGIC);
END my74181;

ARCHITECTURE rtl OF my74181 IS
	SIGNAL f, a, b, s	: SIGNED(3 downto 0);
BEGIN
	a <= signed(a0);
	b <= signed(b0);
	s <= signed(s0);
	
	PROCESS (a, b, s, m, cn)
		VARIABLE inc : SIGNED(3 downto 0);
	BEGIN
		IF (cn = '1') --logica invertida
		THEN inc := "0000";
		ELSE inc := "0001";
		END IF;
		
		mode: CASE m IS
		WHEN '0' =>
			op_sel0: CASE s IS
			WHEN "0000" =>
				f <= a + inc;
			WHEN "0001" =>
				f <= (a or b) + inc;
			WHEN "0010" =>
				f <= (a or not(b)) + inc;
			WHEN "0011" =>
				f <= (-"0001") + inc;
			WHEN "0100" =>
				f <= (a + (a and not(b))) + inc;
			WHEN "0101" =>
				f <= ((a or b) + (a and not(b))) + inc;
			WHEN "0110" =>
				f <= (a - b - "0001") + inc;
			WHEN "0111" =>
				f <= ((a and not(b)) - "0001") + inc;
			WHEN "1000" =>
				f <= (a + (a and b)) + inc;
			WHEN "1001" =>
				f <= (a + b) + inc;
			WHEN "1010" =>
				f <= ((a or not(b)) + (a and b)) + inc;
			WHEN "1011" =>
				f <= ((a and b) - "0001") + inc;
			WHEN "1100" =>
				f <= (a + a) + inc;
			WHEN "1101" =>
				f <= ((a or b) + a) + inc;
			WHEN "1110" =>
				f <= ((a or not(b)) + a) + inc;
			WHEN "1111" =>
				f <= (a - "0001") + inc;
			END CASE op_sel0;
		WHEN '1' =>
			op_sel1: CASE s IS
			WHEN "0000" =>
				f <= not(a);
			WHEN "0001" =>
				f <= not(a or b);
			WHEN "0010" =>
				f <= not(a) and b;
			WHEN "0011" =>
				f <= "0000";
			WHEN "0100" =>
				f <= not(a and b);
			WHEN "0101" =>
				f <= not(b);
			WHEN "0110" =>
				f <= a xor b;
			WHEN "0111" =>
				f <= a and not(b);
			WHEN "1000" =>
				f <= not(a) or b;
			WHEN "1001" =>
				f <= a xnor b;
			WHEN "1010" =>
				f <= b;
			WHEN "1011" =>
				f <= a and b;
			WHEN "1100" =>
				f <= "1111";
			WHEN "1101" =>
				f <= a or not(b);
			WHEN "1110" =>
				f <= a or b;
			WHEN "1111" =>
				f <= a;
			END CASE op_sel1;
		END CASE mode;
	END PROCESS;
	
	f0 <= std_logic_vector(f);
END rtl;
