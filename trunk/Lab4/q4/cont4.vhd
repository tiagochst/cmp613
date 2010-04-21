LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY cont4 IS
	PORT (clk, en, clr: IN STD_LOGIC;
	      top: IN STD_LOGIC_VECTOR(3 downto 0);
	      q: OUT STD_LOGIC_VECTOR(3 downto 0);
	      cout: OUT STD_LOGIC);
END cont4;

ARCHITECTURE rtl OF cont4 IS
	SIGNAL count: STD_LOGIC_VECTOR(3 downto 0);
BEGIN
	PROCESS (clk, en, clr) BEGIN
		IF (clr = '1') THEN
			count <= "0000";
		ELSIF (clk='1' and clk'event) THEN
			IF (en = '1') THEN 
				IF (count + "1" = top) THEN
					count <= "0000";
				ELSE
					count <= count + "1";
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	cout <= '1' WHEN (count + "1" = top) ELSE '0';
	q <= count;
END rtl;