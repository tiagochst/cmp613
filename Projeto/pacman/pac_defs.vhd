LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
	
PACKAGE pac_defs IS
	-----------------------------------------------------------------------------
	-- Definições de dados, constantes e tipos para o jogo
	-----------------------------------------------------------------------------
	
	-- Constantes Básicas
	CONSTANT SCR_HGT : INTEGER := 96; --Resolução de blocos usada (hgt linhas por wdt colunas)
	CONSTANT SCR_WDT : INTEGER := 128;
	CONSTANT TAB_LEN: INTEGER := 91; --Maior dimensao do tabuleiro (em blocos)
	CONSTANT FAN_NO: INTEGER := 2; --Número de fantasmas no jogo
	CONSTANT FRUTA_NO: INTEGER := 2;
	
	-- Tipos básicos
	SUBTYPE t_color_3b is std_logic_vector(2 downto 0);
	SUBTYPE t_pos is INTEGER range 0 to TAB_LEN-1;
	SUBTYPE t_offset IS INTEGER range -TAB_LEN to TAB_LEN;
	SUBTYPE t_fan_time is INTEGER range 0 to 1000;
	TYPE t_direcao is (CIMA,DIREI,BAIXO,ESQUE,NADA);
	
	--A legenda pros elementos no cenário é dada por t_tab_sym
	--' ': vazio, '.': caminho, 6 tipos de parede de acordo com a orientação,
	--C: moeda, P: moeda especial, D: porta
	TYPE t_tab_sym is (' ', '.', '|', '-', 'Q', 'W', 'E', 'R', 'C', 'P', 'D');
	
	--Simbologia de direção usada para os fantasmas
	--C: cima, E: esquerda, B: baixo, D: direita
	TYPE t_dir_sym is (' ', 'C', 'E', 'B', 'D');
	
	SUBTYPE t_blk_id is STD_LOGIC_VECTOR(3 downto 0);
	SUBTYPE t_ovl_blk_id is STD_LOGIC_VECTOR(8 downto 0);
	
	-- Definição dos blocos (cenário e overlay)
	TYPE t_blk_sym is (BLK_NULL, BLK_PATH, BLK_WALL_V, BLK_WALL_H, BLK_WALL_Q, BLK_WALL_W, BLK_WALL_E,
					 BLK_WALL_R, BLK_COIN, BLK_SPC_COIN, BLK_DOOR);
	
	TYPE t_ovl_blk_sym is (BLK_NULL,
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
					 BLK_FAN_GRN_00, BLK_FAN_GRN_01, BLK_FAN_GRN_02, BLK_FAN_GRN_03, BLK_FAN_GRN_04,
					 BLK_FAN_GRN_10                                    , BLK_FAN_GRN_14, --área reservada para os olhos
					 BLK_FAN_GRN_20                                    , BLK_FAN_GRN_24,
					 BLK_FAN_GRN_30, BLK_FAN_GRN_31, BLK_FAN_GRN_32, BLK_FAN_GRN_33, BLK_FAN_GRN_34,
					 BLK_FAN_GRN_40, BLK_FAN_GRN_41, BLK_FAN_GRN_42, BLK_FAN_GRN_43, BLK_FAN_GRN_44,
					 BLK_EYE_GRN_CIM_00, BLK_EYE_GRN_CIM_01, BLK_EYE_GRN_CIM_02, BLK_EYE_GRN_CIM_10, BLK_EYE_GRN_CIM_11, BLK_EYE_GRN_CIM_12,
					 BLK_EYE_GRN_DIR_00, BLK_EYE_GRN_DIR_01, BLK_EYE_GRN_DIR_02, BLK_EYE_GRN_DIR_10, BLK_EYE_GRN_DIR_11, BLK_EYE_GRN_DIR_12,
					 BLK_EYE_GRN_BAI_00, BLK_EYE_GRN_BAI_01, BLK_EYE_GRN_BAI_02, BLK_EYE_GRN_BAI_10, BLK_EYE_GRN_BAI_11, BLK_EYE_GRN_BAI_12,
					 BLK_EYE_GRN_ESQ_00, BLK_EYE_GRN_ESQ_01, BLK_EYE_GRN_ESQ_02, BLK_EYE_GRN_ESQ_10, BLK_EYE_GRN_ESQ_11, BLK_EYE_GRN_ESQ_12,
					 BLK_FAN_RED_00, BLK_FAN_RED_01, BLK_FAN_RED_02, BLK_FAN_RED_03, BLK_FAN_RED_04,
					 BLK_FAN_RED_10                                    , BLK_FAN_RED_14, --área reservada para os olhos
					 BLK_FAN_RED_20                                    , BLK_FAN_RED_24,
					 BLK_FAN_RED_30, BLK_FAN_RED_31, BLK_FAN_RED_32, BLK_FAN_RED_33, BLK_FAN_RED_34,
					 BLK_FAN_RED_40, BLK_FAN_RED_41, BLK_FAN_RED_42, BLK_FAN_RED_43, BLK_FAN_RED_44,
					 BLK_EYE_RED_CIM_00, BLK_EYE_RED_CIM_01, BLK_EYE_RED_CIM_02, BLK_EYE_RED_CIM_10, BLK_EYE_RED_CIM_11, BLK_EYE_RED_CIM_12,
					 BLK_EYE_RED_DIR_00, BLK_EYE_RED_DIR_01, BLK_EYE_RED_DIR_02, BLK_EYE_RED_DIR_10, BLK_EYE_RED_DIR_11, BLK_EYE_RED_DIR_12,
					 BLK_EYE_RED_BAI_00, BLK_EYE_RED_BAI_01, BLK_EYE_RED_BAI_02, BLK_EYE_RED_BAI_10, BLK_EYE_RED_BAI_11, BLK_EYE_RED_BAI_12,
					 BLK_EYE_RED_ESQ_00, BLK_EYE_RED_ESQ_01, BLK_EYE_RED_ESQ_02, BLK_EYE_RED_ESQ_10, BLK_EYE_RED_ESQ_11, BLK_EYE_RED_ESQ_12,
					 BLK_EYE_BLK_CIM_00, BLK_EYE_BLK_CIM_01, BLK_EYE_BLK_CIM_02, BLK_EYE_BLK_CIM_10, BLK_EYE_BLK_CIM_11, BLK_EYE_BLK_CIM_12,
					 BLK_EYE_BLK_DIR_00, BLK_EYE_BLK_DIR_01, BLK_EYE_BLK_DIR_02, BLK_EYE_BLK_DIR_10, BLK_EYE_BLK_DIR_11, BLK_EYE_BLK_DIR_12,
					 BLK_EYE_BLK_BAI_00, BLK_EYE_BLK_BAI_01, BLK_EYE_BLK_BAI_02, BLK_EYE_BLK_BAI_10, BLK_EYE_BLK_BAI_11, BLK_EYE_BLK_BAI_12,
					 BLK_EYE_BLK_ESQ_00, BLK_EYE_BLK_ESQ_01, BLK_EYE_BLK_ESQ_02, BLK_EYE_BLK_ESQ_10, BLK_EYE_BLK_ESQ_11, BLK_EYE_BLK_ESQ_12,
					 BLK_FAN_VULN_00, BLK_FAN_VULN_01, BLK_FAN_VULN_02, BLK_FAN_VULN_03, BLK_FAN_VULN_04,
					 BLK_FAN_VULN_10, BLK_FAN_VULN_11, BLK_FAN_VULN_12, BLK_FAN_VULN_13, BLK_FAN_VULN_14,
 					 BLK_FAN_VULN_20, BLK_FAN_VULN_21, BLK_FAN_VULN_22, BLK_FAN_VULN_23, BLK_FAN_VULN_24,
					 BLK_FAN_VULN_30, BLK_FAN_VULN_31, BLK_FAN_VULN_32, BLK_FAN_VULN_33, BLK_FAN_VULN_34,
					 BLK_FAN_VULN_40, BLK_FAN_VULN_41, BLK_FAN_VULN_42, BLK_FAN_VULN_43, BLK_FAN_VULN_44,
					 BLK_MACA_00, BLK_MACA_01, BLK_MACA_02, BLK_MACA_03, BLK_MACA_04,
					 BLK_MACA_10, BLK_MACA_11, BLK_MACA_12, BLK_MACA_13, BLK_MACA_14,
 					 BLK_MACA_20, BLK_MACA_21, BLK_MACA_22, BLK_MACA_23, BLK_MACA_24,
					 BLK_MACA_30, BLK_MACA_31, BLK_MACA_32, BLK_MACA_33, BLK_MACA_34,
					 BLK_MACA_40, BLK_MACA_41, BLK_MACA_42, BLK_MACA_43, BLK_MACA_44,
					 BLK_CEREJA_00, BLK_CEREJA_01, BLK_CEREJA_02, BLK_CEREJA_03, BLK_CEREJA_04,
					 BLK_CEREJA_10, BLK_CEREJA_11, BLK_CEREJA_12, BLK_CEREJA_13, BLK_CEREJA_14,
 					 BLK_CEREJA_20, BLK_CEREJA_21, BLK_CEREJA_22, BLK_CEREJA_23, BLK_CEREJA_24,
					 BLK_CEREJA_30, BLK_CEREJA_31, BLK_CEREJA_32, BLK_CEREJA_33, BLK_CEREJA_34,
					 BLK_CEREJA_40, BLK_CEREJA_41, BLK_CEREJA_42, BLK_CEREJA_43, BLK_CEREJA_44
					);
	
	-- "Funções" para blocos
	TYPE t_blk_bool is array(t_blk_sym) of boolean;
	CONSTANT WALKABLE: t_blk_bool := --define quais blocos são percorríveis
		(BLK_PATH => true, BLK_COIN => true, BLK_SPC_COIN => true, OTHERS => false);
	TYPE c_tab_blk is array(t_tab_sym) of t_blk_sym;
	CONSTANT CONV_TAB_BLK: c_tab_blk := 
		(' ' => BLK_NULL, '.' => BLK_PATH, '|' => BLK_WALL_V, '-' => BLK_WALL_H, 'Q' => BLK_WALL_Q, 'W' => BLK_WALL_W,
		 'E' => BLK_WALL_E, 'R' => BLK_WALL_R, 'C' => BLK_COIN, 'P' => BLK_SPC_COIN, 'D' => BLK_DOOR);

	-- Tabelas de blocos
	TYPE t_tab is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	TYPE t_blk_sym_3x3 is array(-1 to 1, -1 to 1) of t_blk_sym;
	
	-- Tipos indexados de armazenamento gráfico em blocos e pixels
	TYPE t_sprite5 is array(0 to 4, 0 to 4) of STD_LOGIC;
	TYPE t_ovl_blk_5x5 is array(0 to 4, 0 to 4) of t_ovl_blk_sym;
	TYPE t_ovl_blk_dir_vet is array(t_direcao) of t_ovl_blk_5x5;
	TYPE t_fans_ovl_blk_dir_vet is array(0 to FAN_NO-1) of t_ovl_blk_dir_vet;
	TYPE t_frut_ovl_blk_vet is array(0 to FRUTA_NO) of t_ovl_blk_5x5;
	TYPE t_sprite5_vet is array(t_blk_sym) of t_sprite5;
	TYPE t_ovl_sprite5_vet is array(t_ovl_blk_sym) of t_sprite5;
	
	TYPE t_fan_state is (ST_VIVO, ST_VULN, ST_VULN_BLINK, ST_DEAD, ST_PRE_DEAD, ST_FIND_EXIT, ST_FUGA);
	
	--Tipos em array para os fantasmas
	TYPE t_fans_pos is array(0 to FAN_NO-1) of t_pos;
	TYPE t_fans_dirs is array(0 to FAN_NO-1) of t_direcao;
	TYPE t_fans_blk_sym is array(0 to FAN_NO-1) of t_blk_sym;
	TYPE t_fans_blk_sym_3x3 is array(0 to FAN_NO-1) of t_blk_sym_3x3;
	TYPE t_fans_states is array(0 to FAN_NO-1) of t_fan_state;
	TYPE t_fans_times is array(0 to FAN_NO-1) of t_fan_time;
	SUBTYPE t_fans_bits is STD_LOGIC_VECTOR(0 to FAN_NO-1);
	
	TYPE t_vidas_pos is array(0 to 2) of t_pos;
	SUBTYPE t_fruta_id is INTEGER range 0 to FRUTA_NO; -- 0 significa sem fruta
	
	-- Constantes do jogo
	CONSTANT CELL_IN_X : INTEGER := 42; --posição da célula principal dentro da cela
	CONSTANT CELL_IN_Y : INTEGER := 44;
	CONSTANT CELL_OUT_Y : INTEGER := 35; --posição Y da célula principal fora da cela
	CONSTANT TELE_DIR_POS : INTEGER := 82;
	CONSTANT TELE_ESQ_POS : INTEGER := 2;
	CONSTANT VIDA_ICONS_X: t_vidas_pos := (90, 90, 90);
	CONSTANT VIDA_ICONS_Y: t_vidas_pos := (89, 83, 77);
	CONSTANT FRUTA_X: t_pos := 42;
	CONSTANT FRUTA_Y: t_pos := 53;
	
	SUBTYPE t_velocs is INTEGER range 0 to 20;
	TYPE t_vet_velocs is array(0 to 2) of t_velocs;
	--divisores de atualização para: 0=pacman, 1=fantasma, 2=fantasma morto
	CONSTANT VEL_DIV: t_vet_velocs := (6, 5, 4); 
	   
	--Fatores de divisão do clock de 27MHz, usados para atualização do
	--estado do jogo ("velocidade de execução") e do display
	CONSTANT DIV_FACT: INTEGER := 202500;
	CONSTANT DISP_DIV_FACT: INTEGER := 27000000/4;

	subtype sentido is INTEGER range -1 to 1;
	TYPE t_direc is array(0 to 1) of sentido;
	TYPE t_direc_vet is array(t_direcao) of t_direc;
	
	CONSTANT DIRS: t_direc_vet := (CIMA  => (-1, 0), DIREI => ( 0, 1), 
	                               BAIXO => ( 1, 0), ESQUE => ( 0,-1),
	                               NADA  => ( 0, 0));
	
	TYPE t_tab_array is array(0 to SCR_WDT*SCR_HGT-1) of t_tab_sym;
	TYPE t_dir_mapa is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_dir_sym;
	
	--Mapa de inicialização da RAM inferior, a legenda está mais acima
	CONSTANT MAPA_INICIAL: t_tab_array :=
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
	
	-- Neste mapa, estão armazenados apenas a próxima direção do percurso de um fantasma
    -- quando este está morto. A legenda é definida para o tipo t_dir_sym
	CONSTANT FAN_PERCURSO: t_dir_mapa :=(
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                ", 
	"    DDDDDDDDDDDDDDDBEEEEEEEEDDDDDDDDDB         BEEEEEEEEEDDDDDDDDBEEEEEEEEEEEEEEE                                               ",
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ",
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    B              B                 B         B                 B              B                                               ", 
	"    DDDDDDDDDDDDDDDDDDDDDDDDBEEEEEEEEEEEEEDDDDDDDDDDDDDDBEEEEEEEEEEEEEEEEEEEEEEEE                                               ", 
	"    C              C        B                           B        C              C                                               ", 
	"    C              C        B                           B        C              C                                               ", 
	"    C              C        B                           B        C              C                                               ", 
	"    C              C        B                           B        C              C                                               ", 
	"    C              C        B                           B        C              C                                               ", 
	"    C              C        B                           B        C              C                                               ", 
	"    C              C        B                           B        C              C                                               ",
	"    C              C        B                           B        C              C                                               ", 
	"    CDDDDDDDDDDDDDDC        DDDDDDDDDB         BEEEEEEEEE        CEEEEEEEEEEEEEEC                                               ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B                 B         B                 B                                                              ", 
	"                   B        BEEEEEEEEEEEEEBEEEEEEEEEEEEEE        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B             B             C        B                                                              ", 
	"                   B        B       BEE   B   BEE       C        B                                                              ", 
	" DDDDDDDDDDDDDDDDDDDDDDDDDDDB       B CEEEEEEEE C       CEEEEEEEEEEEEEEEEEEEEEEEEEEE                                            ", 
	"                   C        B       DDDDDDDDDDDDC       C        C                                                              ", 
	"                   C        B                           C        C                                                              ", 
	"                   C        B                           C        C                                                              ", 
	"                   C        B                           C        C                                                              ", 
	"                   C        B                           C        C                                                              ",
	"                   C        B                           C        C                                                              ", 
	"                   C        B                           C        C                                                              ", 
	"                   C        B                           C        C                                                              ", 
	"                   C        DDDDDDDDDDDDDDDDDDDDDDDDDDDDC        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"                   C        C                           C        C                                                              ", 
	"    DDDDDDDDDDDDDDDDDDDDDDDDCEEEEEEEEE         DDDDDDDDDCEEEEEEEEEEEEEEEEEEEEEEEE                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    C              C                 C         C                 C              C                                               ", 
	"    CEEEEEE        CEEEEEEEEDDDDDDDDDCEEEEEDDDDCEEEEEEEEEDDDDDDDDC        DDDDDDC                                               ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"          C        C        C                           C        C        C                                                     ", 
	"    DDDDDDDDDDDDDDDC        CEEEEEEEEE         DDDDDDDDDC        CEEEEEEEEEEEEEEE                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    C                                C         C                                C                                               ", 
	"    CEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDCEEEEEDDDDCEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDC                                               ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ", 
	"                                                                                                                                ");

END pac_defs;
