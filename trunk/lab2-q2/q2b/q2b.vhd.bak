LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q2b IS
	PORT (a,b: IN STD_LOGIC_VECTOR(0 to 3);
	      z: INOUT STD_LOGIC_VECTOR(0 to 3);
	      s: IN STD_LOGIC;
	      ovf: OUT STD_LOGIC;
	      seg: OUT STD_LOGIC_VECTOR(0 to 7));
END q2b;

ARCHITECTURE struct OF q2b IS
	SHARED VARIABLE zcor: STD_LOGIC_VECTOR(0 to 3);
COMPONENT q2a IS
	PORT (a,bi: IN STD_LOGIC_VECTOR(0 to 3);
	      z: INOUT STD_LOGIC_VECTOR(0 to 3);
	      s: IN STD_LOGIC;
	      ovf: OUT STD_LOGIC);
END COMPONENT q2a;
COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y6,y5,y4,y3,y2,y1,y0: OUT STD_LOGIC);
END COMPONENT conv_7seg;
BEGIN
	sum: COMPONENT q2a
		PORT MAP (a, b, z, s, ovf);
	
	PROCESS (z)
	BEGIN IF z(3) = '1' THEN
			zcor:=not(z);
			zcor(3):=zcor(3) xor (zcor(0) and zcor(1) and zcor(2));
			zcor(2):=zcor(2) xor (zcor(0) and zcor(1));
			zcor(1):=zcor(1) xor zcor(0);
			zcor(0):=not zcor(0);
			seg(7)<='1'; --acender ponto decimal
		ELSE 
			zcor:=z;
			seg(7)<='0';
		END IF;
	END PROCESS;
	
	disp: COMPONENT conv_7seg
		PORT MAP (zcor(3), zcor(2), zcor(1), zcor(0), seg(6), seg(5),
		          seg(4), seg(3), seg(2), seg(1), seg(0));
END struct;