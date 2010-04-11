LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

Entity four_bit_barrel_shifter is
  port(direction:in STD_LOGIC;
       clk:IN STD_LOGIC;
       nshift:IN STD_LOGIC_VECTOR(1 downto 0);
       number:IN STD_LOGIC_VECTOR(3 downto 0);
       output:OUT STD_LOGIC_VECTOR(9 downto 0));
End four_bit_barrel_shifter;

architecture behave of four_bit_barrel_shifter is
 SIGNAL d_nshift: STD_LOGIC_VECTOR(1 downto 0);
 SIGNAL d_direction: STD_LOGIC;
 SIGNAL d_number: STD_LOGIC_VECTOR(3 downto 0);
 SIGNAL clock: STD_LOGIC;

COMPONENT debounce 
	PORT(pb, clock_100Hz 	: IN	STD_LOGIC;
		 pb_debounced		: OUT	STD_LOGIC);
END COMPONENT debounce;

COMPONENT div_freq 
PORT (clk: IN STD_LOGIC;
	  clk_out: OUT STD_LOGIC);
END COMPONENT div_freq;

BEGIN

d0: COMPONENT div_freq
      PORT MAP (clk,clock);

d1: COMPONENT debounce
      PORT MAP (nshift(0),clock,d_nshift(0));

d2: COMPONENT debounce
	  PORT MAP (nshift(1),clock,d_nshift(1));

d3: COMPONENT debounce
	  PORT MAP (direction,clock,d_direction);

d4: COMPONENT debounce
      PORT MAP (number(0),clock,d_number(0));

d5: COMPONENT debounce
      PORT MAP (number(1),clock,d_number(1));

d6: COMPONENT debounce
      PORT MAP (number(2),clock,d_number(2));
      
d7: COMPONENT debounce
      PORT MAP (number(3),clock,d_number(3));



  Pshifter: PROCESS(d_nshift,d_direction,d_number)
    VARIABLE shift, b: INTEGER;

    BEGIN
        shift:=to_integer(unsigned(d_nshift));
        output<="0000000000";

        --right shift
        if d_direction = '0' then
          if shift = 3 then
            output(3 downto 0) <= d_number(3 downto 0);
          elsif shift = 2 then
            output(4 downto 1) <= d_number(3 downto 0);
          elsif shift = 1 then
            output(5 downto 2) <= d_number(3 downto 0);
          elsif shift = 0 then
            output(6 downto 3) <= d_number(3 downto 0);
         end if;
       
        -- left shift
        else 
          if shift = 3 then
            output(9 downto 6) <= d_number(3 downto 0) ;
          elsif shift = 2 then
            output(8 downto 5) <= d_number(3 downto 0) ;
          elsif shift = 1 then
            output(7 downto 4) <= d_number(3 downto 0) ;
          elsif shift = 0 then
            output(6 downto 3) <= d_number(3 downto 0) ;
         end if;
      
      END IF;
  end process Pshifter;
end behave;
