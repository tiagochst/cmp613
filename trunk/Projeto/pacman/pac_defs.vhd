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
	
	--Maior dimensao do tabuleiro (em casas)
	CONSTANT TAB_LEN: INTEGER := 91; 
	
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
	
	type ovl_bitmap5 is array(0 to 4, 0 to 4) of STD_LOGIC;
	type ovl_bitmap5_vet is array(0 to 3) of ovl_bitmap5; 
	   
	--Fator de divis�o do clock de 27MHz, usada para atualiza��o do
	--estado do jogo ("velocidade de execu��o")
	CONSTANT DIV_FACT: INTEGER := 270000;
	
	subtype sentido is INTEGER range -1 to 1;
	type direc is array(0 to 1) of sentido;
	type direc_vet is array(0 to 3) of direc;
	
	--Quatro vetores de dire��o: cima, direita, baixo, esquerda
	CONSTANT DIRS: direc_vet := ((-1,0), (0,1), (1,0), (0,-1));
	
	CONSTANT PAC_START_X : INTEGER := 42;
	CONSTANT PAC_START_Y : INTEGER := 71;
	
	--Desenhos do pacman nas quatro possiveis direcoes
	CONSTANT PAC_BITMAPS: ovl_bitmap5_vet := 
	(("01010", "10111", "11111", "11111", "01110"),
	 ("01110", "11101", "11110", "11111", "01110"),
	 ("01110", "11111", "11111", "10111", "01010"),
	 ("01110", "10111", "01111", "11111", "01110"));
END pac_defs;
