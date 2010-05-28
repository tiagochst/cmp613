LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY kbd_key IS 
  PORT (
    ------------------------   Clock Input       ------------------------
    CLOCK_27   :    IN   STD_LOGIC;                 --   24 MHz
    ------------------------   Push Button      -------------------------
    KEY : IN   STD_LOGIC;                           --   Pushbutton reset
    ----------------------------   LED      ----------------------------
    LEDG  : OUT   STD_LOGIC_VECTOR (7 downto 5);    --   LED Green[7:0]
    ------------------------	PS2		--------------------------------
    PS2_DAT : inout STD_LOGIC;                      --   PS2 Data
    PS2_CLK : inout STD_LOGIC;	                    --   PS2 Clock
    ---------------------------Players direction -----------------------
    p1_dir,p2_dir: OUT STD_LOGIC_VECTOR(2 downto 0)
    );
END;

architecture struct of kbd_key is

   COMPONENT player_dir is 
      port( code: IN STD_LOGIC_VECTOR(47 downto 0);
            p1_dir,p2_dir: OUT STD_LOGIC_VECTOR(2 downto 0));
      END COMPONENT player_dir;

  component kbdex_ctrl
    generic(
      clkfreq : INTEGER
    );
    port(
      ps2_data : inout std_logic;
      ps2_clk  : inout std_logic;
      clk      : IN std_logic;
      en       : IN std_logic;
      resetn   : IN std_logic;
      lights   : IN std_logic_vector(2 downto 0); -- lights(Caps, Nun, Scroll)		
      key_on   : OUT std_logic_vector(2 downto 0);
      key_code : OUT std_logic_vector(47 downto 0)
    );
  END component;
		
  signal resetn : std_logic:='0';
  signal key_all : std_logic_vector(47 downto 0);
  signal lights, key_on  : std_logic_vector( 2 downto 0):="000";

BEGIN 
  resetn <= KEY;

  code:player_dir port map(
    key_all,p1_dir,p2_dir
  );

  kbd_ctrl : kbdex_ctrl generic map(24000) port map(
    PS2_DAT, PS2_CLK, CLOCK_27, '1', resetn, lights(1) & lights(2) & lights(0),
    key_on, key_code(47 downto 0) => key_all
  );
	
  LEDG(7 downto 5) <= key_on;
END struct;