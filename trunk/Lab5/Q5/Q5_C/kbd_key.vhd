LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity kbd_key is
	port
	(
		------------------------	Clock Input	 	------------------------
		CLOCK_24	: 	in	STD_LOGIC_VECTOR (1 downto 0);	--	24 MHz
		CLOCK_27	:		in	STD_LOGIC_VECTOR (1 downto 0);	--	27 MHz
		CLOCK_50	: 	in	STD_LOGIC;											--	50 MHz
		-- CLOCKTAP	: 	out	STD_LOGIC;											
		
		------------------------	Push Button		------------------------
		KEY 	:		in	STD_LOGIC_VECTOR (3 downto 0);		--	Pushbutton[3:0]

		------------------------	DPDT Switch		------------------------
		SW 	:		in	STD_LOGIC_VECTOR (9 downto 0);			--	Toggle Switch[9:0]
		
		------------------------	7-SEG Dispaly	------------------------
		HEX0 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 0
		
		----------------------------	LED		----------------------------
		LEDG 	:		out	STD_LOGIC_VECTOR (7 downto 0);		--	LED Green[7:0]
		LEDR 	:		out	STD_LOGIC_VECTOR (9 downto 0);		--	LED Red[9:0]
					
		------------------------	PS2		--------------------------------
		PS2_DAT 	:		inout	STD_LOGIC;	--	PS2 Data
		PS2_CLK		:		inout	STD_LOGIC		--	PS2 Clock
	);
end;

architecture struct of kbd_key is

   COMPONENT alfa_char is 
      port( code: IN STD_LOGIC_VECTOR(15 downto 0);
            alfa_code: OUT STD_LOGIC_VECTOR(6 downto 0));
      end COMPONENT alfa_char;

	component kbdex_ctrl
		generic(
			clkfreq : integer
		);
		port(
			ps2_data	:	inout	std_logic;
			ps2_clk		:	inout	std_logic;
			clk				:	in 	std_logic;
			en				:	in 	std_logic;
			resetn		:	in 	std_logic;
			lights		: in	std_logic_vector(2 downto 0); -- lights(Caps, Nun, Scroll)		
			key_on		:	out	std_logic_vector(2 downto 0);
			key_code	:	out	std_logic_vector(47 downto 0)
		);
	end component;
		
	signal CLOCKHZ, resetn 	: std_logic;
	signal key0 						: std_logic_vector(15 downto 0);
	signal alfa_code 						: std_logic_vector(3 downto 0);
	signal lights, key_on		: std_logic_vector( 2 downto 0);
begin 
	resetn <= KEY(0);

        code:alfa_char port map(
		    key0(15 downto 0), HEX0
		);

	kbd_ctrl : kbdex_ctrl generic map(24000) port map(
		PS2_DAT, PS2_CLK, CLOCK_24(0), KEY(1), resetn, lights(1) & lights(2) & lights(0),
		key_on, key_code(15 downto 0) => key0
	);
	
	LEDG(7 downto 5) <= key_on;
	
	-- Hz clock	
	process(CLOCK_24(0))
		constant F_HZ : integer := 5;
		
		constant DIVIDER : integer := 24000000/F_HZ;
		variable count : integer range 0 to DIVIDER := 0;		
	begin
		if(rising_edge(CLOCK_24(0))) then
			if count < DIVIDER / 2 then
				CLOCKHZ <= '1';
			else 
				CLOCKHZ <= '0';
			end if;
			if count = DIVIDER then
				count := 0;
			end if;
			count := count + 1;			
		end if;
	end process;	
end struct;
