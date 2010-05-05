LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
	
PACKAGE pac_defs IS
	-----------------------------------------------------------------------------
	-- Defini��es de dados, constantes e tipos para o jogo
	-----------------------------------------------------------------------------
	
	--Resolu��o de tela usada (hgt linhas por wdt colunas)
	CONSTANT SCR_HGT : INTEGER := 96;
	CONSTANT SCR_WDT : INTEGER := 128;
	
	subtype color3 is std_logic_vector(2 downto 0);
	type vcolor is array(0 to 3) of color3; 
	
	-- cores de cada tipo de bloco num�rico tab_sym
	CONSTANT COLORS: vcolor := ("000", "001", "111", "100"); 

	--A legenda pros elementos no tabuleiro � dada por tab_sym
	--Os n�meros representam elementos visuais na tela e o resto
	--representa posi��es especiais
	--' ': vazio, '.': caminho, 1: parede, 2: moeda, 3: porta
	type tab_sym is (' ', '.', '1', '2', '3');         
	type tab is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of tab_sym;
	
	--Fator de divis�o do clock de 27MHz, usada para atualiza��o do
	--estado do jogo ("velocidade de execu��o")
	CONSTANT DIV_FACT: INTEGER := 270000;

	--O cen�rio do jogo eh inicializado com todas as moedas e as paredes
	--As moedas v�o sendo removidas dessa estrutura de acordo com o jogo
	--O pacman e os fantasmas s�o desenhados separadamente sob essa tela
END pac_defs;
