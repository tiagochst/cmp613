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
	SIGNAL s				: SIGNED(3 downto 0);
	SIGNAL f, inc, fi, a, b	: SIGNED(4 downto 0);
	CONSTANT min1			: SIGNED(4 downto 0):="01111";
	
--implementa um not apenas nos bits 0..n-2,
--deixando o maior bit intacto.
FUNCTION notlast(x: SIGNED) return SIGNED IS
BEGIN
	return x(x'length-1)&not(x(x'length-2 downto 0));
END notlast;

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
				f <= (a or notlast(b));
			WHEN "0011" =>
				f <= min1;
			WHEN "0100" =>
				f <= (a + (a and notlast(b)));
			WHEN "0101" =>
				f <= ((a or b) + (a and notlast(b)));
			WHEN "0110" =>
				f <= (a - b + min1);
			WHEN "0111" =>
				f <= ((a and notlast(b)) + min1);
			WHEN "1000" =>
				f <= (a + (a and b));
			WHEN "1001" =>
				f <= (a + b);
			WHEN "1010" =>
				f <= ((a or notlast(b)) + (a and b));
			WHEN "1011" =>
				f <= ((a and b) + min1);
			WHEN "1100" =>
				f <= (a + a);
			WHEN "1101" =>
				f <= ((a or b) + a);
			WHEN "1110" =>
				f <= ((a or notlast(b)) + a);
			WHEN "1111" =>
				f <= (a + min1);
			END CASE op_sel0;
		WHEN '1' =>
			op_sel1: CASE s IS
			WHEN "0000" =>
				f <= notlast(a);
			WHEN "0001" =>
				f <= notlast(a or b);
			WHEN "0010" =>
				f <= notlast(a) and b;
			WHEN "0011" =>
				f <= "00000";
			WHEN "0100" =>
				f <= notlast(a and b);
			WHEN "0101" =>
				f <= notlast(b);
			WHEN "0110" =>
				f <= a xor b;
			WHEN "0111" =>
				f <= a and notlast(b);
			WHEN "1000" =>
				f <= notlast(a) or b;
			WHEN "1001" =>
				f <= a xnor b;
			WHEN "1010" =>
				f <= b;
			WHEN "1011" =>
				f <= a and b;
			WHEN "1100" =>
				f <= "01111";
			WHEN "1101" =>
				f <= a or notlast(b);
			WHEN "1110" =>
				f <= a or b;
			WHEN "1111" =>
				f <= a;
			END CASE op_sel1;
		END CASE mode;
	END PROCESS;
	
	--logica invertida no carry
	inc <= "00001" WHEN (cn='0' and m='0')
	ELSE "00000";
	
	--carrys lookahead prop. e ger. (nao dependem do carry)
	p <= '1' WHEN f > "01111" ELSE '0';
	g <= '1' WHEN f >="01111" ELSE '0';
	
	--inclui carry-in no f
	fi <= f + inc;
	
	cn4 <= '0' WHEN fi(4)='1' ELSE '1';
	aeqb <= '1' WHEN fi(3 downto 0) = "1111" ELSE '0';
	
	f0 <= std_logic_vector(fi (3 downto 0));
END rtl;
