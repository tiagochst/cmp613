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
	
	--Maior dimensao do tabuleiro (em blocos)
	CONSTANT TAB_LEN: INTEGER := 91; 
	
	SUBTYPE t_color_3b is std_logic_vector(2 downto 0);
	
	TYPE t_direcao is (CIMA,DIREI,BAIXO,ESQUE,NADA);
	
	--A legenda pros elementos no tabuleiro � dada por t_tab_sym
	--Cuidado para manter a mesma sequencia observada em t_blk_sym (FIXME)
	--Os n�meros representam elementos visuais na tela e o resto
	--representa posi��es especiais
	--' ': vazio, '.': caminho, 6 tipos de parede de acordo com a orienta��o,
	--C: moeda, P: moeda especial, D: porta
	TYPE t_tab_sym is (' ', '.', '|', '-', 'Q', 'W', 'E', 'R', 'C', 'P', 'D');
	
	SUBTYPE t_blk_id is STD_LOGIC_VECTOR(3 downto 0);
	SUBTYPE t_ovl_blk_id is STD_LOGIC_VECTOR(7 downto 0);
	
	TYPE t_blk_sym is (BLK_NULL, BLK_PATH, BLK_WALL_V, BLK_WALL_H, BLK_WALL_Q, BLK_WALL_W, BLK_WALL_E,
					 BLK_WALL_R, BLK_COIN, BLK_SPC_COIN, BLK_DOOR);
	
	TYPE ovl_blk_sym is (BLK_NULL,
	                 BLK_PAC_CIM_00, BLK_PAC_CIM_01, BLK_PAC_CIM_02, BLK_PAC_CIM_03, BLK_PAC_CIM_04,
	                 BLK_PAC_CIM_10, BLK_PAC_CIM_11, BLK_PAC_CIM_12, BLK_PAC_CIM_13, BLK_PAC_CIM_14,
					 BLK_PAC_CIM_20, BLK_PAC_CIM_21, BLK_PAC_CIM_22, BLK_PAC_CIM_23, BLK_PAC_CIM_24,
					 BLK_PAC_CIM_30, BLK_PAC_CIM_31, BLK_PAC_CIM_32, BLK_PAC_CIM_33, BLK_PAC_CIM_34,
					 BLK_PAC_CIM_40, BLK_PAC_CIM_41, BLK_PAC_CIM_42, BLK_PAC_CIM_43, BLK_PAC_CIM_44,
					 BLK_PAC_DIR_00, BLK_PAC_DIR_01, BLK_PAC_DIR_02, BLK_PAC_DIR_03, BLK_PAC_DIR_04,
	                 BLK_PAC_DIR_10, BLK_PAC_DIR_11, BLK_PAC_DIR_12, BLK_PAC_DIR_13, BLK_PAC_DIR_14,
					 BLK_PAC_DIR_20, BLK_PAC_DIR_21, BLK_PAC_DIR_22, BLK_PAC_DIR_23, BLK_PAC_DIR_24,
					 BLK_PAC_DIR_30, BLK_PAC_DIR_31, BLK_PAC_DIR_32, BLK_PAC_DIR_33, BLK_PAC_DIR_34,
					 BLK_PAC_DIR_40, BLK_PAC_DIR_41, BLK_PAC_DIR_42, BLK_PAC_DIR_43, BLK_PAC_DIR_44,
					 BLK_PAC_BAI_00, BLK_PAC_BAI_01, BLK_PAC_BAI_02, BLK_PAC_BAI_03, BLK_PAC_BAI_04,
	                 BLK_PAC_BAI_10, BLK_PAC_BAI_11, BLK_PAC_BAI_12, BLK_PAC_BAI_13, BLK_PAC_BAI_14,
					 BLK_PAC_BAI_20, BLK_PAC_BAI_21, BLK_PAC_BAI_22, BLK_PAC_BAI_23, BLK_PAC_BAI_24,
					 BLK_PAC_BAI_30, BLK_PAC_BAI_31, BLK_PAC_BAI_32, BLK_PAC_BAI_33, BLK_PAC_BAI_34,
					 BLK_PAC_BAI_40, BLK_PAC_BAI_41, BLK_PAC_BAI_42, BLK_PAC_BAI_43, BLK_PAC_BAI_44,
					 BLK_PAC_ESQ_00, BLK_PAC_ESQ_01, BLK_PAC_ESQ_02, BLK_PAC_ESQ_03, BLK_PAC_ESQ_04,
	                 BLK_PAC_ESQ_10, BLK_PAC_ESQ_11, BLK_PAC_ESQ_12, BLK_PAC_ESQ_13, BLK_PAC_ESQ_14,
					 BLK_PAC_ESQ_20, BLK_PAC_ESQ_21, BLK_PAC_ESQ_22, BLK_PAC_ESQ_23, BLK_PAC_ESQ_24,
					 BLK_PAC_ESQ_30, BLK_PAC_ESQ_31, BLK_PAC_ESQ_32, BLK_PAC_ESQ_33, BLK_PAC_ESQ_34,
					 BLK_PAC_ESQ_40, BLK_PAC_ESQ_41, BLK_PAC_ESQ_42, BLK_PAC_ESQ_43, BLK_PAC_ESQ_44,
					 BLK_PAC_FECH_00, BLK_PAC_FECH_01, BLK_PAC_FECH_02, BLK_PAC_FECH_03, BLK_PAC_FECH_04,
					 BLK_PAC_FECH_10, BLK_PAC_FECH_11, BLK_PAC_FECH_12, BLK_PAC_FECH_13, BLK_PAC_FECH_14,
					 BLK_PAC_FECH_20, BLK_PAC_FECH_21, BLK_PAC_FECH_22, BLK_PAC_FECH_23, BLK_PAC_FECH_24,
					 BLK_PAC_FECH_30, BLK_PAC_FECH_31, BLK_PAC_FECH_32, BLK_PAC_FECH_33, BLK_PAC_FECH_34,
					 BLK_PAC_FECH_40, BLK_PAC_FECH_41, BLK_PAC_FECH_42, BLK_PAC_FECH_43, BLK_PAC_FECH_44,
					 BLK_PAC_FECV_00, BLK_PAC_FECV_01, BLK_PAC_FECV_02, BLK_PAC_FECV_03, BLK_PAC_FECV_04,
					 BLK_PAC_FECV_10, BLK_PAC_FECV_11, BLK_PAC_FECV_12, BLK_PAC_FECV_13, BLK_PAC_FECV_14,
					 BLK_PAC_FECV_20, BLK_PAC_FECV_21, BLK_PAC_FECV_22, BLK_PAC_FECV_23, BLK_PAC_FECV_24,
					 BLK_PAC_FECV_30, BLK_PAC_FECV_31, BLK_PAC_FECV_32, BLK_PAC_FECV_33, BLK_PAC_FECV_34,
					 BLK_PAC_FECV_40, BLK_PAC_FECV_41, BLK_PAC_FECV_42, BLK_PAC_FECV_43, BLK_PAC_FECV_44,
					 BLK_FAN_00, BLK_FAN_01, BLK_FAN_02, BLK_FAN_03, BLK_FAN_04,
					 BLK_FAN_10, BLK_FAN_11, BLK_FAN_12, BLK_FAN_13, BLK_FAN_14,
					 BLK_FAN_20, BLK_FAN_21, BLK_FAN_22, BLK_FAN_23, BLK_FAN_24,
					 BLK_FAN_30, BLK_FAN_31, BLK_FAN_32, BLK_FAN_33, BLK_FAN_34,
					 BLK_FAN_40, BLK_FAN_41, BLK_FAN_42, BLK_FAN_43, BLK_FAN_44
					);
					 
	TYPE c_tab_blk is array(t_tab_sym) of t_blk_sym;
	CONSTANT CONV_TAB_BLK: c_tab_blk := 
		(' ' => BLK_NULL, '.' => BLK_PATH, '|' => BLK_WALL_V, '-' => BLK_WALL_H, 'Q' => BLK_WALL_Q, 'W' => BLK_WALL_W,
		 'E' => BLK_WALL_E, 'R' => BLK_WALL_R, 'C' => BLK_COIN, 'P' => BLK_SPC_COIN, 'D' => BLK_DOOR);

	TYPE tab is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	TYPE blk_sym_3x3 is array(-1 to 1, -1 to 1) of t_blk_sym;
	
	TYPE sprite5 is array(0 to 4, 0 to 4) of STD_LOGIC;
	TYPE ovl_blk_5x5 is array(0 to 4, 0 to 4) of ovl_blk_sym;
	TYPE ovl_blk_dir_vet is array(t_direcao) of ovl_blk_5x5;
	TYPE sprite5_vet is array(t_blk_sym) of sprite5;
	TYPE ovl_sprite5_vet is array(ovl_blk_sym) of sprite5;
	
	CONSTANT FAN_NO: INTEGER := 2; --N�mero de fantasmas no jogo (n�o � gen�rico no toplevel FIXME)
	--Tipos em array para os fantasmas
	SUBTYPE t_pos is INTEGER range 0 to TAB_LEN-1;
	SUBTYPE t_fan_time is INTEGER range 0 to 1000;
	TYPE t_fan_state is (ST_VIVO, ST_VULN, ST_DEAD, ST_FIND_EXIT, ST_FUGA);
	
	TYPE t_fans_pos is array(0 to FAN_NO-1) of t_pos;
	TYPE t_fans_dirs is array(0 to FAN_NO-1) of t_direcao;
	TYPE t_fans_blk_sym is array(0 to FAN_NO-1) of t_blk_sym;
	TYPE t_fans_blk_sym_3x3 is array(0 to FAN_NO-1) of blk_sym_3x3;
	TYPE t_fans_states is array(0 to FAN_NO-1) of t_fan_state;
	TYPE t_fans_times is array(0 to FAN_NO-1) of t_fan_time;
	   
	--Fator de divis�o do clock de 27MHz, usada para atualiza��o do
	--estado do jogo ("velocidade de execu��o")
	CONSTANT DIV_FACT: INTEGER := 225000;

	subtype sentido is INTEGER range -1 to 1;
	TYPE direc is array(0 to 1) of sentido;
	TYPE direc_vet is array(t_direcao) of direc;
	
	CONSTANT DIRS: direc_vet := (CIMA  => (-1, 0), DIREI => ( 0, 1), 
	                             BAIXO => ( 1, 0), ESQUE => ( 0,-1),
	                             NADA  => ( 0, 0));
	
	CONSTANT PAC_START_X : INTEGER := 42;
	CONSTANT PAC_START_Y : INTEGER := 71;
	CONSTANT FANS_START_X : t_fans_pos := (40, 45);
	CONSTANT FANS_START_Y : t_fans_pos := (44, 44);
	CONSTANT FAN_TIME_VULN : INTEGER := 1000;
	CONSTANT FAN_TIME_DEAD : INTEGER := 1000;
	CONSTANT CELL_IN_X : INTEGER := 42;
	CONSTANT CELL_IN_Y : INTEGER := 44;
	CONSTANT CELL_OUT_Y : INTEGER := 35;
	CONSTANT TELE_DIR_POS : INTEGER := 82;
	CONSTANT TELE_ESQ_POS : INTEGER := 2;
	
	--Desenhos do pacman nas quatro possiveis direcoes
	CONSTANT PAC_BITMAPS: ovl_blk_dir_vet := (
	CIMA =>   ((BLK_PAC_CIM_00, BLK_PAC_CIM_01, BLK_PAC_CIM_02, BLK_PAC_CIM_03, BLK_PAC_CIM_04),
	           (BLK_PAC_CIM_10, BLK_PAC_CIM_11, BLK_PAC_CIM_12, BLK_PAC_CIM_13, BLK_PAC_CIM_14),
	           (BLK_PAC_CIM_20, BLK_PAC_CIM_21, BLK_PAC_CIM_22, BLK_PAC_CIM_23, BLK_PAC_CIM_24),
	           (BLK_PAC_CIM_30, BLK_PAC_CIM_31, BLK_PAC_CIM_32, BLK_PAC_CIM_33, BLK_PAC_CIM_34),
	           (BLK_PAC_CIM_40, BLK_PAC_CIM_41, BLK_PAC_CIM_42, BLK_PAC_CIM_43, BLK_PAC_CIM_44)),
	DIREI =>  ((BLK_PAC_DIR_00, BLK_PAC_DIR_01, BLK_PAC_DIR_02, BLK_PAC_DIR_03, BLK_PAC_DIR_04),
	           (BLK_PAC_DIR_10, BLK_PAC_DIR_11, BLK_PAC_DIR_12, BLK_PAC_DIR_13, BLK_PAC_DIR_14),
	           (BLK_PAC_DIR_20, BLK_PAC_DIR_21, BLK_PAC_DIR_22, BLK_PAC_DIR_23, BLK_PAC_DIR_24),
	           (BLK_PAC_DIR_30, BLK_PAC_DIR_31, BLK_PAC_DIR_32, BLK_PAC_DIR_33, BLK_PAC_DIR_34),
	           (BLK_PAC_DIR_40, BLK_PAC_DIR_41, BLK_PAC_DIR_42, BLK_PAC_DIR_43, BLK_PAC_DIR_44)),
    BAIXO =>  ((BLK_PAC_BAI_00, BLK_PAC_BAI_01, BLK_PAC_BAI_02, BLK_PAC_BAI_03, BLK_PAC_BAI_04),
	           (BLK_PAC_BAI_10, BLK_PAC_BAI_11, BLK_PAC_BAI_12, BLK_PAC_BAI_13, BLK_PAC_BAI_14),
	           (BLK_PAC_BAI_20, BLK_PAC_BAI_21, BLK_PAC_BAI_22, BLK_PAC_BAI_23, BLK_PAC_BAI_24),
	           (BLK_PAC_BAI_30, BLK_PAC_BAI_31, BLK_PAC_BAI_32, BLK_PAC_BAI_33, BLK_PAC_BAI_34),
	           (BLK_PAC_BAI_40, BLK_PAC_BAI_41, BLK_PAC_BAI_42, BLK_PAC_BAI_43, BLK_PAC_BAI_44)),
	ESQUE =>  ((BLK_PAC_ESQ_00, BLK_PAC_ESQ_01, BLK_PAC_ESQ_02, BLK_PAC_ESQ_03, BLK_PAC_ESQ_04),
	           (BLK_PAC_ESQ_10, BLK_PAC_ESQ_11, BLK_PAC_ESQ_12, BLK_PAC_ESQ_13, BLK_PAC_ESQ_14),
	           (BLK_PAC_ESQ_20, BLK_PAC_ESQ_21, BLK_PAC_ESQ_22, BLK_PAC_ESQ_23, BLK_PAC_ESQ_24),
	           (BLK_PAC_ESQ_30, BLK_PAC_ESQ_31, BLK_PAC_ESQ_32, BLK_PAC_ESQ_33, BLK_PAC_ESQ_34),
	           (BLK_PAC_ESQ_40, BLK_PAC_ESQ_41, BLK_PAC_ESQ_42, BLK_PAC_ESQ_43, BLK_PAC_ESQ_44)),
	OTHERS => (OTHERS => (OTHERS => BLK_NULL))
	);
	
	CONSTANT PAC_FECH_BITMAP: ovl_blk_5x5 := (
		(BLK_PAC_FECH_00, BLK_PAC_FECH_01, BLK_PAC_FECH_02, BLK_PAC_FECH_03, BLK_PAC_FECH_04),
		(BLK_PAC_FECH_10, BLK_PAC_FECH_11, BLK_PAC_FECH_12, BLK_PAC_FECH_13, BLK_PAC_FECH_14),
		(BLK_PAC_FECH_20, BLK_PAC_FECH_21, BLK_PAC_FECH_22, BLK_PAC_FECH_23, BLK_PAC_FECH_24),
		(BLK_PAC_FECH_30, BLK_PAC_FECH_31, BLK_PAC_FECH_32, BLK_PAC_FECH_33, BLK_PAC_FECH_34),
		(BLK_PAC_FECH_40, BLK_PAC_FECH_41, BLK_PAC_FECH_42, BLK_PAC_FECH_43, BLK_PAC_FECH_44));

	CONSTANT PAC_FECV_BITMAP: ovl_blk_5x5 := (
		(BLK_PAC_FECV_00, BLK_PAC_FECV_01, BLK_PAC_FECV_02, BLK_PAC_FECV_03, BLK_PAC_FECV_04),
		(BLK_PAC_FECV_10, BLK_PAC_FECV_11, BLK_PAC_FECV_12, BLK_PAC_FECV_13, BLK_PAC_FECV_14),
		(BLK_PAC_FECV_20, BLK_PAC_FECV_21, BLK_PAC_FECV_22, BLK_PAC_FECV_23, BLK_PAC_FECV_24),
		(BLK_PAC_FECV_30, BLK_PAC_FECV_31, BLK_PAC_FECV_32, BLK_PAC_FECV_33, BLK_PAC_FECV_34),
		(BLK_PAC_FECV_40, BLK_PAC_FECV_41, BLK_PAC_FECV_42, BLK_PAC_FECV_43, BLK_PAC_FECV_44));
		
	CONSTANT FAN_BITMAP: ovl_blk_5x5 := (
		(BLK_FAN_00, BLK_FAN_01, BLK_FAN_02, BLK_FAN_03, BLK_FAN_04),
		(BLK_FAN_10, BLK_FAN_11, BLK_FAN_12, BLK_FAN_13, BLK_FAN_14),
		(BLK_FAN_20, BLK_FAN_21, BLK_FAN_22, BLK_FAN_23, BLK_FAN_24),
		(BLK_FAN_30, BLK_FAN_31, BLK_FAN_32, BLK_FAN_33, BLK_FAN_34),
		(BLK_FAN_40, BLK_FAN_41, BLK_FAN_42, BLK_FAN_43, BLK_FAN_44));
	 
	--A longa lista de sprites 5x5 usados para mascarar um bloco
	--em 5x5 pixels em tr�s componentes de cores (8 cores)
	CONSTANT SPRITES_RED: sprite5_vet := (
	BLK_COIN 	    => ("00000","01110","01110","01110","00000"),
	BLK_SPC_COIN    => ("01110","11111","11111","11111","01110"),	
	BLK_DOOR		=> ("11111","11111","11111","00000","00000"),
	OTHERS			=> (OTHERS => (OTHERS => '0')));
	
	CONSTANT SPRITES_GRN: sprite5_vet := (
	BLK_COIN    	=> ("00000","01110","01110","01110","00000"),
	BLK_SPC_COIN    => ("01110","11111","11111","11111","01110"),
	OTHERS			=> (OTHERS => (OTHERS => '0')));
	
	CONSTANT SPRITES_BLU: sprite5_vet := (
	BLK_COIN 	    => ("00000","01110","01110","01110","00000"),
	BLK_SPC_COIN    => ("01110","11111","11111","11111","01110"),	
	BLK_WALL_V 		=> ("10010","10010","10010","10010","10010"),
	BLK_WALL_H 		=> ("11111","00000","00000","11111","00000"),
	BLK_WALL_Q      => ("00111","01100","11000","10001","10010"),
	BLK_WALL_W      => ("11000","01100","00110","00010","10010"),
	BLK_WALL_E      => ("10001","11001","01100","00111","00000"),
	BLK_WALL_R      => ("00010","00110","01100","11000","00000"),
	OTHERS			=> (OTHERS => (OTHERS => '0')));

	CONSTANT OVL_SPRITES_RED: ovl_sprite5_vet := (
	BLK_PAC_CIM_00 => ("00000","00000","00000","00000","00001"),
	BLK_PAC_CIM_01 => ("00000","00000","00000","11000","11000"),
	BLK_PAC_CIM_02 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_CIM_03 => ("00000","00000","00000","00011","00011"),
	BLK_PAC_CIM_04 => ("00000","00000","00000","00000","10000"),
	BLK_PAC_CIM_10 => ("00011","00111","00111","01111","01111"),
	BLK_PAC_CIM_11 => ("11100","11100","11110","11110","11111"),
	BLK_PAC_CIM_12 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_CIM_13 => ("00111","00111","01111","01111","11111"),
	BLK_PAC_CIM_14 => ("11000","11100","11100","11110","11110"),
	BLK_PAC_CIM_20 => ("01111","01111","01111","01111","01111"),
	BLK_PAC_CIM_21 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_CIM_22 => ("10001","10001","11011","11111","11111"),
	BLK_PAC_CIM_23 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_CIM_24 => ("11110","11110","11110","11110","11110"),
	BLK_PAC_CIM_30 => ("00111","00111","00011","00001","00000"),
	BLK_PAC_CIM_31 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_CIM_32 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_CIM_33 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_CIM_34 => ("11100","11100","11000","10000","00000"),
	BLK_PAC_CIM_40 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_CIM_41 => ("01111","00011","00001","00000","00000"),
	BLK_PAC_CIM_42 => ("11111","11111","11111","00000","00000"),
	BLK_PAC_CIM_43 => ("11110","11000","10000","00000","00000"),
	BLK_PAC_CIM_44 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_DIR_00 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_DIR_01 => ("00000","00000","00011","00111","01111"),
	BLK_PAC_DIR_02 => ("00000","11111","11111","11111","11111"),
	BLK_PAC_DIR_03 => ("00000","11000","11110","11111","11111"),
	BLK_PAC_DIR_04 => ("00000","00000","00000","00000","10000"),
	BLK_PAC_DIR_10 => ("00000","00001","00001","00011","00111"),
	BLK_PAC_DIR_11 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_DIR_12 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_DIR_13 => ("11111","11111","11111","11100","10000"),
	BLK_PAC_DIR_14 => ("11000","11000","00000","00000","00000"),
	BLK_PAC_DIR_20 => ("00111","00111","00111","00111","00111"),
	BLK_PAC_DIR_21 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_DIR_22 => ("11111","11100","11000","11100","11111"),
	BLK_PAC_DIR_23 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_DIR_24 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_DIR_30 => ("00111","00011","00001","00001","00000"),
	BLK_PAC_DIR_31 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_DIR_32 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_DIR_33 => ("10000","11100","11111","11111","11111"),
	BLK_PAC_DIR_34 => ("00000","00000","00000","11000","11000"),
	BLK_PAC_DIR_40 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_DIR_41 => ("01111","00111","00011","00000","00000"),
	BLK_PAC_DIR_42 => ("11111","11111","11111","11111","00000"),
	BLK_PAC_DIR_43 => ("11111","11111","11110","11000","00000"),
	BLK_PAC_DIR_44 => ("10000","00000","00000","00000","00000"),
	BLK_PAC_BAI_00 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_BAI_01 => ("00000","00000","00001","00011","01111"),
	BLK_PAC_BAI_02 => ("00000","00000","11111","11111","11111"),
	BLK_PAC_BAI_03 => ("00000","00000","10000","11000","11110"),
	BLK_PAC_BAI_04 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_BAI_10 => ("00000","00001","00011","00111","00111"),
	BLK_PAC_BAI_11 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_BAI_12 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_BAI_13 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_BAI_14 => ("00000","10000","11000","11100","11100"),
	BLK_PAC_BAI_20 => ("01111","01111","01111","01111","01111"),
	BLK_PAC_BAI_21 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_BAI_22 => ("11111","11111","11011","10001","10001"),
	BLK_PAC_BAI_23 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_BAI_24 => ("11110","11110","11110","11110","11110"),
	BLK_PAC_BAI_30 => ("01111","01111","00111","00111","00011"),
	BLK_PAC_BAI_31 => ("11111","11110","11110","11100","11100"),
	BLK_PAC_BAI_32 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_BAI_33 => ("11111","01111","01111","00111","00111"),
	BLK_PAC_BAI_34 => ("11110","11110","11100","11100","11000"),
	BLK_PAC_BAI_40 => ("00001","00000","00000","00000","00000"),
	BLK_PAC_BAI_41 => ("11000","11000","00000","00000","00000"),
	BLK_PAC_BAI_42 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_BAI_43 => ("00011","00011","00000","00000","00000"),
	BLK_PAC_BAI_44 => ("10000","00000","00000","00000","00000"),
	BLK_PAC_ESQ_00 => ("00000","00000","00000","00000","00001"),
	BLK_PAC_ESQ_01 => ("00000","00011","01111","11111","11111"),
	BLK_PAC_ESQ_02 => ("00000","11111","11111","11111","11111"),
	BLK_PAC_ESQ_03 => ("00000","00000","11000","11100","11110"),
	BLK_PAC_ESQ_04 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_ESQ_10 => ("00011","00011","00000","00000","00000"),
	BLK_PAC_ESQ_11 => ("11111","11111","11111","00111","00001"),
	BLK_PAC_ESQ_12 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_ESQ_13 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_ESQ_14 => ("00000","10000","10000","11000","11100"),
	BLK_PAC_ESQ_20 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_ESQ_21 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_ESQ_22 => ("11111","00111","00011","00111","11111"),
	BLK_PAC_ESQ_23 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_ESQ_24 => ("11100","11100","11100","11100","11100"),
	BLK_PAC_ESQ_30 => ("00000","00000","00000","00011","00011"),
	BLK_PAC_ESQ_31 => ("00001","00111","11111","11111","11111"),
	BLK_PAC_ESQ_32 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_ESQ_33 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_ESQ_34 => ("11100","11000","10000","10000","00000"),
	BLK_PAC_ESQ_40 => ("00001","00000","00000","00000","00000"),
	BLK_PAC_ESQ_41 => ("11111","11111","01111","00011","00000"),
	BLK_PAC_ESQ_42 => ("11111","11111","11111","11111","00000"),
	BLK_PAC_ESQ_43 => ("11110","11100","11000","00000","00000"),
	BLK_PAC_ESQ_44 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECV_00 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECV_01 => ("00000","00000","00001","00011","01111"),
	BLK_PAC_FECV_02 => ("00000","00000","11111","11111","11111"),
	BLK_PAC_FECV_03 => ("00000","00000","10000","11000","11110"),
	BLK_PAC_FECV_04 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECV_10 => ("00000","00001","00011","00111","00111"),
	BLK_PAC_FECV_11 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_12 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_13 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_14 => ("00000","10000","11000","11100","11100"),
	BLK_PAC_FECV_20 => ("01111","01111","01111","01111","01111"),
	BLK_PAC_FECV_21 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_22 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_23 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_24 => ("11110","11110","11110","11110","11110"),
	BLK_PAC_FECV_30 => ("00111","00111","00011","00001","00000"),
	BLK_PAC_FECV_31 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_32 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_33 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECV_34 => ("11100","11100","11000","10000","00000"),
	BLK_PAC_FECV_40 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECV_41 => ("01111","00011","00001","00000","00000"),
	BLK_PAC_FECV_42 => ("11111","11111","11111","00000","00000"),
	BLK_PAC_FECV_43 => ("11110","11000","10000","00000","00000"),
	BLK_PAC_FECV_44 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECH_00 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECH_01 => ("00000","00000","00011","00111","01111"),
	BLK_PAC_FECH_02 => ("00000","11111","11111","11111","11111"),
	BLK_PAC_FECH_03 => ("00000","00000","11000","11100","11110"),
	BLK_PAC_FECH_04 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECH_10 => ("00000","00001","00001","00011","00111"),
	BLK_PAC_FECH_11 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_12 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_13 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_14 => ("00000","10000","10000","11000","11100"),
	BLK_PAC_FECH_20 => ("00111","00111","00111","00111","00111"),
	BLK_PAC_FECH_21 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_22 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_23 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_24 => ("11100","11100","11100","11100","11100"),
	BLK_PAC_FECH_30 => ("00111","00011","00001","00001","00000"),
	BLK_PAC_FECH_31 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_32 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_33 => ("11111","11111","11111","11111","11111"),
	BLK_PAC_FECH_34 => ("11100","11000","10000","10000","00000"),
	BLK_PAC_FECH_40 => ("00000","00000","00000","00000","00000"),
	BLK_PAC_FECH_41 => ("01111","00111","00011","00000","00000"),
	BLK_PAC_FECH_42 => ("11111","11111","11111","11111","00000"),
	BLK_PAC_FECH_43 => ("11110","11100","11000","00000","00000"),
	BLK_PAC_FECH_44 => ("00000","00000","00000","00000","00000"),
	OTHERS			=> (OTHERS => (OTHERS => '0')));
	
	CONSTANT OVL_SPRITES_GRN: ovl_sprite5_vet := OVL_SPRITES_RED;
	
	CONSTANT OVL_SPRITES_BLU: ovl_sprite5_vet := (
	BLK_FAN_00 => ("00000","00000","00000","00000","00001"),
	BLK_FAN_01 => ("00000","00111","11111","11111","11111"),
	BLK_FAN_02 => ("00000","11111","11111","11111","11111"),
	BLK_FAN_03 => ("00000","11100","11110","11110","11111"),
	BLK_FAN_04 => ("00000","00000","00000","00000","00000"),
	BLK_FAN_10 => ("00011","00011","00111","00111","00111"),
	BLK_FAN_11 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_12 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_13 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_14 => ("10000","10000","11000","11000","11000"),
	BLK_FAN_20 => ("00111","01111","01111","01111","01111"),
	BLK_FAN_21 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_22 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_23 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_24 => ("11000","11100","11100","11100","11100"),
	BLK_FAN_30 => ("01111","01111","01111","01111","01111"),
	BLK_FAN_31 => ("11111","11111","11111","11111","10011"),
	BLK_FAN_32 => ("11111","11111","11111","11111","11111"),
	BLK_FAN_33 => ("11111","11111","11111","11111","10011"),
	BLK_FAN_34 => ("11100","11100","11100","11100","11100"),
	BLK_FAN_40 => ("01111","01111","00110","00000","00000"),
	BLK_FAN_41 => ("00001","00000","00000","00000","00000"),
	BLK_FAN_42 => ("11111","11110","01100","00000","00000"),
	BLK_FAN_43 => ("00001","00001","00000","00000","00000"),
	BLK_FAN_44 => ("11100","11100","11000","00000","00000"),
	OTHERS			=> (OTHERS => (OTHERS => '0')));
	
	TYPE tab_array_t is array(0 to SCR_WDT*SCR_HGT-1) of t_tab_sym;
	TYPE tab_mapa_t is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	--Mapa de inicializa��o da RAM inferior, a legenda est� acima 
	CONSTANT MAPA_INICIAL: tab_array_t :=
	"                                                                                                                                "&
	"                                                                                                                                "&
	" Q--------------------------------------W   Q--------------------------------------W                                            "&
	" |                                      |   |                                      |                                            "&
	" |                                      |   |                                      |                                            "& 
	" |  C..C..C..C..C..C..C..C..C..C..C..C  |   |  C..C..C..C..C..C..C..C..C..C..C..C  |                                            "&
	" |  .              .                 .  |   |  .                 .              .  |                                            "& 
	" |  .              .                 .  |   |  .                 .              .  |                                            "&
	" |  C  Q--------W  C  Q-----------W  C  |   |  C  Q-----------W  C  Q--------W  C  |                                            "& 
	" |  .  |        |  .  |           |  .  |   |  .  |           |  .  |        |  .  |                                            "& 
	" |  .  |        |  .  |           |  .  |   |  .  |           |  .  |        |  .  |                                            "& 
	" |  P  |        |  C  |           |  C  |   |  C  |           |  C  |        |  P  |                                            "& 
	" |  .  |        |  .  |           |  .  |   |  .  |           |  .  |        |  .  |                                            "& 
	" |  .  |        |  .  |           |  .  |   |  .  |           |  .  |        |  .  |                                            "& 
	" |  C  E--------R  C  E-----------R  C  E---R  C  E-----------R  C  E--------R  C  |                                            "& 
	" |  .              .                 .         .                 .              .  |                                            "& 
	" |  .              .                 .         .                 .              .  |                                            "& 
	" |  C..C..C..C..C..C..C..C..C..C..C..C..C...C..C..C..C..C..C..C..C..C..C..C..C..C  |                                            "& 
	" |  .              .        .                           .        .              .  |                                            "& 
	" |  .              .        .                           .        .              .  |                                            "& 
	" |  C  Q--------W  C  Q--W  C  Q---------------------W  C  Q--W  C  Q--------W  C  |                                            "& 
	" |  .  |        |  .  |  |  .  |                     |  .  |  |  .  |        |  .  |                                            "& 
	" |  .  |        |  .  |  |  .  |                     |  .  |  |  .  |        |  .  |                                            "& 
	" |  C  E--------R  C  |  |  C  E--------W   Q--------R  C  |  |  C  E--------R  C  |                                            "& 
	" |  .              .  |  |  .           |   |           .  |  |  .              .  |                                            "& 
	" |  .              .  |  |  .           |   |           .  |  |  .              .  |                                            "& 
	" |  C..C..C..C..C..C  |  |  C..C..C..C  |   |  C..C..C..C  |  |  C..C..C..C..C..C  |                                            "& 
	" |                 .  |  |           .  |   |  .           |  |  .                 |                                            "& 
	" |                 .  |  |           .  |   |  .           |  |  .                 |                                            "& 
	" E--------------W  C  |  E--------W  .  |   |  .  Q--------R  |  C  Q--------------R                                            "& 
	"                |  .  |           |  .  |   |  .  |           |  .  |                                                           "& 
	"                |  .  |           |  .  |   |  .  |           |  .  |                                                           "& 
	"                |  C  |  Q--------R  .  E---R  .  E--------W  |  C  |                                                           "& 
	"                |  .  |  |           .         .           |  |  .  |                                                           "& 
	"                |  .  |  |           .         .           |  |  .  |                                                           "& 
	"                |  C  |  |  .............................  |  |  C  |                                                           "& 
	"                |  .  |  |  .                           .  |  |  .  |                                                           "& 
	"                |  .  |  |  .                           .  |  |  .  |                                                           "& 
	"                |  C  |  |  .  Q-------W     Q-------W  .  |  |  C  |                                                           "& 
	"                |  .  |  |  .  |       |DDDDD|       |  .  |  |  .  |                                                           "& 
	"                |  .  |  |  .  | Q-----R     E-----W |  .  |  |  .  |                                                           "& 
	" ---------------R  C  E--R  .  | |                 | |  .  E--R  C  E---------------                                            "& 
	"                   .        .  | |                 | |  .        .                                                              "& 
	"                   .        .  | |                 | |  .        .                                                              "& 
	" ..................C.........  | |                 | |  .........C..................                                            "& 
	"                   .        .  | |                 | |  .        .                                                              "& 
	"                   .        .  | |                 | |  .        .                                                              "& 
	" ---------------W  C  Q--W  .  | |                 | |  .  Q--W  C  Q---------------                                            "& 
	"                |  .  |  |  .  | E-----------------R |  .  |  |  .  |                                                           "& 
	"                |  .  |  |  .  |                     |  .  |  |  .  |                                                           "& 
	"                |  C  |  |  .  E---------------------R  .  |  |  C  |                                                           "& 
	"                |  .  |  |  .                           .  |  |  .  |                                                           "& 
	"                |  .  |  |  .                           .  |  |  .  |                                                           "& 
	"                |  C  |  |  .............................  |  |  C  |                                                           "& 
	"                |  .  |  |  .                           .  |  |  .  |                                                           "& 
	"                |  .  |  |  .                           .  |  |  .  |                                                           "& 
	"                |  C  |  |  .  Q---------------------W  .  |  |  C  |                                                           "& 
	"                |  .  |  |  .  |                     |  .  |  |  .  |                                                           "& 
	"                |  .  |  |  .  |                     |  .  |  |  .  |                                                           "& 
	" Q--------------R  C  E--R  .  E--------W   Q--------R  .  E--R  C  E--------------W                                            "& 
	" |                 .        .           |   |           .        .                 |                                            "& 
	" |                 .        .           |   |           .        .                 |                                            "& 
	" |  C..C..C..C..C..C..C..C..C..C..C..C  |   |  C..C..C..C..C..C..C..C..C..C..C..C  |                                            "& 
	" |  .              .                 .  |   |  .                 .              .  |                                            "& 
	" |  .              .                 .  |   |  .                 .              .  |                                            "& 
	" |  C  Q--------W  C  Q-----------W  C  |   |  C  Q-----------W  C  Q--------W  C  |                                            "& 
	" |  .  |        |  .  |           |  .  |   |  .  |           |  .  |        |  .  |                                            "& 
	" |  .  |        |  .  |           |  .  |   |  .  |           |  .  |        |  .  |                                            "& 
	" |  P  E-----W  |  C  E-----------R  C  E---R  C  E-----------R  C  |  Q-----R  P  |                                            "& 
	" |  .        |  |  .                 .         .                 .  |  |        .  |                                            "& 
	" |  .        |  |  .                 .         .                 .  |  |        .  |                                            "& 
	" |  C..C..C  |  |  C..C..C..C..C..C..C.........C..C..C..C..C..C..C  |  |  C..C..C  |                                            "& 
	" |        .  |  |  .        .                           .        .  |  |  .        |                                            "& 
	" |        .  |  |  .        .                           .        .  |  |  .        |                                            "& 
	" E-----W  C  |  |  C  Q--W  C  Q---------------------W  C  Q--W  C  |  |  C  Q-----R                                            "& 
	"       |  .  |  |  .  |  |  .  |                     |  .  |  |  .  |  |  .  |                                                  "& 
	"       |  .  |  |  .  |  |  .  |                     |  .  |  |  .  |  |  .  |                                                  "& 
	" Q-----R  C  E--R  C  |  |  C  E--------W   Q--------R  C  |  |  C  E--R  C  E-----W                                            "& 
	" |        .        .  |  |  .           |   |           .  |  |  .        .        |                                            "& 
	" |        .        .  |  |  .           |   |           .  |  |  .        .        |                                            "& 
	" |  C..C..C..C..C..C  |  |  C..C..C..C  |   |  C..C..C..C  |  |  C..C..C..C..C..C  |                                            "& 
	" |  .                 |  |           .  |   |  .           |  |                 .  |                                            "& 
	" |  .                 |  |           .  |   |  .           |  |                 .  |                                            "& 
	" |  C  Q--------------R  E--------W  C  |   |  C  Q--------R  E--------------W  C  |                                            "& 
	" |  .  |                          |  .  |   |  .  |                          |  .  |                                            "& 
	" |  .  |                          |  .  |   |  .  |                          |  .  |                                            "& 
	" |  C  E--------------------------R  C  E---R  C  E--------------------------R  C  |                                            "& 
	" |  .                                .         .                                .  |                                            "& 
	" |  .                                .         .                                .  |                                            "& 
	" |  C..C..C..C..C..C..C..C..C..C..C..C..C...C..C..C..C..C..C..C..C..C..C..C..C..C  |                                            "& 
	" |                                                                                 |                                            "& 
	" |                                                                                 |                                            "& 
	" E---------------------------------------------------------------------------------R                                            "& 
	"                                                                                                                                "& 
	"                                                                                                                                "& 
	"                                                                                                                                ";
	
	--Neste mapa, est�o armazenados apenas a pr�xima dire��o do percurso de um fantasma
    --quando este � comido. A legenda � Q: CIMA, W: BAIXO, E: ESQUERDA, R: DIREITA 
	CONSTANT FAN_PERCURSO: tab_mapa_t :=(
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                ", 
	"    RRRRRRRRRRRRRRRWEEEEEEEERRRRRRRRRW         WEEEEEEEEERRRRRRRRREEEEEEEEEEEEEEE                                               ",
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ",
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    W              W                 W         W                 W              W                                               ", 
	"    RRRRRRRRRRRRRRRRRRRRRRRRWEEEEEEEEEEEEERRRRRRRRRRRRRRWEEEEEEEEEEEEEEEEEEEEEEEE                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    Q              Q        W                           W        Q              Q                                               ",
	"    Q              Q        W                           W        Q              Q                                               ", 
	"    QRRRRRRRRRRRRRRQ        RRRRRRRRRW         WEEEEEEEEE        QEEEEEEEEEEEEEEQ                                               ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W                 W         W                 W                                                              ", 
	"                   W        WEEEEEEEEEEEEEWEEEEEEEEEEEEEE        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W             W             Q        W                                                              ", 
	"                   W        W       WEE   W   WEE       Q        W                                                              ", 
	" DDDDDDDDDDDDDDDDDDDDDDDDDDDW       W QEEEEEEEE Q       QEEEEEEEEEEEEEEEEEEEEEEEEEEE                                            ", 
	"                   Q        W       RRRRRRRRRRRRQ       Q        Q                                                              ", 
	"                   Q        W                           Q        Q                                                              ", 
	"                   Q        W                           Q        Q                                                              ", 
	"                   Q        W                           Q        Q                                                              ", 
	"                   Q        W                           Q        Q                                                              ",
	"                   Q        W                           Q        Q                                                              ", 
	"                   Q        W                           Q        Q                                                              ", 
	"                   Q        W                           Q        Q                                                              ", 
	"                   Q        RRRRRRRRRRRRRRRRRRRRRRRRRRRRQ        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"                   Q        Q                           Q        Q                                                              ", 
	"    RRRRRRRRRRRRRRRRRRRRRRRRQEEEEEEEEE         RRRRRRRRRQEEEEEEEEEEEEEEEEEEEEEEEE                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    Q              Q                 Q         Q                 Q              Q                                               ", 
	"    QEEEEEE        QEEEEEEEERRRRRRRRRQEEEEERRRRQEEEEEEEEERRRRRRRRQ        RRRRRRQ                                               ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"          Q        Q        Q                           Q        Q        Q                                                     ", 
	"    RRRRRRRRRRRRRRRQ        QEEEEEEEEE         RRRRRRRRRQ        QEEEEEEEEEEEEEEE                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    Q                                Q         Q                                Q                                               ", 
	"    QEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRRQEEEEERRRRQEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRQ                                               ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ");

END pac_defs;
