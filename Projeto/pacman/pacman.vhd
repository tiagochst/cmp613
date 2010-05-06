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
    SIGNAL pixel_bit : STD_LOGIC;                   -- um bit do vetor acima

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
    type estado_t is (show_splash, inicio, constroi_quadro, atualiza);
    SIGNAL estado: estado_t := show_splash;
    SIGNAL pr_estado: estado_t := show_splash;

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
	
	--O cenário do jogo eh inicializado com todas as moedas e as paredes
	--As moedas vão sendo removidas dessa estrutura de acordo com o jogo
	--O pacman e os fantasmas são desenhados separadamente sob essa tela
	CONSTANT mapa: tab := (
	"                                                                                                                                ",
	"                                                                                                                                ",
	" 1111111111111111111111111111111111111111   1111111111111111111111111111111111111111                                            ",
	" 1                                      1   1                                      1                                            ",
	" 1                                      1   1                                      1                                            ",
	" 1  2..2..2..2..2..2..2..2..2..2..2..2  1   1  2..2..2..2..2..2..2..2..2..2..2..2  1                                            ",
	" 1  .              .                 .  1   1  .                 .              .  1                                            ",
	" 1  .              .                 .  1   1  .                 .              .  1                                            ",
	" 1  2  1111111111  2  1111111111111  2  1   1  2  1111111111111  2  1111111111  2  1                                            ",
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            ",
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            ",
	" 1  2  1        1  2  1           1  2  1   1  2  1           1  2  1        1  2  1                                            ",
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            ",
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            ",
	" 1  2  1111111111  2  1111111111111  2  11111  2  1111111111111  2  1111111111  2  1                                            ",
	" 1  .              .                 .         .                 .              .  1                                            ",
	" 1  .              .                 .         .                 .              .  1                                            ",
	" 1  2..2..2..2..2..2..2..2..2..2..2..2..2...2..2..2..2..2..2..2..2..2..2..2..2..2  1                                            ",
	" 1  .              .        .                           .        .              .  1                                            ",
	" 1  .              .        .                           .        .              .  1                                            ",
	" 1  2  1111111111  2  1111  2  11111111111111111111111  2  1111  2  1111111111  2  1                                            ",
	" 1  .  1        1  .  1  1  .  1                     1  .  1  1  .  1        1  .  1                                            ",
	" 1  .  1        1  .  1  1  .  1                     1  .  1  1  .  1        1  .  1                                            ",
	" 1  2  1111111111  2  1  1  2  1111111111   1111111111  2  1  1  2  1111111111  2  1                                            ",
	" 1  .              .  1  1  .           1   1           .  1  1  .              .  1                                            ",
	" 1  .              .  1  1  .           1   1           .  1  1  .              .  1                                            ",
	" 1  2..2..2..2..2..2  1  1  2..2..2..2  1   1  2..2..2..2  1  1  2..2..2..2..2..2  1                                            ",
	" 1                 .  1  1           .  1   1  .           1  1  .                 1                                            ",
	" 1                 .  1  1           .  1   1  .           1  1  .                 1                                            ",
	" 1111111111111111  2  1  1111111111  .  1   1  .  1111111111  1  2  1111111111111111                                            ",
	"                1  .  1           1  .  1   1  .  1           1  .  1                                                           ",
	"                1  .  1           1  .  1   1  .  1           1  .  1                                                           ",
	"                1  2  1  1111111111  .  11111  .  1111111111  1  2  1                                                           ",
	"                1  .  1  1           .         .           1  1  .  1                                                           ",
	"                1  .  1  1           .         .           1  1  .  1                                                           ",
	"                1  2  1  1  .............................  1  1  2  1                                                           ",
	"                1  .  1  1  .                           .  1  1  .  1                                                           ",
	"                1  .  1  1  .                           .  1  1  .  1                                                           ",
	"                1  2  1  1  .  111111111     111111111  .  1  1  2  1                                                           ",
	"                1  .  1  1  .  1       1333331       1  .  1  1  .  1                                                           ",
	"                1  .  1  1  .  1       1     1       1  .  1  1  .  1                                                           ",
	" 1111111111111111  2  1111  .  1  111111     111111  1  .  1111  2  1111111111111111                                            ",
	"                   .        .  1  1               1  1  .        .                                                              ",
	"                   .        .  1  1               1  1  .        .                                                              ",
	" ..................2.........  1  1               1  1  .........2..................                                            ",
	"                   .        .  1  1               1  1  .        .                                                              ",
	"                   .        .  1  1               1  1  .        .                                                              ",
	" 1111111111111111  2  1111  .  1  11111111111111111  1  .  1111  2  1111111111111111                                            ",
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           ",
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           ",
	"                1  2  1  1  .  11111111111111111111111  .  1  1  2  1                                                           ",
	"                1  .  1  1  .                           .  1  1  .  1                                                           ",
	"                1  .  1  1  .                           .  1  1  .  1                                                           ",
	"                1  2  1  1  .............................  1  1  2  1                                                           ",
	"                1  .  1  1  .                           .  1  1  .  1                                                           ",
	"                1  .  1  1  .                           .  1  1  .  1                                                           ",
	"                1  2  1  1  .  11111111111111111111111  .  1  1  2  1                                                           ",
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           ",
	"                1  .  1  1  .  1                     1  .  1  1  .  1                                                           ",
	" 1111111111111111  2  1111  .  1111111111   1111111111  .  1111  2  1111111111111111                                            ",
	" 1                 .        .           1   1           .        .                 1                                            ",
	" 1                 .        .           1   1           .        .                 1                                            ",
	" 1  2..2..2..2..2..2..2..2..2..2..2..2  1   1  2..2..2..2..2..2..2..2..2..2..2..2  1                                            ",
	" 1  .              .                 .  1   1  .                 .              .  1                                            ",
	" 1  .              .                 .  1   1  .                 .              .  1                                            ",
	" 1  2  1111111111  2  1111111111111  2  1   1  2  1111111111111  2  1111111111  2  1                                            ",
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            ",
	" 1  .  1        1  .  1           1  .  1   1  .  1           1  .  1        1  .  1                                            ",
	" 1  2  1111111  1  2  1111111111111  2  11111  2  1111111111111  2  1  1111111  2  1                                            ",
	" 1  .        1  1  .                 .         .                 .  1  1        .  1                                            ",
	" 1  .        1  1  .                 .         .                 .  1  1        .  1                                            ",
	" 1  2..2..2  1  1  2..2..2..2..2..2..2.........2..2..2..2..2..2..2  1  1  2..2..2  1                                            ",
	" 1        .  1  1  .        .                           .        .  1  1  .        1                                            ",
	" 1        .  1  1  .        .                           .        .  1  1  .        1                                            ",
	" 1111111  2  1  1  2  1111  2  11111111111111111111111  2  1111  2  1  1  2  1111111                                            ",
	"       1  .  1  1  .  1  1  .  1                     1  .  1  1  .  1  1  .  1                                                  ",
	"       1  .  1  1  .  1  1  .  1                     1  .  1  1  .  1  1  .  1                                                  ",
	" 1111111  2  1111  2  1  1  2  1111111111   1111111111  2  1  1  2  1111  2  1111111                                            ",
	" 1        .        .  1  1  .           1   1           .  1  1  .        .        1                                            ",
	" 1        .        .  1  1  .           1   1           .  1  1  .        .        1                                            ",
	" 1  2..2..2..2..2..2  1  1  2..2..2..2  1   1  2..2..2..2  1  1  2..2..2..2..2..2  1                                            ",
	" 1  .                 1  1           .  1   1  .           1  1                 .  1                                            ",
	" 1  .                 1  1           .  1   1  .           1  1                 .  1                                            ",
	" 1  2  1111111111111111  1111111111  2  1   1  2  1111111111  1111111111111111  2  1                                            ",
	" 1  .  1                          1  .  1   1  .  1                          1  .  1                                            ",
	" 1  .  1                          1  .  1   1  .  1                          1  .  1                                            ",
	" 1  2  1111111111111111111111111111  2  11111  2  1111111111111111111111111111  2  1                                            ",
	" 1  .                                .         .                                .  1                                            ",
	" 1  .                                .         .                                .  1                                            ",
	" 1  2..2..2..2..2..2..2..2..2..2..2..2..2...2..2..2..2..2..2..2..2..2..2..2..2..2  1                                            ",
	" 1                                                                                 1                                            ",
	" 1                                                                                 1                                            ",
	" 11111111111111111111111111111111111111111111111111111111111111111111111111111111111                                            ",
	"                                                                                                                                ",
	"                                                                                                                                ",
	"                                                                                                                                "
	);
    
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
    ELSE       '0';
				  
	conta_linha: COMPONENT counter
		PORT MAP (clk 	=> clk27M,
		          rstn 	=> line_rstn,
		          en	=> line_inc,
				  max	=> SCR_HGT-1,
				  q		=> line);
    

    -- podemos avançar para o próximo estado?
    fim_escrita <= '1' when (line = SCR_HGT-1) and (col = SCR_WDT-1)
                   ELSE '0'; 

    -----------------------------------------------------------------------------
    -- Abaixo estão PROCESSos relacionados com a atualização da posição da
    -- bola. Todos são controlados por sinais de enable de modo que a posição
    -- só é de fato atualizada quando o controle (uma máquina de estados)
    -- solicitar.
    -----------------------------------------------------------------------------

    -- purpose: Este PROCESSo irá atualizar a coluna atual da bola,
    --          alterando sua posição no próximo quadro a ser desenhado.
    -- type   : sequential
    -- inputs : clk27M, rstn
    -- outputs: pos_x
    --  p_atualiza_pos_x: PROCESS (clk27M, rstn)
    --    type direcao_t is (direita, esquerda);
    --    VARIABLE direcao : direcao_t := direita;
    --  BEGIN  -- PROCESS p_atualiza_pos_x
    --    IF rstn = '0' THEN                  -- asynchronous reset (active low)
    --      pos_x <= 0;
    --    elsif clk27M'event and clk27M = '1' THEN  -- rising clock edge
    --      IF atualiza_pos_x = '1' THEN
    --        IF direcao = direita THEN         
    --          IF pos_x = 127 THEN
    --            direcao := esquerda;  
    --          ELSE
    --            pos_x <= pos_x + 1;
    --          END IF;        
    --        ELSE  -- se a direcao é esquerda
    --          IF pos_x = 0 THEN
    --            direcao := direita;
    --          ELSE
    --            pos_x <= pos_x - 1;
    --          END IF;
    --        END IF;
    --      END IF;
    --    END IF;
    --  END PROCESS p_atualiza_pos_x;
    --
    --  -- purpose: Este PROCESSo irá atualizar a linha atual da bola,
    --  --          alterando sua posição no próximo quadro a ser desenhado.
    --  -- type   : sequential
    --  -- inputs : clk27M, rstn
    --  -- outputs: pos_y
    --  p_atualiza_pos_y: PROCESS (clk27M, rstn)
    --    type direcao_t is (desce, sobe);
    --    VARIABLE direcao : direcao_t := desce;
    --  BEGIN  -- PROCESS p_atualiza_pos_x
    --    IF rstn = '0' THEN                  -- asynchronous reset (active low)
    --      pos_y <= 0;
    --    elsif clk27M'event and clk27M = '1' THEN  -- rising clock edge
    --      IF atualiza_pos_y = '1' THEN
    --        IF direcao = desce THEN         
    --          IF pos_y = 95 THEN
    --            direcao := sobe;  
    --          ELSE
    --            pos_y <= pos_y + 1;
    --          END IF;        
    --        ELSE  -- se a direcao é para subir
    --          IF pos_y = 0 THEN
    --            direcao := desce;
    --          ELSE
    --            pos_y <= pos_y - 1;
    --          END IF;
    --        END IF;
    --      END IF;
    --    END IF;
    --  END PROCESS p_atualiza_pos_y;

    -----------------------------------------------------------------------------
    -- Brilho do pixel
    -----------------------------------------------------------------------------

    pixel <= COLORS(1) WHEN mapa(line,col) = '1'
    ELSE     COLORS(2) WHEN mapa(line,col) = '2'
    ELSE     COLORS(3) WHEN mapa(line,col) = '3'
    ELSE     COLORS(0);
    pixel_bit <= '1';

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
    logica_mealy: PROCESS (estado, fim_escrita, timer)
    BEGIN
        case estado is
        when inicio  => IF timer = '1' THEN              
                            pr_estado <= constroi_quadro;
                        ELSE
                            pr_estado <= inicio;
                        END IF;
                        line_rstn      <= '0';  -- reset é active low!
                        line_enable    <= '0';
                        col_rstn       <= '0';  -- reset é active low!
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '1';  -- reset é active low!
                        timer_enable   <= '1';

        when constroi_quadro => IF fim_escrita = '1' THEN
                            pr_estado <= atualiza;
                        ELSE
                            pr_estado <= constroi_quadro;
                        END IF;
                        line_rstn      <= '1';
                        line_enable    <= '1';
                        col_rstn       <= '1';
                        col_enable     <= '1';
                        we             <= '1';
                        timer_rstn     <= '0'; 
                        timer_enable   <= '0';

        when atualiza => pr_estado <= inicio;
                        line_rstn      <= '1';
                        line_enable    <= '0';
                        col_rstn       <= '1';
                        col_enable     <= '0';
                        we             <= '0';
                        timer_rstn     <= '0'; 
                        timer_enable   <= '0';

        when others  => pr_estado <= inicio;
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
            estado <= inicio;
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
