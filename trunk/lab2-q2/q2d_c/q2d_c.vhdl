LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q2d_c IS
	PORT (a_0,bi_0: IN STD_LOGIC_VECTOR(0 to 3);
	      z: BUFFER STD_LOGIC_VECTOR(0 to 3);
	      s_0, clk: IN STD_LOGIC;
	      ovf: OUT STD_LOGIC);
END q2d_c;

ARCHITECTURE struct OF q2d_c IS
	SIGNAL b, cla: STD_LOGIC_VECTOR(0 to 3);
	SIGNAL a, bi, z_0: STD_LOGIC_VECTOR(0 to 3); --variaveis sincronas
	SIGNAL s, ovf_0: STD_LOGIC; --variaveis sincronas
COMPONENT q2c IS
	PORT (a,bi: IN STD_LOGIC_VECTOR(0 to 3);
	      z: INOUT STD_LOGIC_VECTOR(0 to 3);
	      s: IN STD_LOGIC;
	      ovf: OUT STD_LOGIC);
END COMPONENT q2c;
BEGIN
	PROCESS (clk) --carrega entradas
	BEGIN
		if (clk'event and clk = '1') THEN 
			a<=a_0;
			bi<=bi_0;
			s<=s_0;
		END IF;
	END PROCESS;
	
	adder: COMPONENT q2c
		PORT MAP (a, bi, z_0, s, ovf_0);
	
	PROCESS (clk)
	BEGIN
		if (clk'event and clk = '1') THEN 
			z<=z_0;
			ovf<=ovf_0;
		END IF;
	END PROCESS;
END struct;
