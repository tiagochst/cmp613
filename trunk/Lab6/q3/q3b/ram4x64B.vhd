LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram4x64B IS
	PORT
	(
		clk       :IN STD_LOGIC ; 
		input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  -- dados entrada
		output    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida
		address   : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  -- endereco
		wren      : IN STD_LOGIC;                      -- W write-enable
		rden      : IN STD_LOGIC                       -- G read-enable
	);
END ram4x64B;

ARCHITECTURE behav OF ram4x64B IS
SIGNAL sel:STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	q_sig1,q_sig2,q_sig3,q_sig4 : STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida


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
 

BEGIN

PROCESS(address)
variable ram_sel:STD_LOGIC_VECTOR (1 downto 0);

BEGIN
	ram_sel:=address(7 downto 6);

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
		clk,input,q_sig1,address(5 downto 0),wren,sel(0),rden);

ram2: ram_64B PORT MAP (
		clk,input,q_sig2,address(5 downto 0),wren,sel(1),rden
	);

ram3: ram_64B PORT MAP (
		clk,input,q_sig3,address(5 downto 0),wren,sel(2),rden
	);

ram4: ram_64B PORT MAP (
		clk,input,q_sig4,address(5 downto 0),wren,sel(3),rden
	);
END behav;

