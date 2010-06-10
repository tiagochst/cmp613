LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;

ENTITY counter IS
	PORT (clk, rstn, en: IN STD_LOGIC;
	      max: IN INTEGER;
	      q: OUT STD_LOGIC);
END counter;

ARCHITECTURE rtl OF counter IS
	SIGNAL cont: INTEGER := 0;
	SIGNAL aux: STD_LOGIC:='0';
BEGIN
	PROCESS (clk, rstn)
	BEGIN	
		IF (rstn = '0') THEN					-- asynchronous reset (active low)
			cont <= 0;
		elsif (clk'event and clk = '1') THEN	-- rising clock edge
			IF (en = '1') THEN
				IF (cont = max) THEN
					cont <= 0;
					if(aux='0') then
						aux<='1';
					else
						aux<='0';
					end if;
				ELSE
					cont <= cont + 1; 
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	q <= '1' when aux = '1' else '0';
END rtl;
