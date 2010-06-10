LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY disp IS
   port(
	  CLK:       IN STD_LOGIC;                 --   27 MHz
--      VIDAS: IN INTEGER range 0 to 5:=1;
--      PNT :IN INTEGER range  0 to 9999:=0;
--      PEDRAS: IN INTEGER range 0 to 255:=0;              --   Pushbutton reset
PEDRAS,VIDAS:IN STD_LOGIC;  
      HEX0,HEX1,HEX2,HEX3 : OUT STD_LOGIC_VECTOR (6 downto 0);       --   Display sete segmentos
	enable : OUT STD_LOGIC
	);
END;

architecture struct of disp is
   SIGNAL new_key: STD_LOGIC_VECTOR(6 downto 0):="0000000";
   SIGNAL en: STD_LOGIC;
   
   COMPONENT counter is 
 	PORT (clk, rstn, en: IN STD_LOGIC;
	      max: IN INTEGER;
	      q: OUT STD_LOGIC);
     END COMPONENT counter;

 COMPONENT disp_roll IS
	 PORT( clk:IN STD_LOGIC;
           new_key: IN STD_LOGIC_VECTOR(6 downto 0);
           b_ld: IN STD_LOGIC;
           seg0,seg1,seg2,seg3: OUT STD_LOGIC_VECTOR(6 downto 0));
   END COMPONENT disp_roll;

   COMPONENT disp_words IS
	 PORT( en:IN STD_LOGIC;
          -- VIDAS,PNT,PEDRAS: IN INTEGER;
           VIDAS,PEDRAS: IN STD_LOGIC;
           PNT: IN INTEGER;
           seg0,seg1,seg2,seg3:OUT STD_LOGIC_VECTOR(6 downto 0)
           );
   END COMPONENT disp_words;
BEGIN

words: disp_words port map(en,VIDAS,PEDRAS,2345,HEX0,HEX1,HEX2,HEX3);
count: counter port map(CLK,'1','1',6500000,en);

enable<=en;

END struct;