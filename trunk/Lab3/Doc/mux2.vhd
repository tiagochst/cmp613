LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux2 IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        s: IN STD_LOGIC_VECTOR(1 downto 0); 
        z: OUT STD_LOGIC);
END mux2;

ARCHITECTURE rtl OF mux2 IS
BEGIN
  z <= x(to_integer(unsigned(s)));
END rtl;
