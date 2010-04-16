LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY exemplo IS
   PORT (clk, d: IN STD_LOGIC;
         ffq, ltq: OUT STD_LOGIC);
END exemplo;

ARCHITECTURE rtl OF exemplo IS
COMPONENT ff_d IS
	port(clk,d: in std_logic;
        q, notq: out std_logic);
end COMPONENT ff_d;
COMPONENT latch_d IS
	PORT(en, d: IN STD_LOGIC;
	     q, notq: OUT STD_LOGIC);
END COMPONENT latch_d;	     
BEGIN
	ff: COMPONENT ff_d
	PORT MAP (clk, d, ffq);
	
	lt: COMPONENT latch_d
	PORT MAP (clk, d, ltq);
END rtl;
