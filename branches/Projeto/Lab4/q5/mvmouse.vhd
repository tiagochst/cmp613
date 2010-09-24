LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mvmouse IS
	port
	(
		------------------------	Clock Input	 	------------------------
		CLOCK_24	: 	in	STD_LOGIC_VECTOR (1 downto 0);		--	24 MHz
		CLOCK_27	:	in	STD_LOGIC_VECTOR (1 downto 0);		--	27 MHz
		CLOCK_50	: 	in	STD_LOGIC;							--	50 MHz
		CLOCK_300	: 	out	STD_LOGIC;							--	300 KHz
		
		------------------------	Push Button		------------------------
		KEY 	:		in	STD_LOGIC_VECTOR (3 downto 0);		--	Pushbutton[3:0]

		------------------------	DPDT Switch		------------------------
		SW 	:			in	STD_LOGIC_VECTOR (9 downto 0);		--	Toggle Switch[9:0]
		
		------------------------	7-SEG Dispaly	------------------------
		HEX0 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 0
		HEX1 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 1
		HEX2 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 2
		HEX3 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 3
		
		----------------------------	LED		----------------------------
		LEDG 	:		out	STD_LOGIC_VECTOR (7 downto 0);		--	LED Green[7:0]
		LEDR 	:		out	STD_LOGIC_VECTOR (9 downto 0);		--	LED Red[9:0]
					
		------------------------	PS2		--------------------------------
		PS2_DAT 	:	inout	STD_LOGIC;	                    --	PS2 Data
		PS2_CLK		:	inout	STD_LOGIC		                --	PS2 Clock
	);
end;

architecture struct of mvmouse IS
 
	-- Display 7 segmentos
    COMPONENT conv_7seg IS
	  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	        y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;

	COMPONENT mouse_ctrl
		generic(
			clkfreq : integer
		);
		port(
			ps2_data	:	inout	std_logic;
			ps2_clk		:	inout	std_logic;
			clk				:	in 	std_logic;
			en				:	in 	std_logic;
			resetn		:	in 	std_logic;
			newdata		:	out	std_logic;
			bt_on			:	out	std_logic_vector(2 downto 0);
			ox, oy		:	out std_logic;
			dx, dy		:	out	std_logic_vector(8 downto 0);
			wheel			: out	std_logic_vector(3 downto 0)
		);
	end COMPONENT;
	
	signal CLOCK_100, CLOCKHZ, signewdata, resetn : std_logic;
	signal dx, dy : std_logic_vector(8 downto 0);
	signal x, y 	: std_logic_vector(7 downto 0);
	signal hexdata : std_logic_vector(15 downto 0);
	
	constant SENSIBILITY : integer := 16; -- Rise to decrease sensibility
begin 
	-- KEY(0) Reset
	resetn <= KEY(0);
	
	mousectrl : mouse_ctrl generic map (24000) port map(
		PS2_DAT, PS2_CLK, CLOCK_24(0), '1', KEY(0),
		signewdata, LEDG(7 downto 5), LEDR(9), LEDR(7), dx, dy, LEDG(3 downto 0)
	);
	
	hexseg0: conv_7seg port map(
		hexdata(3 downto 0), HEX0
	);
	hexseg1: conv_7seg port map(
		hexdata(7 downto 4), HEX1
	);
	hexseg2: conv_7seg port map(
		hexdata(11 downto 8), HEX2
	);
	hexseg3: conv_7seg port map(
		hexdata(15 downto 12), HEX3
	);	
	
	-- Read new mouse data	
	process(signewdata, resetn)
		variable xacc, yacc : integer range -10000 to 10000;
	begin
		if(rising_edge(signewdata)) then			
			x <= std_logic_vector(to_signed(to_integer(signed(x)) + ((xacc + to_integer(signed(dx))) / SENSIBILITY), 8));
			y <= std_logic_vector(to_signed(to_integer(signed(y)) + ((yacc + to_integer(signed(dy))) / SENSIBILITY), 8));
			xacc := ((xacc + to_integer(signed(dx))) rem SENSIBILITY);
			yacc := ((yacc + to_integer(signed(dy))) rem SENSIBILITY);					
		end if;
		if resetn = '0' then
			xacc := 0;
			yacc := 0;
			x <= (others => '0');
			y <= (others => '0');
		end if;
	end process;

	hexdata(3  downto  0) <= y(3 downto 0);
	hexdata(7  downto  4) <= y(7 downto 4);
	hexdata(11 downto  8) <= x(3 downto 0);
	hexdata(15 downto 12) <= x(7 downto 4);

	-- 100 KHz clock	
	process(CLOCK_24(0))
		variable count : integer range 0 to 240 := 0;		
	begin
		if(CLOCK_24(0)'event and CLOCK_24(0) = '1') then
			if count < 240 / 2 then
				CLOCK_100 <= '1';
			else 
				CLOCK_100 <= '0';
			end if;
			if count = 240 then
				count := 0;
			end if;
			count := count + 1;			
		end if;
	end process;
	
	-- 300 KHz clock
	process(CLOCK_24(0))
		variable count : integer range 0 to 80 := 0;		
	begin
		if(CLOCK_24(0)'event and CLOCK_24(0) = '1') then
			if count < 80 / 2 then
				CLOCK_300 <= '1';
			else 
				CLOCK_300 <= '0';
			end if;
			if count = 80 then
				count := 0;
			end if;
			count := count + 1;			
		end if;
	end process;
	
	-- Hz clock	
	process(CLOCK_24(0))
		constant F_HZ : integer := 1000000;
		
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
