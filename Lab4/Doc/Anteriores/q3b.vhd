LIBRARY ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 

ENTITY q3b IS
  PORT (x,y: IN integer range 0 to 15;
        z: OUT integer range 0 to 255 );
END q3b;

ARCHITECTURE struct OF q3b IS

BEGIN
  z<=x*y; --multiplicação de inteiros
END struct;
