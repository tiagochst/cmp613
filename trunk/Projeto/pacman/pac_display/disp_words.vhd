library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY disp_words IS
   port(
	 en:IN STD_LOGIC;
     --VIDAS,PNT,PEDRAS: IN INTEGER;
     VIDAS,PEDRAS: IN STD_LOGIC;
     PNT: IN INTEGER;
     seg0,seg1,seg2,seg3:OUT STD_LOGIC_VECTOR(6 downto 0)
     );
END disp_words;

architecture struct of disp_words is
	SIGNAL P0,P1,P2,P3: std_logic_vector(3 downto 0):="0000"; -- recebe pontuacao passada pelo top level
    SIGNAL  HEX0,HEX1,HEX2,HEX3: STD_LOGIC_VECTOR(6 downto 0):="0000000"; --intermediario pontuacao 
	SIGNAL alfa_code: STD_LOGIC_VECTOR(6 downto 0):="0000000"; -- intermediario letras
	SIGNAL  aux_seg0,aux_seg1,aux_seg2,aux_seg3: STD_LOGIC_VECTOR(6 downto 0):="1111111"; --usado para rolagem do display

 	
    COMPONENT conv_7seg IS
	  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	        y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;

begin
	process(PNT)
		begin
   			P0 <= std_logic_vector(to_unsigned(PNT mod 10,4));        --unidade
			P1 <= std_logic_vector(to_unsigned((PNT/10  mod 10),4));  --dezena		
			P2 <= std_logic_vector(to_unsigned((PNT/100 mod 10),4));  --centena
			P3 <= std_logic_vector(to_unsigned((PNT/1000 mod 10),4)); --milhar
	end process;

 process (en)
VARIABLE counter:INTEGER:=0;
  
      begin
	IF(en='1') then
		IF (counter /= 0 and (PEDRAS ='0' or VIDAS ='0')) then
			aux_seg3 <= aux_seg2;
			aux_seg2 <= aux_seg1;
			aux_seg1 <= aux_seg0;
			else
			aux_seg3 <= "1111111";
			aux_seg2 <= "1111111";
			aux_seg1 <= "1111111";
			aux_seg0 <= "1111111";
		end if;

	if(PEDRAS = '0') then
			case (counter) is
				when 0 =>
					alfa_code <= "0010001"; --Y
				when 1 =>
					alfa_code <= "0100011"; --O
				when 2 =>
					alfa_code <= "1000001"; --U
				when 3 =>
					alfa_code <= "1111111"; -- 
				when 4 =>
					alfa_code <= "0001000"; --A
				when 5 =>
					alfa_code <= "0101111"; --R
				when 6 =>
					alfa_code <= "0000110"; --E
				when 7 =>
					alfa_code <= "1111111"; --
				when 8 =>
					alfa_code <= "0000111"; --T 
				when 9 =>
					alfa_code <= "0001011"; --H
				when 10 =>
					alfa_code <= "0000110"; --E 
				when 11 =>
					alfa_code <= "1111111"; -- 
				when 12 =>
					alfa_code <= "0000011"; --B 
				when 13 =>
					alfa_code <= "0000110"; --E 
				when 14 =>
					alfa_code <= "0010010"; --S
				when 15 =>
					alfa_code <= "0000111"; --T 
				when others =>	
					alfa_code <= "1111111";
				end case;
			counter := (counter +1) mod 16;
		elsif (VIDAS = '0') then
			case (counter) is
				when 0 =>
					alfa_code <= "0010001"; --Y
				when 1 =>
					alfa_code <= "0100011"; --O
				when 2 =>
					alfa_code <= "1000001"; --U
				when 3 =>
					alfa_code <= "1111111"; -- 
				when 4 =>
					alfa_code <= "1000111"; --L
				when 5 =>
					alfa_code <= "0100011"; --O
				when 6 =>
					alfa_code <= "0010010"; --S
				when 7 =>
					alfa_code <= "0000110"; --E
				when others =>
					alfa_code <= "1111111"; -- 
				end case;
			counter := (counter +1) mod 8;
		
		else
			counter :=0;
			alfa_code <= "1111111";
		end if;
	end if;	
	aux_seg0 <= alfa_code;
end process;

	hexseg0: conv_7seg port map(P0, HEX0); --casa da unidade da pontuacao
	hexseg1: conv_7seg port map(P1, HEX1); --casa da dezena da pontuacao
	hexseg2: conv_7seg port map(P2, HEX2); --casa centena da pontuacao
	hexseg3: conv_7seg port map(P3, HEX3); --casa de mil pontos  

--se nem perdeu todas as vidas ou terminou todas as pecas mostra pontuacao,
--caso contrario mostra as frases.
	seg0 <= HEX0 when (VIDAS /= '0' and PEDRAS /= '0') else aux_seg0 ; 
	seg1 <= HEX1 when (VIDAS /= '0' and PEDRAS /= '0') else aux_seg1;
	seg2 <= HEX2 when (VIDAS /= '0' and PEDRAS /= '0') else aux_seg2;
	seg3 <= HEX3 when (VIDAS /= '0' and PEDRAS /= '0') else aux_seg3;

END struct;