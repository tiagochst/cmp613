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
	SIGNAL s, fi		: SIGNED(3 downto 0);
	SIGNAL a, b, f, inc	: SIGNED(4 downto 0);
BEGIN
	--os vetores de operandos e resultado
	--tem um bit a mais para o carry
	a(3 downto 0) <= signed(a0);
	a(4) <= '0';
	b(3 downto 0) <= signed(b0);
	b(4) <= '0';
	s <= signed(s0);
	
	PROCESS (a, b, s, m, cn)
	BEGIN
		mode: CASE m IS
		WHEN '0' =>
			op_sel0: CASE s IS
			WHEN "0000" =>
				f <= a;
			WHEN "0001" =>
				f <= (a or b);
			WHEN "0010" =>
				f <= (a or not(b));
			WHEN "0011" =>
				f <= (-"00001");
			WHEN "0100" =>
				f <= (a + (a and not(b)));
			WHEN "0101" =>
				f <= ((a or b) + (a and not(b)));
			WHEN "0110" =>
				f <= (a - b - "00001");
			WHEN "0111" =>
				f <= ((a and not(b)) - "00001");
			WHEN "1000" =>
				f <= (a + (a and b));
			WHEN "1001" =>
				f <= (a + b);
			WHEN "1010" =>
				f <= ((a or not(b)) + (a and b));
			WHEN "1011" =>
				f <= ((a and b) - "00001");
			WHEN "1100" =>
				f <= (a + a);
			WHEN "1101" =>
				f <= ((a or b) + a);
			WHEN "1110" =>
				f <= ((a or not(b)) + a);
			WHEN "1111" =>
				f <= (a - "00001");
			END CASE op_sel0;
			
			--g <= '1' WHEN f > "01111" ELSE '0';
			--p <= '1' WHEN f >="01111" ELSE '0';
			--f <= f + inc;
		WHEN '1' =>
			op_sel1: CASE s IS
			WHEN "0000" =>
				f <= not(a);
			WHEN "0001" =>
				f <= not(a or b);
			WHEN "0010" =>
				f <= not(a) and b;
			WHEN "0011" =>
				f <= "00000";
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
				f <= "11111";
			WHEN "1101" =>
				f <= a or not(b);
			WHEN "1110" =>
				f <= a or b;
			WHEN "1111" =>
				f <= a;
			END CASE op_sel1;
		END CASE mode;
	END PROCESS;
	
	inc <= "00000" WHEN cn='1' --logica invertida no carry
	ELSE "00001";
	
	--carrys lookahead prop. e ger. (nao dependem do carry)
	p <= '1' WHEN f > "01111" ELSE '0';
	g <= '1' WHEN f >="01111" ELSE '0';
	
	--inclui carry-in no f
	fi <= (f(3 downto 0) + inc(3 downto 0));
	
	aeqb <= '1' WHEN fi = "1111" ELSE '0';
	
	f0 <= std_logic_vector(fi);
END rtl;
