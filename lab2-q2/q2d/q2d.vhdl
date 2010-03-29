LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q2d IS
	PORT (a_0,bi_0: IN STD_LOGIC_VECTOR(0 to 3);
	      z: BUFFER STD_LOGIC_VECTOR(0 to 3);
	      s_0, clk: IN STD_LOGIC;
	      ovf: OUT STD_LOGIC);
END q2d;

ARCHITECTURE struct OF q2d IS
	SIGNAL b, cla: STD_LOGIC_VECTOR(0 to 3);
	SIGNAL a, bi, z_0: STD_LOGIC_VECTOR(0 to 3); --variaveis sincronas
	SIGNAL s, ovf_0: STD_LOGIC; --variaveis sincronas
COMPONENT somador IS
	PORT ( c0, a0, a1 : IN STD_LOGIC ;
		b0, c1 : OUT STD_LOGIC ) ;
END COMPONENT somador;
BEGIN
	PROCESS (clk) --carrega entradas
	BEGIN
		if (clk'event and clk = '1') THEN 
			a<=a_0;
			bi<=bi_0;
			s<=s_0;
		END IF;
	END PROCESS;
	
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
		PORT MAP ('0', a(0), b(0), z_0(0));
	s1: COMPONENT somador
		PORT MAP (cla(0), a(1), b(1), z_0(1));
	s2: COMPONENT somador
		PORT MAP (cla(1), a(2), b(2), z_0(2));
	s3: COMPONENT somador
		PORT MAP (cla(2), a(3), b(3), z_0(3));
		
	ovf_0<=(b(3) and a(3) and not z_0(3)) or (not b(3) and not a(3) and z_0(3));
	
	PROCESS (clk)
	BEGIN
		if (clk'event and clk = '1') THEN 
			z<=z_0;
			ovf<=ovf_0;
		END IF;
	END PROCESS;
END struct;
