LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_64B IS
	PORT
	(
		clk:IN STD_LOGIC  := '0'; 
		input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  -- dados entrada
		output    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- saida
		address   : IN STD_LOGIC_VECTOR (5 DOWNTO 0);  --endereco
		wren      : IN STD_LOGIC;                       -- W
		chipen    : IN STD_LOGIC;                       --E
		outen    : IN STD_LOGIC                        --G
	);
END ram_64B;

ARCHITECTURE behav OF ram_64B IS
	SIGNAL address_sig : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL clock_sig : STD_LOGIC ;
	SIGNAL clken_sig : STD_LOGIC ;
	SIGNAL data_sig: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL wren_sig: STD_LOGIC;
	SIGNAL output_sig : STD_LOGIC_VECTOR (7 DOWNTO 0);

	COMPONENT newram IS
		PORT
		(
		address		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		clken		: IN STD_LOGIC  ;
		clock		: IN STD_LOGIC  ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT newram;

BEGIN
--write
PROCESS(clk) BEGIN
	IF(clk'event and clk = '1') then
		IF(chipen = '1') THEN
			clken_sig<='1';
			IF(wren='1') THEN
				wren_sig <= '1';
				data_sig <= input;
				address_sig <= address;
			ELSE
				wren_sig<='0';
			END IF;
			IF(outen='1') THEN
				wren_sig <= '0';
				address_sig <= address;
				output<=output_sig;
			ELSE
				wren_sig<='0';
			END IF;
			ELSE clken_sig<='0';
		END IF;
	END IF;	
END PROCESS;

newram_inst : newram PORT MAP (
		address	 => address,--address_sig,
		clken	 => '1',--clken_sig,
		clock	 => clk,--clock_sig,
		data	 => input,--data_sig,
		wren	 => wren,--wren_sig,
		q	 => output
	);

END behav;

