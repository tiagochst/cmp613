LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
	      
ENTITY pat_state IS
	GENERIC (
		PATT: STD_LOGIC_VECTOR(0 to 7) := "10110001"
	);
	PORT (clk, rstn: IN STD_LOGIC;
	      pb0, pb1: IN STD_LOGIC;
	      cur_st: OUT STD_LOGIC_VECTOR(2 downto 0);
	      ok: OUT STD_LOGIC);
END pat_state;

ARCHITECTURE behav OF pat_state IS
	CONSTANT PAT_LEN: INTEGER := 8;
	SIGNAL zero, um: STD_LOGIC; --sinais s�ncronos
	
	SIGNAL st_no, nxt_st: INTEGER range 0 to PAT_LEN:=0;
	SIGNAL look_pos: INTEGER range 0 to PAT_LEN-1;
	--estados 0 e PAT_LEN correspondem ao primeiro bit,
    --mas no �ltimo a sequ�ncia acabou de ser encontrada
	--look_pos � o �ndice real do pr�ximo bit esperado
	
	COMPONENT buff IS
		PORT (clk, d: IN STD_LOGIC;
			  q: OUT STD_LOGIC);
	END COMPONENT buff;
BEGIN
	bf0: COMPONENT buff
		PORT MAP (clk, not pb0, zero);
	bf1: COMPONENT buff
		PORT MAP (clk, not pb1, um);

	PROCESS (clk, rstn, st_no, zero, um)
	BEGIN
		IF (rstn = '0') THEN
			st_no <= 0;
		ELSIF (rising_edge(clk)) THEN
			--Transi��o da M�quina de Estados
			IF (zero = '1' and PATT(look_pos) = '0') THEN
				st_no <= nxt_st;
			ELSIF (um = '1' and PATT(look_pos) = '1') THEN
				st_no <= nxt_st;
			ELSIF (zero = '1' or um = '1') THEN
				st_no <= 0;
			END IF;
		END IF;
	END PROCESS;
	
	--Sa�das e sinais de controle da M�quina de Estados
	--Calcula pr�ximo estado se a entrada vier correta
	PROCESS (st_no)
	BEGIN
		CASE st_no IS
			WHEN 0 to PAT_LEN-1 =>
				ok <= '0';
				look_pos <= st_no;
				nxt_st <= st_no + 1;
			WHEN PAT_LEN =>
				ok <= '1';
				look_pos <= 0;
				nxt_st <= 1;
		END CASE;
	END PROCESS;
	
	cur_st <= std_logic_vector(to_unsigned(st_no, 3));
END behav;
