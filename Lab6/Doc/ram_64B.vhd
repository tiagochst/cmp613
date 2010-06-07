LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_64B IS
   PORT
   (
      clk       :IN STD_LOGIC ; 
      input     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  
      output    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); 
      address   : IN STD_LOGIC_VECTOR (5 DOWNTO 0);  
      wren      : IN STD_LOGIC;  -- W write-enable
      chipen    : IN STD_LOGIC;  -- E chip-enable
      rden      : IN STD_LOGIC   -- G read-enable
   );
END ram_64B;

ARCHITECTURE behav OF ram_64B IS
   SIGNAL address_sig : STD_LOGIC_VECTOR (5 DOWNTO 0);
   SIGNAL clock_sig : STD_LOGIC ;
   SIGNAL clken_sig : STD_LOGIC ;
   SIGNAL data_sig: STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL wren_sig,rden_sig: STD_LOGIC;
   SIGNAL q_sig : STD_LOGIC_VECTOR (7 DOWNTO 0);

COMPONENT ram1p IS
   PORT
   (
      clock      : IN STD_LOGIC  := '1';
      data      : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdaddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      rden      : IN STD_LOGIC  := '1';
      wraddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren      : IN STD_LOGIC  := '0';
      q      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
   );

END COMPONENT ram1p;


BEGIN
PROCESS(clk,wren,rden,chipen)
 BEGIN
      IF(chipen = '1') THEN
         --write
         IF(wren='1' and rden ='0') THEN
            wren_sig <= '1';
            rden_sig <= '0';
         --read
         ELSIF(wren='0' and rden ='1') THEN
            wren_sig <= '0';
            rden_sig <= '1';
         --write and read -> nao 
         ELSE
            wren_sig <= '0';
            rden_sig <= '0';
         END IF;
      ELSE
         wren_sig <= '0';
         rden_sig <= '0';
      END IF;
END PROCESS;

PROCESS(q_sig,chipen) BEGIN
      IF(chipen = '1') THEN
         output<=q_sig;
      ELSE
         output<= (others=>'Z');
      END IF;
END PROCESS;


ram1p_inst : ram1p PORT MAP (
      clk,input,address,rden_sig,address,wren_sig,q_sig
   );
END behav;

