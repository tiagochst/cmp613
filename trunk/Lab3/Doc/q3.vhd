LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY q3 IS
	PORT (clk, sh_r, sh_l: IN STD_LOGIC;
	      x_r, x_l, ld: IN STD_LOGIC;
	      x_pl: IN STD_LOGIC_VECTOR(3 downto 0); --paralela
	      q: BUFFER STD_LOGIC_VECTOR(3 downto 0));
END q3;

ARCHITECTURE struct OF q3 IS
	SIGNAL fd, fq: --E/S dos FF
	   STD_LOGIC_VECTOR(3 downto 0) :="0000"; 
COMPONENT ff_jk IS
	PORT (clk, j, k, clr, pr: IN STD_LOGIC;
	      q, notq: BUFFER STD_LOGIC);
END COMPONENT ff_jk;
COMPONENT mux2 IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      s: IN STD_LOGIC_VECTOR(1 downto 0); 
	      z: OUT STD_LOGIC);
END COMPONENT mux2;
BEGIN	
	--quatro possiveis entrada para FF:
	--proprio, esquerda, direita, '0'
	m0: COMPONENT mux2
		PORT MAP (('0', fq(1), x_l, fq(0)), 
		          (sh_r, sh_l), fd(0));
	m1: COMPONENT mux2
		PORT MAP (('0', fq(2), fq(0), fq(1)),
		          (sh_r, sh_l), fd(1));
	m2: COMPONENT mux2
		PORT MAP (('0', fq(3), fq(1), fq(2)),
		          (sh_r, sh_l), fd(2));
	m3: COMPONENT mux2
		PORT MAP (('0', x_r, fq(2), fq(3)),
		          (sh_r, sh_l), fd(3));
	
	ff0: COMPONENT ff_jk
		PORT MAP (clk, fd(0), not fd(0), 
        ld and (not x_pl(0)), ld and x_pl(0), fq(0));
	ff1: COMPONENT ff_jk
		PORT MAP (clk, fd(1), not fd(1), 
        ld and (not x_pl(1)), ld and x_pl(1), fq(1));
	ff2: COMPONENT ff_jk
		PORT MAP (clk, fd(2), not fd(2), 
        ld and (not x_pl(2)), ld and x_pl(2), fq(2));
	ff3: COMPONENT ff_jk
		PORT MAP (clk, fd(3), not fd(3), 
        ld and (not x_pl(3)), ld and x_pl(3), fq(3));
        
    q <= fq;
END struct;
