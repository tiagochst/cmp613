LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY kbd_key is
   port
   (
      ------------------------   Clock Input       ------------------------
      CLOCK_24   :    IN   STD_LOGIC_VECTOR (1 downto 0);     --   24 MHz
      CLOCK_27   :    IN   STD_LOGIC_VECTOR (1 downto 0);     --   27 MHz
      CLOCK_50   :    IN   STD_LOGIC;                         --   50 MHz

      ------------------------   Push Button      ------------------------
      KEY : IN   STD_LOGIC_VECTOR (3 downto 0);       --   Pushbutton[3:0]

      ------------------------   DPDT Switch      ------------------------
      SW  : IN STD_LOGIC_VECTOR (9 downto 0);         --   Toggle Switch[9:0]
      
      ------------------------   7-SEG Dispaly   ------------------------
      HEX0 : OUT STD_LOGIC_VECTOR (6 downto 0);       --   Seven Segment Digit 0
      HEX1 : OUT STD_LOGIC_VECTOR (6 downto 0);       --   Seven Segment Digit 0
      HEX2 : OUT STD_LOGIC_VECTOR (6 downto 0);       --   Seven Segment Digit 0
      HEX3 : OUT STD_LOGIC_VECTOR (6 downto 0);       --   Seven Segment Digit 0
      
      ----------------------------   LED      ----------------------------
      LEDG  : OUT   STD_LOGIC_VECTOR (7 downto 0);    --   LED Green[7:0]
      LEDR  : OUT   STD_LOGIC_VECTOR (9 downto 0);    --   LED Red[9:0]
					
      ------------------------	PS2		--------------------------------
      PS2_DAT : inout STD_LOGIC;                      --   PS2 Data
      PS2_CLK : inout STD_LOGIC	                      --   PS2 Clock
	);
END;

architecture struct of kbd_key is

   COMPONENT alfa_char is 
      port( code: IN STD_LOGIC_VECTOR(15 downto 0);
            alfa_code: OUT STD_LOGIC_VECTOR(6 downto 0));
      END COMPONENT alfa_char;

   COMPONENT disp_roll IS
	 PORT( clk:IN STD_LOGIC;
           new_key: IN STD_LOGIC_VECTOR(6 downto 0);
           b_ld: IN STD_LOGIC;
           seg0,seg1,seg2,seg3: OUT STD_LOGIC_VECTOR(6 downto 0));
   END COMPONENT disp_roll;

	component kbdex_ctrl
		generic(
			clkfreq : INTEGER
		);
		port(
			ps2_data  : inout std_logic;
			ps2_clk	  : inout std_logic;
			clk		  : IN std_logic;
			en		  : IN std_logic;
			resetn	  : IN std_logic;
			lights	  : IN std_logic_vector(2 downto 0); -- lights(Caps, Nun, Scroll)		
			key_on	  : OUT std_logic_vector(2 downto 0);
			key_code  : OUT std_logic_vector(47 downto 0)
		);
	END component;
		
	signal CLOCKHZ: std_logic:='1';
	signal resetn : std_logic:='0';
	signal key0 : std_logic_vector(47 downto 0);
    signal new_key : STD_LOGIC_VECTOR(6 downto 0);
	signal lights, key_on  : std_logic_vector( 2 downto 0):="000";

BEGIN 
	resetn <= KEY(0);

        code:alfa_char port map(
		  key0(15 downto 0), new_key
		);

        display:disp_roll port map(
          CLOCK_27(0),new_key, key_on(0),
          HEX0,HEX1,HEX2,HEX3
        );

	kbd_ctrl : kbdex_ctrl generic map(24000) port map(
		PS2_DAT, PS2_CLK, CLOCK_24(0), KEY(1), resetn, lights(1) & lights(2) & lights(0),
		key_on, key_code(47 downto 0) => key0
	);
	
	LEDG(7 downto 5) <= key_on;
	
	-- Hz clock	
	process(CLOCK_24(0))
		CONSTANT F_HZ : INTEGER := 5;
		
		CONSTANT DIVIDER : INTEGER := 24000000/F_HZ;
		VARIABLE count : INTEGER range 0 to DIVIDER := 0;		
	BEGIN
		IF(rising_edge(CLOCK_24(0))) then
			IF count < DIVIDER / 2 then
				CLOCKHZ <= '1';
			else 
				CLOCKHZ <= '0';
			END IF;
			IF count = DIVIDER then
				count := 0;
			END IF;
			count := count + 1;			
		END IF;
	END process;	
END struct;
