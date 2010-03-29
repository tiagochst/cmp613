LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q2c IS
	PORT (a,bi: IN STD_LOGIC_VECTOR(0 to 3);
          z: BUFFER STD_LOGIC_VECTOR(0 to 3);
          s: IN STD_LOGIC;
          ovf: OUT STD_LOGIC);
END q2c;

ARCHITECTURE struct OF q2c IS
	SIGNAL zcor: STD_LOGIC_VECTOR(0 to 3);
	SIGNAL b, cla: STD_LOGIC_VECTOR(0 to 3);
COMPONENT somador IS
	PORT ( c0, a0, a1 : IN STD_LOGIC ;
		b0, c1 : OUT STD_LOGIC ) ;
END COMPONENT somador;
BEGIN
	compl2: PROCESS (bi, s)
	BEGIN IF s = '0' THEN
			b(3)<=not bi(3) xor (not bi(0) and not bi(1) and not bi(2));
			b(2)<=not bi(2) xor (not bi(0) and not bi(1));
			b(1)<=not bi(1) xor not bi(0);
			b(0)<=bi(0);
		ELSE b<=bi;
		END IF;
	END PROCESS compl2;
	
	--geracao dos carry look-ahead
	cla(0)<=a(0) and b(0);
	cla(1)<=(a(1) and b(1)) or ((a(1) xor b(1)) and cla(0));
	cla(2)<=(a(2) and b(2)) or ((a(2) xor b(2)) and cla(1));
	cla(3)<=(a(3) and b(3)) or ((a(3) xor b(3)) and cla(2));
	
	s0: COMPONENT somador
		PORT MAP ('0', a(0), b(0), z(0));
	s1: COMPONENT somador
		PORT MAP (cla(0), a(1), b(1), z(1));
	s2: COMPONENT somador
		PORT MAP (cla(1), a(2), b(2), z(2));
	s3: COMPONENT somador
		PORT MAP (cla(2), a(3), b(3), z(3));
		
	ovf<=(b(3) and a(3) and not z(3)) or (not b(3) and not a(3) and z(3));
	
	PROCESS (z)
	BEGIN IF z(3) = '1' THEN --aplica compl de 2 para obter o 
			                 --valor absoluto para o display
			zcor(3)<=not z(3) xor (not z(0) and not z(1) and not z(2));
			zcor(2)<=not z(2) xor (not z(0) and not z(1));
			zcor(1)<=not z(1) xor not z(0);
			zcor(0)<=z(0);
		ELSE
			zcor<=z;
		END IF;
	END PROCESS;
END struct;
