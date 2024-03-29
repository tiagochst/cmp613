LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;

ENTITY somsub IS
  PORT (clk, xa, xb: IN STD_LOGIC;
        lsb, sel, rstn: IN STD_LOGIC;
        q: OUT STD_LOGIC_VECTOR(7 downto 0);
        ovf, stb: OUT STD_LOGIC); --overflow e strobe
END somsub;

ARCHITECTURE behav OF somsub IS
  --O estado run apresenta 8 subestados (run_bit) 
  TYPE state_type IS (idle, run);
  SIGNAL state : state_type := idle;
  SIGNAL run_bit: INTEGER range 0 to 7;
  
  SIGNAL res: STD_LOGIC_VECTOR(7 downto 0);
  SIGNAL cin: STD_LOGIC; --carry ou borrow
  SIGNAL opr: STD_LOGIC; --modo de opera��o amostrado
                         --no in�cio da conta
  SIGNAL last_xa, last_xb: STD_LOGIC;
BEGIN

  -- Transi��es da M�quina de Estados
  PROCESS (state, clk, rstn, xa, xb, cin)
  BEGIN
    IF (rstn = '0') THEN
      state <= idle;
    ELSIF (rising_edge(clk)) THEN
      CASE state IS
        WHEN idle => --mostra resultados da conta
          run_bit <= 0;
          cin <= '0';
          
          IF (lsb = '1') THEN --inicia entrada serial
            opr <= sel;
            state <= run;
          END IF;
        
        WHEN run =>
          res(6 downto 0) <= res(7 downto 1); 
                  
          IF (opr = '1') THEN --full adder
            res(7) <= xa xor xb xor cin;
            cin <= (xa and xb) or (cin and (xa xor xb));
          ELSE                --full subtractor (cin � borrow)
            res(7) <= xa xor xb xor cin;
            cin <= (not xa and xb) or (cin and not (xa xor xb));
          END IF;
          
          IF (run_bit = 7) THEN --termino do calculo
            last_xa <= xa;
            last_xb <= xb xor (not opr); --xb c/ sinal de soma
            state <= idle;
          ELSE
            run_bit <= run_bit + 1;
          END IF;
      END CASE;
    END IF;
  END PROCESS;
  
  q <= res;
  
  -- Sa�das dos estados da M�quina de Moore
  PROCESS (state, cin)
  BEGIN
    CASE (state) IS
      WHEN idle =>
        ovf <= (res(7) and not last_xa and not last_xb) or 
               (not res(7) and last_xa and last_xb);
        stb <= '1';
      WHEN run =>
        ovf <= '0';
        stb <= '0';
    END CASE;
  END PROCESS;
END behav;
