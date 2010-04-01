LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

Entity mod_count is
  port(dec,ld:in STD_LOGIC;
       clk: in STD_LOGIC;
       valor: STD_LOGIC_VECTOR(0 to 7);
       seg: OUT STD_LOGIC_VECTOR(0 to 6);
      output: BUFFER STD_LOGIC_VECTOR(3 downto 0));
End mod_count;

architecture behave of mod_count is
--Signal clk:STD_LOGIC;
--divisor de frequencias do lab1 q4
COMPONENT q4 
	PORT(x:IN STD_LOGIC;
		 z:OUT STD_LOGIC);
END COMPONENT q4;

COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y6,y5,y4,y3,y2,y1,y0: OUT STD_LOGIC);
END COMPONENT conv_7seg;

COMPONENT debounce IS
	PORT(pb, clock_100Hz 	: IN	STD_LOGIC;
		 pb_debounced		: OUT	STD_LOGIC);
END COMPONENT debounce;

--divisor de frequencias - 27MHZ em 1.6 Hz

BEGIN
 -- div: COMPONENT q4
 --     PORT MAP(clk_high,clk);
 --clk<=clk_high;
  count_proc: PROCESS(clk,dec,ld,valor)
    Variable count_int: integer range 0 to 255:=0; --contador
    Variable mod_int: integer range 0 to 255;   --guarda valor para loop no relógio
  
  Begin
    IF(ld ='1') then 
      count_int:=0;  
      mod_int:=to_integer(unsigned(valor));   
      output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,4));
    elsif (clk='1') and (clk'event) and (dec='1') then
      if (count_int=mod_int) then 
        count_int:=0;
        output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,4));
      else
        count_int:= count_int +1;
        output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,4));
       end if;
     end if;
  end process count_proc;

  disp: COMPONENT conv_7seg
		PORT MAP (output(3), output(2), output(1), output(0), seg(6), seg(5),
		          seg(4), seg(3), seg(2), seg(1), seg(0));
end behave;
