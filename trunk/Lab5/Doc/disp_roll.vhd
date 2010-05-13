LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY disp_roll IS
PORT( clk:IN STD_LOGIC;
      new_key: IN STD_LOGIC_VECTOR(6 downto 0);
      b_ld: IN STD_LOGIC;
      seg0,seg1,seg2,seg3: OUT STD_LOGIC_VECTOR(6 downto 0));
END ENTITY disp_roll;


ARCHITECTURE rtl of disp_roll IS
  SIGNAL ld:STD_LOGIC; -- tecla pressionada?
  SIGNAL key,key0,key1,key2,key3: STD_LOGIC_VECTOR(6 downto 0):= "1111111";

  COMPONENT buff IS
    PORT (clk, d: IN STD_LOGIC;
	      q: OUT STD_LOGIC);
  END COMPONENT buff;

BEGIN
  bf: COMPONENT buff
    PORT MAP (clk, b_ld, ld);

  PROCESS(ld,clk) begin
    IF(clk'event and clk = '1') then
      IF(ld = '1') then
        key3<=key2;
        key2<=key1;
        key1<=key0;
        key0<=new_key;
      END IF;
    END IF;
  END PROCESS;

    seg3<=key3;
    seg2<=key2;
    seg1<=key1;
    seg0<=key0;

END rtl;