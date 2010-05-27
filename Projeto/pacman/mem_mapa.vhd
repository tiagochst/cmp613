library ieee;
use ieee.std_logic_1164.all;

entity single_clock_ram is
  generic (
    MEMSIZE : natural);  
  port (
    clk                         : in  std_logic;  -- support different clocks
    data_in                     : in  std_logic_vector(2 downto 0);
    raddr, waddr                : in  integer range 0 to MEMSIZE - 1;  
    we                          : in  std_logic;  -- write enable
    data_out                    : out std_logic_vector(2 downto 0));
end single_clock_ram;

architecture behav of single_clock_ram is
  -- we only want to address (store) MEMSIZE elements 
  subtype addr is integer range 0 to MEMSIZE - 1;
  type mem is array (addr) of std_logic_vector(2 downto 0);
  signal ram_block : mem;
  -- we don't care with read after write behavior (whether ram reads
  -- old or new data in the same cycle).
  attribute ramstyle : string;
  attribute ramstyle of single_clock_ram : entity is "no_rw_check";
  attribute ram_init_file : string;
  attribute ram_init_file of ram_block : signal is "pacman.mif";

begin  -- behav

  process (clk)
  begin  -- process write
    if clk'event and clk = '1' then  -- rising clock edge
      if (we = '1') then
        ram_block(waddr) <= data_in;
      end if;
      
      data_out <= ram_block(raddr);
    end if;
  end process write;

end behav;