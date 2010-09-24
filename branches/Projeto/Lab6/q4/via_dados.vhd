LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY via_dados IS
  PORT (clk, rstn: IN STD_LOGIC;
        opcode: IN STD_LOGIC_VECTOR(5 downto 0);
        inp: IN STD_LOGIC_VECTOR(3 downto 0);
        outp: OUT STD_LOGIC_VECTOR(3 downto 0);
        seg0: OUT STD_LOGIC_VECTOR(6 downto 0));
END via_dados;

ARCHITECTURE behav OF via_dados IS
  SUBTYPE reg IS STD_LOGIC_VECTOR(3 downto 0);
  TYPE vreg IS ARRAY(0 to 3) OF reg;
  SUBTYPE reg_index IS NATURAL range 0 to 3;
  
  SIGNAL regs: vreg;
  SIGNAL opr: STD_LOGIC_VECTOR(1 downto 0);
  SIGNAL rd, rs: reg_index;
  SIGNAL reg_disp: reg;
  
  COMPONENT conv_7seg IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        y: OUT STD_LOGIC_VECTOR(6 downto 0));
  END COMPONENT conv_7seg;
BEGIN
  --decodifica parâmetros de controle
  opr <= opcode(5 downto 4);
  rd <= to_integer(unsigned( opcode(3 downto 2) ));
  rs <= to_integer(unsigned( opcode(1 downto 0) ));

  PROCESS (clk, rstn)
  BEGIN
    IF (rstn = '0') THEN
      regs <= (others => x"0");
      reg_disp <= x"0";
    ELSIF (rising_edge(clk)) THEN
      CASE opr IS
        WHEN "00" =>
          regs(rd) <= regs(rs);
        WHEN "01" =>
          regs(rd) <= inp;
        WHEN "10" =>
          --memoriza o conteudo atual do registrador
          --para mostrar no display
          reg_disp <= regs(rs); 
        WHEN others =>
          
      END CASE;
    END IF;
  END PROCESS;
    
  s0: COMPONENT conv_7seg
  PORT MAP (reg_disp, seg0);
  outp <= reg_disp;
END behav;
