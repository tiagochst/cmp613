LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
	      
ENTITY pat_state IS
	PORT (clk, rstn: IN STD_LOGIC;
	      pb0, pb1: IN STD_LOGIC;
	      cur_st: OUT STD_LOGIC_VECTOR(2 downto 0);
	      ok: OUT STD_LOGIC);
END pat_state;

ARCHITECTURE behav OF pat_state IS 
	CONSTANT PAT_LEN: INTEGER := 8;
	SUBTYPE index is INTEGER range 0 to PAT_LEN-1;
	TYPE int_array is ARRAY(0 to PAT_LEN-1) OF index;
	CONSTANT PATT: --padrão desejado de busca
	   STD_LOGIC_VECTOR(0 to PAT_LEN-1) := "10110001";
	CONSTANT FAIL: --próximo estado se a busca falhar em i
	               --deve ser coerente com o padrão PATT
	   int_array := (0, 1, 0, 2, 1, 3, 1, 0);

	SIGNAL zero, um: STD_LOGIC; --sinais síncronos
	SIGNAL st_no, nxt_st: INTEGER range 0 to PAT_LEN:=0;
	SIGNAL look_pos: index;
	--estados 0 e PAT_LEN correspondem ao primeiro bit,
    --mas no último a sequência acabou de ser encontrada
	--look_pos é o índice real do próximo bit esperado
	
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
			--Transição da Máquina de Estados
			IF (zero = '1' and PATT(look_pos) = '0') THEN
				st_no <= nxt_st;
			ELSIF (um = '1' and PATT(look_pos) = '1') THEN
				st_no <= nxt_st;
			ELSIF (zero = '1' or um = '1') THEN
				st_no <= FAIL(look_pos);
			END IF;
		END IF;
	END PROCESS;
	
	--Saídas e sinais de controle da Máquina de Estados
	--Calcula próximo estado se a entrada vier correta
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
