LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;
USE work.PAC_SPRITES.all;

ENTITY pacman is
  PORT (
    clk27M, reset_button      : in  STD_LOGIC;
    red, green, blue          : out STD_LOGIC_vector(3 downto 0);
    hsync, vsync              : out STD_LOGIC;
    LEDG                      : BUFFER STD_LOGIC_VECTOR (7 downto 5); 
    PS2_DAT                   : inout STD_LOGIC;                      
    PS2_CLK                   : inout STD_LOGIC;	                 
    SEG0, SEG1, SEG2, SEG3    : OUT STD_LOGIC_VECTOR(6 downto 0);
    LEDR					  : BUFFER STD_LOGIC_VECTOR (2 downto 0);
    endgame					  : OUT STD_LOGIC
    );
END pacman;

ARCHITECTURE comportamento of pacman is
    SIGNAL rstn: STD_LOGIC;                        -- reset active low
    SIGNAL restartn: STD_LOGIC;                    -- Usado quando o pacman morre (active low)
    SIGNAL le_cenario: STD_LOGIC;				   -- Informa quando o cenário está sendo recarregado
                                        
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
    SIGNAL fim_varredura : STD_LOGIC;                 -- '1' quando um quadro terminou de ser
                                                    -- escrito na memória de vídeo

    -- Especificação dos tipos e sinais da máquina de estados de controle
    TYPE estado_t is (SHOW_SPLASH, CARREGA_MAPA, ESTADO_INICIAL, PERCORRE_QUADRO,
                      ATUALIZA_LOGICA_1, ATUALIZA_LOGICA_2, ATUALIZA_LOGICA_3, MEMORIA_WR,
                      REINICIO, FIM_JOGO);
    SIGNAL estado: estado_t := SHOW_SPLASH;
    SIGNAL pr_estado: estado_t := SHOW_SPLASH;
    
    -- sinais que servem como enable de várias velocidades
    SIGNAL atua_en: STD_LOGIC_VECTOR(0 to VEL_NO-1);
    SIGNAL display_en: STD_LOGIC;
	SIGNAL disp_count: INTEGER range 0 to 27000000;
    SIGNAL sig_blink: UNSIGNED(6 downto 0); -- enables com duty de 50%
                                                    
    -- Sinais de desenho em overlay sobre o cenário do jogo
    SIGNAL varre_tela: STD_LOGIC;
    SIGNAL ovl_blk_in: t_ovl_blk_sym;

    -- Sinais para um contador utilizado para atrasar 
    -- a frequência da atualização
    SIGNAL contador, long_cont : INTEGER range 0 to DIV_FACT-1;
    SIGNAL timer, long_timer : STD_LOGIC;     -- vale '1' quando o contador chegar ao fim
    SIGNAL timer_rstn, timer_enable : STD_LOGIC;
      
    COMPONENT counter IS
	PORT (clk, rstn, en: IN STD_LOGIC;
	      max: IN INTEGER;
	      q: OUT INTEGER);
	END COMPONENT counter;

    -----------------------------------------------------------------------------
    -- Sinais de controle da lógica do jogo
    -----------------------------------------------------------------------------
    SIGNAL got_coin, got_spc_coin: STD_LOGIC;  -- informa se obteve moeda no ultimo movimento
    SIGNAL reg_coin_we: STD_LOGIC;
    SIGNAL q_rem_moedas: INTEGER range 0 to 255 := 240; -- quantidade de moedas normais para vencer
    SIGNAL q_vidas: INTEGER range 0 to 5 := 3;
    SIGNAL q_pontos: INTEGER range 0 to 9999 := 0;
    SIGNAL vidas_arr: STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL update_info: STD_LOGIC;
    SIGNAL fruta_id: t_fruta_id;
    SIGNAL got_fruta: STD_LOGIC;
    SIGNAL nwc: STD_LOGIC := '0';
   
    -- Controle do pacman
    SIGNAL pac_pos_x: t_pos;
    SIGNAL pac_pos_y: t_pos;
    SIGNAL pac_cur_dir: t_direcao;
    SIGNAL pac_area: t_blk_sym_3x3;
    SIGNAL pacman_dead: STD_LOGIC;
    SIGNAL pac_fans_hit: UNSIGNED(0 to FAN_NO-1);
    SIGNAL pac_atua: STD_LOGIC;
 	
 	-- Controle dos fantasmas
 	SIGNAL fan_pos_x: t_fans_pos;
 	SIGNAL fan_pos_y: t_fans_pos;
    SIGNAL fan_cur_dir: t_fans_dirs;
    SIGNAL fan_state: t_fans_states;
	SIGNAL fan_area: t_fans_blk_sym_3x3;
	SIGNAL fan_atua: STD_LOGIC;
	SIGNAL fan_died: STD_LOGIC;

	SIGNAL pac_key_dir: t_direcao; -- sinais lidos pelo teclado
	SIGNAL fan_key_dir: t_fans_dirs;
BEGIN

	-- Controlador VGA com duas camadas (RAMs) de blocos:
	-- cenário e overlay, isto é, o pacman e os fantasmas
	-- Devolve os pixels convertidos pelos sprites e os 
	-- sinais de controle do monitor
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
        ovl_we       => varre_tela);
        
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
		p1_dir    => pac_key_dir,
		p2_dir    => fan_key_dir(0),
		p3_dir    => fan_key_dir(1)
    );
    
	disp_counter: COMPONENT counter
        PORT MAP (clk 	=> clk27M,
		          rstn 	=> rstn,
		          en	=> '1',
				  max	=> DISP_DIV_FACT-1,
				  q		=> disp_count);
	
    display_en <= '1' WHEN (disp_count = DISP_DIV_FACT-1)
		ELSE '0';
    
    -- Módulo que controla os displays 7-seg imprimindo
    -- mensagens e a pontuação atual
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
	
	frutas: ENTITY WORK.ctrl_frutas PORT MAP (
		clk    => clk27M, 	   rstn  => rstn and restartn and (not got_fruta),
		enable => update_info, fruta => fruta_id
	);

    -- Contadores de varredura da tela
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
    fim_varredura <= '1' WHEN (line = SCR_HGT-1) and (col = SCR_WDT-1)
                   ELSE '0';
                   
	-- Controlador dos fantasmas
	ctrl_fans_inst: ENTITY work.ctrl_fans PORT MAP (
		clk 		=> clk27M, 			rstn 		=> rstn and restartn,
		atualiza 	=> fan_atua, 		atua_en 	=> atua_en (1 to 3),
		keys_dir 	=> fan_key_dir,		fan_died	=> fan_died,
		fan_area 	=> fan_area,		pacman_dead => pacman_dead,
		spc_coin	=> got_spc_coin,	pac_fans_hit=> pac_fans_hit,
		fan_pos_x 	=> fan_pos_x, 		fan_pos_y 	=> fan_pos_y,
		fan_state	=> fan_state, 		fan_cur_dir => fan_cur_dir
	);
	
	-- Controlador do pacman
	ctrl_pac_inst: ENTITY work.ctrl_pacman PORT MAP (
		clk 		=> clk27M,			rstn		=> rstn and restartn,
		key_dir		=> pac_key_dir,		atualiza	=> pac_atua and atua_en(0),
		pac_area	=> pac_area,		pac_cur_dir	=> pac_cur_dir,
		pac_pos_x	=> pac_pos_x,		pac_pos_y	=> pac_pos_y,
		got_coin	=> got_coin,		got_spc_coin=> got_spc_coin
	);
	
	-- Preenche as matrizes 3x3 das vizinhanças pac_area 
	-- e fans_area durante PERCORRE_QUADRO
    -- type   : sequential
    p_fill_memarea: PROCESS (clk27M)
		VARIABLE x_offset, y_offset: t_offset;
		VARIABLE blk_out_sp: t_blk_sym; 
	BEGIN
		IF (clk27M'event and clk27M='1') THEN
			IF (varre_tela = '1') THEN
				-- Parte "inútil" do código
				IF (nwc = '1' and (not WALKABLE(block_out))) THEN
					blk_out_sp := BLK_PATH;
				ELSE
					blk_out_sp := block_out;
				END IF;
				
				-- Leitura atrasada devido ao ciclo de clock da ram
				y_offset := line - pac_pos_y;
				x_offset := col - pac_pos_x;
				IF (x_offset >=0 and x_offset <=2 and y_offset >=-1 and y_offset<=1) THEN
					pac_area(y_offset, x_offset-1) <= blk_out_sp;
				END IF;
				
				FOR i in 0 to FAN_NO-1 LOOP
					y_offset := line - fan_pos_y(i);
					x_offset := col - fan_pos_x(i);
					IF (x_offset >=0 and x_offset <=2 and y_offset >=-1 and y_offset<=1) THEN
						fan_area(i)(y_offset, x_offset-1) <= blk_out_sp;
					END IF;
				END LOOP;
			END IF;
		END IF;
	END PROCESS;
	
	-- Atualiza parâmetros de informação atual do jogo
	-- type: sequential
	param_jogo: PROCESS (clk27M, rstn)
	BEGIN
		IF (rstn = '0') THEN
			q_vidas <= 3;
			q_pontos <= 0;
			q_rem_moedas <= 240;
		ELSIF (clk27M'event and clk27M = '1') THEN
			IF (pacman_dead = '1' and update_info = '1') THEN
				q_vidas <= q_vidas - 1;
			END IF;

			IF (fan_died = '1') THEN
				q_pontos <= q_pontos + 200;
			ELSIF (pac_atua = '1' and atua_en(0) = '1') THEN
				IF (got_fruta = '1') THEN
					q_pontos <= q_pontos + 500;
				ELSIF (got_coin = '1') THEN
					q_pontos <= q_pontos + 10;
					q_rem_moedas <= q_rem_moedas - 1;
				ELSIF (got_spc_coin = '1') THEN
					q_pontos <= q_pontos + 50;
				ELSIF (nwc = '1') THEN
					q_pontos <= q_pontos + 1; --modo "especial"
				END IF;
			
				IF (got_coin = '1' or got_spc_coin = '1') THEN
					reg_coin_we <= '1'; --registra uma moeda comida
				ELSE
					reg_coin_we <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS param_jogo;
	
	-- purpose: Processo para que gera todos os sinais de desenho de overlay
	--			(ie, sobre o fundo) da vidas, do pacman e dos fantasmas de acordo
	--          com a varredura de line e col durante PERCORRE_QUADRO
    -- type   : combinational
    des_overlay: PROCESS (pac_pos_x, pac_pos_y, pac_cur_dir, sig_blink, vidas_arr, fruta_id,
                          fan_pos_x, fan_pos_y, fan_state, fan_cur_dir, line, col)
		VARIABLE x_offset, y_offset: t_offset;
		VARIABLE ovl_blk_tmp: t_ovl_blk_sym;
    BEGIN
		ovl_blk_tmp := BLK_NULL; -- este será o bloco que vai pra VGA
		-- a hierarquia dos desenhos tem o último como mais importante
		-- isto é, se ele for desenhado, nenhum outro aparece por cima
		
		-- Desenho da fruta
		IF (fruta_id /= 0) THEN
			y_offset := line - FRUTA_Y + 2;
			x_offset := col - FRUTA_X + 2;
			IF (x_offset>=0 and x_offset<5 and 
				y_offset>=0 and y_offset<5) THEN
				ovl_blk_tmp := FRUTA_BLKMAP(fruta_id)(y_offset, x_offset);
			END IF;
		END IF;
		
		FOR i in 0 to FAN_NO-1 LOOP -- Desenho dos fantasmas
			y_offset := line - fan_pos_y(i) + 2;
			x_offset := col - fan_pos_x(i) + 2;
			IF (x_offset>=0 and x_offset<5 and 
				y_offset>=0 and y_offset<5) THEN
				IF (fan_state(i) = ST_VULN_BLINK) THEN
					IF (sig_blink(5) = '0') THEN --pisca no final do modo vulnerável
						ovl_blk_tmp := FAN_VULN_BLKMAP(y_offset, x_offset);
					ELSE
						ovl_blk_tmp := BLK_NULL;
					END IF;
				ELSIF (fan_state(i) = ST_VULN) THEN
					ovl_blk_tmp := FAN_VULN_BLKMAP(y_offset, x_offset);
				ELSIF (fan_state(i) = ST_DEAD) THEN
					ovl_blk_tmp := FAN_DEAD_BLKMAPS(fan_cur_dir(i))(y_offset, x_offset);
				ELSE
					ovl_blk_tmp := FAN_BLKMAPS(i)(fan_cur_dir(i))(y_offset, x_offset);
				END IF;
				y_offset := line - fan_pos_y(1) + 2;
			END IF;
		END LOOP;
		
		-- Desenho do pacman
		y_offset := line - pac_pos_y + 2;
        x_offset := col - pac_pos_x + 2;
		IF (x_offset>=0 and x_offset<5 and 
			y_offset>=0 and y_offset<5) THEN
			IF (sig_blink(5) = '0') THEN
				ovl_blk_tmp := PAC_BLKMAPS(pac_cur_dir)(y_offset, x_offset);
			ELSE
				IF (pac_cur_dir = DIREI or pac_cur_dir = ESQUE) THEN
					ovl_blk_tmp := PAC_FECH_BLKMAP(y_offset, x_offset);
				ELSE
					ovl_blk_tmp := PAC_FECV_BLKMAP(y_offset, x_offset);
				END IF;
			END IF;
		END IF;
		
		FOR i in 0 to 2 LOOP --Desenho dos ícones de vida
			IF (vidas_arr(i) = '1') THEN
				y_offset := line - VIDA_ICONS_Y(i) + 2;
				x_offset := col - VIDA_ICONS_X(i) + 2;
				IF (x_offset>=0 and x_offset<5 and
				y_offset>=0 and y_offset<5) THEN
					ovl_blk_tmp := PAC_BLKMAPS(DIREI)(y_offset, x_offset);
				END IF;
			END IF;
		END LOOP;
		
		ovl_blk_in <= ovl_blk_tmp;
    END PROCESS;
    
    -- Determina quando o pacman comeu uma fruta
    PROCESS (pac_pos_x, pac_pos_y, fruta_id)
	BEGIN
		IF (pac_pos_x = FRUTA_X and pac_pos_y = FRUTA_Y and fruta_id /= 0) THEN
			got_fruta <= '1';
		ELSE
			got_fruta <= '0';
		END IF;
	END PROCESS;
    
    -- Determina quando o pacman colidiu com cada um dos fantasmas
    -- type: combinational
    PROCESS (pac_pos_x, pac_pos_y, fan_pos_x, fan_pos_y)
		VARIABLE	off_x, off_y: t_offset;
	BEGIN
		FOR i in 0 to FAN_NO-1 LOOP
			off_x := pac_pos_x - fan_pos_x(i);
			off_y := pac_pos_y - fan_pos_y(i);
			-- a tolerância para colisão é uma região 5x5
			IF (off_x >=-2 and off_x <=2 and off_y>=-2 and off_y<=2) THEN
				pac_fans_hit(i) <= '1';
			ELSE
				pac_fans_hit(i) <= '0';
			END IF;
		END LOOP;
	END PROCESS;
    
    -- Define dado que entra na ram de cenário
	def_block_in: PROCESS (le_cenario, addr)
	BEGIN
		IF (le_cenario = '1') THEN
			block_in <= CONV_TAB_BLK(MAPA_INICIAL(addr));
		ELSE
			block_in <= BLK_PATH; --Caso que a moeda é comida pelo pacman
		END IF;
	END PROCESS;
	
	led_vidas: PROCESS (q_vidas)
	BEGIN
		IF (q_vidas = 3) THEN
			vidas_arr <= "111";
		ELSIF (q_vidas = 2) THEN
			vidas_arr <= "011";
		ELSIF (q_vidas = 1) THEN
			vidas_arr <= "001";
		ELSE
			vidas_arr <= "000";
		END IF;
	END PROCESS led_vidas;
	
	LEDR <= vidas_arr;
    
    -----------------------------------------------------------------------------
    -- Processos que definem a FSM principal. Alguns sinais de controle são definidos
    -- apenas para um estado e portanto estão localizados no process seguinte
    -- type   : combinational
    logica_mealy: PROCESS (estado, fim_varredura, timer, long_timer, q_rem_moedas, q_vidas,
                           col, line, pac_pos_x, pac_pos_y, pacman_dead, reg_coin_we, fan_died)
    BEGIN
        case estado is
        when CARREGA_MAPA  => IF (fim_varredura = '1') THEN -- Estado CARREGA_MAPA:
							pr_estado <= ESTADO_INICIAL;    -- Percorre linhas e colunas escrevendo o 
						ELSE								-- conteúdo do cenário inicial na memória.
							pr_estado <= CARREGA_MAPA;      -- Usado para (re)inicializar o jogo inteiro
						END IF;
						line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '1';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr           <= col + SCR_WDT*line;
                        
		when REINICIO  => IF (long_timer = '1') THEN        -- Estado REINICIO:
							pr_estado <= ESTADO_INICIAL;    -- Aguarda um intervalo de alguns segundos antes
						ELSE                                -- de voltar o jogo ao normal. Além disso, ativa
							pr_estado <= REINICIO;          -- o sinal restartn para reinicializar os dados
						END IF;                             -- necessários. O pacman e os fantasmas voltam às
                        line_rstn      <= '1';              -- suas posições originais mas as moedas do mapa
                        line_enable    <= '1';              -- e a pontuação permanecem.
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '1';
                        timer_enable   <= '1';
                        addr           <=  0;
                        
		when FIM_JOGO  => pr_estado <= FIM_JOGO;            -- Estado FIM_JOGO:
                        line_rstn      <= '1';              -- Não realiza ação e fica ocioso nesse estado.
                        line_enable    <= '1';              -- O jogo acabou (as vidas do pacman se esgotaram
                        col_rstn       <= '1';              -- ou este comeu todas as moedas do mapa).
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '0'; 
                        timer_enable   <= '0';
                        addr           <=  0;
                        
        when ESTADO_INICIAL  => IF (timer = '1') THEN       -- Estado ESTADO_INICIAL:
                            pr_estado <= PERCORRE_QUADRO;   -- Primeiro estado durante operação normal do jogo
                        ELSE                                -- Responsável pelo atraso principal da animação,
                            pr_estado <= ESTADO_INICIAL;    -- após o qual será feita a varredura no estado do
                        END IF;                             -- cenário.
                        line_rstn      <= '0';  
                        line_enable    <= '0';
                        col_rstn       <= '0';  
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1';  
                        timer_enable   <= '1';
                        addr           <= 0;

        when PERCORRE_QUADRO => IF (fim_varredura = '1') THEN -- Estado PERCORRE_QUADRO:
                            pr_estado <= ATUALIZA_LOGICA_1;   -- Varre a memória de cenário, lendo as regiões vizinhas
                        ELSE                                  -- dos objetos e, ao mesmo tempo, escrevendo as posições
                            pr_estado <= PERCORRE_QUADRO;     -- atuais dos mesmos na memória de overlay.
                        END IF;
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr           <= col + SCR_WDT*line;
                        
        when ATUALIZA_LOGICA_1 => IF (pacman_dead = '1') THEN -- Estado ATUALIZA_LOGICA_1:
							IF (q_vidas = 0) THEN             -- Faz as checagens fundamentais de final de jogo ou
								pr_estado <= FIM_JOGO;        -- reinício, além de habilitar o próximo movimento
							ELSE                              -- do pacman.
								pr_estado <= REINICIO;
							END IF;
						ELSIF (q_rem_moedas <= 0) THEN
							pr_estado <= FIM_JOGO;
						ELSE
							pr_estado <= ATUALIZA_LOGICA_2;
						END IF;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
                        
		when ATUALIZA_LOGICA_2 => pr_estado <= MEMORIA_WR; -- Estado ATUALIZA_LOGICA_2:
						line_rstn      <= '1';             -- Habilita o próximo movimento dos fantasmas.
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
      
        when MEMORIA_WR => pr_estado <= ESTADO_INICIAL;   -- Estado MEMORIA_WR:
						line_rstn      <= '0';            -- Escreve apenas um bloco que é o novo valor da célula
                        line_enable    <= '0';            -- atual do pacman na memória de cenário. Isso pode apagar
                        col_rstn       <= '0';            -- a moeda que havia sob o pacman se ela foi comida.
                        col_enable     <= '0';
                        we             <= reg_coin_we; 
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= pac_pos_x + SCR_WDT * pac_pos_y;
                        
		when others  => pr_estado <= CARREGA_MAPA;
                        line_rstn      <= '0';
                        line_enable    <= '0';
                        col_rstn       <= '0';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1'; 
                        timer_enable   <= '0';
                        addr           <= 0;
        END case;
    END PROCESS logica_mealy;
    
    -- Define sinais de controle da FSM usados em apenas UM ESTADO
    -- type: combinational
    sinais_extras: PROCESS (estado, atua_en)
	BEGIN
		IF (estado = PERCORRE_QUADRO) 
		THEN varre_tela <= '1';
		ELSE varre_tela <= '0';
		END IF;
		
		IF (estado = CARREGA_MAPA)
		THEN le_cenario <= '1';
		ELSE le_cenario <= '0';
		END IF;
		
		IF (estado = REINICIO) 
		THEN restartn <= '0';
		ELSE restartn <= '1';
		END IF;
		
		IF (estado = ATUALIZA_LOGICA_2)
		THEN fan_atua <= '1';
		ELSE fan_atua <= '0';
		END IF;
		
		IF (estado = ATUALIZA_LOGICA_1) 
		THEN pac_atua <= '1';
		ELSE pac_atua <= '0';
		END IF;
		
		IF (estado = FIM_JOGO) 
		THEN endgame <= '1';
		ELSE endgame <= '0';
		END IF;
		
		IF (estado = MEMORIA_WR)
		THEN update_info <= '1';
		ELSE update_info <= '0';
		END IF;
	END PROCESS;

    -- Avança a FSM para o próximo estado
    -- type   : sequential
    seq_fsm: PROCESS (clk27M, rstn)
    BEGIN 
        IF (rstn = '0') THEN                
            estado <= SHOW_SPLASH;
        elsif (clk27M'event and clk27M = '1') THEN 
            estado <= pr_estado;
        END IF;
    END PROCESS seq_fsm;
    
    -- Atualiza contadores de número de atualizações
	-- Gera enables de atualizações para cada velocidade de atualização
    -- type: sequential
    atual_counters: PROCESS (clk27M, rstn)
		VARIABLE atual_cont: t_vet_velocs;
	BEGIN
		IF (rstn = '0') THEN
			atual_cont := (OTHERS => 0);
            sig_blink  <= (OTHERS => '0');
		ELSIF (clk27M'event and clk27M = '1') THEN
			IF (estado = ATUALIZA_LOGICA_2) THEN
				FOR i IN 0 to VEL_NO-1 LOOP
					IF (atual_cont(i) = VEL_DIV(i)-1) THEN
						atual_cont(i) := 0;
						atua_en(i) <= '1';
					ELSE
						atual_cont(i) := atual_cont(i) + 1;
						atua_en(i) <= '0';
					END IF;
				END LOOP;
				sig_blink <= sig_blink + 1;
			END IF;
		END IF;
	END PROCESS;
	
	-- Easter egg! :)
	PROCESS (clk27M, rstn)
		VARIABLE hit_count: INTEGER := 0;
	BEGIN
		IF (rstn = '0') THEN
			hit_count := 0;
			nwc <= '0';
		ELSIF (clk27M'event and clk27M = '1') THEN
			IF (pac_pos_x = TELE_ESQ_POS or pac_pos_x = TELE_DIR_POS) THEN
				hit_count := hit_count + 1;
			ELSIF (atua_en(4) = '1') THEN 
				hit_count := hit_count - 1;
			END IF;
			
			IF (hit_count = 5) THEN
				nwc <= '1'; -- WARNING: no wall collisions!!
			END IF;
		END IF;
	END PROCESS;

    -- Contadores utilizados para atrasar a animação (evitar
    -- que a atualização de quadros fique muito veloz).
    p_contador0: COMPONENT counter 
        PORT MAP (clk 	=> clk27M,
		          rstn 	=> timer_rstn,
		          en	=> timer_enable,
				  max	=> DIV_FACT - 1,
				  q		=> contador);
	
	p_contador1: COMPONENT counter
        PORT MAP (clk 	=> clk27M,
		          rstn 	=> timer_rstn, --mesmo reset do contador 0, porém
		          en	=> timer, --contagem a cada término do contador 0
				  max	=> 127,
				  q		=> long_cont);
                  
    --O sinal "timer" indica a hora de fazer nova atualização
    timer <= '1' WHEN (contador = DIV_FACT - 1)
    ELSE     '0';
   
    --Timer para mostrar um evento na tela
    long_timer <= '1' WHEN (long_cont = 127)
    ELSE     '0';
    
    -- Processos que sincronizam o reset assíncrono, de preferência com mais
    -- de 1 flipflop, para evitar metaestabilidade.
    -- type   : sequential
    build_rstn: PROCESS (clk27M)
        VARIABLE temp : STD_LOGIC;          -- flipflop intermediario
    BEGIN  
        IF (clk27M'event and clk27M = '1') THEN  
            rstn <= temp;
            temp := reset_button;     
        END IF;
    END PROCESS build_rstn;
END comportamento;
