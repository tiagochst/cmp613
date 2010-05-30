LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;

ENTITY pacman is
  PORT (
    clk27M, reset_button      : in  STD_LOGIC;
    red, green, blue          : out STD_LOGIC_vector(3 downto 0);
    hsync, vsync              : out STD_LOGIC;
    LEDG  : BUFFER STD_LOGIC_VECTOR (7 downto 5);   --   LED Green
    PS2_DAT : inout STD_LOGIC;                      --   PS2 Data
    PS2_CLK : inout STD_LOGIC	                    --   PS2 Clock
    );
END pacman;

ARCHITECTURE comportamento of pacman is
    SIGNAL rstn : STD_LOGIC;                        -- reset active low
                                        
    -- Interface com a mem�ria de v�deo do controlador
    SIGNAL we : STD_LOGIC;                          -- write enable ('1' p/ escrita)
    SIGNAL addr : INTEGER 
                  range 0 to SCR_HGT*SCR_WDT-1;     -- ENDereco mem. vga
    SIGNAL block_in, block_out : block3;            -- dados trocados com a mem. vga
    SIGNAL vga_block_out: block3;

    -- Sinais dos contadores de linhas e colunas utilizados para percorrer
    -- as posi��es da mem�ria de v�deo (pixels) no momento de construir um quadro.
    SIGNAL line : INTEGER range 0 to SCR_HGT-1;     -- linha atual
    SIGNAL col : INTEGER range 0 to SCR_WDT-1;      -- coluna atual
    SIGNAL col_rstn : STD_LOGIC;                    -- reset do contador de colunas
    SIGNAL col_enable : STD_LOGIC;                  -- enable do contador de colunas
    SIGNAL line_rstn : STD_LOGIC;                   -- reset do contador de linhas
    SIGNAL line_enable, line_inc : STD_LOGIC;       -- enable do contador de linhas
    SIGNAL fim_escrita : STD_LOGIC;                 -- '1' quando um quadro terminou de ser
                                                    -- escrito na mem�ria de v�deo

    -- Especifica��o dos tipos e sinais da m�quina de estados de controle
    TYPE estado_t is (SHOW_SPLASH, CARREGA_MAPA, INICIO_JOGO, PERCORRE_QUADRO,
                      ATUALIZA_LOGICA, MEMORIA_WR);
    SIGNAL estado: estado_t := SHOW_SPLASH;
    SIGNAL pr_estado: estado_t := SHOW_SPLASH;
    
    -- Sinais de desenho em overlay sobre o cen�rio do jogo
    SIGNAL overlay: STD_LOGIC;
    SIGNAL ovl_in: block3;

    -- Sinais para um contador utilizado para atrasar 
    -- a frequ�ncia da atualiza��o
    SIGNAL contador : INTEGER range 0 to DIV_FACT-1;
    SIGNAL timer : STD_LOGIC;                       -- vale '1' quando o contador chegar ao fim
    SIGNAL timer_rstn, timer_enable : STD_LOGIC;
    
    SIGNAL mem_area: tab_sym_3x3;
	SIGNAL code: tab_sym;
    
    COMPONENT counter IS
	PORT (clk, rstn, en: IN STD_LOGIC;
	      max: IN INTEGER;
	      q: OUT INTEGER);
	END COMPONENT counter;
	
	FUNCTION walkable(s: tab_sym)
		RETURN boolean IS
	BEGIN
		IF (s = '.' or s = '2') THEN RETURN true;
		ELSE RETURN false;
		END IF;
	END FUNCTION;


    -----------------------------------------------------------------------------
    -- Sinais de controle da l�gica do jogo
    -----------------------------------------------------------------------------
    SIGNAL got_coin: STD_LOGIC;                     -- informa se obteve moeda no ultimo movimento
    SIGNAL key_pac_esq, key_pac_dir: STD_LOGIC;     -- sinais s�ncronos do cursor do usu�rio
    SIGNAL pac_pos_x: INTEGER range 0 to TAB_LEN-1 := PAC_START_X;
    SIGNAL pac_pos_y: INTEGER range 0 to TAB_LEN-1 := PAC_START_Y;
    SIGNAL pac_cur_dir: t_direcao;
 	SIGNAL nxt_cel, dir_cel, esq_cel, cim_cel, bai_cel: tab_sym;
	SIGNAL p1_dir,p2_dir: t_direcao; -- sinais lidos pelo teclado
    
BEGIN
    -- Controlador VGA (resolu��o 128 colunas por 96 linhas)
    -- Sinais:(aspect ratio 4:3). Os sinais que iremos utilizar para comunicar
    -- - write_clk (nosso clock)
    -- - write_enable ('1' quando queremos escrever um pixel)
    -- - write_addr (ENDere�o do pixel a escrever)
    -- - data_in (brilho do pixel RGB, 1 bit pra cada componente de cor)
    vga_controller: entity work.vgacon port map (
        clk27M       => clk27M,
        rstn         => '1',
        vga_block    => vga_block_out,
        data_block   => block_out,
        hsync        => hsync,
        vsync        => vsync,
        write_clk    => clk27M,
        write_enable => we,
        write_addr   => addr,
        data_in      => block_in,
        ovl_in       => ovl_in,
        ovl_we       => overlay);	
        
    red   <= RED_CMP(to_integer(unsigned(vga_block_out)));
	green <= GRN_CMP(to_integer(unsigned(vga_block_out)));
	blue  <= BLU_CMP(to_integer(unsigned(vga_block_out)));
	
	-- Controlador do teclado. Devolve os sinais s�ncronos das teclas
	-- de interesse pressionadas ou n�o.
	kbd: ENTITY WORK.kbd_key PORT MAP (
		CLOCK_27 => clk27M,
		KEY      => reset_button,
		LEDG     => LEDG(7 downto 5),
		PS2_DAT  => PS2_DAT,
		PS2_CLK  => PS2_CLK,
		p1_dir   => p1_dir,
		p2_dir   => p2_dir
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
    
    -- o contador de linha s� incrementa quando o contador de colunas
    -- chegou ao fim
    line_inc <= '1' WHEN (line_enable='1' and col = SCR_WDT-1)
    ELSE        '0';
				  
	conta_linha: COMPONENT counter
		PORT MAP (clk 	=> clk27M,
		          rstn 	=> line_rstn,
		          en	=> line_inc,
				  max	=> SCR_HGT-1,
				  q		=> line);
    
    -- podemos avan�ar para o pr�ximo estado?
    fim_escrita <= '1' WHEN (line = SCR_HGT-1) and (col = SCR_WDT-1)
                   ELSE '0';
				  
	PROCESS (block_out)
	BEGIN
		CASE block_out IS
			WHEN "000"  => code <= ' ';
			WHEN "001"  => code <= '.';
			WHEN "010"  => code <= '1';
			WHEN "011"  => code <= '2';
			WHEN "100"  => code <= '3';
			WHEN OTHERS => code <= ' '; 
		END CASE;
	END PROCESS;
	
	-- purpose: Preenche a matriz 3x3 mem_area no estado MEMORIA_RD
    -- type   : sequential
    -- inputs : clk27M, rstn, mem_area, line, col, estado
    -- outputs: mem_area
    p_fill_memarea: PROCESS (clk27M)
		VARIABLE x_offset, y_offset: INTEGER range -TAB_LEN to TAB_LEN;
	BEGIN
		IF (clk27M'event and clk27M='1') THEN
			IF (estado = PERCORRE_QUADRO) THEN
				--Leitura atrasada devido ao ciclo de clock da ram
				y_offset := line - pac_pos_y;
				x_offset := col - pac_pos_x;
				IF (x_offset >=0 and x_offset <=2 and y_offset >=-1 and y_offset<=1) THEN
					mem_area(y_offset, x_offset-1) <= code;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	--Calcula poss�veis par�metros envolvidos no pr�ximo movimento
	--do pacman
	PROCESS (pac_cur_dir, mem_area)
	BEGIN
		--calcula qual seriam as proximas celulas visitadas pelo pacman
		nxt_cel <= mem_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1));
		dir_cel <= mem_area(0,1);
		esq_cel <= mem_area(0,-1);
		cim_cel <= mem_area(-1,0);
		bai_cel <= mem_area(1,0);
	END PROCESS;

    -- purpose: Este processo ir� atualizar a posic�o do pacman e definir
    --          suas a��es no jogo. Opera no estado ATUALIZA_LOGICA
    -- type   : sequential
    -- inputs : clk27M, rstn, mem_area, key_pac_dir, key_pac_esq
    --          pac_cur_dir, pac_pos_x, pac_pos_y
    -- outputs: pac_cur_dir, pac_pos_x, pac_pos_y, got_coin
    p_atualiza_pacman: PROCESS (clk27M, rstn)
		VARIABLE nxt_move, p1_dir_old: t_direcao;
    BEGIN
        IF (rstn = '0') THEN
            pac_pos_x <= PAC_START_X;
            pac_pos_y <= PAC_START_Y;
			pac_cur_dir <= DIREI; --inicializa direcao para direita
			nxt_move := NADA;
        ELSIF (clk27M'event and clk27M = '1') THEN
             IF (estado = ATUALIZA_LOGICA) THEN
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
				
				IF (nxt_move = CIMA and walkable(cim_cel)) THEN
					pac_cur_dir <= CIMA;
					nxt_move := NADA;
				ELSIF (nxt_move = DIREI and walkable(dir_cel)) THEN
					pac_cur_dir <= DIREI;
					nxt_move := NADA;
				ELSIF (nxt_move = BAIXO and walkable(bai_cel)) THEN
					pac_cur_dir <= BAIXO;
					nxt_move := NADA;
				ELSIF (nxt_move = ESQUE and walkable(esq_cel)) THEN
					pac_cur_dir <= ESQUE;
					nxt_move := NADA;
                ELSIF (walkable(nxt_cel)) THEN --atualiza posicao
					IF(pac_pos_x = 82) then
						pac_pos_x <= 3;
					ELSIF(pac_pos_x = 2) then
						pac_pos_x <= 81;
					ELSE
						pac_pos_x <= pac_pos_x + DIRS(pac_cur_dir)(1);
						pac_pos_y <= pac_pos_y + DIRS(pac_cur_dir)(0);
					END IF;
                 END IF;
                
                IF (nxt_cel = '2') THEN --checa se obteve moeda                    
                    got_coin <= '1';
                ELSE
                    got_coin <= '0';
                END IF;
                p1_dir_old := p1_dir;
            END IF;
        END IF;
	END PROCESS;
	
	-- purpose: Processo para que gera sinais de desenho de 
	--			overlay (ie, sobre o fundo) do pacman e dos fantasmas 
    -- type   : combinational
    des_overlay: PROCESS (pac_pos_x, pac_pos_y, pac_cur_dir, estado, line, col)
		VARIABLE x_offset, y_offset: INTEGER range -TAB_LEN to TAB_LEN;
    BEGIN
        --Sinais para desenho do pacman na tela durante PERCORRE_QUADRO
        y_offset := line - pac_pos_y + 2;
        x_offset := col - pac_pos_x + 2;
        
        if (pac_pos_y = line and pac_pos_x = col) THEN
			ovl_in <= "101";
		ELSE
			ovl_in <= "000";
		END IF;
        
		IF (x_offset>=0 and x_offset<5 and 
			y_offset>=0 and y_offset<5) THEN                
			IF (PAC_BITMAPS(pac_cur_dir)(y_offset, x_offset) = '1') THEN
				ovl_in <= "101";
			ELSE
				ovl_in <= "000";
			END IF;
		ELSE
			ovl_in <= "000";
		END IF;
    END PROCESS;

    -- Define dado que entra na ram
	def_block_in: PROCESS (estado, addr)
	BEGIN
		IF (estado = CARREGA_MAPA) THEN
			CASE MAPA_INICIAL(addr) IS
				WHEN ' '    => block_in <= "000";
				WHEN '.'    => block_in <= "001";
				WHEN '1' 	=> block_in <= "010";
				WHEN '2'    => block_in <= "011";
				WHEN '3'	=> block_in <= "100";
			END CASE;
		ELSE	 
			block_in <= "001";
		END IF;
	END PROCESS;

    -----------------------------------------------------------------------------
    -- Processos que definem a FSM (finite state machine), nossa m�quina
    -- de estados de controle.
    -----------------------------------------------------------------------------

    -- purpose: Esta � a l�gica combinacional que calcula sinais de sa�da a partir
    --          do estado atual e alguns sinais de entrada (M�quina de Mealy).
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
                        line_rstn      <= '0';  -- reset � active low!
                        line_enable    <= '0';
                        col_rstn       <= '0';  -- reset � active low!
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1';  -- reset � active low!
                        timer_enable   <= '1';
                        addr           <= 0;
                        overlay         <= '0';

        when PERCORRE_QUADRO => IF (fim_escrita = '1') THEN
                            pr_estado <= ATUALIZA_LOGICA;
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
                        overlay         <= '1';
                        
        when ATUALIZA_LOGICA => pr_estado <= MEMORIA_WR;
						line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= 0;
                        overlay         <= '0';
      
        when MEMORIA_WR => pr_estado <= INICIO_JOGO;
						line_rstn      <= '0';
                        line_enable    <= '0';
                        col_rstn       <= '0';
                        col_enable     <= '0';
                        we             <= got_coin; 
                        timer_rstn     <= '0';
                        timer_enable   <= '0';
                        addr		   <= pac_pos_x + SCR_WDT * pac_pos_y;
                        overlay         <= '0';
                        
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

    -- purpose: Avan�a a FSM para o pr�ximo estado
    -- type   : sequential
    -- inputs : clk27M, rstn, pr_estado
    -- outputs: estado
    seq_fsm: PROCESS (clk27M, rstn)
    BEGIN  -- PROCESS seq_fsm
        IF rstn = '0' THEN                  -- asynchronous reset (active low)
            estado <= SHOW_SPLASH;
        elsif clk27M'event and clk27M = '1' THEN  -- rising clock edge
            estado <= pr_estado;
        END IF;
    END PROCESS seq_fsm;

    -----------------------------------------------------------------------------
    -- Contador utilizado para atrasar a anima��o (evitar
    -- que a atualiza��o de quadros fique muito veloz).
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
    -- Processos que sincronizam sinais ass�ncronos, de prefer�ncia com mais
    -- de 1 flipflop, para evitar metaestabilidade.
    -----------------------------------------------------------------------------
    -- purpose: Aqui sincronizamos nosso sinal de reset vindo do bot�o da DE1
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
