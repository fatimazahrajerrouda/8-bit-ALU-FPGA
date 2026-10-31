
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_bloc_logique is
end tb_bloc_logique;

architecture Behavioral of tb_bloc_logique is

    signal A          : STD_LOGIC_VECTOR(7 downto 0);
    signal B          : STD_LOGIC_VECTOR(7 downto 0);
    signal Sel_Op     : STD_LOGIC_VECTOR(1 downto 0);
    signal Y_Logique  : STD_LOGIC_VECTOR(7 downto 0);

begin

    DUT : entity work.bloc_logique
        port map (
            A         => A,
            B         => B,
            Sel_Op    => Sel_Op,
            Y_Logique => Y_Logique
        );

    stimulus : process
    begin

        -- Test AND
        A <= x"0F";
        B <= x"33";
        Sel_Op <= "00";
        wait for 10 ns;

        assert Y_Logique = x"03"
            report "Erreur AND"
            severity error;

        -- Test OR
        Sel_Op <= "01";
        wait for 10 ns;

        assert Y_Logique = x"3F"
            report "Erreur OR"
            severity error;

        -- Test NOT
        Sel_Op <= "10";
        wait for 10 ns;

        assert Y_Logique = x"F0"
            report "Erreur NOT"
            severity error;

        report "Tous les tests du bloc logique sont termines."
            severity note;

        wait;

    end process;

end Behavioral;
