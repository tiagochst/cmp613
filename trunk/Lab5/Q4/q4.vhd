LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY q4 IS
	PORT (data: IN STD_LOGIC_VECTOR(3 downto 0);
	      err: IN STD_LOGIC_VECTOR(6 downto 0);
	      d_cor, d_ori: OUT STD_LOGIC_VECTOR(3 downto 0));
END q4;

ARCHITECTURE behav OF q4 IS
	SIGNAL ham, ham_err: STD_LOGIC_VECTOR(6 downto 0);

COMPONENT hamming_enc IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      q: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT hamming_enc;

COMPONENT hamming_dec IS
	PORT (x: IN STD_LOGIC_VECTOR(6 downto 0);
	      q: OUT STD_LOGIC_VECTOR(3 downto 0));
END COMPONENT hamming_dec;

BEGIN
	enc: COMPONENT hamming_enc
		PORT MAP (data, ham);
		
	ham_err <= ham xor err;
	
	dec: COMPONENT hamming_dec
		PORT MAP (ham_err, d_cor);
		
	d_ori <= data;
END behav;
