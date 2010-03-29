LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
ENTITY somador IS
	PORT ( c0, a0, a1 : IN STD_LOGIC ;
		b0, c1 : OUT STD_LOGIC ) ;
END somador ;
ARCHITECTURE LogicFunction OF somador IS
  BEGIN
	b0 <= c0 xor (a0 xor a1);
	c1 <= (a0 and a1) or (c0 and (a0 xor a1));
END LogicFunction ;
