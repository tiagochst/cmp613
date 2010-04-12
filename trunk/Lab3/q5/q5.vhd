LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY q5 IS
	PORT (a, b, s   : IN STD_LOGIC_VECTOR(3 downto 0);
	      m, cn     : IN STD_LOGIC;
	      f         : OUT STD_LOGIC_VECTOR(3 downto 0);
	      p, g      : OUT STD_LOGIC;
	      aeqb, cn4 : OUT STD_LOGIC);
END q5;

ARCHITECTURE struct OF q5 IS
COMPONENT \74181\ IS
	PORT (	s: IN STD_LOGIC_VECTOR (3 downto 0);
		m, cn: IN STD_LOGIC;
		a3n, a2n, a1n, a0n: IN STD_LOGIC;
		b3n, b2n, b1n, b0n: IN STD_LOGIC;
		gn, pn: OUT STD_LOGIC;
		f3n, f2n, f1n, f0n: OUT STD_LOGIC;
		aeqb: OUT STD_LOGIC;
		cn4: OUT STD_LOGIC);
END COMPONENT;
BEGIN
	maxplus: COMPONENT \74181\
	PORT MAP (s		=> s,		m		=> m,
              cn	=> cn,		a3n		=> a(3),
              a2n	=> a(2),	a1n		=> a(1),
              a0n	=> a(0),	b3n		=> b(3),
              b2n	=> b(2),	b1n		=> b(1),
              b0n	=> b(0), 	gn		=> g,
              pn	=> p,		f3n		=> f(3),
              f2n	=> f(2),	f1n		=> f(1),
              f0n	=> f(0),	aeqb	=> aeqb,
              cn4	=> cn4);
END struct;
