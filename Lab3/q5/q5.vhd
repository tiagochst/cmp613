LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY q5 IS
	PORT (a, b, s   : IN STD_LOGIC_VECTOR(3 downto 0);
	      m, cn     : IN STD_LOGIC;
	      test		: OUT STD_LOGIC;
	      seg0		: OUT STD_LOGIC_VECTOR(6 downto 0);
	      --tmp:
	      po1, po2, go1, go2, cn4o1, cn4o2, abo1, abo2: OUT STD_LOGIC;
	      f		   : OUT STD_LOGIC_VECTOR(3 downto 0));
END q5;

ARCHITECTURE struct OF q5 IS
SIGNAL	  f1, f2    			: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL    p1, p2, g1, g2    	: STD_LOGIC;
SIGNAL    ab1, ab2, cn4_1, cn4_2: STD_LOGIC;
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
COMPONENT my74181 IS
	PORT (a0, b0, s0	: IN STD_LOGIC_VECTOR(3 downto 0);
	      m, cn 	   	: IN STD_LOGIC;
	      f0			: OUT STD_LOGIC_VECTOR(3 downto 0);
	      p, g      	: OUT STD_LOGIC;
	      aeqb, cn4 	: OUT STD_LOGIC);
END COMPONENT my74181;
COMPONENT conv_7seg IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;
BEGIN
	maxplus: COMPONENT \74181\
	PORT MAP (s		=> s,		m		=> m,
              cn	=> cn,		a3n		=> a(3),
              a2n	=> a(2),	a1n		=> a(1),
              a0n	=> a(0),	b3n		=> b(3),
              b2n	=> b(2),	b1n		=> b(1),
              b0n	=> b(0), 	gn		=> g1,
              pn	=> p1,		f3n		=> f1(3),
              f2n	=> f1(2),	f1n		=> f1(1),
              f0n	=> f1(0),	aeqb	=> ab1,
              cn4	=> cn4_1);
	myvhd: COMPONENT my74181
	PORT MAP (s0	=> s,		m		=> m,
              cn	=> cn,		a0		=> a,
              b0	=> b, 		g		=> g2,
              p		=> p2,		f0		=> f2,
              cn4	=> cn4_2,	aeqb	=> ab2);
              
    test <= '1' WHEN (std_match(f1, f2) and ab1 = ab2 and
                      p1 = p2 and g1 = g2) 
    ELSE '0';
    
    po1 <= p1;
    go1 <= g1;
    cn4o1 <= cn4_1;
    abo1 <= ab1;
    f <= f1;
    
    po2 <= p2;
    go2 <= g2;
    abo2 <= ab2;
    cn4o2 <= cn4_2;
    
    s0: COMPONENT conv_7seg
		PORT MAP (f2,seg0);
END struct;
