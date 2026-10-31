
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_add_sub_8 is
end tb_add_sub_8;

architecture Behavioral of tb_add_sub_8 is

    signal A        : STD_LOGIC_VECTOR(7 downto 0);
    signal B        : STD_LOGIC_VECTOR(7 downto 0);
    signal Sub      : STD_LOGIC;
    signal R_Arith  : STD_LOGIC_VECTOR(7 downto 0);
    signal Cout     : STD_LOGIC;
    signal Overflow : STD_LOGIC;

begin

    DUT : entity work.add_sub_8
        port map (
            A        => A,
            B        => B,
            Sub      => Sub,
            R_Arith  => R_Arith,
            Cout     => Cout,
            Overflow => Overflow
        );

    stimulus : process
    begin

        -- Test 1 : Addition 10 + 4 = 14
        A <= x"0A";
        B <= x"04";
        Sub <= '0';
        wait for 10 ns;

        assert R_Arith = x"0E"
            report "Erreur addition 10 + 4"
            severity error;

        assert Cout = '0' and Overflow = '0'
            report "Erreur flags addition"
            severity error;

        -- Test 2 : Soustraction 10 - 4 = 6
        Sub <= '1';
        wait for 10 ns;

        assert R_Arith = x"06"
            report "Erreur soustraction 10 - 4"
            severity error;

        assert Cout = '1' and Overflow = '0'
            report "Erreur flags soustraction 10 - 4"
            severity error;

        -- Test 3 : Soustraction 4 - 10 = -6
        A <= x"04";
        B <= x"0A";
        Sub <= '1';
        wait for 10 ns;

        assert R_Arith = x"FA"
            report "Erreur soustraction 4 - 10"
            severity error;

        assert Cout = '0' and Overflow = '0'
            report "Erreur flags soustraction 4 - 10"
            severity error;

        -- Test 4 : Addition 127 + 1
        A <= x"7F";
        B <= x"01";
        Sub <= '0';
        wait for 10 ns;

        assert R_Arith = x"80"
            report "Erreur addition 127 + 1"
            severity error;

        assert Cout = '0' and Overflow = '1'
            report "Erreur detection Overflow"
            severity error;

        report "Tous les tests ADD/SUB sont termines."
            severity note;

        wait;
    end process;

end Behavioral;
