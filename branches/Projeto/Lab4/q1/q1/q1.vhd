LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY q1 IS
	PORT (hi_clk, reset: IN STD_LOGIC;
	      seg: OUT STD_LOGIC_VECTOR(6 downto 0));
END q1;
ARCHITECTURE rtl OF q1 IS
	SIGNAL q:		STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL clk: 	STD_LOGIC;
	
COMPONENT freq_div IS
	PORT (clk: IN STD_LOGIC;
	      ratio: IN INTEGER;
	      clk_out: OUT STD_LOGIC);
END COMPONENT freq_div;
COMPONENT cont IS
	PORT (clk, reset: IN STD_LOGIC;
	      q: BUFFER STD_LOGIC_VECTOR(2 downto 0));
END COMPONENT cont;
COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

BEGIN
	fd: COMPONENT freq_div
		PORT MAP (hi_clk, 27000000, clk);
		
	ct: COMPONENT cont
		PORT MAP (clk, reset, q);
		
	s0: COMPONENT conv_7seg
		PORT MAP ('0', q(2), q(1), q(0), seg);
END rtl;
	