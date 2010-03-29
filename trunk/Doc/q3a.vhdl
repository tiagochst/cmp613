LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q3a IS
	PORT (x,y: IN STD_LOGIC_VECTOR(3 downto 0);
	      z: OUT STD_LOGIC_VECTOR(7 downto 0));
END q3a;

ARCHITECTURE struct OF q3a IS
	SIGNAL cm: STD_LOGIC_VECTOR(0 to 2);
	SIGNAL zm: STD_LOGIC_VECTOR(0 to 2);
	SIGNAL hi: STD_LOGIC_VECTOR(3 downto 0);
COMPONENT somador IS
	PORT ( c0, a0, a1 : IN STD_LOGIC ;
		b0, c1 : OUT STD_LOGIC ) ;
END COMPONENT somador;
 COMPONENT \74284\
	PORT ( gan: IN STD_LOGIC;
	gbn: IN STD_LOGIC;
	a: IN STD_LOGIC_VECTOR (4 downto 1);
	b: IN STD_LOGIC_VECTOR (4 downto 1);
	y: OUT STD_LOGIC_VECTOR (8 downto 5));
END COMPONENT;
BEGIN
	--multiplicador para bits menos significativos
	z(0)<=x(0) and y(0);
	s1: COMPONENT somador
		PORT MAP ('0', y(1) and x(0), y(0) and x(1), 	z(1), cm(0));
	s2: COMPONENT somador
		PORT MAP (cm(0), y(1) and x(1), y(0) and x(2), zm(0), cm(1));
	s3: COMPONENT somador
		PORT MAP ('0', y(2) and x(0), zm(0), 	z(2), cm(2));
	s4: COMPONENT somador
		PORT MAP (cm(1), x(3) and y(0), y(1) and x(2), zm(1));
	s5: COMPONENT somador
		PORT MAP (cm(2), zm(1), y(2) and x(1), zm(2));
	s6: COMPONENT somador
		PORT MAP ('0', zm(2), y(3) and x(0), 	z(3));

	mul: COMPONENT \74284\
		PORT MAP ('0', '0', x, y, hi);

	z(7 downto 4)<=hi;
END struct;
