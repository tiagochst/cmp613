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
entity player_dir is 
port(
	code: IN STD_LOGIC_VECTOR(47 downto 0);
	p1_dir,p2_dir,p3_dir: OUT t_direcao
);
end entity player_dir;

architecture rtl of player_dir is
  signal key_1,key_2,key_3 : std_logic_vector(15 downto 0);

begin
-- Modelo:
-->> 2-players -> cada um aperta uma tecla
-- Codigo referente a cada tecla deve estar em key_1, key_2 ou key_3 
-- Problemas referentes a entrada de teclas:
-->> se um player aperta 3 teclas, o outro nao tera a sua tecla lida 
  key_1<=code(47 downto 32);-- terceira tecla pressionada
  key_2<=code(31 downto 16);-- segunda tecla pressionada
  key_3<=code(15 downto 0); -- primeira tecla pressionada

-- P 1 Teclas
-- Movimentacao|     Tecla    | codigo  
-- Cima        |  (Numpad 8)  | x"0075" 
-- Baixo       |  (Numpad 5)  | x"0073"
-- Esquerda    |  (Numpad 4)  | x"006B"
-- Direita     |  (Numpad 6)  | x"0074"

-- P 2 Teclas
-- Movimentacao|Tecla | codigo  
-- Cima        | (W)  | x"001d" 
-- Baixo       | (S)  | x"001b"
-- Esquerda    | (A)  | x"001c"
-- Direita     | (D)  | x"0023"

-- P 3 Teclas
-- Movimentacao|Tecla | codigo  
-- Cima        | (I)  | x"0043" 
-- Baixo       | (K)  | x"0042"
-- Esquerda    | (J)  | x"003B"
-- Direita     | (L)  | x"004B"

	--Implementação mais simples para 2 players com 3 teclas
	p1_dir <= CIMA  WHEN (key_1 = x"0075" or key_2 = x"0075" or key_3 = x"0075")
		ELSE  DIREI WHEN (key_1 = x"0074" or key_2 = x"0074" or key_3 = x"0074")
		ELSE  BAIXO WHEN (key_1 = x"0073" or key_2 = x"0073" or key_3 = x"0073")
		ELSE  ESQUE WHEN (key_1 = x"006B" or key_2 = x"006B" or key_3 = x"006B")
		ELSE  NADA;
		
	p2_dir <= CIMA  WHEN (key_1 = x"001d" or key_2 = x"001d" or key_3 = x"001d")
		ELSE  DIREI WHEN (key_1 = x"0023" or key_2 = x"0023" or key_3 = x"0023")
		ELSE  BAIXO WHEN (key_1 = x"001b" or key_2 = x"001b" or key_3 = x"001b")
		ELSE  ESQUE WHEN (key_1 = x"001c" or key_2 = x"001c" or key_3 = x"001c")
		ELSE  NADA;
		
	p3_dir <= CIMA  WHEN (key_1 = x"0043" or key_2 = x"0043" or key_3 = x"0043")
		ELSE  DIREI WHEN (key_1 = x"004B" or key_2 = x"004B" or key_3 = x"004B")
		ELSE  BAIXO WHEN (key_1 = x"0042" or key_2 = x"0042" or key_3 = x"0042")
		ELSE  ESQUE WHEN (key_1 = x"003B" or key_2 = x"003B" or key_3 = x"003B")
		ELSE  NADA;
END rtl;
