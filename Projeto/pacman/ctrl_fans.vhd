LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;

ENTITY ctrl_fans IS
	PORT (
	clk27M, rstn			:IN STD_LOGIC;
    atualiza				:IN STD_LOGIC;
    atua_en					:IN STD_LOGIC_VECTOR(2 downto 0); --velocidades para atualizar
    keys_dir				:IN t_fans_dirs; --teclas de ação lidas pelo teclado
    fan_area	          	:IN t_fans_blk_sym_3x3; --mapa 3x3 em torno da posição atual
    spc_coin                :IN STD_LOGIC;
    pac_fans_hit            :IN UNSIGNED(0 to FAN_NO-1);
    fan_pos_x, fan_pos_y	:BUFFER t_fans_pos;
    fan_state               :BUFFER t_fans_states;
    fan_cur_dir				:BUFFER t_fans_dirs;
    pacman_dead				:OUT STD_LOGIC;
    fan_died				:OUT STD_LOGIC
	);
END ctrl_fans;

ARCHITECTURE behav OF ctrl_fans IS
	SIGNAL fan_nxt_cel, fan_dir_cel, fan_esq_cel, fan_cim_cel, fan_bai_cel: t_fans_blk_sym;
    SIGNAL fan_tempo: t_fans_times;
    SIGNAL fan_rstn_tempo: t_fans_bits;
    SIGNAL pr_fan_state: t_fans_states;
BEGIN
	--Calcula possíveis parâmetros envolvidos no próximo movimento
	--de todos os fantasmas
	-- type: combinational
	PROCESS (fan_area, fan_cur_dir)
	BEGIN
		FOR i in 0 to FAN_NO-1 LOOP
			fan_nxt_cel(i) <= fan_area(i)(DIRS(fan_cur_dir(i))(0), DIRS(fan_cur_dir(i))(1));
			
			IF (WALKABLE(fan_area(i)(DIRS(fan_cur_dir(i))(0), DIRS(fan_cur_dir(i))(1)))) THEN
				fan_dir_cel(i) <= fan_area(i)(DIRS(fan_cur_dir(i))(0), DIRS(fan_cur_dir(i))(1) + 1);
				fan_esq_cel(i) <= fan_area(i)(DIRS(fan_cur_dir(i))(0), DIRS(fan_cur_dir(i))(1) - 1);
				fan_cim_cel(i) <= fan_area(i)(DIRS(fan_cur_dir(i))(0) - 1, DIRS(fan_cur_dir(i))(1));
				fan_bai_cel(i) <= fan_area(i)(DIRS(fan_cur_dir(i))(0) + 1, DIRS(fan_cur_dir(i))(1));
			ELSE
				fan_dir_cel(i) <= fan_area(i)(0,1);
				fan_esq_cel(i) <= fan_area(i)(0,-1);
				fan_cim_cel(i) <= fan_area(i)(-1,0);
				fan_bai_cel(i) <= fan_area(i)(1,0);
			END IF;
		END LOOP;
	END PROCESS;
	
	-- purpose: Este processo irá atualizar as posições dos fantasmas e definir
    --          suas ações no jogo de acordo com seus estados.
    -- type   : sequential
    -- inputs : clk27M, rstn, pac_area
    --          fan_cur_dir, fan_pos_x, fan_pos_y
    -- outputs: fan_cur_dir, fan_pos_x, fan_pos_y, got_coin
    p_atualiza_fan: PROCESS (clk27M, rstn)
		VARIABLE keys_dir_old, nxt_move: t_fans_dirs;
    BEGIN
        IF (rstn = '0') THEN
            fan_pos_x <= FANS_START_X;
            fan_pos_y <= FANS_START_Y;
			fan_cur_dir <= (others => NADA);
			nxt_move := (others => NADA);
        ELSIF (clk27M'event and clk27M = '1') THEN
             IF (atualiza = '1') THEN
				FOR i in 0 to FAN_NO-1 LOOP
					CASE fan_state(i) IS
					WHEN ST_VIVO | ST_VULN | ST_VULN_BLINK => 
						IF (atua_en(1) = '1') THEN
							--Checa teclado para "agendar" um movimento
							IF (keys_dir(i) /= NADA and keys_dir_old(i) = NADA) THEN
								nxt_move(i) := keys_dir(i);
							END IF;
							
							IF (nxt_move(i) = CIMA and WALKABLE(fan_cim_cel(i))) THEN
								fan_cur_dir(i) <= CIMA;
								nxt_move(i) := NADA;
							ELSIF (nxt_move(i) = DIREI and WALKABLE(fan_dir_cel(i))) THEN
								fan_cur_dir(i) <= DIREI;
								nxt_move(i) := NADA;
							ELSIF (nxt_move(i) = BAIXO and WALKABLE(fan_bai_cel(i))) THEN
								fan_cur_dir(i) <= BAIXO;
								nxt_move(i) := NADA;
							ELSIF (nxt_move(i) = ESQUE and WALKABLE(fan_esq_cel(i))) THEN
								fan_cur_dir(i) <= ESQUE;
								nxt_move(i) := NADA;
							END IF;
							
							IF (WALKABLE(fan_nxt_cel(i))) THEN --atualiza posicao
								IF(fan_pos_x(i) = TELE_DIR_POS) then --teletransporte
									fan_pos_x(i) <= TELE_ESQ_POS + 1;
								ELSIF(fan_pos_x(i) = TELE_ESQ_POS) then
									fan_pos_x(i) <= TELE_DIR_POS - 1;
								ELSE
									fan_pos_x(i) <= fan_pos_x(i) + DIRS(fan_cur_dir(i))(1);
									fan_pos_y(i) <= fan_pos_y(i) + DIRS(fan_cur_dir(i))(0);
								END IF;
							END IF;
							
							keys_dir_old(i) := keys_dir(i);
						END IF;
					WHEN ST_DEAD | ST_PRE_DEAD | ST_FIND_EXIT => 
						IF (atua_en(2) = '1') THEN
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
						IF (atua_en(1) = '1') THEN 
							fan_pos_y(i) <= fan_pos_y(i) - 1;
							fan_cur_dir(i) <= CIMA;
						END IF;
					END CASE;
				END LOOP;
            END IF;
        END IF;
	END PROCESS p_atualiza_fan;
	
	-- Gera o próximo estado de cada fantasma na atualização
	-- type: combinational
	p_fan_next_state: PROCESS (fan_state, spc_coin, pac_fans_hit, fan_tempo,
	                           fan_pos_x, fan_pos_y, atua_en)
		VARIABLE pacman_dead_var, fan_died_var: STD_LOGIC;
	BEGIN
		pacman_dead_var := '0';
		fan_died_var := '0';

		FOR i in 0 to FAN_NO-1 LOOP
			CASE fan_state(i) IS
				WHEN ST_VIVO =>
					IF (pac_fans_hit(i) = '1') THEN
						pr_fan_state(i) <= ST_VIVO;
						pacman_dead_var := '1';
					ELSIF (spc_coin = '1') THEN
						pr_fan_state(i) <= ST_VULN;
					ELSE
						pr_fan_state(i) <= ST_VIVO;
					END IF;
					fan_rstn_tempo(i) <= '0';
					
				WHEN ST_VULN =>
					IF (pac_fans_hit(i) = '1') THEN
						pr_fan_state(i) <= ST_PRE_DEAD;
						fan_died_var := '1';
					ELSIF (fan_tempo(i) > FAN_TIME_VULN_START_BLINK) THEN
						pr_fan_state(i) <= ST_VULN_BLINK;
					ELSE
						pr_fan_state(i) <= ST_VULN;
					END IF;
					fan_rstn_tempo(i) <= '1';
					
				WHEN ST_VULN_BLINK =>
					IF (pac_fans_hit(i) = '1') THEN
						pr_fan_state(i) <= ST_PRE_DEAD;
						fan_died_var := '1';
					ELSIF (fan_tempo(i) > FAN_TIME_VULN_END) THEN
						pr_fan_state(i) <= ST_VIVO;
					ELSE
						pr_fan_state(i) <= ST_VULN_BLINK;
					END IF;
					fan_rstn_tempo(i) <= '1';
					
				WHEN ST_PRE_DEAD => --apenas zera contador de tempo
					pr_fan_state(i) <= ST_DEAD;
					fan_rstn_tempo(i) <= '0';
					pacman_dead <= '0';
				
				WHEN ST_DEAD =>
					IF (fan_tempo(i) > FAN_TIME_DEAD) THEN
						pr_fan_state(i) <= ST_FIND_EXIT;
					ELSE 
						pr_fan_state(i) <= ST_DEAD;
					END IF;
					fan_rstn_tempo(i) <= '1';
				
				WHEN ST_FIND_EXIT =>
					IF (fan_pos_x(i) = CELL_IN_X and fan_pos_y(i) = CELL_IN_Y) THEN
						pr_fan_state(i) <= ST_FUGA;
					ELSE
						pr_fan_state(i) <= ST_FIND_EXIT;
					END IF;
					fan_rstn_tempo(i) <= '0';
					
				WHEN ST_FUGA =>
					IF (fan_pos_y(i) = CELL_OUT_Y) THEN
						pr_fan_state(i) <= ST_VIVO;
					ELSE
						pr_fan_state(i) <= ST_FUGA;
					END IF;
					fan_rstn_tempo(i) <= '0';
			END CASE;
		END LOOP;

		pacman_dead <= pacman_dead_var and atua_en(1);
		fan_died <= fan_died_var;
	END PROCESS p_fan_next_state;

	-- Avança a FSM para o próximo estado
	-- type: sequential
	seq_fsm_fan: PROCESS (clk27M, rstn)
    BEGIN 
        IF (rstn = '0') THEN                  -- asynchronous reset (active low)
            fan_state <= (OTHERS => ST_FIND_EXIT);
        ELSIF (clk27M'event and clk27M = '1') THEN 
            fan_state <= pr_fan_state;
        END IF;
    END PROCESS seq_fsm_fan;
    
    -- Contadores de tempo para os fantasmas
    fan_counters: PROCESS (clk27M, fan_rstn_tempo)
	BEGIN
		FOR i in 0 to FAN_NO-1 LOOP
			IF (fan_rstn_tempo(i) = '0') THEN
				fan_tempo(i) <= 0;
			ELSIF (clk27M'event and clk27M = '1') THEN
				IF (atualiza = '1') THEN
					fan_tempo(i) <= fan_tempo(i) + 1;
				END IF;
			END IF;
		END LOOP;
	END PROCESS fan_counters;
END behav;
