LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY cont8_dec IS
  PORT (clk: IN STD_LOGIC;
        q: BUFFER STD_LOGIC_VECTOR(2 downto 0));
END cont8_dec;

ARCHITECTURE struct OF cont8_dec IS
COMPONENT ff_jk IS
  PORT (clk, j, k: IN STD_LOGIC;
        q, notq: OUT STD_LOGIC);
END COMPONENT ff_jk;
BEGIN
  ff0: COMPONENT ff_jk
    PORT MAP (clk, '1', '1', q(0));
  ff1: COMPONENT ff_jk
    PORT MAP (clk, not q(0), not q(0), q(1));
  ff2: COMPONENT ff_jk
    PORT MAP (clk, not (q(0) or q(1)), 
                  not (q(0) or q(1)), q(2));
END struct;
