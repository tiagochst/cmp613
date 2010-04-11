LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY q3 IS
	PORT (clk, sh_r, sh_l: IN STD_LOGIC;
	      x_r, x_l, ld: IN STD_LOGIC;
	      x_pl: IN STD_LOGIC_VECTOR(3 downto 0); --entr paralela
	      q: OUT STD_LOGIC_VECTOR(3 downto 0));
END q3;

ARCHITECTURE struct OF q3 IS
	SIGNAL fd, fq: STD_LOGIC_VECTOR(3 downto 0); --E/S dos FF
	SIGNAL sh_r2, sh_l2: STD_LOGIC;
COMPONENT ff_jk IS
	PORT (clk, j, k: IN STD_LOGIC;
	      q, notq: BUFFER STD_LOGIC);
END COMPONENT ff_jk;
COMPONENT mux2 IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      s: IN STD_LOGIC_VECTOR(1 downto 0); 
	      z: OUT STD_LOGIC);
END COMPONENT mux2;
BEGIN
	PROCESS (ld, sh_r, sh_l)
	BEGIN
		IF (ld='1') THEN
			--corrige sh_l e sh_r para o mux (ignora shifts)
			sh_r2 <= '1';
			sh_l2 <= '1';
		ELSE
			sh_r2 <= sh_r;
			sh_l2 <= sh_l;
		END IF;
	END PROCESS;
	
	m0: COMPONENT mux2
		PORT MAP ((x_pl(0), x_r, x_l, fq(0)), (sh_r2, sh_l2), fd(0));
	m1: COMPONENT mux2
		PORT MAP ((x_pl(1), x_r, x_l, fq(1)), (sh_r2, sh_l2), fd(1));
	m2: COMPONENT mux2
		PORT MAP ((x_pl(2), x_r, x_l, fq(2)), (sh_r2, sh_l2), fd(2));
	m3: COMPONENT mux2
		PORT MAP ((x_pl(3), x_r, x_l, fq(3)), (sh_r2, sh_l2), fd(3));
	
	ff0: COMPONENT ff_jk
		PORT MAP (clk, fd(0), not fd(0), fq(0));
	ff1: COMPONENT ff_jk
		PORT MAP (clk, fd(1), not fd(1), fq(1));
	ff2: COMPONENT ff_jk
		PORT MAP (clk, fd(2), not fd(2), fq(2));
	ff3: COMPONENT ff_jk
		PORT MAP (clk, fd(3), not fd(3), fq(3));
	
	--enquanto load eh '1', a saida eh diretamente o vetor
	--paralelo, que sera armazenado na proxima borda de su
	--bida de clk (tempo de hold)
	q<=fq WHEN ld='0'
	ELSE x_pl; 
END struct;
