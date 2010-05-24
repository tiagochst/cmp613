library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bounce is
  port (    
    clk27M, reset_button      : in  std_logic;    
    red, green, blue          : out std_logic_vector(3 downto 0);
    hsync, vsync              : out std_logic);
end bounce;

architecture comportamento of bounce is
  signal rstn : std_logic;              -- reset active low para nossos
                                        -- circuitos sequenciais.

  -- Interface com a mem�ria de v�deo do controlador

  signal we : std_logic;                        -- write enable ('1' p/ escrita)
  signal addr : integer range 0 to 12287;       -- endereco mem. vga
  signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel

  -- Sinais dos contadores de linhas e colunas utilizados para percorrer
  -- as posi��es da mem�ria de v�deo (pixels) no momento de construir um quadro.
  
  signal line : integer range 0 to 95;  -- linha atual
  signal col : integer range 0 to 127;  -- coluna atual

  signal col_rstn : std_logic;          -- reset do contador de colunas
  signal col_enable : std_logic;        -- enable do contador de colunas

  signal line_rstn : std_logic;          -- reset do contador de linhas
  signal line_enable : std_logic;        -- enable do contador de linhas

  signal fim_escrita : std_logic;       -- '1' quando um quadro terminou de ser
                                        -- escrito na mem�ria de v�deo

  -- Sinais que armazem a posi��o de uma bola, que dever� ser desenhada
  -- na tela de acordo com sua posi��o.

  signal pos_x : integer range 0 to 127;  -- coluna atual da bola
  signal pos_y : integer range 0 to 95;   -- linha atual da bola

  signal atualiza_pos_x : std_logic;    -- se '1' = bola muda sua pos. no eixo x
  signal atualiza_pos_y : std_logic;    -- se '1' = bola muda sua pos. no eixo y

  -- Especifica��o dos tipos e sinais da m�quina de estados de controle
  type estado_t is (show_splash, apaga_quadro, inicio, constroi_quadro, move_bola);
  signal estado: estado_t := show_splash;
  signal proximo_estado: estado_t := show_splash;

  -- Sinais para um contador utilizado para atrasar a atualiza��o da
  -- posi��o da bola, a fim de evitar que a anima��o fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 270000, de modo que quando
  -- alimentado com um clock de 27MHz, ele demore 10ms para contar at� o final.
  
  signal contador : integer range 0 to 270000 - 1;  -- contador
  signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
  signal timer_rstn, timer_enable : std_logic;
  
  SIGNAL cor : UNSIGNED(2 downto 0); --cor atual da bola
  SIGNAL custom_we: STD_LOGIC; --n�o escrita em c�lulas antigas permite
                               --exibir o rastro da bola

begin  -- comportamento

  -- Aqui instanciamos o controlador de v�deo, 128 colunas por 96 linhas
  -- (aspect ratio 4:3). Os sinais que iremos utilizar para comunicar
  -- com a mem�ria de v�deo (para alterar o brilho dos pixels) s�o
  -- write_clk (nosso clock), write_enable ('1' quando queremos escrever
  -- o valor de um pixel), write_addr (endere�o do pixel a escrever)
  -- e data_in (valor do brilho do pixel RGB, 1 bit pra cada componente de cor)
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
  -- Processos que controlam contadores de linhas e coluna para varrer
  -- todos os endere�os da mem�ria de v�deo, no momento de construir um quadro.
  -----------------------------------------------------------------------------

  -- purpose: Este processo conta o n�mero da coluna atual, quando habilitado
  --          pelo sinal "col_enable".
  -- type   : sequential
  -- inputs : clk27M, col_rstn
  -- outputs: col
  conta_coluna: process (clk27M, col_rstn)
  begin  -- process conta_coluna
    if col_rstn = '0' then                  -- asynchronous reset (active low)
      col <= 0;
    elsif clk27M'event and clk27M = '1' then  -- rising clock edge
      if col_enable = '1' then
        if col = 127 then               -- conta de 0 a 127 (128 colunas)
          col <= 0;
        else
          col <= col + 1;  
        end if;
      end if;
    end if;
  end process conta_coluna;
    
  -- purpose: Este processo conta o n�mero da linha atual, quando habilitado
  --          pelo sinal "line_enable".
  -- type   : sequential
  -- inputs : clk27M, line_rstn
  -- outputs: line
  conta_linha: process (clk27M, line_rstn)
  begin  -- process conta_linha
    if line_rstn = '0' then                  -- asynchronous reset (active low)
      line <= 0;
    elsif clk27M'event and clk27M = '1' then  -- rising clock edge
      -- o contador de linha s� incrementa quando o contador de colunas
      -- chegou ao fim (valor 127)
      if line_enable = '1' and col = 127 then
        if line = 95 then               -- conta de 0 a 95 (96 linhas)
          line <= 0;
        else
          line <= line + 1;  
        end if;        
      end if;
    end if;
  end process conta_linha;

  -- Este sinal � �til para informar nossa l�gica de controle quando
  -- o quadro terminou de ser escrito na mem�ria de v�deo, para que
  -- possamos avan�ar para o pr�ximo estado.
  fim_escrita <= '1' when (line = 95) and (col = 127)
                 else '0'; 

  -----------------------------------------------------------------------------
  -- Abaixo est�o processos relacionados com a atualiza��o da posi��o da
  -- bola. Todos s�o controlados por sinais de enable de modo que a posi��o
  -- s� � de fato atualizada quando o controle (uma m�quina de estados)
  -- solicitar.
  -----------------------------------------------------------------------------

  -- purpose: Este processo ir� atualizar a coluna atual da bola,
  --          alterando sua posi��o no pr�ximo quadro a ser desenhado.
  -- type   : sequential
  -- inputs : clk27M, rstn
  -- outputs: pos_x
  p_atualiza_pos_x: process (clk27M, rstn)
    type direcao_t is (direita, esquerda);
    variable direcao : direcao_t := direita;
  begin  -- process p_atualiza_pos_x
    if rstn = '0' then                  -- asynchronous reset (active low)
      pos_x <= 0;
    elsif clk27M'event and clk27M = '1' then  -- rising clock edge
      if atualiza_pos_x = '1' then
        if direcao = direita then         
          if pos_x = 127 then
            direcao := esquerda;  
          else
            pos_x <= pos_x + 1;
          end if;        
        else  -- se a direcao � esquerda
          if pos_x = 0 then
            direcao := direita;
          else
            pos_x <= pos_x - 1;
          end if;
        end if;
      end if;
    end if;
  end process p_atualiza_pos_x;

  -- purpose: Este processo ir� atualizar a linha atual da bola,
  --          alterando sua posi��o no pr�ximo quadro a ser desenhado.
  -- type   : sequential
  -- inputs : clk27M, rstn
  -- outputs: pos_y
  p_atualiza_pos_y: process (clk27M, rstn)
    type direcao_t is (desce, sobe);
    variable direcao : direcao_t := desce;
  begin  -- process p_atualiza_pos_x
    if rstn = '0' then                  -- asynchronous reset (active low)
      pos_y <= 0;
    elsif clk27M'event and clk27M = '1' then  -- rising clock edge
      if atualiza_pos_y = '1' then
        if direcao = desce then         
          if pos_y = 95 then
            direcao := sobe;  
          else
            pos_y <= pos_y + 1;
          end if;        
        else  -- se a direcao � para subir
          if pos_y = 0 then
            direcao := desce;
          else
            pos_y <= pos_y - 1;
          end if;
        end if;
      end if;
    end if;
  end process p_atualiza_pos_y;

  -----------------------------------------------------------------------------
  -- Brilho do pixel
  -----------------------------------------------------------------------------
  -- O brilho do pixel � branco quando os contadores de linha e coluna, que
  -- indicam o endere�o do pixel sendo escrito para o quadro atual, casam com a
  -- posi��o da bola (sinais pos_x e pos_y). Caso contr�rio,
  -- o pixel � preto.
  
  atualiza_cor: PROCESS (clk27M, rstn, cor)
    type direcao_t_x is (direita, esquerda);
    type direcao_t_y is (desce,cima);
    variable direcao_x : direcao_t_x := direita;
    variable direcao_y : direcao_t_y := desce;

	VARIABLE nxt_cor: UNSIGNED(2 downto 0);
  BEGIN
	IF (cor = "111") THEN
		nxt_cor := "001";
	ELSE
	    nxt_cor := cor + "001";
	END IF;
  
    IF (rstn = '0') THEN
       cor <= "001";
    ELSIF (clk27M'event and clk27M = '1') THEN
		IF (atualiza_pos_y = '1' ) THEN
			IF (pos_y = 0 and direcao_y = cima) THEN
				direcao_y := desce;
				IF(pos_x /= 127 and pos_x /= 0)THEN
					cor <= nxt_cor;
				END IF;
			ELSIF (pos_y = 95 and direcao_y = desce) THEN
				direcao_y := cima;
				IF(pos_x /= 127 and pos_x /= 0)THEN
					cor <= nxt_cor;
				END IF;
			END IF;
		END IF;
	
		IF (atualiza_pos_x = '1') THEN
			IF (pos_x = 0 and direcao_x = esquerda ) THEN
				cor <= nxt_cor;
				direcao_x:=direita;
			ELSIF (pos_x = 127 and direcao_x = direita) THEN
				cor <= nxt_cor;
				direcao_x := esquerda;
			END IF;
		END IF;
	END IF;
  END PROCESS;
  
  pixel <= "000" WHEN (estado = apaga_quadro)
  ELSE std_logic_vector(cor) WHEN (col = pos_x) and (line = pos_y)
  ELSE "000";
           
  custom_we <= '1' WHEN (col = pos_x) and (line = pos_y)
           else '0';
  
  -- O endere�o de mem�ria pode ser constru�do com essa f�rmula simples,
  -- a partir da linha e coluna atual
  addr  <= col + (128 * line);

  -----------------------------------------------------------------------------
  -- Processos que definem a FSM (finite state machine), nossa m�quina
  -- de estados de controle.
  -----------------------------------------------------------------------------

  -- purpose: Esta � a l�gica combinacional que calcula sinais de sa�da a partir
  --          do estado atual e alguns sinais de entrada (M�quina de Mealy).
  -- type   : combinational
  -- inputs : estado, fim_escrita, timer
  -- outputs: proximo_estado, atualiza_pos_x, atualiza_pos_y, line_rstn,
  --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
  logica_mealy: process (estado, fim_escrita, timer, custom_we)
  begin  -- process logica_mealy
    case estado is
      when apaga_quadro => if fim_escrita = '1' then
                               proximo_estado <= inicio;
                             else
                               proximo_estado <= apaga_quadro;
                             end if;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '1';
                             col_rstn       <= '1';
                             col_enable     <= '1';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
                             
      when inicio         => if timer = '1' then              
                               proximo_estado <= constroi_quadro;
                             else
                               proximo_estado <= inicio;
                             end if;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '0';  -- reset � active low!
                             line_enable    <= '0';
                             col_rstn       <= '0';  -- reset � active low!
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1';  -- reset � active low!
                             timer_enable   <= '1';

      when constroi_quadro=> if fim_escrita = '1' then
                               proximo_estado <= move_bola;
                             else
                               proximo_estado <= constroi_quadro;
                             end if;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '1';
                             col_rstn       <= '1';
                             col_enable     <= '1';
                             we             <= custom_we;
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
                           
      when move_bola      => proximo_estado <= inicio;
                             atualiza_pos_x <= '1';
                             atualiza_pos_y <= '1';
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';

      when others         => proximo_estado <= inicio;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '0';
                             line_enable    <= '0';
                             col_rstn       <= '0';
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1'; 
                             timer_enable   <= '0';
      
    end case;
  end process logica_mealy;
  
  -- purpose: Avan�a a FSM para o pr�ximo estado
  -- type   : sequential
  -- inputs : clk27M, rstn, proximo_estado
  -- outputs: estado
  seq_fsm: process (clk27M, rstn)
  begin  -- process seq_fsm
    if rstn = '0' then                  -- asynchronous reset (active low)
      estado <= show_splash;
    elsif clk27M'event and clk27M = '1' then  -- rising clock edge
      estado <= proximo_estado;
    end if;
  end process seq_fsm;

  -----------------------------------------------------------------------------
  -- Processos do contador utilizado para atrasar a anima��o (evitar
  -- que a atualiza��o de quadros fique excessivamente veloz).
  -----------------------------------------------------------------------------
  -- purpose: Incrementa o contador a cada ciclo de clock
  -- type   : sequential
  -- inputs : clk27M, timer_rstn
  -- outputs: contador, timer
  p_contador: process (clk27M, timer_rstn)
  begin  -- process p_contador
    if timer_rstn = '0' then            -- asynchronous reset (active low)
      contador <= 0;
    elsif clk27M'event and clk27M = '1' then  -- rising clock edge
      if timer_enable = '1' then       
        if contador = 270000 - 1 then
          contador <= 0;
        else
          contador <=  contador + 1;        
        end if;
      end if;
    end if;
  end process p_contador;

  -- purpose: Calcula o sinal "timer" que indica quando o contador chegou ao
  --          final
  -- type   : combinational
  -- inputs : contador
  -- outputs: timer
  p_timer: process (contador)
  begin  -- process p_timer
    if contador = 270000 - 1 then
      timer <= '1';
    else
      timer <= '0';
    end if;
  end process p_timer;

  -----------------------------------------------------------------------------
  -- Processos que sincronizam sinais ass�ncronos, de prefer�ncia com mais
  -- de 1 flipflop, para evitar metaestabilidade.
  -----------------------------------------------------------------------------
  
  -- purpose: Aqui sincronizamos nosso sinal de reset vindo do bot�o da DE1
  -- type   : sequential
  -- inputs : clk27M
  -- outputs: rstn
  build_rstn: process (clk27M)
    variable temp : std_logic;          -- flipflop intermediario
  begin  -- process build_rstn
    if clk27M'event and clk27M = '1' then  -- rising clock edge
      rstn <= temp;
      temp := reset_button;      
    end if;
  end process build_rstn;

end comportamento;
