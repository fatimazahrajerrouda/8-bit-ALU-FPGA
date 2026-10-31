
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_comparaison_add_sub is
end tb_comparaison_add_sub;

architecture Behavioral of tb_comparaison_add_sub is

    -- Entrees communes aux deux architectures
    signal A   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal B   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Sub : STD_LOGIC := '0';

    -- Sorties de l'additionneur comportemental
    signal R_Behav        : STD_LOGIC_VECTOR(7 downto 0);
    signal Cout_Behav     : STD_LOGIC;
    signal Overflow_Behav : STD_LOGIC;

    -- Sorties de l'additionneur Ripple Carry
    signal R_RCA        : STD_LOGIC_VECTOR(7 downto 0);
    signal Cout_RCA     : STD_LOGIC;
    signal Overflow_RCA : STD_LOGIC;

    -- Indicateur d'erreur
    signal Error_Flag : STD_LOGIC := '0';

begin

    ---------------------------------------------------------
    -- 1. Architecture comportementale
    ---------------------------------------------------------

    U_BEHAV : entity work.add_sub_8
        port map (
            A        => A,
            B        => B,
            Sub      => Sub,
            R_Arith  => R_Behav,
            Cout     => Cout_Behav,
            Overflow => Overflow_Behav
        );

    ---------------------------------------------------------
    -- 2. Architecture structurelle Ripple Carry
    ---------------------------------------------------------

    U_RCA : entity work.add_sub_8_rca
        port map (
            A        => A,
            B        => B,
            Sub      => Sub,
            R_Arith  => R_RCA,
            Cout     => Cout_RCA,
            Overflow => Overflow_RCA
        );

    ---------------------------------------------------------
    -- 3. Comparaison automatique des sorties
    -- Effectuee apres stabilisation dans le processus
    ---------------------------------------------------------

    ---------------------------------------------------------
    -- 4. Generation des stimuli
    ---------------------------------------------------------

    process

        procedure Test(
            constant Val_A : in integer;
            constant Val_B : in integer;
            constant Mode  : in STD_LOGIC
        ) is
        begin

            -- Application des entrees
            A   <= std_logic_vector(to_unsigned(Val_A, 8));
            B   <= std_logic_vector(to_unsigned(Val_B, 8));
            Sub <= Mode;

            -- Attendre la stabilisation des circuits
            wait for 10 ns;

            -- Comparaison des resultats
            if (R_Behav /= R_RCA) or
               (Cout_Behav /= Cout_RCA) or
               (Overflow_Behav /= Overflow_RCA) then
                Error_Flag <= '1';
            else
                Error_Flag <= '0';
            end if;

            assert R_Behav = R_RCA
                report "ERREUR : Resultats differents"
                severity error;

            assert Cout_Behav = Cout_RCA
                report "ERREUR : Cout differents"
                severity error;

            assert Overflow_Behav = Overflow_RCA
                report "ERREUR : Overflow differents"
                severity error;

        end procedure;

    begin

        -----------------------------------------------------
        -- Tests d'addition
        -----------------------------------------------------

        Test(5,   3,   '0');
        Test(15,  10,  '0');
        Test(127, 1,   '0');
        Test(255, 1,   '0');
        Test(200, 100, '0');

        -----------------------------------------------------
        -- Tests de soustraction
        -----------------------------------------------------

        Test(5,   3,   '1');
        Test(10,  15,  '1');
        Test(0,   1,   '1');
        Test(127, 255, '1');
        Test(255, 255, '1');

        -----------------------------------------------------
        -- Tests supplementaires
        -----------------------------------------------------

        Test(0,   0,   '0');
        Test(255, 255, '0');
        Test(128, 128, '1');
        Test(100, 50,  '1');
        Test(50,  100, '1');

        -----------------------------------------------------
        -- Fin de simulation
        -----------------------------------------------------

        report "FIN : 15 tests de comparaison executes."
            severity note;

        wait;

    end process;

end Behavioral;
