LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY q2 IS
  PORT (clk_base, rst, pre: IN STD_LOGIC;
      clk_sel: IN STD_LOGIC_VECTOR(1 downto 0);
      seg0, seg1, seg2: OUT STD_LOGIC_VECTOR(6 downto 0));
END q2;

ARCHITECTURE rtl OF q2 IS
  SIGNAL clk_v: STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL clk: STD_LOGIC;
  SIGNAL un, de, ce: STD_LOGIC_VECTOR(3 downto 0);

COMPONENT bcd_count IS
  PORT (clk, rst, pre: IN STD_LOGIC;
      un, de, ce: BUFFER STD_LOGIC_VECTOR(3 downto 0));
END COMPONENT bcd_count;
COMPONENT freq_div IS
  PORT (clk: IN STD_LOGIC;
        ratio: IN INTEGER;
        clk_out: BUFFER STD_LOGIC);
END COMPONENT freq_div;
COMPONENT conv_7seg IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

BEGIN
  d0: COMPONENT freq_div
    PORT MAP (clk_base, 27000000, clk_v(0));
  d1: COMPONENT freq_div
    PORT MAP (clk_base, 27000000/4, clk_v(1));
  d2: COMPONENT freq_div
    PORT MAP (clk_base, 27000000/12, clk_v(2));
  d3: COMPONENT freq_div
    PORT MAP (clk_base, 27000000/32, clk_v(3));
    
  clk <= clk_v(to_integer(unsigned(clk_sel)));
  
  count: COMPONENT bcd_count
    PORT MAP (clk, rst, pre, un, de, ce);
    
  s0: COMPONENT conv_7seg
    PORT MAP (un, seg0);
  s1: COMPONENT conv_7seg
    PORT MAP (de, seg1);
  s2: COMPONENT conv_7seg
    PORT MAP (ce, seg2);
END rtl;
