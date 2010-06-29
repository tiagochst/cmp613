LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY disp IS
   port(
	  CLK:       IN STD_LOGIC;
 	  EN:        IN STD_LOGIC;
      VIDAS: IN INTEGER range 0 to 5:=1;       
      PNT :IN INTEGER range 0 to 9999:=0;
      PEDRAS: IN INTEGER range -10 to 255:=0;   
      seg0,seg1,seg2,seg3 : OUT STD_LOGIC_VECTOR (6 downto 0) --   Display sete segmentos
	);
END;

architecture struct of disp is
	SIGNAL P0,P1,P2,P3: std_logic_vector(3 downto 0):="0000"; -- recebe pontuacao passada pelo top level
    SIGNAL  HEX0,HEX1,HEX2,HEX3: STD_LOGIC_VECTOR(6 downto 0):="0000000"; --intermediario pontuacao 
	SIGNAL  aux_seg0,aux_seg1,aux_seg2,aux_seg3: STD_LOGIC_VECTOR(6 downto 0):="1111111"; --usado para rolagem do dISplay
 	
    COMPONENT conv_7seg IS
	  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	        y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;

	SIGNAL cont1, cont2: INTEGER range 0 to 100;
	SIGNAL show_pts, frase_rstn: STD_LOGIC;
BEGIN
	PROCESS(PNT)
		BEGIN
   			P0 <= std_logic_vector(to_unsigned(PNT mod 10,4));        --unidade
			P1 <= std_logic_vector(to_unsigned((PNT/10  mod 10),4));  --dezena		
			P2 <= std_logic_vector(to_unsigned((PNT/100 mod 10),4));  --centena
			P3 <= std_logic_vector(to_unsigned((PNT/1000 mod 10),4)); --milhar
	END PROCESS;

	PROCESS (clk)
		VARIABLE alfa_code: STD_LOGIC_VECTOR(6 downto 0):="0000000"; -- intermediario letras
    BEGIN
		IF(clk'event and clk = '1') THEN
			IF (en = '1') THEN
				IF(PEDRAS<= 0) THEN
					case (cont1) IS
						WHEN 0 =>
							alfa_code := "0010001"; --Y
						WHEN 1 =>
							alfa_code := "1000000"; --O
						WHEN 2 =>
							alfa_code := "1000001"; --U
						WHEN 3 =>
							alfa_code := "1111111"; -- 
						WHEN 4 =>
							alfa_code := "0001000"; --A
						WHEN 5 =>
							alfa_code := "0101111"; --R
						WHEN 6 =>
							alfa_code := "0000110"; --E
						WHEN 7 =>
							alfa_code := "1111111"; --
						WHEN 8 =>
							alfa_code := "0000111"; --T 
						WHEN 9 =>
							alfa_code := "0001011"; --H
						WHEN 10 =>
							alfa_code := "0000110"; --E 
						WHEN 11 =>
							alfa_code := "1111111"; -- 
						WHEN 12 =>
							alfa_code := "0000011"; --B 
						WHEN 13 =>
							alfa_code := "0000110"; --E 
						WHEN 14 =>
							alfa_code := "0010010"; --S
						WHEN 15 =>
							alfa_code := "0000111"; --T 
						WHEN others =>	
							alfa_code := "1111111";
						END case;
					
				ELSIF (VIDAS = 0) THEN
					case (cont2) IS
						WHEN 0 =>
							alfa_code := "0010001"; --Y
						WHEN 1 =>
							alfa_code := "1000000"; --O
						WHEN 2 =>
							alfa_code := "1000001"; --U
						WHEN 3 =>
							alfa_code := "1111111"; -- 
						WHEN 4 =>
							alfa_code := "1000111"; --L
						WHEN 5 =>
							alfa_code := "1000000"; --O
						WHEN 6 =>
							alfa_code := "0010010"; --S
						WHEN 7 =>
							alfa_code := "0000110"; --E
						WHEN others =>
							alfa_code := "1111111"; -- 
						END case;
				END IF;
								
				IF (PEDRAS<=0 or VIDAS=0) THEN
					aux_seg3 <= aux_seg2; -- dISplay
					aux_seg2 <= aux_seg1; -- rolante
					aux_seg1 <= aux_seg0; --
					aux_seg0 <= alfa_code;
				ELSE
					aux_seg3 <= "1111111"; -- apaga palavras
					aux_seg2 <= "1111111"; -- quANDo jogo e
					aux_seg1 <= "1111111"; -- reiniciado ou 
					aux_seg0 <= "1111111"; -- iniciado
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	frase_rstn <= '1' WHEN (PEDRAS <=0 or VIDAS = 0)
	ELSE '0';

	p_contador0: ENTITY WORK.counter 
        PORT MAP (clk 	=> CLK,
		          rstn 	=> frase_rstn,
		          en	=> en,
				  max	=> 24,
				  q		=> cont1);
				  
	p_contador1: ENTITY WORK.counter 
        PORT MAP (clk 	=> CLK,
		          rstn 	=> frase_rstn,
		          en	=> en,
				  max	=> 16,
				  q		=> cont2);

	hexseg0: conv_7seg port map(P0, HEX0); --casa da unidade da pontuacao
	hexseg1: conv_7seg port map(P1, HEX1); --casa da dezena da pontuacao
	hexseg2: conv_7seg port map(P2, HEX2); --casa centena da pontuacao
	hexseg3: conv_7seg port map(P3, HEX3); --casa de mil pontos  

	--se nem perdeu todas as vidas ou terminou todas as pecas mostra pontuacao,
	--caso contrario mostra as frases.
	show_pts <= '1' WHEN ((PEDRAS <= 0 and cont1 >= 20) or (VIDAS = 0 and cont2 >= 12)
	                      or (VIDAS /=0 and PEDRAS > 0))
	ELSE '0';
	
	seg0 <= HEX0 WHEN (show_pts = '1') ELSE aux_seg0; 
	seg1 <= HEX1 WHEN (show_pts = '1') ELSE aux_seg1;
	seg2 <= HEX2 WHEN (show_pts = '1') ELSE aux_seg2;
	seg3 <= HEX3 WHEN (show_pts = '1') ELSE aux_seg3;
END struct;