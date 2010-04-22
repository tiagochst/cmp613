LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY q4 IS
	PORT (hi_clk, mode_tg, ninc, disp_tg: IN STD_LOGIC;
	      seg0, seg1,
	      seg2, seg3: OUT STD_LOGIC_VECTOR(6 downto 0));
END q4;

ARCHITECTURE rtl OF q4 IS
	SIGNAL clk_4hz, inc_seg: STD_LOGIC;
	SIGNAL disp, fdisp: STD_LOGIC; --modo de display
	SIGNAL co: STD_LOGIC_VECTOR(5 downto 0); --carry outs
	SIGNAL is_md: STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL md, qs0, qs1, qm0, qm1, 
	       qh0, qh1: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL max_h0, max_h1: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL si0, si1, si2, si3: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL st0, st1, st2, st3: STD_LOGIC_VECTOR(6 downto 0);
	SIGNAL clk_cnt: STD_LOGIC_VECTOR(1 downto 0);
COMPONENT freq_div IS
	PORT (clk: IN STD_LOGIC;
	      ratio: IN INTEGER;
	      clk_out: OUT STD_LOGIC);
END COMPONENT freq_div;
COMPONENT cont4 IS
	PORT (clk, en, clr: IN STD_LOGIC;
	      top: IN STD_LOGIC_VECTOR(3 downto 0);
	      q: OUT STD_LOGIC_VECTOR(3 downto 0);
	      cout: OUT STD_LOGIC);
END COMPONENT cont4;
COMPONENT conv_7seg IS
	PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	      y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

BEGIN
	fd: COMPONENT freq_div --usar pino de 27 MHz!
		PORT MAP (hi_clk, 27000000/4, clk_4hz);
		
	--conta as subidas de 4Hz mod 4 (ciclo de 1Hz)
	PROCESS (clk_4hz) BEGIN
		IF (clk_4hz'event and clk_4hz='1') THEN
			clk_cnt <= clk_cnt + "1";
		END IF;
	END PROCESS;

	mode: COMPONENT cont4 --ativado pelo PB4
		PORT MAP (clk_4hz, not mode_tg, '0', "0101", md);
		
	--implementa um dmux para o sinal md (5 estados)
	is_md(0) <= '1' WHEN md="0000" ELSE '0'; --modo normal
	is_md(1) <= '1' WHEN md="0001" ELSE '0'; --seta m0
	is_md(2) <= '1' WHEN md="0010" ELSE '0'; --seta m1
	is_md(3) <= '1' WHEN md="0011" ELSE '0'; --seta h0
	is_md(4) <= '1' WHEN md="0100" ELSE '0'; --seta h1
	
	--ativa uma vez a cada 4, logo a cada um segundo 
	inc_seg <= clk_cnt(0) and clk_cnt(1);
	
	s0: COMPONENT cont4
		PORT MAP (clk_4hz, inc_seg and is_md(0), 
		          not is_md(0), "1010", qs0, co(0));
	s1: COMPONENT cont4
		PORT MAP (clk_4hz, co(0), 
		          not is_md(0), "0110", qs1, co(1));
	
	--valor max para os digitos da hora depende do outro
	max_h0 <= "0100" WHEN qh1  = "0010" ELSE "1010";
	max_h1 <= "0010" WHEN qh0 >= "0100" ELSE "0011";
	
	--incr os contadores caso tenha dado cout no cont.
	--anterior ou por ajuste de incremento no digito
	m0: COMPONENT cont4
		PORT MAP (clk_4hz, (co(1) and is_md(0)) or 
		(is_md(1) and not ninc), '0', "1010", qm0, co(2));
	m1: COMPONENT cont4
		PORT MAP (clk_4hz, (co(2) and is_md(0)) or 
		(is_md(2) and not ninc), '0', "0110", qm1, co(3));
	h0: COMPONENT cont4
		PORT MAP (clk_4hz, (co(3) and is_md(0)) or 
		(is_md(3) and not ninc), '0', max_h0, qh0, co(4));
	h1: COMPONENT cont4
		PORT MAP (clk_4hz, (co(4) and is_md(0)) or 
		(is_md(4) and not ninc), '0', max_h1, qh1, co(5));
		          
	PROCESS (disp_tg) BEGIN --troca modo de display
		IF (disp_tg'event and disp_tg = '1') THEN
			disp <= not disp;
		END IF;
	END PROCESS;
	
	fdisp <= disp and is_md(0); --display forcado pelo modo
	si0 <= qs0 WHEN fdisp = '1' ELSE qm0;
	si1 <= qs1 WHEN fdisp = '1' ELSE qm1;
	si2 <= qm0 WHEN fdisp = '1' ELSE qh0;
	si3 <= qm1 WHEN fdisp = '1' ELSE qh1;

	sseg0: COMPONENT conv_7seg
		PORT MAP (si0, st0);	
	sseg1: COMPONENT conv_7seg
		PORT MAP (si1, st1);
	sseg2: COMPONENT conv_7seg
		PORT MAP (si2, st2);
	sseg3: COMPONENT conv_7seg
		PORT MAP (si3, st3);
		
	--pisca displays em modo de ajuste (75% tempo aceso)
	seg0 <= "1111111" WHEN (inc_seg = '1' and is_md(1)='1')
	ELSE st0;
	seg1 <= "1111111" WHEN (inc_seg = '1' and is_md(2)='1')
	ELSE st1;
	seg2 <= "1111111" WHEN (inc_seg = '1' and is_md(3)='1')
	ELSE st2;
	seg3 <= "1111111" WHEN (inc_seg = '1' and is_md(4)='1')
	ELSE st3;
END rtl;
