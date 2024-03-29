LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY reg4 IS
  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
        clk: IN STD_LOGIC;
        q: OUT STD_LOGIC_VECTOR(3 downto 0));
END reg4;

ARCHITECTURE struct OF reg4 IS
  SIGNAL cont: STD_LOGIC_VECTOR(3 downto 0) := "0000";
BEGIN
  PROCESS (clk) BEGIN
    IF (clk'event AND clk='1') THEN
      cont<=x;
    END IF;
    q<=cont;
  END PROCESS;
END;
