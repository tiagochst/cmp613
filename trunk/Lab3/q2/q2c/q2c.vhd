LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY q2c IS
	PORT (hi_clk: IN STD_LOGIC;
	      seg0, seg1: OUT STD_LOGIC_VECTOR(6 downto 0));
END q2c;

ARCHITECTURE struct OF q2c IS
	SIGNAL clk: STD_LOGIC;
	SIGNAL xi, xd: STD_LOGIC_VECTOR(2 downto 0);
COMPONENT freq_div IS --divisor de frequencia (27MHz->1,6Hz)
	PORT (hi_clk: IN STD_LOGIC;
		  clk: OUT STD_LOGIC);
END COMPONENT freq_div;
COMPONENT cont8_inc IS
	PORT (clk: IN STD_LOGIC;
	      q: BUFFER STD_LOGIC_VECTOR(2 downto 0));
END COMPONENT cont8_inc;
COMPONENT cont8_dec IS
	PORT (clk: IN STD_LOGIC;
	      q: BUFFER STD_LOGIC_VECTOR(2 downto 0));
END COMPONENT cont8_dec;
COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;
BEGIN
	fd: COMPONENT freq_div
		PORT MAP (hi_clk, clk);
		
	cti: COMPONENT cont8_inc
		PORT MAP (clk, xi);
	ctd: COMPONENT cont8_dec
		PORT MAP (clk, xd);
		
	s0: COMPONENT conv_7seg
		PORT MAP ('0',xi(2),xi(1),xi(0),seg0);
	s1: COMPONENT conv_7seg
		PORT MAP ('0',xd(2),xd(1),xd(0),seg1);
END struct;