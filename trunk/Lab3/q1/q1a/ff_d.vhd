Library ieee;
use ieee.std_logic_1164.all;

entity ff_d is port
        (clock,d: in std_logic;
        q, notq: out std_logic);
end ff_d;

architecture rtl of ff_d is

signal 
COMPONENT latch_sr IS
	PORT  (enable,reset,set: in std_logic;
        q, notq: out std_logic);
END COMPONENT latch_sr;
Begin 
Process (clock,d)
	Begin
	if clock'event and clock ='1'
	q<=d; 

end rtl;  
