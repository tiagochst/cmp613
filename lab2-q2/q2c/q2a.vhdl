LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q2a IS
	PORT (a,bi: IN STD_LOGIC_VECTOR(0 to 3);
	      z: INOUT STD_LOGIC_VECTOR(0 to 3);
	      s: IN STD_LOGIC;
	      ovf: OUT STD_LOGIC);
END q2a;

ARCHITECTURE struct OF q2a IS
	SHARED VARIABLE b, cla, cint: STD_LOGIC_VECTOR(0 to 3);
COMPONENT somador IS
	PORT ( c0, a0, a1 : IN STD_LOGIC ;
		b0, c1 : OUT STD_LOGIC ) ;
END COMPONENT somador;
BEGIN
	PROCESS (bi, s)
	BEGIN IF s = '0' THEN
			b:=not(bi);
			b(3):=b(3) xor (b(0) and b(1) and b(2));
			b(2):=b(2) xor (b(0) and b(1));
			b(1):=b(1) xor b(0);
			b(0):=not b(0);
		ELSE b:=bi;
		END IF;
	END PROCESS;

	cla(0):=x(0) and y(0);
	cla(1):=(x(1) and y(1)) or (x(1) xor y(1)) and cla(0);
	cla(2):=(x(2) and y(2)) or (x(2) xor y(2)) and cla(1);
	cla(3):=(x(3) and y(3)) or (x(3) xor y(3)) and cla(2);
	
	s0: COMPONENT somador
		PORT MAP ('0', a(0), b(0), z(0), cint(0));
	s1: COMPONENT somador
		PORT MAP (cla(0), a(1), b(1), z(1), cint(1));
	s2: COMPONENT somador
		PORT MAP (cla(1), a(2), b(2), z(2), cint(2));
	s3: COMPONENT somador
		PORT MAP (cla(2), a(3), b(3), z(3), cint(3));
		
	ovf<=(b(3) and a(3) and not z(3)) or (not b(3) and not a(3) and z(3));
END struct;
