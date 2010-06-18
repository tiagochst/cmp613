LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
--USE work.PAC_SPRITES.all;
	
PACKAGE pac_defs IS
	-----------------------------------------------------------------------------
	-- Definições de dados, constantes e tipos para o jogo
	-----------------------------------------------------------------------------
		
	--Resolução de blocos usada (hgt linhas por wdt colunas)
	CONSTANT SCR_HGT : INTEGER := 96;
	CONSTANT SCR_WDT : INTEGER := 128;
	
	--Maior dimensao do tabuleiro (em blocos)
	CONSTANT TAB_LEN: INTEGER := 91; 
	
	SUBTYPE t_color_3b is std_logic_vector(2 downto 0);
	
	TYPE t_direcao is (CIMA,DIREI,BAIXO,ESQUE,NADA);
	
	--A legenda pros elementos no tabuleiro é dada por t_tab_sym
	--Cuidado para manter a mesma sequencia observada em t_blk_sym (FIXME)
	--Os números representam elementos visuais na tela e o resto
	--representa posições especiais
	--' ': vazio, '.': caminho, 6 tipos de parede de acordo com a orientação,
	--C: moeda, P: moeda especial, D: porta
	TYPE t_tab_sym is (' ', '.', '|', '-', 'Q', 'W', 'E', 'R', 'C', 'P', 'D');
	
	SUBTYPE t_blk_id is STD_LOGIC_VECTOR(3 downto 0);
	SUBTYPE t_ovl_blk_id is STD_LOGIC_VECTOR(8 downto 0);
	
	TYPE t_blk_sym is (BLK_NULL, BLK_PATH, BLK_WALL_V, BLK_WALL_H, BLK_WALL_Q, BLK_WALL_W, BLK_WALL_E,
					 BLK_WALL_R, BLK_COIN, BLK_SPC_COIN, BLK_DOOR);
					 
	TYPE t_blk_bool is array(t_blk_sym) of boolean;
	CONSTANT WALKABLE: t_blk_bool := --define quais blocos são percorríveis
		(BLK_PATH => true, BLK_COIN => true, BLK_SPC_COIN => true, OTHERS => false);
	
	TYPE t_ovl_blk_sym is (Ver figura XXXXXX);	
	CONSTANT FAN_NO: INTEGER := 2; --Número de fantasmas no jogo
					 
	TYPE c_tab_blk is array(t_tab_sym) of t_blk_sym;
	CONSTANT CONV_TAB_BLK: c_tab_blk := 
		(' ' => BLK_NULL, '.' => BLK_PATH, '|' => BLK_WALL_V, '-' => BLK_WALL_H, 'Q' => BLK_WALL_Q, 'W' => BLK_WALL_W,
		 'E' => BLK_WALL_E, 'R' => BLK_WALL_R, 'C' => BLK_COIN, 'P' => BLK_SPC_COIN, 'D' => BLK_DOOR);

	TYPE t_tab is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	TYPE t_blk_sym_3x3 is array(-1 to 1, -1 to 1) of t_blk_sym;
	
	TYPE t_sprite5 is array(0 to 4, 0 to 4) of STD_LOGIC;
	TYPE t_ovl_blk_5x5 is array(0 to 4, 0 to 4) of t_ovl_blk_sym;
	TYPE t_ovl_blk_dir_vet is array(t_direcao) of t_ovl_blk_5x5;
	TYPE t_fans_ovl_blk_dir_vet is array(0 to FAN_NO-1) of t_ovl_blk_dir_vet;
	
	TYPE t_sprite5_vet is array(t_blk_sym) of t_sprite5;
	TYPE t_ovl_sprite5_vet is array(t_ovl_blk_sym) of t_sprite5;
	
	--Tipos em array para os fantasmas
	SUBTYPE t_pos is INTEGER range 0 to TAB_LEN-1;
	SUBTYPE t_offset IS INTEGER range -TAB_LEN to TAB_LEN;
	SUBTYPE t_fan_time is INTEGER range 0 to 1000;
	TYPE t_fan_state is (ST_VIVO, ST_VULN, ST_VULN_BLINK, ST_DEAD, ST_PRE_DEAD, ST_FIND_EXIT, ST_FUGA);
	
	TYPE t_fans_pos is array(0 to FAN_NO-1) of t_pos;
	TYPE t_fans_dirs is array(0 to FAN_NO-1) of t_direcao;
	TYPE t_fans_blk_sym is array(0 to FAN_NO-1) of t_blk_sym;
	TYPE t_fans_blk_sym_3x3 is array(0 to FAN_NO-1) of t_blk_sym_3x3;
	TYPE t_fans_states is array(0 to FAN_NO-1) of t_fan_state;
	TYPE t_fans_times is array(0 to FAN_NO-1) of t_fan_time;
	SUBTYPE t_fans_bits is STD_LOGIC_VECTOR(0 to FAN_NO-1);
	
	TYPE t_vidas_pos is array(0 to 2) of t_pos;
	
	SUBTYPE t_velocs is INTEGER range 0 to 20;
	TYPE t_vet_velocs is array(0 to 2) of t_velocs;
	   
	--Fator de divisão do clock de 27MHz, usada para atualização do
	--estado do jogo ("velocidade de execução")
	CONSTANT DIV_FACT: INTEGER := 202500;
	CONSTANT DISP_DIV_FACT: INTEGER := 20*DIV_FACT;

	subtype sentido is INTEGER range -1 to 1;
	TYPE t_direc is array(0 to 1) of sentido;
	TYPE t_direc_vet is array(t_direcao) of t_direc;
	
	CONSTANT DIRS: t_direc_vet := (CIMA  => (-1, 0), DIREI => ( 0, 1), 
	                               BAIXO => ( 1, 0), ESQUE => ( 0,-1),
	                               NADA  => ( 0, 0));
	
	CONSTANT PAC_START_X : INTEGER := 42;
	CONSTANT PAC_START_Y : INTEGER := 71;
	CONSTANT FANS_START_X : t_fans_pos := (40, 45);
	CONSTANT FANS_START_Y : t_fans_pos := (44, 44);
	CONSTANT FAN_TIME_VULN_START_BLINK : INTEGER := 600;
	CONSTANT FAN_TIME_VULN_END : INTEGER := 750;
	CONSTANT FAN_TIME_DEAD : INTEGER := 700;
	CONSTANT CELL_IN_X : INTEGER := 42;
	CONSTANT CELL_IN_Y : INTEGER := 44;
	CONSTANT CELL_OUT_Y : INTEGER := 35;
	CONSTANT TELE_DIR_POS : INTEGER := 82;
	CONSTANT TELE_ESQ_POS : INTEGER := 2;
	CONSTANT VIDA_ICONS_X: t_vidas_pos := (90, 90, 90);
	CONSTANT VIDA_ICONS_Y: t_vidas_pos := (89, 83, 77);
	--velocidades de atualização para: 0=pacman, 1=fantasma, 2=fantasma morto
	CONSTANT VEL_DIV: t_vet_velocs := (6, 5, 4); 
	
	TYPE t_tab_array is array(0 to SCR_WDT*SCR_HGT-1) of t_tab_sym;
	TYPE t_tab_mapa is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	--Mapa de inicialização da RAM inferior, a legenda está acima 
	CONSTANT MAPA_INICIAL: t_tab_array := VER -----
	
	--Neste mapa, estão armazenados apenas a próxima direção do percurso de um fantasma
    --quando este é comido. A legenda é Q: CIMA, W: BAIXO, E: ESQUERDA, R: DIREITA 
	CONSTANT FAN_PERCURSO: t_tab_mapa := ver --------


END pac_defs;
