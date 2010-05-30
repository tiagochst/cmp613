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
	
	SUBTYPE block3 is std_logic_vector(2 downto 0);
	SUBTYPE color4 is std_logic_vector(3 downto 0);
	TYPE vcolor is array(0 to 5) of color4;
	
	TYPE t_direcao is (CIMA,DIREI,BAIXO,ESQUE,NADA);
	
	-- cores de cada tipo de bloco num�rico tab_sym
	CONSTANT RED_CMP: vcolor :=
	("0000", "0000", "0000", "1111", "1111", "1111");
	CONSTANT GRN_CMP: vcolor :=
	("0000", "0000", "0000", "1111", "0000", "1111");
	CONSTANT BLU_CMP: vcolor :=
	("0000", "0000", "1111", "1111", "0000", "0000");

	--A legenda pros elementos no tabuleiro � dada por tab_sym
	--Os n�meros representam elementos visuais na tela e o resto
	--representa posi��es especiais
	--' ': vazio, '.': caminho, 1: parede, 2: moeda, 3: porta
	TYPE tab_sym is (' ', '.', '1', '2', '3');
	TYPE blk_sym is (BLK_NULL, BLK_PATH, BLK_WALL, BLK_COIN, BLK_DOOR, BLK_PAC);
	
	TYPE tab is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of tab_sym;
	TYPE tab_sym_3x3 is array(-1 to 1, -1 to 1) of tab_sym;
	
	TYPE ovl_bitmap5 is array(0 to 4, 0 to 4) of STD_LOGIC;
	TYPE ovl_bitmap5_vet is array(t_direcao) of ovl_bitmap5; 
	   
	--Fator de divis�o do clock de 27MHz, usada para atualiza��o do
	--estado do jogo ("velocidade de execu��o")
	CONSTANT DIV_FACT: INTEGER := 1350000;

	subtype sentido is INTEGER range -1 to 1;
	TYPE direc is array(0 to 1) of sentido;
	TYPE direc_vet is array(t_direcao) of direc;
	
	CONSTANT DIRS: direc_vet := (CIMA  => (-1, 0), DIREI => ( 0, 1), 
	                             BAIXO => ( 1, 0), ESQUE => ( 0,-1),
	                             NADA  => ( 0, 0));
	
	CONSTANT PAC_START_X : INTEGER := 42;
	CONSTANT PAC_START_Y : INTEGER := 71;
	
	--Desenhos do pacman nas quatro possiveis direcoes
	CONSTANT PAC_BITMAPS: ovl_bitmap5_vet := 
	(CIMA =>  ("01010", "10111", "11111", "11111", "01110"),
	 DIREI => ("01110", "11101", "11110", "11111", "01110"),
	 BAIXO => ("01110", "11111", "11111", "10111", "01010"),
	 ESQUE => ("01110", "10111", "01111", "11111", "01110"),
	 OTHERS=> (OTHERS => (OTHERS => '0')));
	 
	TYPE mapa_t is array(0 to SCR_WDT*SCR_HGT-1) of tab_sym;
	CONSTANT MAPA_INICIAL: mapa_t := 
	"                                                                                                                                "&
	"                                                                                                                                "&
	" 1111111111111111111111111111111111111111   1111111111111111111111111111111111111111                                            "&
	" 1                                      1   1                                      1                                            "&
	" 1                                      1   1                                      1                                            "& 
	" 1  2..2..2..2..2..2..2..2..2..2..2..2  1   1  2..2..2..2..2..2..2..2..2..2..2..2  1                                            "&
	" 1  .              .                 .  1   1  .                 .              .  1                                            "& 
	" 1  .              .                 .  1   1  .                 .              .  1                                            "&
	" 1  2  1111111111  2  1111111111111  2  1   1  2  1111111111111  2  1111111111  2  1                                            "& 
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            "& 
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            "& 
	" 1  2  1        1  2  1           1  2  1   1  2  1           1  2  1        1  2  1                                            "& 
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            "& 
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            "& 
	" 1  2  1111111111  2  1111111111111  2  11111  2  1111111111111  2  1111111111  2  1                                            "& 
	" 1  .              .                 .         .                 .              .  1                                            "& 
	" 1  .              .                 .         .                 .              .  1                                            "& 
	" 1  2..2..2..2..2..2..2..2..2..2..2..2..2...2..2..2..2..2..2..2..2..2..2..2..2..2  1                                            "& 
	" 1  .              .        .                           .        .              .  1                                            "& 
	" 1  .              .        .                           .        .              .  1                                            "& 
	" 1  2  1111111111  2  1111  2  11111111111111111111111  2  1111  2  1111111111  2  1                                            "& 
	" 1  .  1        1  .  1  1  .  1                     1  .  1  1  .  1        1  .  1                                            "& 
	" 1  .  1        1  .  1  1  .  1                     1  .  1  1  .  1        1  .  1                                            "& 
	" 1  2  1111111111  2  1  1  2  1111111111   1111111111  2  1  1  2  1111111111  2  1                                            "& 
	" 1  .              .  1  1  .           1   1           .  1  1  .              .  1                                            "& 
	" 1  .              .  1  1  .           1   1           .  1  1  .              .  1                                            "& 
	" 1  2..2..2..2..2..2  1  1  2..2..2..2  1   1  2..2..2..2  1  1  2..2..2..2..2..2  1                                            "& 
	" 1                 .  1  1           .  1   1  .           1  1  .                 1                                            "& 
	" 1                 .  1  1           .  1   1  .           1  1  .                 1                                            "& 
	" 1111111111111111  2  1  1111111111  .  1   1  .  1111111111  1  2  1111111111111111                                            "& 
	"                1  .  1           1  .  1   1  .  1           1  .  1                                                           "& 
	"                1  .  1           1  .  1   1  .  1           1  .  1                                                           "& 
	"                1  2  1  1111111111  .  11111  .  1111111111  1  2  1                                                           "& 
	"                1  .  1  1           .         .           1  1  .  1                                                           "& 
	"                1  .  1  1           .         .           1  1  .  1                                                           "& 
	"                1  2  1  1  .............................  1  1  2  1                                                           "& 
	"                1  .  1  1  .                           .  1  1  .  1                                                           "& 
	"                1  .  1  1  .                           .  1  1  .  1                                                           "& 
	"                1  2  1  1  .  111111111     111111111  .  1  1  2  1                                                           "& 
	"                1  .  1  1  .  1       1333331       1  .  1  1  .  1                                                           "& 
	"                1  .  1  1  .  1       1     1       1  .  1  1  .  1                                                           "& 
	" 1111111111111111  2  1111  .  1  111111     111111  1  .  1111  2  1111111111111111                                            "& 
	"                   .        .  1  1               1  1  .        .                                                              "& 
	"                   .        .  1  1               1  1  .        .                                                              "& 
	" ..................2.........  1  1               1  1  .........2..................                                            "& 
	"                   .        .  1  1               1  1  .        .                                                              "& 
	"                   .        .  1  1               1  1  .        .                                                              "& 
	" 1111111111111111  2  1111  .  1  11111111111111111  1  .  1111  2  1111111111111111                                            "& 
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           "& 
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           "& 
	"                1  2  1  1  .  11111111111111111111111  .  1  1  2  1                                                           "& 
	"                1  .  1  1  .                           .  1  1  .  1                                                           "& 
	"                1  .  1  1  .                           .  1  1  .  1                                                           "& 
	"                1  2  1  1  .............................  1  1  2  1                                                           "& 
	"                1  .  1  1  .                           .  1  1  .  1                                                           "& 
	"                1  .  1  1  .                           .  1  1  .  1                                                           "& 
	"                1  2  1  1  .  11111111111111111111111  .  1  1  2  1                                                           "& 
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           "& 
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           "& 
	" 1111111111111111  2  1111  .  1111111111   1111111111  .  1111  2  1111111111111111                                            "& 
	" 1                 .        .           1   1           .        .                 1                                            "& 
	" 1                 .        .           1   1           .        .                 1                                            "& 
	" 1  2..2..2..2..2..2..2..2..2..2..2..2  1   1  2..2..2..2..2..2..2..2..2..2..2..2  1                                            "& 
	" 1  .              .                 .  1   1  .                 .              .  1                                            "& 
	" 1  .              .                 .  1   1  .                 .              .  1                                            "& 
	" 1  2  1111111111  2  1111111111111  2  1   1  2  1111111111111  2  1111111111  2  1                                            "& 
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            "& 
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            "& 
	" 1  2  1111111  1  2  1111111111111  2  11111  2  1111111111111  2  1  1111111  2  1                                            "& 
	" 1  .        1  1  .                 .         .                 .  1  1        .  1                                            "& 
	" 1  .        1  1  .                 .         .                 .  1  1        .  1                                            "& 
	" 1  2..2..2  1  1  2..2..2..2..2..2..2.........2..2..2..2..2..2..2  1  1  2..2..2  1                                            "& 
	" 1        .  1  1  .        .                           .        .  1  1  .        1                                            "& 
	" 1        .  1  1  .        .                           .        .  1  1  .        1                                            "& 
	" 1111111  2  1  1  2  1111  2  11111111111111111111111  2  1111  2  1  1  2  1111111                                            "& 
	"       1  .  1  1  .  1  1  .  1                     1  .  1  1  .  1  1  .  1                                                  "& 
	"       1  .  1  1  .  1  1  .  1                     1  .  1  1  .  1  1  .  1                                                  "& 
	" 1111111  2  1111  2  1  1  2  1111111111   1111111111  2  1  1  2  1111  2  1111111                                            "& 
	" 1        .        .  1  1  .           1   1           .  1  1  .        .        1                                            "& 
	" 1        .        .  1  1  .           1   1           .  1  1  .        .        1                                            "& 
	" 1  2..2..2..2..2..2  1  1  2..2..2..2  1   1  2..2..2..2  1  1  2..2..2..2..2..2  1                                            "& 
	" 1  .                 1  1           .  1   1  .           1  1                 .  1                                            "& 
	" 1  .                 1  1           .  1   1  .           1  1                 .  1                                            "& 
	" 1  2  1111111111111111  1111111111  2  1   1  2  1111111111  1111111111111111  2  1                                            "& 
	" 1  .  1                          1  .  1   1  .  1                          1  .  1                                            "& 
	" 1  .  1                          1  .  1   1  .  1                          1  .  1                                            "& 
	" 1  2  1111111111111111111111111111  2  11111  2  1111111111111111111111111111  2  1                                            "& 
	" 1  .                                .         .                                .  1                                            "& 
	" 1  .                                .         .                                .  1                                            "& 
	" 1  2..2..2..2..2..2..2..2..2..2..2..2..2...2..2..2..2..2..2..2..2..2..2..2..2..2  1                                            "& 
	" 1                                                                                 1                                            "& 
	" 1                                                                                 1                                            "& 
	" 11111111111111111111111111111111111111111111111111111111111111111111111111111111111                                            "& 
	"                                                                                                                                "& 
	"                                                                                                                                "& 
	"                                                                                                                                ";

END pac_defs;
