LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY freq_div6 IS
  PORT (hi_clk: in STD_LOGIC;
        clk: out STD_LOGIC);
END freq_div6;

ARCHITECTURE rtl OF freq_div6 IS
  SIGNAL rst: STD_LOGIC;
  SIGNAL q: STD_LOGIC_VECTOR(2 downto 0);
COMPONENT \74161\
  PORT (clk, ldn, clrn: in STD_LOGIC;
    enp, ent: in STD_LOGIC;
    d, c, b, a: in STD_LOGIC;
    qd, qc, qb, qa: out STD_LOGIC;
    rco: out STD_LOGIC);
END COMPONENT;
BEGIN
  ct: COMPONENT \74161\
    PORT MAP (hi_clk, '1', not rst, '1', '1',
              '0', '0', '0', '0',
              qc=>q(2), qb=>q(1), qa=>q(0));
  
  --termino da contagem em 6
  rst <= q(2) and q(1) and not q(0); 
  --clock '0' em 0,1,2 ou '1' cc.
  clk <= q(2) or (q(1) and q(0));
END rtl;
