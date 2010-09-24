LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY hamming_dec IS
  PORT (x: IN STD_LOGIC_VECTOR(6 downto 0);
        q: OUT STD_LOGIC_VECTOR(3 downto 0));
END hamming_dec;

ARCHITECTURE rtl OF hamming_dec IS
  SIGNAL p: STD_LOGIC_VECTOR(2 downto 0);
  --paridades dos subsets
BEGIN
  p(0) <= x(0) xor x(2) xor x(4) xor x(6);
  p(1) <= x(1) xor x(2) xor x(5) xor x(6);
  p(2) <= x(3) xor x(4) xor x(5) xor x(6);
  --O vetor de paridades informa em qual (posição+1)
  --de bit ocorreu erro ou 000 quando não houve.
  
  q(0) <= not x(2) WHEN (p="011")
  ELSE x(2);
  
  q(1) <= not x(4) WHEN (p="101")
  ELSE x(4);
  
  q(2) <= not x(5) WHEN (p="110")
  ELSE x(5);
  
  q(3) <= not x(6) WHEN (p="111")
  ELSE x(6);
END rtl;
