--codigo retirado

architecture struct of kbd_key is

   COMPONENT alfa_char is 
      port( code: IN STD_LOGIC_VECTOR(15 downto 0);
            alfa_code: OUT STD_LOGIC_VECTOR(6 downto 0));
      END COMPONENT alfa_char;

   COMPONENT disp_roll IS
    PORT(  clk:IN STD_LOGIC;
           new_key: IN STD_LOGIC_VECTOR(6 downto 0);
           b_ld: IN STD_LOGIC;
           seg0,seg1,seg2,seg3: OUT STD_LOGIC_VECTOR(6 downto 0));
   END COMPONENT disp_roll;

--codigo retirado

   signal key0 : std_logic_vector(15 downto 0);
   signal alfa_code : std_logic_vector(3 downto 0);
   signal new_key : STD_LOGIC_VECTOR(6 downto 0);

BEGIN 

   code:alfa_char port map(
     key0(15 downto 0), new_key
      );

   display:disp_roll port map(
     CLOCK_27(0),new_key, key_on(0),
     HEX0,HEX1,HEX2,HEX3
   );

--codigo retirado

END struct;
