--Demonstração apenas do código alterado no lab
--Inserção do componente conv_7seg
--Para ver código completo em vhdl veja q5/mvmouse.vhd

--código removido
architecture struct of mvmouse IS

    -- Display 7 segmentos
    COMPONENT conv_7seg IS
	  PORT (x: IN STD_LOGIC_VECTOR(3 downto 0);
	        y: OUT STD_LOGIC_VECTOR(6 downto 0));
    END COMPONENT conv_7seg;

--código removido
end struct;
