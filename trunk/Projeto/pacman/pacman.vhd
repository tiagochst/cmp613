LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;

ENTITY pacman is
  PORT (
    clk27M, reset_button      : in  STD_LOGIC;
    red, green, blue          : out STD_LOGIC_vector(3 downto 0);
    hsync, vsync              : out STD_LOGIC);
END pacman;

ARCHITECTURE comportamento of pacman is
    SIGNAL rstn : STD_LOGIC;                        -- reset active low
                                        
    -- Interface com a memória de vídeo do controlador
    SIGNAL we : STD_LOGIC;                          -- write enable ('1' p/ escrita)
    SIGNAL addr : INTEGER 
                  range 0 to SCR_HGT*SCR_WDT-1;     -- ENDereco mem. vga
    SIGNAL pixel : color3;                          -- valor de cor do pixel

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
    SIGNAL fim_memarea : STD_LOGIC;					-- término da leitura de mem_area

    -- Especificação dos tipos e sinais da máquina de estados de controle
    TYPE estado_t is (SHOW_SPLASH, INICIO, CONSTROI_QUADRO,
                      MEMORIA_RD, ATUALIZA_LOGICA, MEMORIA_WR);
    SIGNAL estado: estado_t := SHOW_SPLASH;
    SIGNAL pr_estado: estado_t := SHOW_SPLASH;
    
    -- Sinais de desenho em overlay sobre o cenário do jogo
    SIGNAL overlay: STD_LOGIC;
    SIGNAL ovl_color: color3;

    -- Sinais para um contador utilizado para atrasar 
    -- a frequência da atualização
    SIGNAL contador : INTEGER range 0 to DIV_FACT-1;
    SIGNAL timer : STD_LOGIC;                       -- vale '1' quando o contador chegar ao fim
    SIGNAL timer_rstn, timer_enable : STD_LOGIC;
    
    SIGNAL mem_area: tab_sym_3x3;
    SIGNAL mem_line: INTEGER range 0 to SCR_HGT-1;
    SIGNAL mem_col: INTEGER range 0 to SCR_WDT-1;
    SIGNAL mem_we: STD_LOGIC;
    SIGNAL mem_write_cel, mem_read_cel: tab_sym;
    
    COMPONENT counter IS
	PORT (clk, rstn, en: IN STD_LOGIC;
	      max: IN INTEGER;
	      q: OUT INTEGER);
	END COMPONENT counter;
	
	COMPONENT mem_mapa IS
	PORT (clk: IN STD_LOGIC;
		  y_cor: IN INTEGER range 0 to SCR_HGT - 1;
		  x_cor: IN INTEGER range 0 to SCR_WDT - 1;
		  data: IN tab_sym;
		  we: IN STD_LOGIC;
		  q: OUT tab_sym);
	END COMPONENT mem_mapa;

    -----------------------------------------------------------------------------
    -- Sinais de controle da lógica do jogo
    -----------------------------------------------------------------------------
    SIGNAL got_coin: STD_LOGIC;                     -- informa se obteve moeda no ultimo movimento
    SIGNAL key_pac_esq, key_pac_dir: STD_LOGIC := '0';     -- sinais síncronos do cursor do usuário
    SIGNAL pac_pos_x: INTEGER range 0 to TAB_LEN-1 := PAC_START_X;
    SIGNAL pac_pos_y: INTEGER range 0 to TAB_LEN-1 := PAC_START_Y;
    SIGNAL pac_cur_dir: INTEGER range 0 to 3:= 1;
    
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
        red          => red,
        green        => green,
        blue         => blue,
        hsync        => hsync,
        vsync        => vsync,
        write_clk    => clk27M,
        write_enable => we,
        write_addr   => addr,
        data_in      => pixel);

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
                   
    fim_memarea <= '1' WHEN (line = 2) and (col = 2)
				  ELSE '0';
				  
	-----------------------------------------------------------------------------
    -- Controladores da RAM que armazena o mapa atual
    -----------------------------------------------------------------------------
				  
	ram_mapa: COMPONENT mem_mapa
		PORT MAP (clk 	=> clk27M,
		          y_cor	=> mem_line, x_cor => mem_col,
		          data => mem_write_cel, 
		          we => (mem_we and got_coin),
		          q => mem_read_cel);
		          
	mem_line <= pac_pos_y WHEN (estado = ATUALIZA_LOGICA)
                ELSE line;
    mem_col  <= pac_pos_x WHEN (estado = ATUALIZA_LOGICA)
                ELSE col;
    mem_we   <= '1' WHEN (estado = MEMORIA_WR)
				ELSE '0';
	
	-- purpose: Preenche a matriz 3x3 mem_area no estado MEMORIA_RD
    -- type   : sequential
    -- inputs : clk27M, rstn, mem_area, line, col, estado
    -- outputs: mem_area
    p_fill_memarea: PROCESS (clk27M, rstn, line, col)
	BEGIN
		IF (clk27M'event and clk27M='1') THEN
			IF (estado = MEMORIA_RD) THEN
				mem_area(line-1, col-1) <= mem_read_cel;
			END IF;
		END IF;
	END PROCESS; 

    -- purpose: Este processo irá atualizar a posicão do pacman e definir
    --          suas ações no jogo. Opera nos estados atualiza*
    -- type   : sequential
    -- inputs : clk27M, rstn, mem_area, key_pac_dir, key_pac_esq
    --          pac_cur_dir, pac_pos_x, pac_pos_y
    -- outputs: pac_cur_dir, pac_pos_x, pac_pos_y, got_coin
    p_atualiza_pacman: PROCESS (clk27M, rstn, key_pac_dir, key_pac_esq, mem_area,
	                            pac_pos_x, pac_pos_y, pac_cur_dir)
        VARIABLE esq_dir, dir_dir: INTEGER range 0 to 3 := 3;
        VARIABLE nxt_cel, dir_cel, esq_cel: tab_sym;
    BEGIN
		IF (pac_cur_dir = 3)
		THEN dir_dir := 0;
		ELSE dir_dir := pac_cur_dir + 1;
		END IF;
		
		IF (pac_cur_dir = 0)
		THEN esq_dir := 3;
		ELSE esq_dir := pac_cur_dir - 1;
		END IF;
		
		--calcula qual seriam as proximas celulas visitadas pelo pacman
		nxt_cel := mem_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1));
		dir_cel := mem_area(DIRS(dir_dir)(0), DIRS(dir_dir)(1));
		esq_cel := mem_area(DIRS(esq_dir)(0), DIRS(esq_dir)(1));
		        
        IF (rstn = '0') THEN
            pac_pos_x <= PAC_START_X;
            pac_pos_y <= PAC_START_Y;
            pac_cur_dir <= 1; --inicializa direcao para direita
        ELSIF (clk27M'event and clk27M = '1') THEN
            IF (estado = ATUALIZA_LOGICA) THEN
                IF (nxt_cel = '.' or nxt_cel = '2') THEN --atualiza posicao
                    pac_pos_x <= pac_pos_x + DIRS(pac_cur_dir)(1);
                    pac_pos_y <= pac_pos_y + DIRS(pac_cur_dir)(0);
                END IF;
                
                IF (nxt_cel = '2') THEN --checa se obteve moeda                    
                    got_coin <= '1';
                    mem_write_cel <= ' ';
                ELSE
                    got_coin <= '0';
                END IF;
                
                --atualizar direcao do pacman
                IF (key_pac_dir = '1' and dir_cel = '.') THEN 
                    pac_cur_dir <= dir_dir;
                ELSIF (key_pac_esq = '1' and esq_cel = '.') THEN
                    pac_cur_dir <= esq_dir;
                END IF;
            END IF;
        END IF;
	END PROCESS;
	
	-- purpose: Processo para que gera sinais de desenho de 
	--			overlay (ie, sobre o fundo) do pacman e dos fantasmas 
    -- type   : sequential
    -- inputs : pac_cur_dir, pac_pos_x, pac_pos_y
    -- outputs: overlay, ovl_color
	des_overlay: PROCESS (clk27M, pac_pos_x, pac_pos_y, pac_cur_dir, line, col)
		VARIABLE x_offset, y_offset: INTEGER range -TAB_LEN to TAB_LEN;
    BEGIN
        --Sinais para desenho do pacman na tela durante CONSTROI_QUADRO
        y_offset := line - pac_pos_y + 2;
        x_offset := col - pac_pos_x + 2;
        
        IF (clk27M'event and clk27M = '1') THEN
            IF (x_offset>=0 and x_offset<5 and 
                y_offset>=0 and y_offset<5) THEN
                
                overlay <= '1';  --desenha camada sobre o cenario
                IF (PAC_BITMAPS(pac_cur_dir)(y_offset, x_offset) = '1') THEN
                    ovl_color <= "110"; --amarelo
                ELSE
					ovl_color <= "000"; --cor de fundo
                END IF;
            ELSE
                overlay <= '0';
            END IF;
        END IF;
    END PROCESS;

    -----------------------------------------------------------------------------
    -- Brilho do pixel
    -----------------------------------------------------------------------------

    pixel <= ovl_color WHEN overlay = '1'
    ELSE     COLORS(1) WHEN mem_area(0,0) = '1'
    ELSE     COLORS(2) WHEN mem_area(0,0) = '2'
    ELSE     COLORS(3) WHEN mem_area(0,0) = '3'
    ELSE     COLORS(0);

    addr  <= col + (SCR_WDT * line); -- O endereço de memória a ser escrito

    -----------------------------------------------------------------------------
    -- Processos que definem a FSM (finite state machine), nossa máquina
    -- de estados de controle.
    -----------------------------------------------------------------------------

    -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
    --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
    -- type   : combinational
    -- inputs : estado, fim_escrita, timer
    -- outputs: pr_estado, atualiza_pos_x, atualiza_pos_y, line_rstn,
    --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
    logica_mealy: PROCESS (estado, fim_escrita, fim_memarea, timer)
    BEGIN
        case estado is
        when INICIO  => IF timer = '1' THEN              
                            pr_estado <= CONSTROI_QUADRO;
                        ELSE
                            pr_estado <= INICIO;
                        END IF;
                        line_rstn      <= '0';  -- reset é active low!
                        line_enable    <= '0';
                        col_rstn       <= '0';  -- reset é active low!
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1';  -- reset é active low!
                        timer_enable   <= '1';

        when CONSTROI_QUADRO => IF (fim_escrita = '1') THEN
                            pr_estado <= MEMORIA_RD;
                        ELSE
                            pr_estado <= CONSTROI_QUADRO;
                        END IF;
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '1';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';

        when MEMORIA_RD => IF (fim_memarea = '1') THEN
							pr_estado <= ATUALIZA_LOGICA;
						ELSE
							pr_estado <= MEMORIA_RD;
						END IF;
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        
        when ATUALIZA_LOGICA => pr_estado <= MEMORIA_WR;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
      
        when MEMORIA_WR => pr_estado <= INICIO;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        
		when others  => pr_estado <= INICIO;
                        line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1'; 
                        timer_enable   <= '0';
        END case;
    END PROCESS logica_mealy;

    -- purpose: Avança a FSM para o próximo estado
    -- type   : sequential
    -- inputs : clk27M, rstn, pr_estado
    -- outputs: estado
    seq_fsm: PROCESS (clk27M, rstn)
    BEGIN  -- PROCESS seq_fsm
        IF rstn = '0' THEN                  -- asynchronous reset (active low)
            estado <= INICIO;
        elsif clk27M'event and clk27M = '1' THEN  -- rising clock edge
            estado <= pr_estado;
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
        IF clk27M'event and clk27M = '1' THEN  -- rising clock edge
            rstn <= temp;
            temp := reset_button;      
        END IF;
    END PROCESS build_rstn;
    
END comportamento;
