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
    SIGNAL load_cenario: STD_LOGIC;				   -- Informa quando o cenário está sendo recarregado
                                        
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
                      ATUALIZA_LOGICA_1, ATUALIZA_LOGICA_2, ATUALIZA_LOGICA_3, MEMORIA_WR,
                      REINICIO, FIM_JOGO, PACMAN_VENCE);
    SIGNAL estado: estado_t := SHOW_SPLASH;
    SIGNAL pr_estado: estado_t := SHOW_SPLASH;
    
    -- sinais que servem como enable de várias velocidades
    SIGNAL atua_en: STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL display_en: STD_LOGIC;
    SIGNAL disp_count: INTEGER range 0 to 4194304;
    SIGNAL sig_blink: UNSIGNED(6 downto 0); -- enables com duty de 50%
                                                    
    -- Sinais de desenho em overlay sobre o cenário do jogo
    SIGNAL overlay: STD_LOGIC;
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
   
    -- Controle do pacman
    SIGNAL pac_pos_x: t_pos := PAC_START_X;
    SIGNAL pac_pos_y: t_pos := PAC_START_Y;
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
		p1_dir    => pac_key_dir,
		p2_dir    => fan_key_dir(0),
		p3_dir    => fan_key_dir(1)
    );
    
	disp_counter: COMPONENT counter
        PORT MAP (clk 	=> clk27M,
		          rstn 	=> '1',
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
    fim_escrita <= '1' WHEN (line = SCR_HGT-1) and (col = SCR_WDT-1)
                   ELSE '0';
                   
	-- Controlador dos fantasmas
	ctrl_fans_inst: ENTITY work.ctrl_fans PORT MAP (
		clk27M 		=> clk27M, 			rstn 		=> rstn and restartn,
		atualiza 	=> fan_atua, 		atua_en 	=> atua_en,
		keys_dir 	=> fan_key_dir,		fan_died	=> fan_died,
		fan_area 	=> fan_area,		pacman_dead => pacman_dead,
		spc_coin	=> got_spc_coin,	pac_fans_hit=> pac_fans_hit,
		fan_pos_x 	=> fan_pos_x, 		fan_pos_y 	=> fan_pos_y,
		fan_state	=> fan_state, 		fan_cur_dir => fan_cur_dir
	);
	
	-- Controlador do pacman
	ctrl_pac_inst: ENTITY work.ctrl_pacman PORT MAP (
		clk27M		=> clk27M,			rstn		=> rstn and restartn,
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
	
	-- Atualiza parâmetros de informação atual do jogo
	-- type: sequential
	param_jogo: PROCESS (clk27M, rstn)
	BEGIN
		IF (rstn = '0') THEN
			q_vidas <= 3;
			q_pontos <= 0;
			q_rem_moedas <= 240;
		ELSIF (clk27M'event and clk27M = '1') THEN
			IF (pacman_dead = '1' and fan_atua = '1') THEN--estado = fan_atua) THEN
				q_vidas <= q_vidas - 1;
			END IF;

			IF (fan_died = '1') THEN
				q_pontos <= q_pontos + 200;
			ELSIF (pac_atua = '1' and atua_en(0) = '1') THEN
				IF (got_coin = '1') THEN
					q_pontos <= q_pontos + 10;
					q_rem_moedas <= q_rem_moedas - 1;
				ELSIF (got_spc_coin = '1') THEN
					q_pontos <= q_pontos + 50;
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
    des_overlay: PROCESS (pac_pos_x, pac_pos_y, pac_cur_dir, sig_blink, vidas_arr,
                          fan_pos_x, fan_pos_y, fan_state, fan_cur_dir, line, col)
		VARIABLE x_offset, y_offset: t_offset;
		VARIABLE ovl_blk_tmp: t_ovl_blk_sym;
    BEGIN
		ovl_blk_tmp := BLK_NULL; -- este será o bloco que vai pra VGA

		FOR i in 0 to FAN_NO-1 LOOP -- Desenho dos fantasmas
			y_offset := line - fan_pos_y(i) + 2;
			x_offset := col - fan_pos_x(i) + 2;
			IF (x_offset>=0 and x_offset<5 and 
				y_offset>=0 and y_offset<5) THEN
				IF (fan_state(i) = ST_VULN_BLINK) THEN
					IF (sig_blink(4) = '0') THEN --pisca no final do modo vulnerável
						ovl_blk_tmp := FAN_VULN_BITMAP(y_offset, x_offset);
					ELSE
						ovl_blk_tmp := BLK_NULL;
					END IF;
				ELSIF (fan_state(i) = ST_VULN) THEN
					ovl_blk_tmp := FAN_VULN_BITMAP(y_offset, x_offset);
				ELSIF (fan_state(i) = ST_DEAD) THEN
					ovl_blk_tmp := FAN_DEAD_BITMAPS(fan_cur_dir(i))(y_offset, x_offset);
				ELSE
					ovl_blk_tmp := FAN_BITMAPS(i)(fan_cur_dir(i))(y_offset, x_offset);
				END IF;
				y_offset := line - fan_pos_y(1) + 2;
			END IF;
		END LOOP;
		
		-- Desenho do pacman
		y_offset := line - pac_pos_y + 2;
        x_offset := col - pac_pos_x + 2;
		IF (x_offset>=0 and x_offset<5 and 
			y_offset>=0 and y_offset<5) THEN
			IF (sig_blink(4) = '0') THEN
				ovl_blk_tmp := PAC_BITMAPS(pac_cur_dir)(y_offset, x_offset);
			ELSE
				IF (pac_cur_dir = DIREI or pac_cur_dir = ESQUE) THEN
					ovl_blk_tmp := PAC_FECH_BITMAP(y_offset, x_offset);
				ELSE
					ovl_blk_tmp := PAC_FECV_BITMAP(y_offset, x_offset);
				END IF;
			END IF;
		END IF;
		
		FOR i in 0 to 2 LOOP --Desenho dos ícones de vida
			IF (vidas_arr(i) = '1') THEN
				y_offset := line - VIDA_ICONS_Y(i) + 2;
				x_offset := col - VIDA_ICONS_X(i) + 2;
				IF (x_offset>=0 and x_offset<5 and
				y_offset>=0 and y_offset<5) THEN
					ovl_blk_tmp := PAC_BITMAPS(DIREI)(y_offset, x_offset);
				END IF;
			END IF;
		END LOOP;
		
		ovl_blk_in <= ovl_blk_tmp;
    END PROCESS;
    
    -- Determina quando o pacman colidiu com cada um dos fantasmas
    -- type: combinational
    PROCESS (pac_pos_x, pac_pos_y, fan_pos_x, fan_pos_y)
		VARIABLE	off_x, off_y: t_offset;
	BEGIN
		FOR i in 0 to FAN_NO-1 LOOP
			off_x := pac_pos_x - fan_pos_x(i);
			off_y := pac_pos_y - fan_pos_y(i);
			-- a tolerância para colisão é uma região 3x3
			IF (off_x >=-1 and off_x <=1 and off_y>=-1 and off_y<=1) THEN
				pac_fans_hit(i) <= '1';
			ELSE
				pac_fans_hit(i) <= '0';
			END IF;
		END LOOP;
	END PROCESS;
    
    -- Define dado que entra na ram de cenário
	def_block_in: PROCESS (load_cenario, addr)
	BEGIN
		IF (load_cenario = '1') THEN
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
    logica_mealy: PROCESS (estado, fim_escrita, timer, long_timer, q_rem_moedas, q_vidas,
                           col, line, pac_pos_x, pac_pos_y, pacman_dead, reg_coin_we, fan_died)
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
                        
		when REINICIO  => IF (long_timer = '1') THEN
							pr_estado <= INICIO_JOGO;
						ELSE
							pr_estado <= REINICIO;
						END IF;
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '1';
                        timer_enable   <= '1';
                        addr           <=  0;
                        
		when FIM_JOGO  => pr_estado <= FIM_JOGO; --não sai disso
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '0'; 
                        timer_enable   <= '0';
                        addr           <=  0;
                        
		when PACMAN_VENCE => pr_estado <= PACMAN_VENCE; --não sai disso
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '0';  -- reset é active low!
                        timer_enable   <= '0';
                        addr           <=  0;

        when INICIO_JOGO  => IF (timer = '1') THEN
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
                        
        when ATUALIZA_LOGICA_1 => IF (pacman_dead = '1') THEN
							IF (q_vidas = 0) THEN
								pr_estado <= FIM_JOGO;
							ELSE
								pr_estado <= REINICIO;
							END IF;
						ELSIF (q_rem_moedas <= 0) THEN
							pr_estado <= PACMAN_VENCE;
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
                        
		when ATUALIZA_LOGICA_2 => pr_estado <= ATUALIZA_LOGICA_3;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
		
		when ATUALIZA_LOGICA_3 => pr_estado <= MEMORIA_WR;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
      
        when MEMORIA_WR => pr_estado <= INICIO_JOGO;
						line_rstn      <= '0';
                        line_enable    <= '0';
                        col_rstn       <= '0';
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
		THEN overlay <= '1';
		ELSE overlay <= '0';
		END IF;
		
		IF (estado = CARREGA_MAPA)
		THEN load_cenario <= '1';
		ELSE load_cenario <= '0';
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
				FOR i IN 0 to 2 LOOP
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
