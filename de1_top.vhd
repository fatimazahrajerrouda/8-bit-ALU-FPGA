
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity de1_top is
    generic (
        DEBOUNCE_LIMIT : natural := 999999
    );
    Port (
        CLOCK_50 : in STD_LOGIC;

        SW  : in STD_LOGIC_VECTOR(9 downto 0);
        KEY : in STD_LOGIC_VECTOR(3 downto 0);

        HEX0 : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1 : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2 : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3 : out STD_LOGIC_VECTOR(6 downto 0);

        LEDR : out STD_LOGIC_VECTOR(9 downto 0)
    );
end de1_top;

architecture Structural of de1_top is

    -- Registres des operandes
    signal Reg_A : STD_LOGIC_VECTOR(7 downto 0)
                   := (others => '0');

    signal Reg_B : STD_LOGIC_VECTOR(7 downto 0)
                   := (others => '0');

    -- Compteur du sous-mode
    signal Sous_Mode : UNSIGNED(1 downto 0)
                       := "00";

    signal ALU_Ctrl_Int : STD_LOGIC_VECTOR(3 downto 0);

    -- Sorties de l'UAL
    signal Result_Int : STD_LOGIC_VECTOR(15 downto 0);
    signal Zero_Int, Cout_Int, Overflow_Int : STD_LOGIC;

    -- Valeur envoyee aux afficheurs
    signal Display_Data : STD_LOGIC_VECTOR(15 downto 0);

    -- Synchronisation des boutons
    signal Key_Meta : STD_LOGIC_VECTOR(3 downto 0)
                      := (others => '1');

    signal Key_Sync : STD_LOGIC_VECTOR(3 downto 0)
                      := (others => '1');

    -- Etats debounces : 1 = relache, 0 = appuye
    signal Key_Stable : STD_LOGIC_VECTOR(3 downto 0)
                        := (others => '1');

    signal Key_Prev : STD_LOGIC_VECTOR(2 downto 0)
                      := (others => '1');


    type Counter_Array is array (0 to 3) of
        natural range 0 to DEBOUNCE_LIMIT;

    signal Debounce_Cnt : Counter_Array
                          := (others => 0);

    -- Decodeur hexadecimal vers 7 segments
    -- Segments actifs a l'etat bas
    function hex_to_7seg(
        digit : STD_LOGIC_VECTOR(3 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000110"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when others => return "0001110"; -- F
        end case;
    end function;

begin

    -- =========================================
    -- 1. SYNCHRONISATION DES BOUTONS
    -- =========================================

    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            Key_Meta <= KEY;
            Key_Sync <= Key_Meta;
        end if;
    end process;

    -- =========================================
    -- 2. ANTI-REBOND DES QUATRE BOUTONS
    -- =========================================

    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            for i in 0 to 3 loop

                if Key_Sync(i) = Key_Stable(i) then
                    Debounce_Cnt(i) <= 0;

                elsif Debounce_Cnt(i) = DEBOUNCE_LIMIT then
                    Key_Stable(i) <= Key_Sync(i);
                    Debounce_Cnt(i) <= 0;

                else
                    Debounce_Cnt(i) <= Debounce_Cnt(i) + 1;
                end if;

            end loop;
        end if;
    end process;

    -- =========================================
    -- 3. MEMORISATION A / B ET SOUS-MODE
    -- =========================================

    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then

            -- Detection du front d'appui
            -- Les boutons KEY sont actifs a 0

            if Key_Prev(0) = '1' and
               Key_Stable(0) = '0' then
                Reg_A <= SW(7 downto 0);
            end if;

            if Key_Prev(1) = '1' and
               Key_Stable(1) = '0' then
                Reg_B <= SW(7 downto 0);
            end if;

            if Key_Prev(2) = '1' and
               Key_Stable(2) = '0' then
                Sous_Mode <= Sous_Mode + 1;
            end if;

            Key_Prev <= Key_Stable(2 downto 0);

        end if;
    end process;

    -- =========================================
    -- 4. CONSTRUCTION DE ALU_Ctrl
    -- =========================================

    ALU_Ctrl_Int <= SW(9 downto 8) &
                    STD_LOGIC_VECTOR(Sous_Mode);

    -- =========================================
    -- 5. INSTANCIATION DE L'UAL
    -- =========================================

    U_ALU : entity work.ual_8bits
        port map (
            SrcA       => Reg_A,
            SrcB       => Reg_B,
            ALU_Ctrl   => ALU_Ctrl_Int,
            ALU_Result => Result_Int,
            Zero       => Zero_Int,
            Cout       => Cout_Int,
            Overflow   => Overflow_Int
        );

    -- =========================================
    -- 6. SELECTION DE L'AFFICHAGE
    -- =========================================

    -- KEY3 maintenu : afficher A puis B
    -- Sinon : afficher le resultat 16 bits

    Display_Data <= Reg_A & Reg_B
                    when Key_Stable(3) = '0'
                    else Result_Int;

    -- =========================================
    -- 7. DECODAGE DES QUATRE AFFICHEURS
    -- =========================================

    HEX0 <= hex_to_7seg(Display_Data(3 downto 0));
    HEX1 <= hex_to_7seg(Display_Data(7 downto 4));
    HEX2 <= hex_to_7seg(Display_Data(11 downto 8));
    HEX3 <= hex_to_7seg(Display_Data(15 downto 12));

    -- =========================================
    -- 8. AFFICHAGE DES FLAGS
    -- =========================================

    LEDR(0) <= Zero_Int;
    LEDR(1) <= Cout_Int;
    LEDR(2) <= Overflow_Int;

    LEDR(9 downto 3) <= (others => '0');

end Structural;
