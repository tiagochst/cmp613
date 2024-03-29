LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY q2a IS
  PORT (a,bi: IN STD_LOGIC_VECTOR(0 to 3);
      z: BUFFER STD_LOGIC_VECTOR(0 to 3);
      s: IN STD_LOGIC;
      ovf: OUT STD_LOGIC);
END q2a;

ARCHITECTURE struct OF q2a IS
  SIGNAL cint, b: STD_LOGIC_VECTOR(0 to 3);
COMPONENT somador IS
  PORT ( c0, a0, a1 : IN STD_LOGIC ;
    b0, c1 : OUT STD_LOGIC ) ;
END COMPONENT somador;
BEGIN
  PROCESS (bi, s)
  BEGIN IF s = '0' THEN
      b(3)<=not bi(3) xor (not bi(0) and not bi(1) 
            and not bi(2));
      b(2)<=not bi(2) xor (not bi(0) and not bi(1));
      b(1)<=not bi(1) xor not bi(0);
      b(0)<=bi(0);
    ELSE b<=bi;
    END IF;
  END PROCESS;
  
  s0: COMPONENT somador
    PORT MAP ('0', a(0), b(0), z(0), cint(0));
  s1: COMPONENT somador
    PORT MAP (cint(0), a(1), b(1), z(1), cint(1));
  s2: COMPONENT somador
    PORT MAP (cint(1), a(2), b(2), z(2), cint(2));
  s3: COMPONENT somador
    PORT MAP (cint(2), a(3), b(3), z(3), cint(3));
    
  ovf<=(b(3) and a(3) and not z(3)) or 
       (not b(3) and not a(3) and z(3));
END struct;
