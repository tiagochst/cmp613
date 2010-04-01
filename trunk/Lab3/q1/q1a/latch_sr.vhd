Library ieee;
use ieee.std_logic_1164.all;

entity latch_sr is port
        (enable,reset,set: in std_logic;
        q, notq: out std_logic);
end latch_sr;

architecture rtl of latch_sr is
begin latch: 
	process(enable,reset,set)
begin
    if enable = '1' then
    if reset ='1' then
		q<= '0';
		notq<=not(set);	
	else
	    if set ='1' then
		  q<=set;
		  notq<= reset;
		end if;
    end if;
    end if;

end process latch;
end rtl;  