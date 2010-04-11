LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use IEEE.numeric_std.all;

--direction esquerda ou direita
--nshift - 0,1,2,3
--number - numero inicial
--run - realizar opera��o
--shift_vec - numero a ser colocado
--output - saida

Entity four_bit_barrel_shifter is
  port(direction:in STD_LOGIC;
       nshift:IN STD_LOGIC_VECTOR(1 downto 0);
       number:IN STD_LOGIC_VECTOR(3 downto 0);
       run:in STD_LOGIC;
       shift_vec:IN STD_LOGIC_VECTOR(3 downto 0);
       output:OUT STD_LOGIC_VECTOR(3 downto 0));
End four_bit_barrel_shifter;

architecture behave of four_bit_barrel_shifter is
 SIGNAL save_dir: STD_LOGIC:='0';

BEGIN

  Pdir:PROCESS(direction)
   BEGIN
     IF (direction'event AND direction='1') THEN
       save_dir<=not(save_dir);
     END IF;  
  end process Pdir;

  Pshifter: PROCESS(run)
    VARIABLE shift, b: INTEGER;

    BEGIN
      IF (run'event AND run='1') THEN
        shift:=to_integer(unsigned(nshift));
      
        --right shift
        if direction = '0' then
          if shift = 3 then
            output <= shift_vec(3 downto 0);
          elsif shift = 2 then
            output <= shift_vec(3 downto 1) & number(3);
          elsif shift = 1 then
            output <= shift_vec(3 downto 2)  & number(3 downto 2);
          elsif shift = 0 then
            output <= shift_vec(3) & number(2 downto 0);
         end if;
       
        -- left shift
        else 
          if shift = 3 then
            output <=  shift_vec(3 downto 0);
          elsif shift = 2 then
            output <=  number(3) & shift_vec(3 downto 1) ;
          elsif shift = 1 then
            output <=  number(3 downto 2) & shift_vec(3 downto 2) ;
          elsif shift = 0 then
            output <=  number(2 downto 0) & shift_vec(3) ;
         end if;
      
      END IF;
    END IF;
  end process Pshifter;
end behave;
