-- VGA controller component
-- Based on original design by Rafael Auler
--
-- Modified to generate up to 640x480 different
-- pixels through mapping logical blocks of size
-- 5x5 pixels into user-defined RGB sprites
-- Also, it has two logical screen maps, overlayed
-- one on top of another.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.PAC_DEFS.all;
USE work.PAC_SPRITES.all;

entity vgacon is
  generic (
    --  When changing this, remember to keep 4:3 aspect ratio
    --  Must also keep in mind that our native resolution is 640x480, and
    --  you can't cross these bounds (although you will seldom have enough
    --  on-chip memory to instantiate this module with higher res).
    NUM_HORZ_BLOCKS : natural := 128;  -- Number of horizontal pixels
    NUM_VERT_BLOCKS : natural := 96);  -- Number of vertical pixels
  
  port (
    clk27M, rstn              : in  std_logic;
    write_clk, write_enable   : in  std_logic;
    write_addr                : in  integer range 0 to
                                  NUM_HORZ_BLOCKS * NUM_VERT_BLOCKS - 1;
    data_in                   : in  t_blk_sym;
    vga_clk                   : buffer std_logic;  -- Ideally 25.175 MHz
    vga_pixel                 : out t_color_3b;    --at 25.2 MHz
    data_block                : out t_blk_sym;     --at 27 MHz
    hsync, vsync              : out std_logic;
    ovl_in                    : in t_ovl_blk_sym;
    ovl_we                    : in std_logic);
end vgacon;

architecture behav of vgacon is
  -- Two signals: one is delayed by one clock cycle. The monitor control uses
  -- the delayed one. We need a counter 1 clock cycle earlier, relative
  -- to the monitor signal, in order to index the memory contents 
  -- for the next cycle, when the pixel is in fact sent to the monitor.
  signal h_count, h_count_d : integer range 0 to 799;  -- horizontal counter
  signal v_count, v_count_d : integer range 0 to 524;  -- vertical counter

  signal read_addr : integer range 0 to NUM_HORZ_BLOCKS * NUM_VERT_BLOCKS - 1;
  signal h_drawarea, v_drawarea, drawarea : std_logic;
  signal vga_data_out	  : t_blk_sym;
  signal vga_ovl_data_out : t_ovl_blk_sym;
  signal id_vga_data_out, id_data_block, id_data_in: t_blk_id;
  signal id_ovl_in, id_vga_ovl_data_out: t_ovl_blk_id;
  signal vga_pixel_0 : t_color_3b;
begin

  -- This is our PLL (Phase Locked Loop) to divide the DE1 27 MHz
  -- clock and produce a 25.2MHz clock adequate to our VGA controller
  divider: work.vga_pll port map (clk27M, vga_clk);

  -- This is our main dual clock RAM. We use our VGA clock to read contents from
  -- memory (block type value). The user of this module may use any clock
  -- to write contents to this memory, modifying blocks individually.
  vgamem0 : work.dual_clock_ram -- RAM used for the background elements
  generic map (
    MEMSIZE => NUM_HORZ_BLOCKS * NUM_VERT_BLOCKS,
    MEMWDT  => 4)
  port map (
    a_clk          => vga_clk,
    b_clk          => write_clk,
    a_address      => read_addr,
    b_address      => write_addr,
    b_data_in      => id_data_in,
    a_data_out     => id_vga_data_out,
    b_data_out     => id_data_block,
    b_we           => write_enable);
  vgamem1 : work.dual_clock_ram -- RAM used for overlayed characters
  generic map (
    MEMSIZE => NUM_HORZ_BLOCKS * NUM_VERT_BLOCKS,
    MEMWDT  => 9)
  port map (
    a_clk          => vga_clk,
    b_clk          => write_clk,
    a_address      => read_addr,
    b_address      => write_addr,
    b_data_in      => id_ovl_in,
    a_data_out     => id_vga_ovl_data_out,
    b_we           => ovl_we);
    
  -- Block enumeration to/from logic_vector conversions 
  id_data_in       <= std_logic_vector(to_unsigned(t_blk_sym'pos(data_in), 4));
  id_ovl_in        <= std_logic_vector(to_unsigned(t_ovl_blk_sym'pos(ovl_in), 9));
  vga_data_out     <= t_blk_sym'val(to_integer(unsigned(id_vga_data_out)));
  data_block       <= t_blk_sym'val(to_integer(unsigned(id_data_block)));
  vga_ovl_data_out <= t_ovl_blk_sym'val(to_integer(unsigned(id_vga_ovl_data_out)));

  -- purpose: Increments the current horizontal position counter
  -- type   : sequential
  -- inputs : vga_clk, rstn
  -- outputs: h_count, h_count_d
  horz_counter: process (vga_clk, rstn)
  begin  -- process horz_counter
    if rstn = '0' then                  -- asynchronous reset (active low)
      h_count <= 0;
      h_count_d <= 0;
    elsif vga_clk'event and vga_clk = '1' then  -- rising clock edge
      h_count_d <= h_count;             -- 1 clock cycle delayed counter
      if h_count = 799 then
        h_count <= 0;
      else
        h_count <= h_count + 1;
      end if;
    end if;
  end process horz_counter;

  -- purpose: Determines if we are in the horizontal "drawable" area
  -- type   : combinational
  -- inputs : h_count_d
  -- outputs: h_drawarea
  horz_sync: process (h_count_d)
  begin  -- process horz_sync
    if h_count_d < 640 then
      h_drawarea <= '1';
    else
      h_drawarea <= '0';
    end if;
  end process horz_sync;

  -- purpose: Increments the current vertical counter position
  -- type   : sequential
  -- inputs : vga_clk, rstn
  -- outputs: v_count, v_count_d
  vert_counter: process (vga_clk, rstn)
  begin  -- process vert_counter
    if rstn = '0' then              -- asynchronous reset (active low)
      v_count <= 0;
      v_count_d <= 0;
    elsif vga_clk'event and vga_clk = '1' then  -- rising clock edge
      v_count_d <= v_count;             -- 1 clock cycle delayed counter
      if h_count = 699 then
        if v_count = 524 then
          v_count <= 0;
        else
          v_count <= v_count + 1;
        end if;          
      end if;
    end if;
  end process vert_counter;

  -- purpose: Updates information based on vertical position
  -- type   : combinational
  -- inputs : v_count_d
  -- outputs: v_drawarea
  vert_sync: process (v_count_d)
  begin  -- process vert_sync
    if v_count_d < 480 then
      v_drawarea <= '1';
    else
      v_drawarea <= '0';
    end if;
  end process vert_sync;

  -- purpose: Generates synchronization signals
  -- type   : combinational
  -- inputs : v_count_d, h_count_d
  -- outputs: hsync, vsync
  sync: process (v_count_d, h_count_d)
  begin  -- process sync
    if (h_count_d >= 659) and (h_count_d <= 755) then
      hsync <= '0';
    else
      hsync <= '1';
    end if;
    if (v_count_d >= 493) and (v_count_d <= 494) then
      vsync <= '0';
    else
      vsync <= '1';
    end if;
  end process sync;

  -- determines whether we are in drawable area on screen a.t.m.
  drawarea <= v_drawarea and h_drawarea;

  -- purpose: calculates the controller memory address to read block data
  -- type   : combinational
  -- inputs : h_count, v_count
  -- outputs: read_addr
  gen_r_addr: process (h_count, v_count)
  begin  -- process gen_r_addr
    read_addr <= h_count / (640 / NUM_HORZ_BLOCKS)
                 + ((v_count/(480 / NUM_VERT_BLOCKS))
                    * NUM_HORZ_BLOCKS);
  end process gen_r_addr;

  -- Build color signals based on memory output and "drawarea" signal
  -- (if we are not in the drawable area of 640x480, must deassert all
  --  color signals).
  PROCESS (vga_data_out, vga_ovl_data_out, drawarea, h_count, v_count)
	VARIABLE pixel_normal, pixel_ovl: t_color_3b; 
  BEGIN
	pixel_ovl(0) := OVL_SPRITES_RED(vga_ovl_data_out)(v_count mod 5, (h_count+4) mod 5);
    pixel_ovl(1) := OVL_SPRITES_GRN(vga_ovl_data_out)(v_count mod 5, (h_count+4) mod 5);
    pixel_ovl(2) := OVL_SPRITES_BLU(vga_ovl_data_out)(v_count mod 5, (h_count+4) mod 5);
    
    pixel_normal(0) := SPRITES_RED(vga_data_out)(v_count mod 5, (h_count+4) mod 5);
    pixel_normal(1) := SPRITES_GRN(vga_data_out)(v_count mod 5, (h_count+4) mod 5);
    pixel_normal(2) := SPRITES_BLU(vga_data_out)(v_count mod 5, (h_count+4) mod 5);
    
    IF (drawarea = '1') THEN
	  IF (pixel_ovl /= "000") THEN
        vga_pixel_0 <= pixel_ovl;
      ELSE
        vga_pixel_0 <= pixel_normal;
      END IF;
    ELSE
      vga_pixel_0 <= "000";
    END IF;  
  END PROCESS;
  
  -- Here, we register the pixel before sending to VGA pin
  -- in order to help compiler recognize the critical path
  -- to the pin and set the timing constraints accordingly.
  -- It prevents glitches displayed in the screen. 
  PROCESS (vga_clk) 
  BEGIN
    IF (vga_clk'event and vga_clk = '1') THEN
		vga_pixel <= vga_pixel_0;
	END IF;
  END PROCESS;
end behav;


-------------------------------------------------------------------------------
-- The following entity is a dual clock RAM (read operates at different
-- clock from write). This is used to isolate two clock domains. The first
-- is the 25.2 MHz clock domain in which our VGA controller needs to operate.
-- This is the read clock, because we read from this memory to determine
-- the color of a pixel. The second is the clock domain of the user of this
-- module, writing in the memory the contents it wants to display in the VGA.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
USE work.PAC_DEFS.all;

entity dual_clock_ram is

  generic (
    MEMSIZE : natural;
    MEMWDT  : natural);  
  port (
    a_clk, b_clk  		        : in  std_logic;  -- support different clocks
    b_data_in                   : in  std_logic_vector(MEMWDT-1 downto 0); --only b writes
    a_address, b_address        : in  integer range 0 to MEMSIZE - 1;
    b_we                        : in  std_logic;  -- write enable
    a_data_out, b_data_out      : out std_logic_vector(MEMWDT-1 downto 0));
end dual_clock_ram;

architecture behav of dual_clock_ram is
  -- we only want to address (store) MEMSIZE elements 
  subtype addr is integer range 0 to MEMSIZE - 1;
  type mem is array (addr) of std_logic_vector(MEMWDT-1 downto 0);
  signal ram_block : mem;
  -- we don't care with read after write behavior (whether ram reads
  -- old or new data in the same cycle).
  attribute ramstyle : string;
  attribute ramstyle of dual_clock_ram : entity is "no_rw_check";
begin  -- behav

  -- purpose: Reads data from RAM
  -- type   : sequential
  a: process (a_clk)
  begin  -- process read
    if (a_clk'event and a_clk = '1') then  -- rising clock edge
      a_data_out <= ram_block(a_address);      
    end if;
  end process a;

  -- purpose: Reads/Writes data to RAM
  -- type   : sequential
  b: process (b_clk)
  begin  -- process write
    if (b_clk'event and b_clk = '1') then  -- rising clock edge
      if (b_we = '1') then
        ram_block(b_address) <= b_data_in;
      end if;
      b_data_out <= ram_block(b_address);
    end if;
  end process b;

end behav;

-------------------------------------------------------------------------------
-- The following entity is automatically generated by Quartus (a megafunction).
-- As Altera DE1 board does not have a 25.175 MHz, but a 27 Mhz, we
-- instantiate a PLL (Phase Locked Loop) to divide out 27 MHz clock
-- and reach a satisfiable 25.2MHz clock for our VGA controller (14/15 ratio)
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY vga_pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
END vga_pll;


ARCHITECTURE SYN OF vga_pll IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire4_bv	: BIT_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire4	: STD_LOGIC_VECTOR (0 DOWNTO 0);



	COMPONENT altpll
	GENERIC (
		clk0_divide_by		: NATURAL;
		clk0_duty_cycle		: NATURAL;
		clk0_multiply_by		: NATURAL;
		clk0_phase_shift		: STRING;
		compensate_clock		: STRING;
		inclk0_input_frequency		: NATURAL;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		operation_mode		: STRING;
		port_activeclock		: STRING;
		port_areset		: STRING;
		port_clkbad0		: STRING;
		port_clkbad1		: STRING;
		port_clkloss		: STRING;
		port_clkswitch		: STRING;
		port_configupdate		: STRING;
		port_fbin		: STRING;
		port_inclk0		: STRING;
		port_inclk1		: STRING;
		port_locked		: STRING;
		port_pfdena		: STRING;
		port_phasecounterselect		: STRING;
		port_phasedone		: STRING;
		port_phasestep		: STRING;
		port_phaseupdown		: STRING;
		port_pllena		: STRING;
		port_scanaclr		: STRING;
		port_scanclk		: STRING;
		port_scanclkena		: STRING;
		port_scandata		: STRING;
		port_scandataout		: STRING;
		port_scandone		: STRING;
		port_scanread		: STRING;
		port_scanwrite		: STRING;
		port_clk0		: STRING;
		port_clk1		: STRING;
		port_clk2		: STRING;
		port_clk3		: STRING;
		port_clk4		: STRING;
		port_clk5		: STRING;
		port_clkena0		: STRING;
		port_clkena1		: STRING;
		port_clkena2		: STRING;
		port_clkena3		: STRING;
		port_clkena4		: STRING;
		port_clkena5		: STRING;
		port_extclk0		: STRING;
		port_extclk1		: STRING;
		port_extclk2		: STRING;
		port_extclk3		: STRING
	);
	PORT (
			inclk	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			clk	: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	sub_wire4_bv(0 DOWNTO 0) <= "0";
	sub_wire4    <= To_stdlogicvector(sub_wire4_bv);
	sub_wire1    <= sub_wire0(0);
	c0    <= sub_wire1;
	sub_wire2    <= inclk0;
	sub_wire3    <= sub_wire4(0 DOWNTO 0) & sub_wire2;

	altpll_component : altpll
	GENERIC MAP (
		clk0_divide_by => 15,
		clk0_duty_cycle => 50,
		clk0_multiply_by => 14,
		clk0_phase_shift => "0",
		compensate_clock => "CLK0",
		inclk0_input_frequency => 37037,
		intended_device_family => "Cyclone II",
		lpm_hint => "CBX_MODULE_PREFIX=vga_pll",
		lpm_type => "altpll",
		operation_mode => "NORMAL",
		port_activeclock => "PORT_UNUSED",
		port_areset => "PORT_UNUSED",
		port_clkbad0 => "PORT_UNUSED",
		port_clkbad1 => "PORT_UNUSED",
		port_clkloss => "PORT_UNUSED",
		port_clkswitch => "PORT_UNUSED",
		port_configupdate => "PORT_UNUSED",
		port_fbin => "PORT_UNUSED",
		port_inclk0 => "PORT_USED",
		port_inclk1 => "PORT_UNUSED",
		port_locked => "PORT_UNUSED",
		port_pfdena => "PORT_UNUSED",
		port_phasecounterselect => "PORT_UNUSED",
		port_phasedone => "PORT_UNUSED",
		port_phasestep => "PORT_UNUSED",
		port_phaseupdown => "PORT_UNUSED",
		port_pllena => "PORT_UNUSED",
		port_scanaclr => "PORT_UNUSED",
		port_scanclk => "PORT_UNUSED",
		port_scanclkena => "PORT_UNUSED",
		port_scandata => "PORT_UNUSED",
		port_scandataout => "PORT_UNUSED",
		port_scandone => "PORT_UNUSED",
		port_scanread => "PORT_UNUSED",
		port_scanwrite => "PORT_UNUSED",
		port_clk0 => "PORT_USED",
		port_clk1 => "PORT_UNUSED",
		port_clk2 => "PORT_UNUSED",
		port_clk3 => "PORT_UNUSED",
		port_clk4 => "PORT_UNUSED",
		port_clk5 => "PORT_UNUSED",
		port_clkena0 => "PORT_UNUSED",
		port_clkena1 => "PORT_UNUSED",
		port_clkena2 => "PORT_UNUSED",
		port_clkena3 => "PORT_UNUSED",
		port_clkena4 => "PORT_UNUSED",
		port_clkena5 => "PORT_UNUSED",
		port_extclk0 => "PORT_UNUSED",
		port_extclk1 => "PORT_UNUSED",
		port_extclk2 => "PORT_UNUSED",
		port_extclk3 => "PORT_UNUSED"
	)
	PORT MAP (
		inclk => sub_wire3,
		clk => sub_wire0
	);

END SYN;
