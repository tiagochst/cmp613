LIBRARY ieee;
USE ieee.std_logic_1164.all;
	      
ENTITY pat_shift IS
	GENERIC (
		PAT_LEN: INTEGER := 8
	);
	PORT (clk, rstn: IN STD_LOGIC;
	      pb0, pb1: IN STD_LOGIC;
	      shreg: OUT STD_LOGIC_VECTOR(PAT_LEN-1 downto 0);
	      ok: OUT STD_LOGIC);
END pat_shift;

ARCHITECTURE behav OF pat_shift IS
	CONSTANT PATT: 
		STD_LOGIC_VECTOR(0 to PAT_LEN-1):="10110001";
	SIGNAL zero, um: STD_LOGIC; --sinais síncronos
	
	SIGNAL det_in, det_en: STD_LOGIC;
BEGIN
	bf0: ENTITY WORK.buff
		PORT MAP (clk, not pb0, zero);
	bf1: ENTITY WORK.buff
		PORT MAP (clk, not pb1, um);
	
	--Converte sinais para entrada binária
	det_in <= '1' WHEN um = '1'
	ELSE '0';
	
	det_en <= '1' WHEN (zero = '1' or um = '1')
	ELSE '0';
		
	det0: ENTITY WORK.pat_shift_det
		PORT MAP (clk, rstn, det_en, PATT,
		          det_in, shreg, ok);
END behav;
