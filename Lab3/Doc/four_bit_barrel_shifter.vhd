LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE IEEE.numeric_std.all;

ENTITY four_bit_barrel_shifter IS
	PORT (direction : IN STD_LOGIC;
	      nshift:IN STD_LOGIC_VECTOR(1 downto 0);
	      number:IN STD_LOGIC_VECTOR(3 downto 0);
	      output:OUT STD_LOGIC_VECTOR(9 downto 0));
END four_bit_barrel_shifter;

ARCHITECTURE behave OF four_bit_barrel_shifter IS
	SIGNAL save_dir: STD_LOGIC:='0';
BEGIN

	Pshifter: PROCESS (nshift,direction,number)
		VARIABLE shift, b: INTEGER;
	BEGIN
		shift:=to_integer(unsigned(nshift));
		output<="0000000000";

		--right shift
		IF direction = '0' THEN
			IF shift = 3 THEN
			output(3 downto 0) <= number(3 downto 0);
			ELSIF shift = 2 THEN
			output(4 downto 1) <= number(3 downto 0);
			ELSIF shift = 1 THEN
			output(5 downto 2) <= number(3 downto 0);
			ELSIF shift = 0 THEN
			output(6 downto 3) <= number(3 downto 0);
		END IF;

		-- left shift
		ELSE
			IF shift = 3 THEN
			output(9 downto 6) <= number(3 downto 0) ;
			ELSIF shift = 2 THEN
			output(8 downto 5) <= number(3 downto 0) ;
			ELSIF shift = 1 THEN
			output(7 downto 4) <= number(3 downto 0) ;
			ELSIF shift = 0 THEN
			output(6 downto 3) <= number(3 downto 0) ;
		END IF;
		END IF;
	END PROCESS Pshifter;
END behave;

