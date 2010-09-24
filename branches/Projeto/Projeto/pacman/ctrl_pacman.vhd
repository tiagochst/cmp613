LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.NUMERIC_STD.all;
USE work.PAC_DEFS.all;

ENTITY ctrl_pacman IS
	PORT (
	clk, rstn				:IN STD_LOGIC;
    atualiza				:IN STD_LOGIC;
    key_dir					:IN t_direcao; --tecla de ação lida pelo teclado
    pac_area	          	:IN t_blk_sym_3x3; --mapa 3x3 em torno da posição atual
    pac_pos_x, pac_pos_y	:BUFFER t_pos;
    pac_cur_dir				:BUFFER t_direcao;
    got_coin, got_spc_coin	:OUT STD_LOGIC
	);
END ctrl_pacman;

ARCHITECTURE behav OF ctrl_pacman IS
 	SIGNAL pac_nxt_cel, pac_dir_cel, pac_esq_cel, pac_cim_cel, pac_bai_cel: t_blk_sym;
 	
 	CONSTANT PAC_START_X : INTEGER := 42;
	CONSTANT PAC_START_Y : INTEGER := 71;
BEGIN
	-- Calcula possíveis parâmetros envolvidos no próximo movimento
	-- do pacman
	-- type: combinational
	PROCESS (pac_cur_dir, pac_area)
	BEGIN
		--calcula qual seriam as proximas celulas visitadas pelo pacman
		pac_nxt_cel <= pac_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1));
		
		IF (WALKABLE(pac_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1)))) THEN
			-- aqui o pacman conseguirá andar para a próxima casa
			-- então as células candidatas para fazer curva estão nas diagonais
			pac_dir_cel <= pac_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1) + 1);
			pac_esq_cel <= pac_area(DIRS(pac_cur_dir)(0), DIRS(pac_cur_dir)(1) - 1);
			pac_cim_cel <= pac_area(DIRS(pac_cur_dir)(0)-1, DIRS(pac_cur_dir)(1));
			pac_bai_cel <= pac_area(DIRS(pac_cur_dir)(0)+1, DIRS(pac_cur_dir)(1));
		ELSE
			-- caso o pacman esteja travado (parado) em alguma parede
			pac_dir_cel <= pac_area( 0, 1);
			pac_esq_cel <= pac_area( 0, -1);
			pac_cim_cel <= pac_area(-1, 0);
			pac_bai_cel <= pac_area( 1, 0);
		END IF;
	END PROCESS;

    -- purpose: Este processo irá atualizar a posicão do pacman e definir
    --          suas ações no jogo.
    -- type   : sequential
    p_atualiza_pacman: PROCESS (clk, rstn)
		VARIABLE nxt_move, key_dir_old: t_direcao;
    BEGIN
        IF (rstn = '0') THEN
            pac_pos_x <= PAC_START_X;
            pac_pos_y <= PAC_START_Y;
			pac_cur_dir <= NADA;
			nxt_move := NADA;			
        ELSIF (clk'event and clk = '1') THEN
             IF (atualiza = '1') THEN
				--Checa teclado para "agendar" um movimento
				IF (key_dir /= NADA and key_dir_old = NADA) THEN
					nxt_move := key_dir;
				END IF;
				
                --atualiza direção
				IF (nxt_move = CIMA and WALKABLE(pac_cim_cel)) THEN
					pac_cur_dir <= CIMA;
					nxt_move := NADA;
				ELSIF (nxt_move = DIREI and WALKABLE(pac_dir_cel)) THEN
					pac_cur_dir <= DIREI;
					nxt_move := NADA;
				ELSIF (nxt_move = BAIXO and WALKABLE(pac_bai_cel)) THEN
					pac_cur_dir <= BAIXO;
					nxt_move := NADA;
				ELSIF (nxt_move = ESQUE and WALKABLE(pac_esq_cel)) THEN
					pac_cur_dir <= ESQUE;
					nxt_move := NADA;
                END IF;
                
				IF (WALKABLE(pac_nxt_cel)) THEN --atualiza posicao
					IF (pac_pos_x = MAP_X_MAX) then --teletransporte
						pac_pos_x <= MAP_X_MIN + 1;
					ELSIF (pac_pos_x = MAP_X_MIN) then
						pac_pos_x <= MAP_X_MAX - 1;
					ELSIF (pac_pos_y = MAP_Y_MIN) then
						pac_pos_y <= MAP_Y_MAX - 1;
					ELSIF (pac_pos_y = MAP_Y_MAX) then
						pac_pos_y <= MAP_Y_MIN + 1;
					ELSE
						pac_pos_x <= pac_pos_x + DIRS(pac_cur_dir)(1);
						pac_pos_y <= pac_pos_y + DIRS(pac_cur_dir)(0);
					END IF;
				END IF;
                key_dir_old := key_dir;
            END IF;
        END IF;
	END PROCESS;
	
	-- Sinais de controle externos ficam ativos durante um ciclo de "atualiza"
	got_coin <= '1' WHEN (pac_nxt_cel = BLK_COIN and atualiza = '1')
	ELSE '0';
			
	got_spc_coin <= '1' WHEN (pac_nxt_cel = BLK_SPC_COIN and atualiza = '1')
	ELSE '0';
END behav;
