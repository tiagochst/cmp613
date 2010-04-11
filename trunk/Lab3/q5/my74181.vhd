LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY my74181 IS
	PORT (a, b, s   : IN SIGNED(3 downto 0);
	      m, ci     : IN STD_LOGIC;
	      f         : OUT SIGNED(3 downto 0);
	      p, g      : OUT STD_LOGIC;
	      aeqb, cn4 : OUT STD_LOGIC);
END my74181;

ARCHITECTURE rtl OF my74181 IS
BEGIN
	PROCESS (a, b, s, m, ci)
		VARIABLE inc : SIGNED(3 downto 0);
	BEGIN
		IF (ci = '1')
		THEN inc := "0001";
		ELSE inc := "0000";
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
				f <= ((a and b) - "0001") + inc;
			WHEN "1000" =>
				f <= (a + (a or b)) + inc;
			WHEN "1001" =>
				f <= (a + b) + inc;
			WHEN "1010" =>
				f <= ((a or not(b)) + (a or b)) + inc;
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
				f <= not(a) + inc;
			WHEN "0001" =>
				f <= (not(a) or not(b)) + inc;
			WHEN "0010" =>
				f <= (not(a) and b) + inc;
			WHEN "0011" =>
				f <= ("0000") + inc;
			WHEN "0100" =>
				f <= (not(a and b)) + inc;
			WHEN "0101" =>
				f <= (not(b)) + inc;
			WHEN "0110" =>
				f <= (a xor b) + inc;
			WHEN "0111" =>
				f <= (a and not(b)) + inc;
			WHEN "1000" =>
				f <= (not(a) or b) + inc;
			WHEN "1001" =>
				f <= (not(a) xor not(b)) + inc;
			WHEN "1010" =>
				f <= (b) + inc;
			WHEN "1011" =>
				f <= (a and b) + inc;
			WHEN "1100" =>
				f <= ("0001") + inc;
			WHEN "1101" =>
				f <= (a or not(b)) + inc;
			WHEN "1110" =>
				f <= (a or b) + inc;
			WHEN "1111" =>
				f <= (a) + inc;
			END CASE op_sel1;
		END CASE mode;
	END PROCESS;
END rtl;
