LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

Entity mod_count is
  port(enable,ld:in STD_LOGIC;
       clk_high: in STD_LOGIC;
       valor:IN STD_LOGIC_VECTOR(0 to 7);
       seg1: OUT STD_LOGIC_VECTOR(0 to 6);
       seg2: OUT STD_LOGIC_VECTOR(0 to 6));
End mod_count;

architecture behave of mod_count is
   Signal clk:STD_LOGIC;
   Signal output: STD_LOGIC_VECTOR(7 downto 0);
   constant zero:integer:=0;

COMPONENT div_freq 
	PORT (clk: IN STD_LOGIC;
	      clk_out: OUT STD_LOGIC);
END COMPONENT div_freq;

COMPONENT conv_7seg IS
	PORT (x3,x2,x1,x0: IN STD_LOGIC;
	      y6,y5,y4,y3,y2,y1,y0: OUT STD_LOGIC);
END COMPONENT conv_7seg;

BEGIN
  --divisor de frequencias - 24MHZ em 1.0 Hz
  div: COMPONENT div_freq
      PORT MAP(clk_high,clk);
 
   count_proc: PROCESS(clk,enable,ld,valor)
    Variable count_int: integer range 0 to 255:=0; --contador
    Variable mod_int: integer range 0 to 255:=0;   --guarda valor para loop no relógio
  
  Begin
  
    IF(ld ='1') then 
      count_int:=0;  
      mod_int:=to_integer(unsigned(valor));   
      output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,8));
    elsif ((clk='1') and (clk'event) and (enable='1') and (mod_int/=zero)) then
      count_int:= (count_int +1) MOD mod_int;
      output <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_int,8));
    end if;
end process count_proc;

 disp: COMPONENT conv_7seg
		PORT MAP (output(3), output(2), output(1), output(0), seg1(6), seg1(5),
		          seg1(4), seg1(3), seg1(2), seg1(1), seg1(0));

  disp2: COMPONENT conv_7seg
		PORT MAP (output(7), output(6), output(5), output(4), seg2(6), seg2(5),
		          seg2(4), seg2(3), seg2(2), seg2(1), seg2(0));

end behave;
