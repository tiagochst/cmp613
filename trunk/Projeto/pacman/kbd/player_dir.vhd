--
--  decodifica tecla pressionada
--           em direcao
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pac_defs.all;

--entrada: codigo proveniente do teclado
--saida: mudancas de direcao do player
-- code entrada codificada das teclas 
--(maximo tres teclas pressionadas 16 bits cada)
-- p1_dir - p2_dir representacao de cima,desce,esquerda,direita,nenhuma
entity player_dir is 
port(
	code: IN STD_LOGIC_VECTOR(47 downto 0);
	p1_dir,p2_dir: OUT t_direcao;
	p2_key0: OUT STD_LOGIC
);
end entity player_dir;

architecture rtl of player_dir is
  signal key_1,key_2,key_3 : std_logic_vector(15 downto 0);

begin
-- Modelo:
-->> 2-players -> cada um aperta uma tecla
-- Codigo referente a cada tecla deve estar em key_1 ou key_2 
-->> Desconsiderarei key_3 -> implementacao futura mas sem grande utilidade.
-- Problemas referentes a entrada de teclas:
-->> se um player aperta 3 teclas, o outro nao tera a sua teclalida 
  key_1<=code(47 downto 32);-- terceira tecla pressionada
  key_2<=code(31 downto 16);-- segunda tecla pressionada
  key_3<=code(15 downto 0); -- primeira tecla pressionada

-- P 1 Teclas
-- Movimentacao|     Tecla         | codigo  
-- Cima        |(up - key arrow)   | x"E075" 
-- Baixo       |(down - key arrow) | x"E072"
-- Esquerda    |(down - key arrow) | x"E06b"
-- Direita     |(right - key arrow)| x"E074"

-- P 2 Teclas
-- Movimentacao|Tecla | codigo  
-- Cima        | (W)  | x"001d" 
-- Baixo       | (S)  | x"001b"
-- Esquerda    | (A)  | x"001c"
-- Direita     | (D)  | x"0023"

--Tabela de decodificao
-- Cima     :  010
-- Baixo    :  011
-- Esquerda :  001
-- Direita  :  000
-- Nenhuma  :  111

--Implementacao para 1 player
--     process(key_3)
--      begin
--      case (key_3) is
--	    when x"E074" =>
--		   p1_dir <= "000"; -- direita p1
--			p2_dir <="000";
--	    when x"E06b" =>
--		   p1_dir <= "001"; -- esquerda p1
--		   p2_dir <="000";
--	    when x"E075" =>
--		   p1_dir <= "010"; -- cima p1
--		   p2_dir <="000";
--	    when x"E072" =>
--		   p1_dir <= "011"; -- baixo p1
--			p2_dir <="000";
--	   when others=>  --Apaga leds
--		   p1_dir <= "111"; -- cima p1
--		   p2_dir <="111";
--      end case;

--
--Implementacao para 2 players...sera que tem lentidao?
--
--  PROCESS(key_3,key_2)
--    BEGIN
--      IF((key_3 = x"E074" and key_2 =x"0023") or 
--		(key_2 = x"E074" and key_3 =x"0023") ) THEN
--	  	   p1_dir <= "000";  -- direita p1
--		p2_dir <= "000";  -- diretia p2
--	  ELSIF ((key_3 = x"E06b" and key_2 = x"001c") or
--		     (key_2 = x"E06b" and key_3 = x"001c") ) THEN
--		  p1_dir <= "001";  -- esquerda p1
--		  p2_dir <= "001";  -- esquerda p2
--	  ELSIF ((key_3 = x"001d" and key_2 = x"E075") or
--		     (key_2 = x"001d" and key_3 = x"E075") ) THEN
--		  p1_dir <= "010";  -- cima p1
--		  p2_dir <= "010";  -- cima p2
--	  ELSIF ((key_3 = x"001b" and key_2 =  x"E072") or
--		     (key_2 = x"001b" and key_3 =  x"E072") ) THEN
--		  p1_dir <= "011";  -- baixo p1
--		  p2_dir <= "011";  -- baixo p2
--	  ELSIF ((key_3 = x"E074" and key_2 =  x"001c") or
--		     (key_2 = x"E074" and key_3 =  x"001c") ) THEN
--		  p1_dir <= "000";  -- direira  p1
--		  p2_dir <="001";   -- esquerda p2 
--	  ELSIF ((key_3 = x"E074" and key_2 =  x"001d") or
--		     (key_2 = x"E074" and key_3 =  x"001d") ) THEN
--		  p1_dir <= "000";  -- direira  p1
--		  p2_dir <="010";   -- cima p2 
--	  ELSIF ((key_3 = x"E074" and key_2 =  x"001b") or
--		     (key_2 = x"E074" and key_3 =  x"001b") ) THEN
--		  p1_dir <= "000";  -- direira  p1
--		  p2_dir <="011";   -- baixo p2 
--	  ELSIF ((key_3 = x"E06b" and key_2 =  x"0023") or
--		     (key_2 = x"E06b" and key_3 =  x"0023") ) THEN
--		  p1_dir <= "001";  -- esquerda  p1
--		  p2_dir <="000";   -- direita p2 
--	  ELSIF ((key_3 = x"E06b" and key_2 =  x"001d") or
--		     (key_2 = x"E06b" and key_3 =  x"001d") ) THEN
--		  p1_dir <= "001";  -- esquerda  p1
--		  p2_dir <="010";   -- cima p2 
--	  ELSIF ((key_3 = x"E06b" and key_2 =  x"001b") or
--		     (key_2 = x"E06b" and key_3 =  x"001b") ) THEN
--		  p1_dir <= "001";  -- esquerda  p1
--		  p2_dir <= "011";  -- baixo p2 
--	  ELSIF ((key_3 = x"0023" and key_2 = x"E075") or
--		     (key_2 = x"0023" and key_3 = x"E075") ) THEN
--		  p1_dir <= "010";  -- cima p1
--		  p2_dir <= "000";  -- direita p2
--	  ELSIF ((key_3 = x"001c" and key_2 = x"E075") or
--		     (key_2 = x"001c" and key_3 = x"E075") ) THEN
--		  p1_dir <= "010";  -- cima p1
--		  p2_dir <= "001";  -- esquerda p2
--	  ELSIF ((key_3 = x"001b" and key_2 = x"E075") or
--		     (key_2 = x"001b" and key_3 = x"E075") ) THEN
--		  p1_dir <= "010";  -- cima p1
--		  p2_dir <= "011";  -- baixo p2
--	  ELSIF ((key_3 = x"0023" and key_2 =  x"E072") or
--		     (key_2 = x"0023" and key_3 =  x"E072") ) THEN
--		  p1_dir <= "011";  -- baixo p1
--		  p2_dir <= "000";  -- direita p2
--	  ELSIF ((key_3 = x"001c" and key_2 =  x"E072") or
--		     (key_2 = x"001c" and key_3 =  x"E072") ) THEN
--		  p1_dir <= "011";  -- baixo p1
--		  p2_dir <= "001";  -- esquerda p2
--	  ELSIF ((key_3 = x"001d" and key_2 =  x"E072") or
--		     (key_2 = x"001d" and key_3 =  x"E072") ) THEN
--		  p1_dir <= "011";  -- baixo p1
--		  p2_dir <= "010";  -- cima p2
--	  ELSIF (key_3 = x"E074" ) THEN
--		  p1_dir <= "000";  -- direita p1
--		  p2_dir <= "111";  -- nenhum  p2
--	  ELSIF (key_3 = x"E06b" ) THEN
--		  p1_dir <= "001";  -- esquerda p1
--		  p2_dir <= "111";  -- nenhum  p2
--	  ELSIF (key_3 = x"E075" ) THEN
--		  p1_dir <= "010";  -- cima p1
--		  p2_dir <= "111";  -- nenhum  p2
--	  ELSIF (key_3 = x"E072" ) THEN
--		  p1_dir <= "011";  -- baixo p1
--		  p2_dir <= "111";  -- nenhum  p2
--	  ELSIF (key_3 = x"0023" ) THEN
--		  p1_dir <= "111";  -- nenhum p1
--		  p2_dir <= "000";  -- direita  p2
--	  ELSIF (key_3 = x"001c" ) THEN
--		  p1_dir <= "111";  -- nenhum p1
--		  p2_dir <= "001";  -- esquerda  p2
--	  ELSIF (key_3 = x"001d" ) THEN
--		  p1_dir <= "111";  -- nenhum p1
--		  p2_dir <= "010";  -- cima  p2
--	  ELSIF (key_3 = x"001b" ) THEN
--		  p1_dir <= "111";  -- nenhum p1
--		  p2_dir <= "011";  -- baixo  p2
--      ELSE 
--		  p1_dir <= "111";  --nenhum p1
--		  p2_dir <= "111";  --nenhum  p2
--      END IF;
--  END PROCESS;

	--Implementação mais simples para 2 players com 3 teclas
	p1_dir <= CIMA  WHEN (key_1 = x"E075" or key_2 = x"E075" or key_3 = x"E075")
		ELSE  DIREI WHEN (key_1 = x"E074" or key_2 = x"E074" or key_3 = x"E074")
		ELSE  BAIXO WHEN (key_1 = x"E072" or key_2 = x"E072" or key_3 = x"E072")
		ELSE  ESQUE WHEN (key_1 = x"E06b" or key_2 = x"E06b" or key_3 = x"E06b")
		ELSE  NADA;
		
	p2_dir <= CIMA  WHEN (key_1 = x"001d" or key_2 = x"001d" or key_3 = x"001d")
		ELSE  DIREI WHEN (key_1 = x"0023" or key_2 = x"0023" or key_3 = x"0023")
		ELSE  BAIXO WHEN (key_1 = x"001b" or key_2 = x"001b" or key_3 = x"001b")
		ELSE  ESQUE WHEN (key_1 = x"001c" or key_2 = x"001c" or key_3 = x"001c")
		ELSE  NADA;
		
	p2_key0 <= '1' WHEN (key_1 = x"0029" or key_2 = x"0029" or key_3 = x"0029")
		ELSE '0';
END rtl;
