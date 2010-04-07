LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

Entity four_bit_barrel_shifter is
  port(direction:in STD_LOGIC;
       nshift:IN STD_LOGIC_VECTOR(0 downto 1);
       number:BUFFER STD_LOGIC_VECTOR(0 downto 4);
       run:in STD_LOGIC;
       shift_vec:IN STD_LOGIC_VECTOR(0 downto 4));      
End four_bit_barrel_shifter;

architecture behave of four_bit_barrel_shifter is
 SIGNAL save_dir: STD_LOGIC;
--COMPONENT reg4 IS
--	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
--	      clk: IN STD_LOGIC;
--	      q: OUT STD_LOGIC_VECTOR(3 downto 0));
--END COMPONENT reg4;

BEGIN

  direction:PROCESS(direction)
    save_dir<=not(save_dir);
  end process direction;


  shifter: PROCESS(run)
    VARIABLE shift, b: INTEGER;

	BEGIN
      IF (run'event AND run='1') THEN
          shift:=to_integer(unsigned(nshift));
      if shift = '4' then
		 number <= I;
      elsif shift = '3' then
		 number <= I & number(3 downto 2);
      elsif shift = '2' then
		 number <= I & number(3 downto 1);
      elsif shift = '1' then
		 number <= I & number(3 downto 0);


	  end if;

 
      END IF;
  end process shifter;

end behave;
