LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY reacao IS
  PORT (hi_clk, rstn, pb1, pb2: IN STD_LOGIC;
        seg1, seg0: OUT STD_LOGIC_VECTOR(6 downto 0));
END reacao;

ARCHITECTURE behav OF reacao IS
  CONSTANT CLK_VAL : INTEGER := 27000000;
  TYPE state_type IS (get_rand, delay, wait_b2, result, error);
  SIGNAL state : state_type := result;
  SIGNAL delay_amt, 
         delay_cnt: INTEGER range CLK_VAL to 2*CLK_VAL-1;
  SIGNAL delay_rst, delay_en: STD_LOGIC;
  SIGNAL delta, rnd_cnt: INTEGER range 0 to CLK_VAL;
  SIGNAL b1, b2: STD_LOGIC;
  SIGNAL cs0, cs1: STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL seg_cs0, seg_cs1: STD_LOGIC_VECTOR(6 downto 0);
  
COMPONENT cont_int IS
  PORT (clk, en, sclr: IN STD_LOGIC;
        top: IN INTEGER;
        q: OUT INTEGER;
        cout: OUT STD_LOGIC);
END COMPONENT cont_int;
COMPONENT buff IS
  PORT (clk, d: IN STD_LOGIC;
        q: OUT STD_LOGIC);
END COMPONENT buff;
COMPONENT conv_7seg IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

BEGIN
  --gerador de n�mero aleat�rio simples
  rnd_counter: COMPONENT cont_int
    PORT MAP (hi_clk, '1', '0', CLK_VAL+1, rnd_cnt);
    
  --contador de tempo para o delay aleat�rio e para
  --o tempo de rea��o aleat�rio. Seu valor m�ximo � 2s.
  delay_counter: COMPONENT cont_int
    PORT MAP (hi_clk, delay_en, delay_rst,
              2*CLK_VAL, delay_cnt);
    
  --os sinais b1 e b2 sincronizam e evitam repeti��es
  --na a��o dos bot�es (deve-se soltar e apertar denovo)
  bf0: buff PORT MAP (hi_clk, not pb1, b1);
  bf1: buff PORT MAP (hi_clk, not pb2, b2);
    
  --d�gitos do tempo de rea��o medido (cent�simos de seg)
  cseg0: conv_7seg PORT MAP (cs0, seg_cs0);
  cseg1: conv_7seg PORT MAP (cs1, seg_cs1);

  -- Transi��es da M�quina de Estados
  PROCESS (hi_clk, rstn, b1, b2)
  BEGIN
    IF (rstn = '0') THEN
      delay_en <= '0';
      state <= result;
    ELSIF (rising_edge(hi_clk)) THEN
      CASE state IS
        WHEN get_rand =>
          delay_amt <= CLK_VAL + rnd_cnt;
          delay_rst <= '1'; --inicia contagem do atraso
          delay_en <= '1';
          state <= delay;
        WHEN delay => 
          IF (delay_cnt = delay_amt) THEN
            delay_rst <= '1'; --inicia contagem de rea��o 
            state <= wait_b2;
          ELSE
            delay_rst <= '0';
          END IF;
          
          IF (b2 = '1') THEN
            state <= error;
          END IF;
          delay_en <= '1';
        WHEN wait_b2 =>
          delay_rst <= '0';
          
          IF (b2 = '1') THEN --rea��o do usu�rio 
            state <= result;
          ELSIF (b1 = '1') THEN --bot�o inv�lido!
            state <= error;
          ELSIF (delay_cnt = CLK_VAL) THEN --timeout de rea��o
            state <= error;
          END IF;
        WHEN result =>
          delay_en <= '0';  --p�ra contagem de tempo de rea��o
          IF (b1 = '1') THEN --reinicia ciclo
            state <= get_rand;
          END IF;
        WHEN error =>
          delay_rst <= '1';
          IF (b1 = '1') THEN --reinicia ciclo
            state <= get_rand;
          END IF;
      END CASE;
    END IF;
  END PROCESS;
  
  --Sa�da do contador de delay convertida em cent�simos de seg.
  delta <= 100*delay_cnt/CLK_VAL;
  cs0 <= std_logic_vector(to_unsigned(delta MOD 10, 4));
  cs1 <= std_logic_vector(to_unsigned((delta/10) MOD 10, 4));

  -- Sa�das de estados da M�quina de Moore
  PROCESS (state, seg_cs0, seg_cs1)
  BEGIN
    CASE state IS
      WHEN get_rand | delay =>
        seg0 <= "1111111"; --apaga todos os displays
        seg1 <= "1111111";
      WHEN wait_b2 =>
        seg0 <= "0000000"; --acende todos os displays
        seg1 <= "0000000";
      WHEN result =>
        seg0 <= seg_cs0;
        seg1 <= seg_cs1;
      WHEN error =>
        seg0 <= "0000110";
        seg1 <= "0000110";
    END CASE;
  END PROCESS;
END behav;
