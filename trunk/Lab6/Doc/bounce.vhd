  --codigo omitido  
  SIGNAL cor : UNSIGNED(2 downto 0); --cor atual da bola
  SIGNAL custom_we: STD_LOGIC; --não escrita em células antigas permite
                               --exibir o rastro da bola
  -----------------------------------------------------------------------------
  -- Brilho do pixel
  -----------------------------------------------------------------------------
  -- O brilho do pixel é branco quando os contadores de linha e coluna, que
  -- indicam o endereço do pixel sendo escrito para o quadro atual, casam com a
  -- posição da bola (sinais pos_x e pos_y). Caso contrário,
  -- o pixel é preto.
  
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
       direcao_y := desce;
       direcao_x := direita; 
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
  
  -- O endereço de memória pode ser construído com essa fórmula simples,
  -- a partir da linha e coluna atual
  addr  <= col + (128 * line);

  -----------------------------------------------------------------------------
  -- Processos que definem a FSM (finite state machine), nossa máquina
  -- de estados de controle.
  -----------------------------------------------------------------------------

  -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
  --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
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

                             
  --codigo omitido