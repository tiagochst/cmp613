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
  CONSTANT TAB_LEN: INTEGER := 93; -- Maior coordenada do tabuleiro
  CONSTANT FAN_NO: INTEGER := 2; -- Número de fantasmas no jogo. O código foi projetado para 
                                 -- esse número possa ser facilmente alterado. Provavelmente,
                                 -- será necessário apenas definir um mapa de sprites em 
                                 -- "des_overlay" para os novos fantasmas e criar novas teclas
                                 -- de controle no "player_dir.vhd"
  CONSTANT FRUTA_NO: INTEGER := 2; -- Tipos de frutas no jogo
  
  -- Tipos básicos
  SUBTYPE t_color_3b is std_logic_vector(2 downto 0);
  SUBTYPE t_pos is INTEGER range 0 to TAB_LEN;
  SUBTYPE t_offset IS INTEGER range -TAB_LEN to TAB_LEN;
  SUBTYPE t_fan_time is INTEGER range 0 to 1000;
  TYPE t_direcao is (CIMA,DIREI,BAIXO,ESQUE,NADA);
  
  --A legenda pros elementos no cenário é dada por t_tab_sym
  --' ': vazio, '.': caminho, 6 tipos de parede de acordo com a orientação,
  --C: moeda, P: moeda especial, D: porta
  TYPE t_tab_sym is (' ', '.', '|', '-', 'Q', 'W', 'E', 'R', 'C', 'P', 'D');
  
  --Legenda de direção usada para o piloto automático dos fantasmas
  --C: cima, E: esquerda, B: baixo, D: direita
  TYPE t_dir_sym is (' ', 'C', 'E', 'B', 'D');
  
  -- Os blocos de cenário (4 bits) e overlay (9 bits)
  SUBTYPE t_blk_id is STD_LOGIC_VECTOR(3 downto 0);
  SUBTYPE t_ovl_blk_id is STD_LOGIC_VECTOR(8 downto 0);
  
  -- Definição dos blocos (cenário e overlay)
  TYPE t_blk_sym is (BLK_NULL, BLK_PATH, BLK_WALL_V, BLK_WALL_H, BLK_WALL_Q, BLK_WALL_W, BLK_WALL_E,
           BLK_WALL_R, BLK_COIN, BLK_SPC_COIN, BLK_DOOR);
  
  TYPE t_ovl_blk_sym is (...) --- TRECHO DE CÓDIGO SUPRIMIDO
  
  -- "Funções" para blocos
  TYPE t_blk_bool is array(t_blk_sym) of boolean;
  CONSTANT WALKABLE: t_blk_bool := -- define quais blocos são percorríveis
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
  
  TYPE t_fan_state is (ST_VIVO, ST_PRE_VULN, ST_VULN, ST_VULN_BLINK,
                       ST_DEAD, ST_PRE_DEAD, ST_FIND_EXIT, ST_FUGA);
  
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
  CONSTANT CELL_OUT_Y : INTEGER := 35; -- posição Y da célula principal fora da cela
  CONSTANT MAP_X_MAX : INTEGER := 82; -- coordenadas limites do mapa 
  CONSTANT MAP_X_MIN : INTEGER := 2;
  CONSTANT MAP_Y_MAX : INTEGER := 93;
  CONSTANT MAP_Y_MIN : INTEGER := 1;
  CONSTANT VIDA_ICONS_X: t_vidas_pos := (90, 90, 90);
  CONSTANT VIDA_ICONS_Y: t_vidas_pos := (89, 83, 77);
  CONSTANT FRUTA_X: t_pos := 42;
  CONSTANT FRUTA_Y: t_pos := 53;
  CONSTANT FRUTA_ICONS_X: INTEGER := 90;
  CONSTANT FRUTA_ICONS_Y0: INTEGER := 65;
  CONSTANT MAX_FRUTA_COM: INTEGER := 5;
  
  CONSTANT VEL_NO: INTEGER := 5;
  SUBTYPE t_velocs is INTEGER range 0 to 100;
  TYPE t_vet_velocs is array(0 to VEL_NO-1) of t_velocs;
  --divisores de atualização para: 0=pacman, 1= fant vuln, 2=fant, 3=fant morto
  CONSTANT VEL_DIV: t_vet_velocs := (6, 8, 5, 4, 60); 
       
  --Fatores de divisão do clock de 27MHz, usados para atualização do
  --estado do jogo ("velocidade de execução") e do display
  CONSTANT DIV_FACT: INTEGER := 202500;
  CONSTANT DISP_DIV_FACT: INTEGER := 27000000/4;

  -- lista de frutas comidas recentemente
  TYPE t_fruta_vet is array(0 to MAX_FRUTA_COM - 1) of t_fruta_id;

  subtype sentido is INTEGER range -1 to 1;
  TYPE t_direc is array(0 to 1) of sentido;
  TYPE t_direc_vet is array(t_direcao) of t_direc;
  
  CONSTANT DIRS: t_direc_vet := (CIMA  => (-1, 0), DIREI => ( 0, 1), 
                                 BAIXO => ( 1, 0), ESQUE => ( 0,-1),
                                 NADA  => ( 0, 0));
  
  TYPE t_tab_array is array(0 to SCR_WDT*SCR_HGT-1) of t_tab_sym;
  TYPE t_dir_mapa is array(0 to SCR_HGT-1, 0 to SCR_WDT-1) of t_dir_sym;
  
  -- Mapa de inicialização da RAM inferior (cenário), a legenda está mais acima.
  --
  -- Esse mapa pode ser customizado livremente, sendo necessário apenas definir
  -- algumas constantes de posições especiais (por exemplo, as da "jaula" e das
  -- posições iniciais) e, opcionalmente, criar um novo mapa de piloto
  -- automático para fantasmas (veja abaixo).
  CONSTANT MAPA_INICIAL: t_tab_array; --- TRECHO DE CÓDIGO SUPRIMIDO
  
  -- Mapa de piloto automático para os fantasmas. Legenda do tipo t_dir_sym.
  --
  -- Neste mapa, estão armazenados apenas a próxima direção do percurso de um fantasma
    -- quando este está morto. Não é preciso definir uma direção para todas as casas: 
    -- nas indefinidas, o fantasma será teletransportado diretamente para a jaula,
    -- mas o seu tempo de inatividade não deverá sofrer alteração.
  CONSTANT FAN_PERCURSO: t_dir_mapa ; --- TRECHO DE CÓDIGO SUPRIMIDO

END pac_defs;
