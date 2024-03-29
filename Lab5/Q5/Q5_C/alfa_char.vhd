--
--  decodifica o caractere pressionado
--           no display
--  para caracteres alfanumericos. 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--entrada: codigo proveniente do teclado
--saida: representacao em um display de sete segmentos
entity alfa_char is 
port( code: IN STD_LOGIC_VECTOR(15 downto 0);
      alfa_code: OUT STD_LOGIC_VECTOR(6 downto 0));
end entity alfa_char;

architecture rtl of alfa_char is
begin
   process(code)
      begin
      case (code) is
	    when x"001c" =>
		  alfa_code <= "0001000"; --A
	    when x"0032" =>
		  alfa_code <= "0000011"; --B
	    when x"0021" =>
		  alfa_code <= "1000110"; --C
	    when x"0023" =>
		  alfa_code <= "0100001"; --D
	    when x"0024" =>
		  alfa_code <= "0000110"; --E
	    when x"002b" =>
		  alfa_code <= "0001110"; --F
	    when x"0034" =>
		  alfa_code <= "1000010"; --G
	    when x"0033" =>
		  alfa_code <= "0001011"; --h
	    when x"0043" =>
		  alfa_code <= "1001111"; --I
	    when x"003b" =>
		  alfa_code <= "1100000"; --J
	    when x"0042" =>
		  alfa_code <= "0001001"; --K
	    when x"004b" =>
		  alfa_code <= "1000111"; --L
	    when x"003a" =>
		  alfa_code <= "0000110"; --M (codificado deitado "E")
	    when x"0031" =>
		  alfa_code <= "0101011"; --N ("n")
	    when x"0044" =>
		  alfa_code <= "1100011"; --O
	    when x"004d" =>
		  alfa_code <= "0001100"; --P
	    when x"0015" =>
		  alfa_code <= "0011000"; --Q
	    when x"002d" =>
		  alfa_code <= "0101111"; --R 
	    when x"001b" =>
		  alfa_code <= "0010010"; --S
	    when x"002c" =>
		  alfa_code <= "0000111"; --T ("t")
	    when x"003c" =>
		  alfa_code <= "1000001"; --U
	    when x"002a" =>
		  alfa_code <= "1100011"; --V
	    when x"001d" =>
		  alfa_code <= "0110000"; --W
	    when x"0022" =>
		  alfa_code <= "0001001"; --X
	    when x"0035" =>
		  alfa_code <= "0011001"; --Y
	    when x"001a" =>
		  alfa_code <= "0100100"; --Z
	    when x"0045" =>
		  alfa_code <= "1000000"; --0
	    when x"0016" =>
		  alfa_code <= "1111001"; --1
	    when x"001e" =>
		  alfa_code <= "0100100"; --2
	    when x"0026" =>
		  alfa_code <= "0110000"; --3
	    when x"0025" =>
		  alfa_code <= "0011001"; --4
	    when x"002e" =>
		  alfa_code <= "0010010"; --5
	    when x"0036" =>
		  alfa_code <= "0000010"; --6
	    when x"003d" =>
		  alfa_code <= "1111000"; --7
	    when x"003e" =>
		  alfa_code <= "0000000"; --8
	    when x"0046" =>
		  alfa_code <= "0011000"; --9
	    when others =>
		  alfa_code <="1111111";  --Apaga leds
      end case;
  end process;
END rtl;
