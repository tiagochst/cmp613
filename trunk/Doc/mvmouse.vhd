--Demonstra��o apenas do c�digo alterado no lab
--Inser��o do componente conv_7seg
--Para ver c�digo completo em vhdl veja q5/mvmouse.vhd

--c�digo removido
architecture struct of mvmouse IS

    -- Display 7 segmentos
    COMPONENT conv_7seg IS
	  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	        y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;

--c�digo removido
end struct;
