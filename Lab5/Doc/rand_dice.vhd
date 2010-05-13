library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

ENTITY rand_dice is 
  PORT( n_ld,clk : in std_logic;
        seg: OUT STD_LOGIC_VECTOR(6 downto 0));
END ENTITY rand_dice;

architecture rtl of rand_dice is
  SIGNAL output,aux:STD_LOGIC_VECTOR(2 downto 0);
  SIGNAL ld:STD_LOGIC;

--display mostra valores aleatórios
COMPONENT conv_7seg IS
  PORT (x3,x2,x1,x0: IN STD_LOGIC;
        y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

--gera valores 1 a 6 freq - 27MHz
COMPONENT cnt6 IS
  PORT (clk: IN STD_LOGIC;
        num: OUT STD_LOGIC_VECTOR(2 downto 0));
END COMPONENT cnt6;

COMPONENT buff IS
  PORT (clk, d: IN STD_LOGIC;
        q: OUT STD_LOGIC);
END COMPONENT buff;

BEGIN
  cnt: COMPONENT cnt6
        PORT MAP (clk,aux);

  bf: COMPONENT buff
        PORT MAP (clk, not n_ld, ld);

  PROCESS(ld,clk) BEGIN
  IF(clk'event and clk = '1') then
          IF(ld = '1') then
            output<=aux ;
          END IF;
        END IF;
  END PROCESS;

s0: COMPONENT conv_7seg
       PORT MAP ('0',output(2), output(1), output(0), seg);
END rtl;
