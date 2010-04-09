Library ieee;
use ieee.std_logic_1164.all;

entity ff_d is
   port(clk,d: in std_logic;
        q, notq: out std_logic);
end ff_d;

architecture rtl of ff_d is
	SIGNAL di: STD_LOGIC;
COMPONENT latch_sr IS
	PORT(en,reset,set: IN STD_LOGIC;
         q, notq: OUT STD_LOGIC);
END COMPONENT latch_sr;
Begin
	--abordagem mestre-escravo:
	--o 1o latch (mestre) funciona com !clk
	--e o 2o (escravo) com clk para simular ff
	
	st0: COMPONENT latch_sr
		PORT MAP (not clk, not d, d, di);
	
	st1: COMPONENT latch_sr
		PORT MAP (clk , not di, di, q, notq);
end rtl;
