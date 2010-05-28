--
--  decodifica tecla pressionada
--           em direcao
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--entrada: codigo proveniente do teclado
--saida: mudancas de direcao do player
entity player_dir is 
port( code: IN STD_LOGIC_VECTOR(47 downto 0);
       p1_dir,p2_dir: OUT STD_LOGIC_VECTOR(2 downto 0));--colocar um enum type
end entity player_dir;

architecture rtl of player_dir is
  signal key_1,key_2,key_3 : std_logic_vector(15 downto 0);

begin
  key_1<=code(47 downto 32);
  key_2<=code(31 downto 16);
  key_3<=code(15 downto 0);

     process(key_1,key_2,key_3)
      begin
      case (key_3) is
	    when x"E074" =>
		   p1_dir <= "000"; -- direita p1
			p2_dir <="000";
	    when x"E06b" =>
		   p1_dir <= "001"; -- esquerda p1
		   p2_dir <="000";
	    when x"E075" =>
		   p1_dir <= "010"; -- cima p1
		   p2_dir <="000";
	    when x"E072" =>
		   p1_dir <= "011"; -- baixo p1
			p2_dir <="000";
--	    when x"001c" =>
--		   p2_dir <= "00"; -- direita p2
--	    when x"0032" =>
--		   p2_dir <= "01"; -- esquerda p2
--	    when x"0021" =>
--		   p2_dir <= "10"; -- cima p2
--	    when x"0023" =>
--		   p2_dir <= "11"; -- baixo p2

	   when others=>  --Apaga leds
		   p1_dir <= "111"; -- cima p1
		   p2_dir <="111";
      end case;

--     case (key_2) is
--	    when x"001c" =>
--		   p1_dir <= "00"; -- direita p1
--	    when x"0032" =>
--		   p1_dir <= "01"; -- esquerda p1
--	    when x"0021" =>
--		   p1_dir <= "10"; -- cima p1
--	    when x"0023" =>
--		   p1_dir <= "11"; -- baixo p1
----
----	    when x"001c" =>
----		   p2_dir <= "00"; -- direita p2
----	    when x"0032" =>
----		   p2_dir <= "01"; -- esquerda p2
----	    when x"0021" =>
----		   p2_dir <= "10"; -- cima p2
----	    when x"0023" =>
----		   p2_dir <= "11"; -- baixo p2
--
--	    when others=>
--	    p1_dir <="00";
--	    p2_dir <="00";--Apaga leds
--      end case;
-- 
--      case (key_3) is
--	    when x"001c" =>
--		   p1_dir <= "00"; -- direita p1
--	    when x"0032" =>
--		   p1_dir <= "01"; -- esquerda p1
--	    when x"0021" =>
--		   p1_dir <= "10"; -- cima p1
--	    when x"0023" =>
--		   p1_dir <= "11"; -- baixo p1
--
--	    when x"001c" =>
--		   p2_dir <= "00"; -- direita p2
--	    when x"0032" =>
--		   p2_dir <= "01"; -- esquerda p2
--	    when x"0021" =>
--		   p2_dir <= "10"; -- cima p2
--	    when x"0023" =>
--		   p2_dir <= "11"; -- baixo p2
--
--	    when others=>  --Apaga leds
--      end case;
 
  end process;
END rtl;
