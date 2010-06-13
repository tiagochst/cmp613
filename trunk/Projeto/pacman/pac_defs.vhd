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
					 BLK_FAN_VULN_40, BLK_FAN_VULN_41, BLK_FAN_VULN_42, BLK_FAN_VULN_43, BLK_FAN_VULN_44
					);
					 
	TYPE c_tab_blk is array(t_tab_sym) of t_blk_sym;
	CONSTANT CONV_TAB_BLK: c_tab_blk := 
		(' ' => BLK_NULL, '.' => BLK_PATH, '|' => BLK_WALL_V, '-' => BLK_WALL_H, 'Q' => BLK_WALL_Q, 'W' => BLK_WALL_W,
		 'E' => BLK_WALL_E, 'R' => BLK_WALL_R, 'C' => BLK_COIN, 'P' => BLK_SPC_COIN, 'D' => BLK_DOOR);

	TYPE t_tab is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	TYPE t_blk_sym_3x3 is array(-1 to 1, -1 to 1) of t_blk_sym;
	
	TYPE t_sprite5 is array(0 to 4, 0 to 4) of STD_LOGIC;
	TYPE t_ovl_blk_5x5 is array(0 to 4, 0 to 4) of t_ovl_blk_sym;
	TYPE t_ovl_blk_dir_vet is array(t_direcao) of t_ovl_blk_5x5;
	TYPE t_sprite5_vet is array(t_blk_sym) of t_sprite5;
	TYPE t_ovl_sprite5_vet is array(t_ovl_blk_sym) of t_sprite5;
	
	CONSTANT FAN_NO: INTEGER := 2; --Número de fantasmas no jogo (não é genérico no toplevel FIXME)
	--Tipos em array para os fantasmas
	SUBTYPE t_pos is INTEGER range 0 to TAB_LEN-1;
	SUBTYPE t_fan_time is INTEGER range 0 to 1000;
	TYPE t_fan_state is (ST_VIVO, ST_VULN, ST_DEAD, ST_FIND_EXIT, ST_FUGA);
	
	TYPE t_fans_pos is array(0 to FAN_NO-1) of t_pos;
	TYPE t_fans_dirs is array(0 to FAN_NO-1) of t_direcao;
	TYPE t_fans_blk_sym is array(0 to FAN_NO-1) of t_blk_sym;
	TYPE t_fans_blk_sym_3x3 is array(0 to FAN_NO-1) of t_blk_sym_3x3;
	TYPE t_fans_states is array(0 to FAN_NO-1) of t_fan_state;
	TYPE t_fans_times is array(0 to FAN_NO-1) of t_fan_time;
	SUBTYPE t_fans_bits is STD_LOGIC_VECTOR(0 to FAN_NO-1);
	   
	--Fator de divisão do clock de 27MHz, usada para atualização do
	--estado do jogo ("velocidade de execução")
	CONSTANT DIV_FACT: INTEGER := 337500;

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
	CONSTANT FAN_TIME_VULN : INTEGER := 500;
	CONSTANT FAN_TIME_DEAD : INTEGER := 1000;
	CONSTANT CELL_IN_X : INTEGER := 42;
	CONSTANT CELL_IN_Y : INTEGER := 44;
	CONSTANT CELL_OUT_Y : INTEGER := 35;
	CONSTANT TELE_DIR_POS : INTEGER := 82;
	CONSTANT TELE_ESQ_POS : INTEGER := 2;
	
	TYPE t_tab_array is array(0 to SCR_WDT*SCR_HGT-1) of t_tab_sym;
	TYPE t_tab_mapa is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_tab_sym;
	--Mapa de inicialização da RAM inferior, a legenda está acima 
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
	
	--Neste mapa, estão armazenados apenas a próxima direção do percurso de um fantasma
    --quando este é comido. A legenda é Q: CIMA, W: BAIXO, E: ESQUERDA, R: DIREITA 
	CONSTANT FAN_PERCURSO: t_tab_mapa :=(
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
