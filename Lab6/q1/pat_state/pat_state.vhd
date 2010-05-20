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
	SIGNAL zero, um: STD_LOGIC; --sinais síncronos
	
	SIGNAL state_no, nxt_state: INTEGER range 0 to 8 := 0;
	--estados 0 e 8 correspondem ao primeiro bit, mas
	--em 8 a sequência acabou de ser encontrada
	
	COMPONENT buff IS
		PORT (clk, d: IN STD_LOGIC;
			  q: OUT STD_LOGIC);
	END COMPONENT buff;
BEGIN
	bf0: COMPONENT buff
		PORT MAP (clk, not pb0, zero);
	bf1: COMPONENT buff
		PORT MAP (clk, not pb1, um);

	PROCESS (clk, rstn, state_no, zero, um)
	BEGIN
		IF (rstn = '0') THEN
			state_no <= 0;
		ELSIF (rising_edge(clk)) THEN
			--Transição da Máquina de Estados
			IF (zero = '1' and PATT(state_no) = '0') THEN
				state_no <= nxt_state;
			ELSIF (um = '1' and PATT(state_no) = '1') THEN
				state_no <= nxt_state;
			ELSIF (zero = '1' or um = '1') THEN
				state_no <= 0;
			END IF;
		END IF;
	END PROCESS;
	
	--Saídas e sinais de controle da Máquina de Estados
	--Calcula próximo estado se a entrada vier correta
	PROCESS (state_no)
	BEGIN
		CASE state_no IS
			WHEN 0 to 7 =>
				ok <= '0';
				nxt_state <= state_no + 1;
			WHEN 8 =>
				ok <= '1';
				nxt_state <= 1;
		END CASE;
	END PROCESS;
	
	cur_st <= std_logic_vector(to_unsigned(state_no, 3));
END behav;
