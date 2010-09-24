LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY hamming_enc IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        q: OUT STD_LOGIC_VECTOR(6 downto 0));
END hamming_enc;

ARCHITECTURE rtl OF hamming_enc IS
  SIGNAL p: STD_LOGIC_VECTOR(2 downto 0);
  --paridades dos subsets
BEGIN
  p(0) <= x(0) xor x(1) xor x(3);
  p(1) <= x(0) xor x(2) xor x(3);
  p(2) <= x(1) xor x(2) xor x(3);
  
  q(0) <= p(0);
  q(1) <= p(1);
  q(2) <= x(0);
  q(3) <= p(2);
  q(4) <= x(1);
  q(5) <= x(2);
  q(6) <= x(3);
END rtl;
  
