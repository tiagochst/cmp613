LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_64B IS
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
END ram_64B;

ARCHITECTURE behav OF ram_64B IS
	SIGNAL address_sig : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL clock_sig : STD_LOGIC ;
	SIGNAL clken_sig : STD_LOGIC ;
	SIGNAL data_sig: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL wren_sig,rden_sig: STD_LOGIC;
	SIGNAL q_sig : STD_LOGIC_VECTOR (7 DOWNTO 0);

	COMPONENT cpm_ram IS
		PORT
		(
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdaddress		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			rden		: IN STD_LOGIC  := '0';
			wraddress		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			wren		: IN STD_LOGIC  := '0';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT cpm_ram;


BEGIN
--write
PROCESS(clk,wren,rden) BEGIN
	IF(clk'event and clk = '1') then
		IF(chipen = '1') THEN
			IF(wren='1' and rden ='0') THEN
				clock_sig<='1';
				wren_sig <= '1';
				rden_sig <= '0';
				data_sig <= input;
				address_sig <= address;
			ELSIF(wren='0' and rden ='1') THEN
				wren_sig <= '0';
				rden_sig <= '1';
				address_sig <= address;
			ELSE
				wren_sig <= '0';
				rden_sig <= '0';
			END IF;
		ELSE
			wren_sig <= '0';
			rden_sig <= '0';
		END IF;
	END IF;	
END PROCESS;
--PROCESS(q_sig) BEGIN
--output<=q_sig;
--END PROCESS;

	cpm_ram_inst : cpm_ram PORT MAP (
		clk,data_sig,address_sig,rden_sig,address_sig,wren_sig,
		output
	);

END behav;

