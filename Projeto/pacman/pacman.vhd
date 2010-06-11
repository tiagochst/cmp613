LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;

ENTITY pacman is
  PORT (
    clk27M, reset_button      : in  STD_LOGIC;
    red, green, blue          : out STD_LOGIC_vector(3 downto 0);
    hsync, vsync              : out STD_LOGIC;
    LEDG                      : BUFFER STD_LOGIC_VECTOR (7 downto 5); --   LED Green
    PS2_DAT                   : inout STD_LOGIC;                      --   PS2 Data
    PS2_CLK                   : inout STD_LOGIC;	                  --   PS2 Clock
    SEG0, SEG1, SEG2, SEG3    : OUT STD_LOGIC_VECTOR(6 downto 0)
    );
END pacman;

ARCHITECTURE comportamento of pacman is
    SIGNAL rstn : STD_LOGIC;                        -- reset active low
                                        
    -- Interface com a memória de vídeo do controlador
    SIGNAL we : STD_LOGIC;                          -- write enable ('1' p/ escrita)
    SIGNAL addr : INTEGER 
                  range 0 to SCR_HGT*SCR_WDT-1;     -- ENDereco mem. vga
    SIGNAL block_in, block_out : t_blk_sym;           -- dados trocados com a mem. vga
    SIGNAL vga_pixel_out: t_color_3b;

    -- Sinais dos contadores de linhas e colunas utilizados para percorrer
    -- as posições da memória de vídeo (pixels) no momento de construir um quadro.
    SIGNAL line : INTEGER range 0 to SCR_HGT-1;     -- linha atual
    SIGNAL col : INTEGER range 0 to SCR_WDT-1;      -- coluna atual
    SIGNAL col_rstn : STD_LOGIC;                    -- reset do contador de colunas
    SIGNAL col_enable : STD_LOGIC;                  -- enable do contador de colunas
    SIGNAL line_rstn : STD_LOGIC;                   -- reset do contador de linhas
    SIGNAL line_enable, line_inc : STD_LOGIC;       -- enable do contador de linhas
    SIGNAL fim_escrita : STD_LOGIC;                 -- '1' quando um quadro terminou de ser
                                                    -- escrito na memória de vídeo

    -- Especificação dos tipos e sinais da máquina de estados de controle
    TYPE estado_t is (SHOW_SPLASH, CARREGA_MAPA, INICIO_JOGO, PERCORRE_QUADRO,
                      ATUALIZA_LOGICA_1, ATUALIZA_LOGICA_2, ATUALIZA_LOGICA_3, MEMORIA_WR);
    SIGNAL estado: estado_t := SHOW_SPLASH;
    SIGNAL pr_estado: estado_t := SHOW_SPLASH;
    
    SIGNAL atual_cont:             -- Contagem (modular) do número de vezes que a lógica
       INTEGER range 0 to 11 := 0; -- atualizou (serve como enable de várias velocidades)
    SIGNAL atual_en_2, atual_en_3, atual_en_4: STD_LOGIC;
                                                    
    
    -- Sinais de desenho em overlay sobre o cenário do jogo
    SIGNAL overlay: STD_LOGIC;
    SIGNAL ovl_blk_in: ovl_blk_sym;

    -- Sinais para um contador utilizado para atrasar 
    -- a frequência da atualização
    SIGNAL contador : INTEGER range 0 to DIV_FACT-1;
    SIGNAL timer : STD_LOGIC;                       -- vale '1' quando o contador chegar ao fim
    SIGNAL timer_rstn, timer_enable : STD_LOGIC;
      
    COMPONENT counter IS
	PORT (clk, rstn, en: IN STD_LOGIC;
	      max: IN INTEGER;
	      q: OUT INTEGER);
	END COMPONENT counter;
	
	FUNCTION walkable(s: t_blk_sym)
		RETURN boolean IS
	BEGIN
		IF (s = BLK_PATH or s = BLK_COIN or s = BLK_SPC_COIN) THEN RETURN true;
		ELSE RETURN false;
		END IF;
	END FUNCTION;

    -----------------------------------------------------------------------------
    -- Sinais de controle da lógica do jogo
    -----------------------------------------------------------------------------
    SIGNAL got_coin, got_spc_coin: STD_LOGIC;       -- informa se obteve moeda no ultimo movimento
    SIGNAL q_rem_moedas: INTEGER range -10 to 255 := 240;
    SIGNAL q_vidas: INTEGER range 0 to 5 := 3;
    SIGNAL q_pontos: INTEGER range 0 to 9999 := 0;
    SIGNAL display_en: STD_LOGIC;
    
    SIGNAL pac_pos_x: t_pos := PAC_START_X;
    SIGNAL pac_pos_y: t_pos := PAC_START_Y;
    SIGNAL pac_cur_dir: t_direcao;
    SIGNAL sig_blink: UNSIGNED(4 downto 0);
 	SIGNAL pac_nxt_cel, pac_dir_cel, pac_esq_cel, pac_cim_cel, pac_bai_cel: t_blk_sym;
    SIGNAL pac_area: blk_sym_3x3;
    SIGNAL pacman_dead: STD_LOGIC;
 	
 	SIGNAL fan_pos_x: t_fans_pos := FANS_START_X;
 	SIGNAL fan_pos_y: t_fans_pos := FANS_START_Y;
    SIGNAL fan_cur_dir: t_fans_dirs;
    SIGNAL fan_nxt_cel, fan_dir_cel, fan_esq_cel, fan_cim_cel, fan_bai_cel: t_fans_blk_sym;
    SIGNAL cur_fan: INTEGER range 0 to FAN_NO-1; -- fantasma controlado atualmente pelo p2
    SIGNAL fan_state: t_fans_states;
	SIGNAL fan_area: t_fans_blk_sym_3x3;

	SIGNAL p1_dir, p2_dir: t_direcao; -- sinais lidos pelo teclado
	SIGNAL p2_toggle: STD_LOGIC;
BEGIN
    -- Controlador VGA (resolução 128 colunas por 96 linhas)
    -- Sinais:(aspect ratio 4:3). Os sinais que iremos utilizar para comunicar
    -- - write_clk (nosso clock)
    -- - write_enable ('1' quando queremos escrever um pixel)
    -- - write_addr (ENDereço do pixel a escrever)
    -- - data_in (brilho do pixel RGB, 1 bit pra cada componente de cor)
    vga_controller: entity work.vgacon port map (
        clk27M       => clk27M,
        rstn         => '1',
        vga_pixel    => vga_pixel_out,
        data_block   => block_out,
        hsync        => hsync,
        vsync        => vsync,
        write_clk    => clk27M,
        write_enable => we,
        write_addr   => addr,
        data_in      => block_in,
        ovl_in       => ovl_blk_in,
        ovl_we       => overlay);
        
    -- Atribuição capada das cores 3b -> 12b
    red   <= (OTHERS => vga_pixel_out(0));
    green <= (OTHERS => vga_pixel_out(1));
    blue  <= (OTHERS => vga_pixel_out(2));
	
	-- Controlador do teclado. Devolve os sinais síncronos das teclas
	-- de interesse pressionadas ou não.
	kbd: ENTITY WORK.kbd_key PORT MAP (
		CLOCK_27  => clk27M,
		KEY       => reset_button,
		LEDG      => LEDG(7 downto 5),
		PS2_DAT   => PS2_DAT,
		PS2_CLK   => PS2_CLK,
		p1_dir    => p1_dir,
		p2_dir    => p2_dir,
		p2_key0   => p2_toggle
    );
    
    display_en <= '1' WHEN (sig_blink = 0 and estado = ATUALIZA_LOGICA_1)
		ELSE '0';
    
    display: ENTITY WORK.disp PORT MAP (
		CLK 	  => clk27M,
		EN		  => display_en,
		VIDAS     => q_vidas,
		PNT       => q_pontos,
		PEDRAS    => q_rem_moedas,
		seg0      => SEG0,
		seg1      => SEG1,
		seg2      => SEG2,
		seg3      => SEG3
	);

    -----------------------------------------------------------------------------
    -- Contadores de varredura da tela
    -----------------------------------------------------------------------------

    conta_coluna: COMPONENT counter
		PORT MAP (clk 	=> clk27M,
		          rstn 	=> col_rstn,
		          en	=> col_enable,
				  max	=> SCR_WDT-1,
				  q		=> col);
    
    -- o contador de linha só incrementa quando o contador de colunas
    -- chegou ao fim
    line_inc <= '1' WHEN (line_enable='1' and col = SCR_WDT-1)
    ELSE        '0';
				  
	conta_linha: COMPONENT counter
		PORT MAP (clk 	=> clk27M,
		          rstn 	=> line_rstn,
		          en	=> line_inc,
				  max	=> SCR_HGT-1,
				  q		=> line);
    
    -- podemos avançar para o próximo estado?
    fim_escrita <= '1' WHEN (line = SCR_HGT-1) and (col = SCR_WDT-1)
                   ELSE '0';
	
	-- purpose: Preenche as matrizes 3x3 das vizinhanças pac_area 
	--          e fans_area durante PERCORRE_QUADRO
    -- type   : sequential
    -- inputs : clk27M, rstn, pac_area, line, col, estado
    -- outputs: pac_area
    p_fill_memarea: PROCESS (clk27M)
		VARIABLE x_offset, y_offset: INTEGER range -TAB_LEN to TAB_LEN;
	BEGIN
		IF (clk27M'event and clk27M='1') THEN
			IF (estado = PERCORRE_QUADRO) THEN
				--Leitura atrasada devido ao ciclo de clock da ram
				y_offset := line - pac_pos_y;
				x_offset := col - pac_pos_x;
				IF (x_offset >=0 and x_offset <=2 and y_offset >=-1 and y_offset<=1) THEN
					pac_area(y_offset, x_offset-1) <= block_out;
				END IF;
				
				FOR i in 0 to FAN_NO-1 LOOP
					y_offset := line - fan_pos_y(i);
					x_offset := col - fan_pos_x(i);
					IF (x_offset >=0 and x_offset <=2 and y_offset >=-1 and y_offset<=1) THEN
						fan_area(i)(y_offset, x_offset-1) <= block_out;
					END IF;
				END LOOP;
			END IF;
		END IF;
	END PROCESS;
	
	--Gera enables de atualizações para cada velocidade de atualização
	PROCESS (atual_cont)
	BEGIN
		IF (atual_cont=0 or atual_cont=6)
		THEN atual_en_2 <= '1';
		ELSE atual_en_2 <= '0';
		END IF;
		
		IF (atual_cont=0 or atual_cont=4  or atual_cont=8)
		THEN atual_en_3 <= '1';
		ELSE atual_en_3 <= '0';
		END IF;
		
		IF (atual_cont=0 or atual_cont=3 or atual_cont=6 or atual_cont=9)
		THEN atual_en_4 <= '1';
		ELSE atual_en_4 <= '0';
		END IF;
	END PROCESS;
	
	--Calcula possíveis parâmetros envolvidos no próximo movimento
	--do pacman
	PROCESS (pac_cur_dir, pac_area)
	BEGIN
		--calcula qual seriam as proximas celulas visitadas pelo pacman
		pac_nxt_cel <= pac_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1));
		pac_dir_cel <= pac_area(0,1);
		pac_esq_cel <= pac_area(0,-1);
		pac_cim_cel <= pac_area(-1,0);
		pac_bai_cel <= pac_area(1,0);
	END PROCESS;

    -- purpose: Este processo irá atualizar a posicão do pacman e definir
    --          suas ações no jogo. Opera no estado ATUALIZA_LOGICA_1
    -- type   : sequential
    -- inputs : clk27M, rstn, pac_area
    --          pac_cur_dir, pac_pos_x, pac_pos_y
    -- outputs: pac_cur_dir, pac_pos_x, pac_pos_y, got_coin
    p_atualiza_pacman: PROCESS (clk27M, rstn)
		VARIABLE nxt_move, p1_dir_old: t_direcao;
    BEGIN
        IF (rstn = '0') THEN
            pac_pos_x <= PAC_START_X;
            pac_pos_y <= PAC_START_Y;
			pac_cur_dir <= NADA; --inicializa direcao para direita
			nxt_move := NADA;
			q_rem_moedas <= 240;
            q_vidas <= 3;
            q_pontos <= 0;
        ELSIF (clk27M'event and clk27M = '1') THEN
             IF (estado = ATUALIZA_LOGICA_1 and atual_en_3 = '1') THEN
				--Checa teclado para "agendar" um movimento
				IF (p1_dir = CIMA and p1_dir_old = NADA) THEN
					nxt_move := CIMA;
				ELSIF (p1_dir = DIREI and p1_dir_old = NADA) THEN
					nxt_move := DIREI;
				ELSIF (p1_dir = BAIXO and p1_dir_old = NADA) THEN
					nxt_move := BAIXO;
				ELSIF (p1_dir = ESQUE and p1_dir_old = NADA) THEN
					nxt_move := ESQUE;
				END IF;
				
                --atualiza direção
				IF (nxt_move = CIMA and walkable(pac_cim_cel)) THEN
					pac_cur_dir <= CIMA;
					nxt_move := NADA;
				ELSIF (nxt_move = DIREI and walkable(pac_dir_cel)) THEN
					pac_cur_dir <= DIREI;
					nxt_move := NADA;
				ELSIF (nxt_move = BAIXO and walkable(pac_bai_cel)) THEN
					pac_cur_dir <= BAIXO;
					nxt_move := NADA;
				ELSIF (nxt_move = ESQUE and walkable(pac_esq_cel)) THEN
					pac_cur_dir <= ESQUE;
					nxt_move := NADA;
                ELSIF (walkable(pac_nxt_cel)) THEN --atualiza posicao
					IF (pac_pos_x = TELE_DIR_POS) then --teletransporte
						pac_pos_x <= TELE_ESQ_POS + 1;
					ELSIF (pac_pos_x = TELE_ESQ_POS) then
						pac_pos_x <= TELE_DIR_POS - 1;
					ELSE
						pac_pos_x <= pac_pos_x + DIRS(pac_cur_dir)(1);
						pac_pos_y <= pac_pos_y + DIRS(pac_cur_dir)(0);
					END IF;
                    
                    IF (pac_nxt_cel = BLK_COIN or pac_nxt_cel = BLK_SPC_COIN) THEN
                        got_coin <= '1';
                    ELSE
                        got_coin <= '0';
                    END IF;
                    
                    IF (pac_nxt_cel = BLK_SPC_COIN) THEN
                        got_spc_coin <= '1';
                    ELSE
                        got_spc_coin <= '0';
                    END IF;
                    
                    IF (pac_nxt_cel = BLK_COIN) THEN
                        q_pontos <= q_pontos + 10;
                        q_rem_moedas <= q_rem_moedas - 1;
                    ELSIF (pac_nxt_cel = BLK_SPC_COIN) THEN
                        q_pontos <= q_pontos + 50;
                    END IF;
                END IF;
                p1_dir_old := p1_dir;
            END IF;
        END IF;
	END PROCESS;
	
	--Calcula possíveis parâmetros envolvidos no próximo movimento
	--de todos os fantasmas
	PROCESS (clk27M)
	BEGIN
		--IF (clk27M'event and clk27M = '1') THEN
			--IF (estado = ATUALIZA_LOGICA_1) THEN
				FOR i in 0 to FAN_NO-1 LOOP
					fan_nxt_cel(i) <= fan_area(i)(DIRS(fan_cur_dir(i))(0), DIRS(fan_cur_dir(i))(1));
					fan_dir_cel(i) <= fan_area(i)(0,1);
					fan_esq_cel(i) <= fan_area(i)(0,-1);
					fan_cim_cel(i) <= fan_area(i)(-1,0);
					fan_bai_cel(i) <= fan_area(i)(1,0);
				END LOOP;
			--END IF;
		--END IF;
	END PROCESS;
	
	-- purpose: Este processo irá atualizar as posições dos fantasmas e definir
    --          suas ações no jogo. Opera no estado ATUALIZA_LOGICA_2
    -- type   : sequential
    -- inputs : clk27M, rstn, pac_area
    --          fan_cur_dir, fan_pos_x, fan_pos_y
    -- outputs: fan_cur_dir, fan_pos_x, fan_pos_y, got_coin
    p_atualiza_fantasmas: PROCESS (clk27M, rstn)
		VARIABLE nxt_move, p2_dir_old: t_direcao;
		VARIABLE p2_toggle_old: STD_LOGIC;
    BEGIN
        IF (rstn = '0') THEN
            fan_pos_x <= FANS_START_X;
            fan_pos_y <= FANS_START_Y;
			fan_cur_dir <= (others => NADA);
			nxt_move := NADA;
        ELSIF (clk27M'event and clk27M = '1') THEN
             IF (estado = ATUALIZA_LOGICA_2) THEN
				FOR i in 0 to FAN_NO-1 LOOP
					CASE fan_state(i) IS
					WHEN ST_VIVO | ST_VULN => 
						IF (cur_fan = i and atual_en_3 = '1') THEN
							--Checa teclado para "agendar" um movimento
							IF (p2_dir = CIMA and p2_dir_old = NADA) THEN
								nxt_move := CIMA;
							ELSIF (p2_dir = DIREI and p2_dir_old = NADA) THEN
								nxt_move := DIREI;
							ELSIF (p2_dir = BAIXO and p2_dir_old = NADA) THEN
								nxt_move := BAIXO;
							ELSIF (p2_dir = ESQUE and p2_dir_old = NADA) THEN
								nxt_move := ESQUE; 
							END IF;
							
							IF (nxt_move = CIMA and walkable(fan_cim_cel(cur_fan))) THEN
								fan_cur_dir(cur_fan) <= CIMA;
								nxt_move := NADA;
							ELSIF (nxt_move = DIREI and walkable(fan_dir_cel(cur_fan))) THEN
								fan_cur_dir(cur_fan) <= DIREI;
								nxt_move := NADA;
							ELSIF (nxt_move = BAIXO and walkable(fan_bai_cel(cur_fan))) THEN
								fan_cur_dir(cur_fan) <= BAIXO;
								nxt_move := NADA;
							ELSIF (nxt_move = ESQUE and walkable(fan_esq_cel(cur_fan))) THEN
								fan_cur_dir(cur_fan) <= ESQUE;
								nxt_move := NADA;
							ELSIF (walkable(fan_nxt_cel(cur_fan))) THEN --atualiza posicao
								IF(fan_pos_x(cur_fan) = TELE_DIR_POS) then --teletransporte
									fan_pos_x(cur_fan) <= TELE_ESQ_POS + 1;
								ELSIF(fan_pos_x(cur_fan) = TELE_ESQ_POS) then
									fan_pos_x(cur_fan) <= TELE_DIR_POS - 1;
								ELSE
									fan_pos_x(cur_fan) <= 
										fan_pos_x(cur_fan) + DIRS(fan_cur_dir(cur_fan))(1);
									fan_pos_y(cur_fan) <= 
										fan_pos_y(cur_fan) + DIRS(fan_cur_dir(cur_fan))(0);
								END IF;
							END IF;
							 
							p2_dir_old := p2_dir;
							p2_toggle_old := p2_toggle;
						END IF;
					WHEN ST_DEAD | ST_FIND_EXIT => 
						IF (atual_en_4 = '1') THEN
							-- Movimento automático do fantasma para a cela
							CASE FAN_PERCURSO(fan_pos_y(i), fan_pos_x(i)) IS
							WHEN 'Q' =>
								fan_pos_y(i) <= fan_pos_y(i) - 1;
								fan_cur_dir(i) <= CIMA;
							WHEN 'W' =>
								fan_pos_y(i) <= fan_pos_y(i) + 1;
								fan_cur_dir(i) <= BAIXO;
							WHEN 'E' =>
								fan_pos_x(i) <= fan_pos_x(i) - 1;
								fan_cur_dir(i) <= ESQUE;
							WHEN 'R' =>
								fan_pos_x(i) <= fan_pos_x(i) + 1;
								fan_cur_dir(i) <= DIREI;
							WHEN OTHERS =>
							END CASE;
						END IF;
					WHEN ST_FUGA => --Supõe que fan_pos_x já vale CELL_IN_X 
						IF (atual_en_3 = '1') THEN 
							fan_pos_y(i) <= fan_pos_y(i) - 1;
						END IF;
					END CASE;
				END LOOP;
				IF (p2_toggle = '1' and p2_toggle_old = '0') THEN
					cur_fan <= cur_fan + 1;
					fan_cur_dir <= (OTHERS => NADA);
				END IF;
            END IF;
        END IF;
	END PROCESS;
	
	-- Gera o próximo estado de cada fantasma na atualização
	p_fan_next_state: PROCESS (clk27M, rstn)
		VARIABLE fan_tempo: t_fans_times;
	BEGIN
		IF (rstn = '0') THEN
			fan_state <= (OTHERS => ST_FIND_EXIT);
			fan_tempo := (OTHERS => 0);
		ELSIF (clk27M'event and clk27M = '1') THEN
			IF (estado = ATUALIZA_LOGICA_3) THEN
				FOR i in 0 to FAN_NO-1 LOOP
					CASE fan_state(i) IS
						WHEN ST_VIVO =>
							IF (pac_pos_x = fan_pos_x(i) and pac_pos_y = fan_pos_y(i)) THEN
								--pacman_dead <= '1';
							ELSE
								IF (got_spc_coin = '1') THEN
									fan_state(i) <= ST_VULN;
								END IF;
								--pacman_dead <= '0';
							END IF;
							fan_tempo(i) := 0;
							
						WHEN ST_VULN =>
							IF (pac_pos_x = fan_pos_x(i) and pac_pos_y = fan_pos_y(i)) THEN
								fan_tempo(i) := 0;
								fan_state(i) <= ST_DEAD;
							ELSIF (fan_tempo(i) = FAN_TIME_VULN) THEN
								fan_state(i) <= ST_VIVO;
							ELSE
								fan_tempo(i) := fan_tempo(i) + 1;
							END IF;
							
						WHEN ST_DEAD =>
							IF (fan_tempo(i) = FAN_TIME_DEAD) THEN
								fan_state(i) <= ST_FIND_EXIT;
							ELSE
								fan_tempo(i) := fan_tempo(i) + 1;
							END IF;
						
						WHEN ST_FIND_EXIT =>
							IF (fan_pos_x(i) = CELL_IN_X and fan_pos_y(i) = CELL_IN_Y) THEN
								fan_state(i) <= ST_FUGA;
							END IF;
							
						WHEN ST_FUGA =>
							IF (fan_pos_y(i) = CELL_OUT_Y) THEN
								fan_state(i) <= ST_VIVO;
                                fan_cur_dir(i) <= NADA;
							END IF;
					END CASE;
				END LOOP;
			END IF;
		END IF;
	END PROCESS;
	
	-- purpose: Processo para que gera sinais de desenho de 
	--			overlay (ie, sobre o fundo) da vidas, do pacman e dos fantasmas 
    -- type   : combinational
    des_overlay: PROCESS (pac_pos_x, pac_pos_y, pac_cur_dir, sig_blink, 
                          fan_pos_x, fan_pos_y, fan_state, fan_cur_dir, line, col)
		VARIABLE x_offset, y_offset: INTEGER range -TAB_LEN to TAB_LEN;
    BEGIN
        --Sinais para desenho do pacman na tela durante PERCORRE_QUADRO
        y_offset := line - pac_pos_y + 2;
        x_offset := col - pac_pos_x + 2;
        
		IF (x_offset>=0 and x_offset<5 and 
			y_offset>=0 and y_offset<5) THEN
			IF (sig_blink(1) = '0') THEN
				ovl_blk_in <= PAC_BITMAPS(pac_cur_dir)(y_offset, x_offset);
			ELSE
				IF (pac_cur_dir = DIREI or pac_cur_dir = ESQUE) THEN
					ovl_blk_in <= PAC_FECH_BITMAP(y_offset, x_offset);
				ELSE
					ovl_blk_in <= PAC_FECV_BITMAP(y_offset, x_offset);
				END IF;
			END IF;
		ELSE --Desenho dos fantasmas
            FOR i in 0 to FAN_NO-1 LOOP
                y_offset := line - fan_pos_y(i) + 2;
                x_offset := col - fan_pos_x(i) + 2;
                IF (x_offset>=0 and x_offset<5 and 
                    y_offset>=0 and y_offset<5) THEN
                    IF (fan_state(i) = ST_VULN) THEN
                        ovl_blk_in <= FAN_VULN_BITMAP(y_offset, x_offset);
                    ELSIF (fan_state(i) = ST_DEAD) THEN
                        ovl_blk_in <= FAN_DEAD_BITMAPS(fan_cur_dir(i))(y_offset, x_offset);
                    ELSE
                        ovl_blk_in <= FAN_BITMAPS(fan_cur_dir(i))(y_offset, x_offset);
                    END IF;
                --ELSE
                    --y_offset := line - fan_pos_y(1) + 2;
                    --x_offset := col - fan_pos_x(1) + 2;
                    --IF (x_offset>=0 and x_offset<5 and
                    --y_offset>=0 and y_offset<5) THEN
                        --IF (fan_state(0) = ST_VULN) THEN
                            --ovl_blk_in <= FAN_VULN_BITMAP(y_offset, x_offset);
                        --ELSIF (fan_state(0) = ST_DEAD) THEN
                            --ovl_blk_in <= FAN_DEAD_BITMAPS(fan_cur_dir(1))(y_offset, x_offset);
                        --ELSE
                            --ovl_blk_in <= FAN_BITMAPS(fan_cur_dir(1))(y_offset, x_offset);
                        --END IF;
                    --ELSE
                        --ovl_blk_in <= BLK_NULL;
                    --END IF;
                END IF;
            END LOOP;
		END IF;
    END PROCESS;
    
    -- Define dado que entra na ram
	def_block_in: PROCESS (estado, addr)
	BEGIN
		IF (estado = CARREGA_MAPA) THEN
			block_in <= CONV_TAB_BLK(MAPA_INICIAL(addr));
		ELSE	 
			block_in <= BLK_PATH; --Caso que a moeda é comida pelo pacman
		END IF;
	END PROCESS;
    
    -----------------------------------------------------------------------------
    -- Processos que definem a FSM (finite state machine), nossa máquina
    -- de estados de controle.
    -----------------------------------------------------------------------------

    -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
    --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
    -- type   : combinational
    -- inputs : estado, fim_escrita, timer, col, line, pac_pos_x, pac_pos_y
    -- outputs: pr_estado, atualiza_pos_x, atualiza_pos_y, line_rstn,
    --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
    logica_mealy: PROCESS (estado, fim_escrita, timer, 
                           col, line, pac_pos_x, pac_pos_y, got_coin)
    BEGIN
        case estado is
        when CARREGA_MAPA  => IF (fim_escrita = '1') THEN
							pr_estado <= INICIO_JOGO;
						ELSE
							pr_estado <= CARREGA_MAPA;
						END IF;
						line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '1';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr           <= col + SCR_WDT*line;
                        overlay         <= '0';
                        
        when INICIO_JOGO  => IF timer = '1' THEN              
                            pr_estado <= PERCORRE_QUADRO;
                        ELSE
                            pr_estado <= INICIO_JOGO;
                        END IF;
                        line_rstn      <= '0';  -- reset é active low!
                        line_enable    <= '0';
                        col_rstn       <= '0';  -- reset é active low!
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1';  -- reset é active low!
                        timer_enable   <= '1';
                        addr           <= 0;
                        overlay         <= '0';

        when PERCORRE_QUADRO => IF (fim_escrita = '1') THEN
                            pr_estado <= ATUALIZA_LOGICA_1;
                        ELSE
                            pr_estado <= PERCORRE_QUADRO;
                        END IF;
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr           <= col + SCR_WDT*line;
                        overlay        <= '1';
                        
        when ATUALIZA_LOGICA_1 => pr_estado <= ATUALIZA_LOGICA_2;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
                        overlay        <= '0';
                        
		when ATUALIZA_LOGICA_2 => pr_estado <= ATUALIZA_LOGICA_3;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
                        overlay        <= '0';
		
		when ATUALIZA_LOGICA_3 => pr_estado <= MEMORIA_WR;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
                        overlay        <= '0';
      
        when MEMORIA_WR => pr_estado <= INICIO_JOGO;
						line_rstn      <= '0';
                        line_enable    <= '0';
                        col_rstn       <= '0';
                        col_enable     <= '0';
                        we             <= got_coin; 
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= pac_pos_x + SCR_WDT * pac_pos_y;
                        overlay        <= '0';
                        
		when others  => pr_estado <= CARREGA_MAPA;
                        line_rstn      <= '0';
                        line_enable    <= '0';
                        col_rstn       <= '0';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1'; 
                        timer_enable   <= '0';
                        addr           <= 0;
                        overlay         <= '0';
        END case;
    END PROCESS logica_mealy;

    -- purpose: Avança a FSM para o próximo estado
    -- type   : sequential
    -- inputs : clk27M, rstn, pr_estado
    -- outputs: estado
    seq_fsm: PROCESS (clk27M, rstn)
    BEGIN  -- PROCESS seq_fsm
        IF rstn = '0' THEN                  -- asynchronous reset (active low)
            estado <= SHOW_SPLASH;
            atual_cont <= 0;
            sig_blink  <= (OTHERS => '0');
        elsif clk27M'event and clk27M = '1' THEN  -- rising clock edge
            estado <= pr_estado;
            
            IF (estado = ATUALIZA_LOGICA_2) THEN
				IF (atual_cont = 11) THEN
					atual_cont <= 0;
				ELSE
					atual_cont <= atual_cont + 1;
				END IF;
				sig_blink <= sig_blink + 1;
			END IF;
        END IF;
    END PROCESS seq_fsm;

    -----------------------------------------------------------------------------
    -- Contador utilizado para atrasar a animação (evitar
    -- que a atualização de quadros fique muito veloz).
    ----------------------------------------------------------------------------
    p_contador: COMPONENT counter 
        PORT MAP (clk 	=> clk27M,
		          rstn 	=> timer_rstn,
		          en	=> timer_enable,
				  max	=> DIV_FACT - 1,
				  q		=> contador);
                  
    --O sinal "timer" indica quando o contador chegou ao final
    timer <= '1' WHEN (contador = DIV_FACT - 1)
    ELSE     '0';
    
    -----------------------------------------------------------------------------
    -- Processos que sincronizam sinais assíncronos, de preferência com mais
    -- de 1 flipflop, para evitar metaestabilidade.
    -----------------------------------------------------------------------------
    -- purpose: Aqui sincronizamos nosso sinal de reset vindo do botão da DE1
    -- type   : sequential
    -- inputs : clk27M
    -- outputs: rstn
    build_rstn: PROCESS (clk27M)
        VARIABLE temp : STD_LOGIC;          -- flipflop intermediario
    BEGIN  -- PROCESS build_rstn
        IF (clk27M'event and clk27M = '1') THEN  -- rising clock edge
            rstn <= temp;
            temp := reset_button;     
        END IF;
    END PROCESS build_rstn;
END comportamento;
