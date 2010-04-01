LIBRARY ieee ;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

--converte entrada unaria de 10 posicoes
--para BCD, prioridade p/ digitos maiores
ENTITY bcd_dec IS
	PORT (x: IN STD_LOGIC_VECTOR(0 to 9);
          z: OUT STD_LOGIC_VECTOR(3 downto 0));
END bcd_dec;

ARCHITECTURE struct OF bcd_dec IS
	SIGNAL zt: UNSIGNED(3 downto 0);
BEGIN
	PROCESS (x)
	BEGIN
		FOR i IN 0 TO 9 LOOP
			IF (x(i)='1') THEN 
			   zt<=to_unsigned(i,4);
			END IF;
		END LOOP;
	END PROCESS;
	
	z(0)<=zt(0); z(1)<=zt(1); z(2)<=zt(2); z(3)<=zt(3);
END struct;
