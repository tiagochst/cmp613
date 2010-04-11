LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY div_freq IS
	PORT (clk: IN STD_LOGIC;
	      clk_out: BUFFER STD_LOGIC);
END div_freq;

ARCHITECTURE struct OF div_freq  IS
	SIGNAL cont: integer range 0 to 270000:= 0;
BEGIN
	PROCESS (clk) BEGIN
		IF (clk'event AND clk='1') THEN
			cont<=cont+1;
	      IF cont=270000 then
	         clk_out <= '1';
	      else
	         clk_out <='0';
	    end if;	
	  END IF;
	END PROCESS;
	
END;