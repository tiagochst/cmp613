LIBRARY ieee ;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY q4 IS
  PORT (sw: IN STD_LOGIC_VECTOR(0 to 9);
          mode_tg, run, load: IN STD_LOGIC;
          su, sd, sc: OUT STD_LOGIC_VECTOR(6 downto 0);
          sig: OUT STD_LOGIC_VECTOR(6 downto 0);
          rclk: BUFFER STD_LOGIC_VECTOR(0 to 3));
END q4;

ARCHITECTURE struct OF q4 IS
  SIGNAL bi: STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL au, bu, ad, bd: STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL ru, rd, rc: UNSIGNED(3 downto 0);
  
COMPONENT bcd_dec IS
  PORT (x: IN STD_LOGIC_VECTOR(0 to 9);
          z: OUT STD_LOGIC_VECTOR(3 downto 0));
END COMPONENT bcd_dec;

COMPONENT reg_mux IS
  PORT (mode_tg, load: IN STD_LOGIC;
        rclk: OUT STD_LOGIC_VECTOR(0 to 3));
END COMPONENT reg_mux;

COMPONENT reg4 IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        clk: IN STD_LOGIC;
        q: OUT STD_LOGIC_VECTOR(3 downto 0));
END COMPONENT reg4;

COMPONENT conv_7seg IS
  PORT (x3,x2,x1,x0: IN STD_LOGIC;
        y6,y5,y4,y3,y2,y1,y0: OUT STD_LOGIC);
END COMPONENT conv_7seg;
BEGIN
  bcd: COMPONENT bcd_dec
    PORT MAP (sw, bi);
    
  sel: COMPONENT reg_mux
    PORT MAP (mode_tg, load, rclk);
    
  r0: COMPONENT reg4
    PORT MAP (bi, rclk(0), au);
  r1: COMPONENT reg4
    PORT MAP (bi, rclk(1), ad);
  r2: COMPONENT reg4
    PORT MAP (bi, rclk(2), bu);
  r3: COMPONENT reg4
    PORT MAP (bi, rclk(3), bd);
  
  PROCESS (run) 
    VARIABLE a, b, res: INTEGER;
  BEGIN
    IF (run'event AND run='1') THEN
      a:=to_integer(unsigned(ad))*10+
         to_integer(unsigned(au));
      b:=to_integer(unsigned(bd))*10+
         to_integer(unsigned(bu));
      
      IF (sw(0)='1') THEN --deseja-se fazer subtracao
        res:=a-b;
      ELSE
        res:=a+b;
      END IF;
    END IF;
    
    IF (res<0) THEN --processamento do resultado p/ 7-seg
      sig<="0111111"; --acende sinal '-'
    ELSE sig<="1111111"; END IF;
    res:=abs(res);
    
    ru<=to_unsigned(res MOD 10, 4);
    rd<=to_unsigned((res/10) MOD 10, 4);
    rc<=to_unsigned((res/100) MOD 10, 4);
  END PROCESS;
  
  lcd0: COMPONENT conv_7seg
    PORT MAP (ru(3),ru(2),ru(1),ru(0),su(6),su(5),
              su(4),su(3),su(2),su(1),su(0));
  lcd1: COMPONENT conv_7seg
    PORT MAP (rd(3),rd(2),rd(1),rd(0),sd(6),sd(5),
              sd(4),sd(3),sd(2),sd(1),sd(0));
  lcd2: COMPONENT conv_7seg
    PORT MAP (rc(3),rc(2),rc(1),rc(0),sc(6),sc(5),
              sc(4),sc(3),sc(2),sc(1),sc(0));
END struct;
