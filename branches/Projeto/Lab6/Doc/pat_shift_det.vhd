LIBRARY ieee;
USE ieee.std_logic_1164.all;
        
ENTITY pat_shift_det IS
  GENERIC (
    PAT_LEN: INTEGER := 8
  );
  PORT (clk, rstn, en: IN STD_LOGIC;
        patt: IN STD_LOGIC_VECTOR(PAT_LEN-1 downto 0);
        inp: IN STD_LOGIC;
        shreg: OUT STD_LOGIC_VECTOR(PAT_LEN-1 downto 0);
        ok: OUT STD_LOGIC);
END pat_shift_det;

ARCHITECTURE behav OF pat_shift_det IS
  SIGNAL qb: INTEGER range 0 to PAT_LEN := 0;
  SIGNAL x: STD_LOGIC_VECTOR(0 to PAT_LEN-1);
  --dados lidos são deslocados em x
BEGIN
  PROCESS (clk, rstn)
  BEGIN
    IF (rstn = '0') THEN
      qb <= 0;
      x  <= (others => '0');
    ELSIF (rising_edge(clk)) THEN
      --desloca os bits caso uma entrada esteja ativa
      IF (en = '1') THEN
        x(0 to PAT_LEN-2) <= x(1 to PAT_LEN-1);
        x(PAT_LEN-1) <= inp;
      
        IF (qb < PAT_LEN) THEN
          qb <= qb + 1; --incr número de bits lidos
        END IF;
      END IF;
    END IF;
  END PROCESS;
  
  shreg <= x;
  
  ok <= '1' WHEN (x = PATT and qb = PAT_LEN)
  ELSE '0';
END behav;
