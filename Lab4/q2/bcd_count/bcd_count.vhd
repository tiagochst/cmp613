LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd_count IS
	PORT (clk, rst, pre: IN STD_LOGIC;
		  un, de, ce: BUFFER STD_LOGIC_VECTOR(3 downto 0));
END bcd_count;

ARCHITECTURE rtl OF bcd_count IS

COMPONENT \7490\
	PORT (set9a, set9b:    in STD_LOGIC;
	      clra, clrb  :    in STD_LOGIC;
	      clka, clkb  :    in STD_LOGIC;
	      qd, qc, qb, qa: out STD_LOGIC);
END COMPONENT;

BEGIN
	c0: COMPONENT \7490\
		PORT MAP ('0', '0', not rst, not rst, clk, un(0),
		          un(3), un(2), un(1), un(0));
	c1: COMPONENT \7490\
		PORT MAP ('0', '0', not rst, not rst, (un(3) and un(0)), de(0),
		          de(3), de(2), de(1), de(0));
    c2: COMPONENT \7490\
		PORT MAP ('0', '0', not rst, not rst, (de(3) and de(0)), ce(0),
		          ce(3), ce(2), ce(1), ce(0));
END rtl;
