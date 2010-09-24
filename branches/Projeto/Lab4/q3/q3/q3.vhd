LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY q3 IS
	PORT (hi_clk: in STD_LOGIC;
	      clk, ori_clk: out STD_LOGIC);
END q3;

ARCHITECTURE rtl OF q3 IS
	SIGNAL clk_d0: STD_LOGIC;
COMPONENT freq_div IS
	PORT (clk: IN STD_LOGIC;
	      ratio: IN INTEGER;
	      clk_out: OUT STD_LOGIC);
END COMPONENT freq_div;
COMPONENT freq_div6 IS
	PORT (hi_clk: in STD_LOGIC;
	      clk: out STD_LOGIC);
END COMPONENT freq_div6;

BEGIN
	fd0: COMPONENT freq_div --obtem 3 Hz se hi_clk=27MHz
		PORT MAP (hi_clk, 27000000/3, clk_d0);
		
	ori_clk <= clk_d0;
		
	fd1: COMPONENT freq_div6
		PORT MAP (clk_d0, clk);
END rtl;
