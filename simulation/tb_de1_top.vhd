
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_de1_top is
end tb_de1_top;

architecture Behavioral of tb_de1_top is

    signal CLOCK_50 : STD_LOGIC := '0';

    signal SW : STD_LOGIC_VECTOR(9 downto 0)
                := (others => '0');

    signal KEY : STD_LOGIC_VECTOR(3 downto 0)
                 := (others => '1');

    signal HEX0, HEX1, HEX2, HEX3 :
        STD_LOGIC_VECTOR(6 downto 0);

    signal LEDR : STD_LOGIC_VECTOR(9 downto 0);

    -- Conversion HEX vers segments actifs a 0
    function seg7(
        d : STD_LOGIC_VECTOR(3 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        case d is
            when "0000" => return "1000000";
            when "0001" => return "1111001";
            when "0010" => return "0100100";
            when "0011" => return "0110000";
            when "0100" => return "0011001";
            when "0101" => return "0010010";
            when "0110" => return "0000010";
            when "0111" => return "1111000";
            when "1000" => return "0000000";
            when "1001" => return "0010000";
            when "1010" => return "0001000";
            when "1011" => return "0000011";
            when "1100" => return "1000110";
            when "1101" => return "0100001";
            when "1110" => return "0000110";
            when others => return "0001110";
        end case;
    end function;

begin

    -- Horloge 50 MHz
    CLOCK_50 <= not CLOCK_50 after 10 ns;

    -- Instanciation du Wrapper
    DUT : entity work.de1_top
        generic map (
            DEBOUNCE_LIMIT => 4
        )
        port map (
            CLOCK_50 => CLOCK_50,
            SW       => SW,
            KEY      => KEY,
            HEX0     => HEX0,
            HEX1     => HEX1,
            HEX2     => HEX2,
            HEX3     => HEX3,
            LEDR     => LEDR
        );

    process

        -- Simuler un appui puis un relachement
        procedure press_key(
            constant n : in natural
        ) is
        begin
            KEY(n) <= '0';
            wait for 200 ns;
            KEY(n) <= '1';
            wait for 200 ns;
        end procedure;

        -- Charger les deux operandes
        procedure load_operands(
            constant a : in STD_LOGIC_VECTOR(7 downto 0);
            constant b : in STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            SW(7 downto 0) <= a;
            wait for 100 ns;
            press_key(0);

            SW(7 downto 0) <= b;
            wait for 100 ns;
            press_key(1);
        end procedure;

        -- Verifier les quatre afficheurs HEX
        procedure check_display(
            constant expected : in STD_LOGIC_VECTOR(15 downto 0);
            constant test_name : in string
        ) is
        begin
            assert HEX0 = seg7(expected(3 downto 0)) and
                   HEX1 = seg7(expected(7 downto 4)) and
                   HEX2 = seg7(expected(11 downto 8)) and
                   HEX3 = seg7(expected(15 downto 12))
            report "Erreur affichage : " & test_name
            severity error;
        end procedure;

        -- Verifier les trois flags
        procedure check_flags(
            constant z : in STD_LOGIC;
            constant c : in STD_LOGIC;
            constant v : in STD_LOGIC;
            constant test_name : in string
        ) is
        begin
            assert LEDR(0) = z and
                   LEDR(1) = c and
                   LEDR(2) = v
            report "Erreur flags : " & test_name
            severity error;
        end procedure;

    begin

        wait for 100 ns;

        -- =====================================
        -- TEST 1 : ADD 5 + 3 = 8
        -- =====================================

        load_operands(x"05", x"03");

        SW(9 downto 8) <= "01";
        wait for 100 ns;

        check_display(x"0008", "ADD");
        check_flags('0','0','0', "ADD");

        -- =====================================
        -- TEST 2 : AFFICHAGE A ET B
        -- =====================================

        KEY(3) <= '0';
        wait for 200 ns;

        check_display(x"0503", "Affichage A/B");

        KEY(3) <= '1';
        wait for 200 ns;

        check_display(x"0008", "Retour resultat");

        -- =====================================
        -- TEST 3 : SUB 5 - 3 = 2
        -- =====================================

        press_key(2);
        check_display(x"0002", "SUB");
        check_flags('0','1','0', "SUB");

        -- =====================================
        -- TEST 4 : MUL 5 * 3 = 15
        -- =====================================

        press_key(2);
        check_display(x"000F", "MUL");
        check_flags('0','0','0', "MUL");

        -- =====================================
        -- TEST 5 : OPERATION RESERVEE
        -- =====================================

        press_key(2);
        check_display(x"0000", "Reservee");
        check_flags('1','0','0', "Reservee");

        -- =====================================
        -- TEST 6 : RETOUR ADD
        -- =====================================

        press_key(2);
        check_display(x"0008", "Retour ADD");

        -- =====================================
        -- TEST 7 : AND 12 AND 10 = 8
        -- =====================================

        load_operands(x"0C", x"0A");

        SW(9 downto 8) <= "00";
        wait for 100 ns;

        check_display(x"0008", "AND");

        -- =====================================
        -- TEST 8 : OR 12 OR 10 = 14
        -- =====================================

        press_key(2);
        check_display(x"000E", "OR");

        -- =====================================
        -- TEST 9 : NOT 12 = F3
        -- =====================================

        press_key(2);
        check_display(x"00F3", "NOT");

        -- =====================================
        -- TEST 10 : CHARGEMENT POUR SHIFT
        -- =====================================

        load_operands(x"80", x"02");

        -- Sous_Mode = 10
        -- Deux appuis pour revenir a 00

        press_key(2);
        press_key(2);

        SW(9 downto 8) <= "10";
        wait for 100 ns;

        -- =====================================
        -- TEST 11 : LSL
        -- =====================================

        check_display(x"0000", "LSL");
        check_flags('1','0','0', "LSL");

        -- =====================================
        -- TEST 12 : LSR
        -- =====================================

        press_key(2);
        check_display(x"0020", "LSR");

        -- =====================================
        -- TEST 13 : ASR
        -- =====================================

        press_key(2);
        check_display(x"00E0", "ASR");

        -- =====================================
        -- TEST 14 : COUT
        -- =====================================

        -- Sous_Mode = 10
        -- Deux appuis pour revenir a 00

        press_key(2);
        press_key(2);

        load_operands(x"FF", x"01");

        SW(9 downto 8) <= "01";
        wait for 100 ns;

        -- 255 + 1 = 256
        -- Resultat 8 bits = 00
        -- Cout = 1

        check_display(x"0000", "Cout ADD");
        check_flags('1','1','0', "Cout ADD");

        -- =====================================
        -- TEST 15 : OVERFLOW
        -- =====================================

        load_operands(x"7F", x"01");
        wait for 100 ns;

        -- 127 + 1 = 128
        -- Resultat 8 bits = 80
        -- Overflow = 1

        check_display(x"0080", "Overflow ADD");
        check_flags('0','0','1', "Overflow ADD");

        -- =====================================
        -- FIN
        -- =====================================

        report "TOUS LES TESTS DU WRAPPER SONT TERMINES"
        severity note;

        wait;

    end process;

end Behavioral;
