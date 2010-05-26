LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_64B IS
	PORT
	(
		input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		output    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		address   : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		wren      : IN STD_LOGIC  := '0';
		chipen    : IN STD_LOGIC  := '0';
		outen    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END ram_64B;

ARCHITECTURE behav OF ram_64B IS
	SIGNAL address_sig : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL clock_sig : STD_LOGIC ;
	SIGNAL clken_sig : STD_LOGIC ;
	SIGNAL data_sig: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL wren_sig: STD_LOGIC;
	SIGNAL q_sig : STD_LOGIC_VECTOR (7 DOWNTO 0);

   COMPONENT conv_7seg IS
	  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	        y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;

	COMPONENT newram IS
		PORT
		(
		address		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT newram;

BEGIN
		clken_sig <= chipen;
		
		newram_inst : newram PORT MAP (
		address	 => address_sig,
		clken	 => clken_sig,
		clock	 => clock_sig,
		data	 => data_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);

END behav;

