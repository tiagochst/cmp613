LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

Entity mod_count is
  port(dec,ld,clk:in STD_LOGIC;
       val: in integer range 0 to 8;
       seg: OUT STD_LOGIC_VECTOR(0 to 6);
      output: BUFFER STD_LOGIC_VECTOR(3 downto 0));
End mod_count;

architecture behave of mod_count is
COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y6,y5,y4,y3,y2,y1,y0: OUT STD_LOGIC);
END COMPONENT conv_7seg;
Begin
  count_proc: PROCESS(clk)
    Variable count_int: integer range 0 to 8;
  Begin
    IF(ld ='1') then 
      count_int:=val;
      output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,4));
    elsif (clk='1') and (clk'event) and (dec='1') then
      if(count_int = 1) then
        count_int:=0;
        output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,4));
      elsif (count_int=0) then 
        ASSERT FALSE REPORT "decremento abaixo de zero" SEVERity warning;
      else
        count_int:= count_int -1;
        output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,4));
       end if;
     end if;
  end process count_proc;

  disp: COMPONENT conv_7seg
		PORT MAP (output(3), output(2), output(1), output(0), seg(6), seg(5),
		          seg(4), seg(3), seg(2), seg(1), seg(0));
 
end behave;
