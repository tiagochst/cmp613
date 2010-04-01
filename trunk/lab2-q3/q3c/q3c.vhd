LIBRARY ieee ;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY q3c IS
	PORT (x,y: IN STD_LOGIC_VECTOR(3 downto 0);
	      ok: OUT STD_LOGIC);
END q3c;

ARCHITECTURE struct OF q3c IS
	SIGNAL za: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL zb: integer range 0 to 255;
	SIGNAL x_int, y_int: integer range 0 to 15;
COMPONENT q3a IS
	PORT (x,y: IN STD_LOGIC_VECTOR(3 downto 0);
	      z: OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT q3a;
COMPONENT q3b IS
	PORT (x,y: IN integer range 0 to 15;
	      z: OUT integer range 0 to 255 );
END COMPONENT q3b;
BEGIN
	x_int<=to_integer(unsigned(x));
	y_int<=to_integer(unsigned(y));
	
	mul_str: COMPONENT q3a
		PORT MAP (x, y, za);
		
	mul_com: COMPONENT q3b
		PORT MAP (x_int, y_int, zb);
		
	ok<='1' WHEN (to_integer(unsigned(za)) = zb) ELSE '0';
END struct;
