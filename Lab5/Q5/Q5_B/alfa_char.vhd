library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alfa_char is 
port( code: IN STD_LOGIC_VECTOR(7 downto 0);
      alfa_code: OUT STD_LOGIC_VECTOR(15 downto 0));
end entity alfa_char;

architecture rtl of alfa_char is
begin
   process(code)
      begin
-- All choice expressions in a VHDL case statement must be constant
-- and unique.	Also, the case statement must be complete, or it must
-- include an others clause. 
      case (code) is
	    when "00000000" =>
		  alfa_code <="0000000000000000";
		  -- Sequential Statement(s)
	    when "00000001" =>
		  alfa_code <="0000000000000001";
		-- Sequential Statement(s)
	    when others =>
		  alfa_code <="0000000000000010";
		-- Sequential Statement(s)
      end case;
  end process;
END rtl;