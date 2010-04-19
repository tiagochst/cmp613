LIBRARY ieee ;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY reg_mux IS
	PORT (mode_tg, load: IN STD_LOGIC;
	      rclk: OUT STD_LOGIC_VECTOR(0 to 3));
END reg_mux;

ARCHITECTURE struct OF reg_mux IS
BEGIN
	PROCESS (mode_tg)
		--id do registrador a ser LOAD
		VARIABLE creg: INTEGER :=-1;
	BEGIN
		IF (mode_tg'event AND mode_tg='1') THEN
			creg:=(creg+1) MOD 4;
		END IF;
		
		rclk<="0000";
		rclk(creg)<=load;
	END PROCESS;
END;
