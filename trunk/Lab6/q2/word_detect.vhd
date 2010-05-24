LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
	      
ENTITY word_detect IS
	PORT (clk, rstn: IN STD_LOGIC;
	      x: IN STD_LOGIC_VECTOR(3 downto 0);
          nxt: IN STD_LOGIC;
	      cur_st: OUT STD_LOGIC_VECTOR(2 downto 0);
          seg0: OUT STD_LOGIC_VECTOR(6 downto 0);
	      ok: OUT STD_LOGIC);
END word_detect;

ARCHITECTURE behav OF word_detect IS
    CONSTANT W_LEN: NATURAL := 6;

    SUBTYPE hexa IS STD_LOGIC_VECTOR(3 downto 0);
    TYPE hword IS ARRAY(0 to W_LEN-1) OF hexa;
    
    CONSTANT WORD: hword := (x"C",x"0",x"F",x"F",x"E",x"E");
    
	SIGNAL sn_nxt: STD_LOGIC; --sinal síncrono
	SIGNAL last_x: hexa := x"0";
	
	SIGNAL state_no, nxt_state: INTEGER range 0 to W_LEN := 0;
	--estados 0 e WLEN correspondem ao primeiro bit, mas
	--em WLEN a sequência acabou de ser encontrada
	
	COMPONENT buff IS
    PORT (clk, d: IN STD_LOGIC;
          q: OUT STD_LOGIC);
	END COMPONENT buff;
    
    COMPONENT conv_7seg IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;
BEGIN
	bf0: COMPONENT buff
		PORT MAP (clk, not nxt, sn_nxt);

	PROCESS (clk, rstn, state_no)
	BEGIN
		IF (rstn = '0') THEN
			state_no <= 0;
		ELSIF (rising_edge(clk)) THEN
			--Transição da Máquina de Estados
            IF (sn_nxt = '1') THEN
                IF (x = WORD(state_no)) THEN
                    state_no <= nxt_state;
                ELSE 
                    state_no <= 0;
                END IF;
                last_x <= x;
            END IF;
		END IF;
	END PROCESS;
	
	--Saídas e sinais de controle da Máquina de Estados
	--Calcula próximo estado se a entrada vier correta
	PROCESS (state_no)
	BEGIN
		CASE state_no IS
			WHEN 0 to W_LEN-1 =>
				ok <= '0';
				nxt_state <= state_no + 1;
			WHEN W_LEN =>
				ok <= '1';
				nxt_state <= 1;
		END CASE;
	END PROCESS;
    
    s0: COMPONENT conv_7seg
        PORT MAP (last_x, seg0);
	
	cur_st <= std_logic_vector(to_unsigned(state_no, 3));
END behav;
