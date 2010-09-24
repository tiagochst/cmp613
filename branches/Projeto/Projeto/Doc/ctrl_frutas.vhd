LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;

ENTITY ctrl_frutas IS
  PORT (
  clk, rstn          :IN STD_LOGIC;
    enable          :IN STD_LOGIC;
    fruta                :OUT t_fruta_id
  );
END ctrl_frutas;

ARCHITECTURE behav OF ctrl_frutas IS
   CONSTANT MIN_ESPERA: INTEGER := 2000;
   CONSTANT DURACAO: INTEGER := 1000;
   
   SIGNAL time_wait, rnd_cont: INTEGER range 0 to 50000;
   SIGNAL time_dur: INTEGER range 0 to DURACAO;
   SIGNAL frut_cont: INTEGER range 0 to FRUTA_NO;
   SIGNAL fruta_reg: t_fruta_id := 1;
BEGIN
  -- Conta os tempos alternadamente de espera e duração
  -- da fruta_reg, amostrando contadores aleatórios
  -- type: sequential
  PROCESS (clk, rstn)
  BEGIN
    IF (rstn = '0') THEN
      time_wait <= 0;
      time_dur <= 0;
      fruta_reg <= 1;
    ELSIF (clk'event and clk = '1') THEN
      IF (enable = '1') THEN
        IF (fruta_reg = 0) THEN
          IF (time_wait = 0) THEN
            fruta_reg <= frut_cont + 1;
            time_dur <= DURACAO;
          ELSE
            time_wait <= time_wait - 1; 
          END IF;
        ELSE
          IF (time_dur = 0) THEN
            fruta_reg <= 0;
            time_wait <= MIN_ESPERA + rnd_cont;
          ELSE
            time_dur <= time_dur - 1;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  
  fruta <= fruta_reg;
  
  random: ENTITY work.counter PORT MAP
    (clk => clk, rstn => '1', en => '1', max => 2*MIN_ESPERA, q => rnd_cont); 
  fruta_random: ENTITY work.counter PORT MAP
    (clk => clk, rstn => '1', en => '1', max => FRUTA_NO-1, q => frut_cont);
END behav;
