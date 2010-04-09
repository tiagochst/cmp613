Library ieee;
USE ieee.std_logic_1164.all;

ENTITY latch_sr IS
   PORT(en,reset,set: IN STD_LOGIC;
        q, notq: OUT STD_LOGIC);
END latch_sr;

ARCHITECTURE rtl OF latch_sr IS
BEGIN latch: 
	PROCESS(en,reset,set)
BEGIN
    IF en = '1' THEN
    IF reset ='1' THEN
		q<= '0';
		notq<=not(set);	
	ELSE
	    IF set ='1' THEN
		  q<=set;
		  notq<= reset;
		END IF;
    END IF;
    END IF;

END PROCESS latch;
END rtl;  