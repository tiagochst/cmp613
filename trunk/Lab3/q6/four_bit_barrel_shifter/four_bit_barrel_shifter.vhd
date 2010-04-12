LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

Entity four_bit_barrel_shifter2 is
port(direction:in STD_LOGIC;
nshift:IN STD_LOGIC_VECTOR(1 downto 0);
number:IN STD_LOGIC_VECTOR(3 downto 0);
output:OUT STD_LOGIC_VECTOR(9 downto 0));
End four_bit_barrel_shifter2;

architecture behave of four_bit_barrel_shifter2 is
SIGNAL save_dir: STD_LOGIC:='0';

BEGIN

Pshifter: PROCESS(nshift,direction,number)
VARIABLE shift, b: INTEGER;

BEGIN
shift:=to_integer(unsigned(nshift));
output<="0000000000";

--right shift
if direction = '0' then
if shift = 3 then
output(3 downto 0) <= number(3 downto 0);
elsif shift = 2 then
output(4 downto 1) <= number(3 downto 0);
elsif shift = 1 then
output(5 downto 2) <= number(3 downto 0);
elsif shift = 0 then
output(6 downto 3) <= number(3 downto 0);
end if;

-- left shift
else
if shift = 3 then
output(9 downto 6) <= number(3 downto 0) ;
elsif shift = 2 then
output(8 downto 5) <= number(3 downto 0) ;
elsif shift = 1 then
output(7 downto 4) <= number(3 downto 0) ;
elsif shift = 0 then
output(6 downto 3) <= number(3 downto 0) ;
end if;

END IF;
end process Pshifter;
end behave;

