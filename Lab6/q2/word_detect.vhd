LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
	      
ENTITY word_detect IS
	PORT (clk, rstn: IN STD_LOGIC;
	      x: IN STD_LOGIC_VECTOR(3 downto 0);
          nxt: IN STD_LOGIC;
          seg0: OUT STD_LOGIC_VECTOR(6 downto 0);
	      ok: OUT STD_LOGIC);
END word_detect;

ARCHITECTURE behav OF word_detect IS
    CONSTANT W_LEN: NATURAL := 6;

	SUBTYPE hexa IS STD_LOGIC_VECTOR(3 downto 0);
    SUBTYPE stream IS 
       STD_LOGIC_VECTOR(W_LEN-1 downto 0);
    TYPE hword IS ARRAY(3 downto 0) OF stream;
                             --COFFEE--
    CONSTANT WORDS: hword := ("101111",
                              "101111",
                              "001111",
                              "001100");
    
	SIGNAL sn_nxt: STD_LOGIC; --sinal síncrono
	SIGNAL last_x: hexa := x"0"; --último número entrado
	
	SIGNAL det_oks: STD_LOGIC_VECTOR(3 downto 0);
    
    COMPONENT conv_7seg IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;
BEGIN
	bf0: ENTITY WORK.buff
		PORT MAP (clk, not nxt, sn_nxt);
		
	pdet0: ENTITY WORK.pat_shift_det GENERIC MAP (6)
		PORT MAP (clk, rstn, sn_nxt, WORDS(0),
	              x(0), ok => det_oks(0));
	pdet1: ENTITY WORK.pat_shift_det GENERIC MAP (6)
		PORT MAP (clk, rstn, sn_nxt, WORDS(1),
	              x(1), ok => det_oks(1));
	pdet2: ENTITY WORK.pat_shift_det GENERIC MAP (6)
		PORT MAP (clk, rstn, sn_nxt, WORDS(2),
	              x(2), ok => det_oks(2));	                  
	pdet3: ENTITY WORK.pat_shift_det GENERIC MAP (6)
		PORT MAP (clk, rstn, sn_nxt, WORDS(3),
	              x(3), ok => det_oks(3));	

	PROCESS (clk, rstn)
	BEGIN
		IF (rstn = '0') THEN
			last_x <= x"0";
		ELSIF (rising_edge(clk)) THEN
            IF (sn_nxt = '1') THEN
				last_x <= x;
            END IF;
		END IF;
	END PROCESS;
	
    s0: COMPONENT conv_7seg
        PORT MAP (last_x, seg0);
        
    ok <= '1' WHEN (det_oks = "1111")
    ELSE '0';
END behav;
