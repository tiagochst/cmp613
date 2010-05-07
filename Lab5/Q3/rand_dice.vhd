library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rand_dice is 
port( ld,clk : in std_logic;
      seg: OUT STD_LOGIC_VECTOR(6 downto 0));
end entity rand_dice;

architecture rtl of rand_dice is
SIGNAL output,aux:STD_LOGIC_VECTOR(2 downto 0);

--display mostra valores aleatórios
COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

--gera valores 1 a 6 freq - 27MHz
COMPONENT cnt6 IS
	PORT (clk: IN STD_LOGIC;
	      num: OUT STD_LOGIC_VECTOR(2 downto 0));
END COMPONENT cnt6;

begin
cnt: COMPONENT cnt6 
	PORT MAP (clk,aux);

output<=aux when ld = '1' else "000"; 
s0: COMPONENT conv_7seg
	PORT MAP ('0',output(2), output(1), output(0), seg);
END rtl;