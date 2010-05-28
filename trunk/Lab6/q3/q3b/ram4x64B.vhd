LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram4x64B IS
	PORT
	(
		clk       :IN STD_LOGIC ; 
		input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  -- dados entrada
		output    : BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida
		--address   : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  -- endereco
		wren      : IN STD_LOGIC;                      -- W write-enable
		rden      : IN STD_LOGIC;                       -- G read-enable
		chmod       : IN STD_LOGIC                       -- G read-enable
	
	);
END ram4x64B;

ARCHITECTURE behav OF ram4x64B IS
SIGNAL sel:STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	q_sig,q_sig1,q_sig2,q_sig3,q_sig4 : STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida


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
--  SIGNAL chmod: STD_LOGIC :='0'; --modo de  amostrado
 
BEGIN

  -- Transicoes da Maquina de Estados
  PROCESS (state, clk)
  BEGIN
    IF  (rising_edge(clk)) THEN
      CASE state IS
        WHEN  wraddress => --leitura de enderço
            address_sig <= input;
	    IF(chmod='1') THEN
               state <=wdata; 
            END IF;
        WHEN wdata =>
	    data_sig<=input;          
	    IF(chmod='1') THEN
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

PROCESS(sel,q_sig1,q_sig2,q_sig3,q_sig4) 
	BEGIN
	--	IF(rden ='1') THEN
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
--	END IF;	
END PROCESS;

ram1: ram_64B PORT MAP (
		clk,data_sig,q_sig1,address_sig(5 downto 0),wren,sel(0),rden);

ram2: ram_64B PORT MAP (
		clk,data_sig,q_sig2,address_sig(5 downto 0),wren,sel(1),rden
	);

ram3: ram_64B PORT MAP (
		clk,data_sig,q_sig3,address_sig(5 downto 0),wren,sel(2),rden
	);

ram4: ram_64B PORT MAP (
		clk,data_sig,q_sig4,address_sig(5 downto 0),wren,sel(3),rden
	);
END behav;

