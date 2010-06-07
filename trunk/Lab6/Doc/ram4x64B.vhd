LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram4x64B IS
   PORT
   (
      clk       :IN STD_LOGIC ; 
      input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);     -- dados entrada
      output    : BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida
      wren      : IN STD_LOGIC;                         -- W write-enable
      rden      : IN STD_LOGIC;                         -- G read-enable
      chmod       : IN STD_LOGIC  ;                     -- G read-enable
      modled       : OUT STD_LOGIC ;                    -- G read-enable
      wrled       : OUT STD_LOGIC;                      -- G read-enable
      rdled       : OUT STD_LOGIC ;                     -- G read-enable
      seg1, seg0: OUT STD_LOGIC_VECTOR(6 downto 0)      --sete segmentos

   );
END ram4x64B;

ARCHITECTURE behav OF ram4x64B IS
SIGNAL sel:STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL   q_sig,q_sig1,q_sig2,q_sig3,q_sig4 : STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida


COMPONENT conv_7seg IS
   PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
         y: OUT STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT conv_7seg;

COMPONENT ram_64B IS
   PORT
   (
      clk       :IN STD_LOGIC ; 
      input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  -- dados entrada
      output    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida
      address   : IN STD_LOGIC_VECTOR (5 DOWNTO 0);  -- endereco
      wren      : IN STD_LOGIC;                      -- W write-enable
      chipen    : IN STD_LOGIC;                      -- E chip-enable
      rden      : IN STD_LOGIC                       -- G read-enable
   );
END COMPONENT ram_64B;

  TYPE state_type IS ( wraddress,wdata);
  SIGNAL state : state_type := wraddress;
  SIGNAL data_sig,address_sig: STD_LOGIC_VECTOR (7 DOWNTO 0):="00000000";
  SIGNAL chmod_sig,wren_sig,rden_sig: STD_LOGIC :='0'; --modo de  amostrado
 
 COMPONENT buff IS
  PORT (clk, d: IN STD_LOGIC;
        q: OUT STD_LOGIC);
END COMPONENT buff;

 BEGIN

  bf: COMPONENT buff
         PORT MAP (clk, chmod,chmod_sig);
 bf1: COMPONENT buff
         PORT MAP (clk, wren,wren_sig);
 bf2: COMPONENT buff
         PORT MAP (clk, rden,rden_sig);

wrled<='1' when wren= '1' else '0'; 
rdled<='1' when rden= '1' else '0';

  -- Transicoes da Maquina de Estados
  PROCESS (state, clk)
  BEGIN
    IF  (rising_edge(clk)) THEN
      CASE state IS
        WHEN  wraddress => --leitura de enderço
            address_sig <= input;
            modled<='1';
       IF(chmod_sig='1') THEN
               state <=wdata; 
            END IF;
        WHEN wdata =>
       data_sig<=input;
       modled<='0';          
       IF(chmod_sig='1') THEN
               state <= wraddress; 
            END IF;
           END CASE;
    END IF;
  END PROCESS;


PROCESS(address_sig)
variable ram_sel:STD_LOGIC_VECTOR (1 downto 0);
BEGIN
   ram_sel:=address_sig(7 downto 6);

   case ram_sel is
      when "00" =>
         sel<="0001";
      when "01" =>
         sel<="0010";
      when "10" =>
         sel<="0100";
      when others =>
         sel<="1000";
   end case;
END PROCESS;


ram1: ram_64B PORT MAP (
      clk,data_sig,q_sig1,address_sig(5 downto 0),wren_sig,sel(0),not wren_sig);

ram2: ram_64B PORT MAP (
      clk,data_sig,q_sig2,address_sig(5 downto 0),wren_sig,sel(1),not wren_sig
   );

ram3: ram_64B PORT MAP (
      clk,data_sig,q_sig3,address_sig(5 downto 0),wren_sig,sel(2),not wren_sig
   );

ram4: ram_64B PORT MAP (
      clk,data_sig,q_sig4,address_sig(5 downto 0),wren_sig,sel(3),not wren_sig
   );


   PROCESS(clk) 
   BEGIN
      IF (clk'event and clk = '1') THEN
         IF(rden_sig ='1') THEN
         case sel is
            when "0001" =>
               output<=q_sig1;
            when "0010"=>
               output<=q_sig2;
            when "0100" =>
               output<=q_sig3;
            when others =>
               output<=q_sig4;
         end case;
         END IF;   
      END IF;
   END PROCESS;   

   --leitura da memoria RAM
   cseg0: COMPONENT conv_7seg
      PORT MAP (output(3 downto 0), seg0);
   cseg1: COMPONENT conv_7seg
      PORT MAP (output(7 downto 4), seg1);


END behav;