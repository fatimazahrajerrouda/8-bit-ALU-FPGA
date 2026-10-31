
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_multiplier_8x8 is
end tb_multiplier_8x8;

architecture Behavioral of tb_multiplier_8x8 is

    -- Signaux du testbench
    signal A      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal B      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Y_Mult : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Instanciation du multiplieur
    DUT : entity work.multiplier_8x8
        port map (
            A      => A,
            B      => B,
            Y_Mult => Y_Mult
        );

    -- Processus de stimulation
    stimulus : process
    begin

        -- TEST 1 : Multiplication simple
        -- 5 x 3 = 15
        A <= std_logic_vector(to_unsigned(5, 8));
        B <= std_logic_vector(to_unsigned(3, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(15, 16)
            report "Erreur TEST 1 : 5 x 3"
            severity error;

        -- TEST 2 : Multiplication par zero
        -- 25 x 0 = 0
        A <= std_logic_vector(to_unsigned(25, 8));
        B <= std_logic_vector(to_unsigned(0, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(0, 16)
            report "Erreur TEST 2 : 25 x 0"
            severity error;

        -- TEST 3 : Multiplication par 1
        -- 100 x 1 = 100
        A <= std_logic_vector(to_unsigned(100, 8));
        B <= std_logic_vector(to_unsigned(1, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(100, 16)
            report "Erreur TEST 3 : 100 x 1"
            severity error;

        -- TEST 4 : Multiplication normale
        -- 12 x 10 = 120
        A <= std_logic_vector(to_unsigned(12, 8));
        B <= std_logic_vector(to_unsigned(10, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(120, 16)
            report "Erreur TEST 4 : 12 x 10"
            severity error;

        -- TEST 5 : Resultat superieur a 8 bits
        -- 200 x 3 = 600
        A <= std_logic_vector(to_unsigned(200, 8));
        B <= std_logic_vector(to_unsigned(3, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(600, 16)
            report "Erreur TEST 5 : 200 x 3"
            severity error;

        -- TEST 6 : Multiplication maximale
        -- 255 x 255 = 65025
        A <= std_logic_vector(to_unsigned(255, 8));
        B <= std_logic_vector(to_unsigned(255, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(65025, 16)
            report "Erreur TEST 6 : 255 x 255"
            severity error;

        -- TEST 7 : Multiplication par puissance de 2
        -- 128 x 2 = 256
        A <= std_logic_vector(to_unsigned(128, 8));
        B <= std_logic_vector(to_unsigned(2, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(256, 16)
            report "Erreur TEST 7 : 128 x 2"
            severity error;

        -- TEST 8 : Commutativite
        -- 3 x 200 = 600
        A <= std_logic_vector(to_unsigned(3, 8));
        B <= std_logic_vector(to_unsigned(200, 8));
        wait for 10 ns;

        assert unsigned(Y_Mult) = to_unsigned(600, 16)
            report "Erreur TEST 8 : Commutativite"
            severity error;

        report "Tous les tests du multiplieur sont termines."
            severity note;

        wait;

    end process;

end Behavioral;
