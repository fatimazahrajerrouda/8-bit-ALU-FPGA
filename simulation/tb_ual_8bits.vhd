
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ual_8bits is
end tb_ual_8bits;

architecture Behavioral of tb_ual_8bits is

    -- Entrees de l'UAL
    signal SrcA : STD_LOGIC_VECTOR(7 downto 0)
                  := (others => '0');

    signal SrcB : STD_LOGIC_VECTOR(7 downto 0)
                  := (others => '0');

    signal ALU_Ctrl : STD_LOGIC_VECTOR(3 downto 0)
                      := (others => '0');

    -- Sorties de l'UAL
    signal ALU_Result : STD_LOGIC_VECTOR(15 downto 0);
    signal Zero       : STD_LOGIC;
    signal Cout       : STD_LOGIC;
    signal Overflow   : STD_LOGIC;

begin

    -- ==============================================
    -- INSTANCIATION DE L'UAL
    -- ==============================================

    DUT : entity work.ual_8bits
        port map (
            SrcA       => SrcA,
            SrcB       => SrcB,
            ALU_Ctrl   => ALU_Ctrl,
            ALU_Result => ALU_Result,
            Zero       => Zero,
            Cout       => Cout,
            Overflow   => Overflow
        );

    -- ==============================================
    -- SCENARIO DE TEST
    -- ==============================================

    stimulus : process
    begin

        -- ==========================================
        -- TEST 1 : AND
        -- 12 AND 10 = 8
        -- ==========================================

        SrcA <= x"0C";
        SrcB <= x"0A";
        ALU_Ctrl <= "0000";

        wait for 10 ns;

        assert ALU_Result = x"0008"
            report "Erreur TEST 1 : AND"
            severity error;


        -- ==========================================
        -- TEST 2 : OR
        -- 12 OR 10 = 14
        -- ==========================================

        ALU_Ctrl <= "0001";

        wait for 10 ns;

        assert ALU_Result = x"000E"
            report "Erreur TEST 2 : OR"
            severity error;


        -- ==========================================
        -- TEST 3 : NOT A
        -- NOT 00001100 = 11110011
        -- ==========================================

        ALU_Ctrl <= "0010";

        wait for 10 ns;

        assert ALU_Result = x"00F3"
            report "Erreur TEST 3 : NOT"
            severity error;


        -- ==========================================
        -- TEST 4 : ADDITION SIMPLE
        -- 15 + 10 = 25
        -- ==========================================

        SrcA <= x"0F";
        SrcB <= x"0A";
        ALU_Ctrl <= "0100";

        wait for 10 ns;

        assert ALU_Result = x"0019"
            report "Erreur TEST 4 : ADD"
            severity error;

        assert Cout = '0' and Overflow = '0'
            report "Erreur TEST 4 : Flags ADD"
            severity error;

        assert Zero = '0'
            report "Erreur TEST 4 : Zero"
            severity error;


        -- ==========================================
        -- TEST 5 : SOUSTRACTION SIMPLE
        -- 15 - 10 = 5
        -- ==========================================

        ALU_Ctrl <= "0101";

        wait for 10 ns;

        assert ALU_Result = x"0005"
            report "Erreur TEST 5 : SUB"
            severity error;

        assert Cout = '1' and Overflow = '0'
            report "Erreur TEST 5 : Flags SUB"
            severity error;


        -- ==========================================
        -- TEST 6 : MULTIPLICATION SIMPLE
        -- 15 x 10 = 150
        -- ==========================================

        ALU_Ctrl <= "0110";

        wait for 10 ns;

        assert ALU_Result = x"0096"
            report "Erreur TEST 6 : MULT"
            severity error;

        assert Cout = '0' and Overflow = '0'
            report "Erreur TEST 6 : Flags MULT"
            severity error;


        -- ==========================================
        -- TEST 7 : LSL
        -- 5 << 2 = 20
        -- ==========================================

        SrcA <= x"05";
        SrcB <= x"02";
        ALU_Ctrl <= "1000";

        wait for 10 ns;

        assert ALU_Result = x"0014"
            report "Erreur TEST 7 : LSL"
            severity error;


        -- ==========================================
        -- TEST 8 : LSR
        -- 128 >> 2 = 32
        -- ==========================================

        SrcA <= x"80";
        ALU_Ctrl <= "1001";

        wait for 10 ns;

        assert ALU_Result = x"0020"
            report "Erreur TEST 8 : LSR"
            severity error;


        -- ==========================================
        -- TEST 9 : ASR SUR NOMBRE NEGATIF
        -- -128 >> 2 = -32
        -- Resultat 8 bits = E0
        -- Extension par zeros = 00E0
        -- ==========================================

        ALU_Ctrl <= "1010";

        wait for 10 ns;

        assert ALU_Result = x"00E0"
            report "Erreur TEST 9 : ASR negatif"
            severity error;

        assert Zero = '0'
            report "Erreur TEST 9 : Zero ASR"
            severity error;


        -- ==========================================
        -- TEST 10 : ZERO FLAG
        -- 5 - 5 = 0
        -- ==========================================

        SrcA <= x"05";
        SrcB <= x"05";
        ALU_Ctrl <= "0101";

        wait for 10 ns;

        assert ALU_Result = x"0000"
            report "Erreur TEST 10 : Resultat nul"
            severity error;

        assert Zero = '1'
            report "Erreur TEST 10 : Flag Zero"
            severity error;


        -- ==========================================
        -- TEST 11 : ADDITION AVEC RETENUE
        -- 255 + 1 = 256
        -- Resultat sur 8 bits = 0
        -- Cout = 1
        -- ==========================================

        SrcA <= x"FF";
        SrcB <= x"01";
        ALU_Ctrl <= "0100";

        wait for 10 ns;

        assert ALU_Result = x"0000"
            report "Erreur TEST 11 : ADD Carry"
            severity error;

        assert Cout = '1'
            report "Erreur TEST 11 : Cout"
            severity error;

        assert Zero = '1'
            report "Erreur TEST 11 : Zero"
            severity error;


        -- ==========================================
        -- TEST 12 : OVERFLOW EN ADDITION
        -- 127 + 1 = 128
        -- Overflow signe = 1
        -- ==========================================

        SrcA <= x"7F";
        SrcB <= x"01";
        ALU_Ctrl <= "0100";

        wait for 10 ns;

        assert ALU_Result = x"0080"
            report "Erreur TEST 12 : ADD Overflow"
            severity error;

        assert Overflow = '1'
            report "Erreur TEST 12 : Flag Overflow"
            severity error;

        assert Cout = '0'
            report "Erreur TEST 12 : Cout"
            severity error;


        -- ==========================================
        -- TEST 13 : MULTIPLICATION MAXIMALE
        -- 255 x 255 = 65025
        -- Resultat sur 16 bits = FE01
        -- ==========================================

        SrcA <= x"FF";
        SrcB <= x"FF";
        ALU_Ctrl <= "0110";

        wait for 10 ns;

        assert ALU_Result = x"FE01"
            report "Erreur TEST 13 : MULT 16 bits"
            severity error;

        assert Zero = '0'
            report "Erreur TEST 13 : Zero MULT"
            severity error;

        assert Cout = '0' and Overflow = '0'
            report "Erreur TEST 13 : Flags MULT"
            severity error;


        -- ==========================================
        -- TEST 14 : OPERATION NON DEFINIE
        -- ALU_Ctrl = 1111
        -- Resultat attendu = 0
        -- ==========================================

        ALU_Ctrl <= "1111";

        wait for 10 ns;

        assert ALU_Result = x"0000"
            report "Erreur TEST 14 : Mode reserve"
            severity error;

        assert Zero = '1'
            report "Erreur TEST 14 : Zero"
            severity error;

        assert Cout = '0' and Overflow = '0'
            report "Erreur TEST 14 : Flags"
            severity error;


        -- ==========================================
        -- TEST 15 : SOUSTRACTION AVEC OVERFLOW
        -- 127 - (-1) = 128
        -- 128 non representable sur 8 bits signes
        -- Overflow = 1
        -- ==========================================

        SrcA <= x"7F";       -- +127
        SrcB <= x"FF";       -- -1
        ALU_Ctrl <= "0101";  -- Soustraction

        wait for 10 ns;

        assert ALU_Result = x"0080"
            report "Erreur TEST 15 : SUB Overflow"
            severity error;

        assert Overflow = '1'
            report "Erreur TEST 15 : Flag Overflow SUB"
            severity error;

        assert Cout = '0'
            report "Erreur TEST 15 : Cout SUB"
            severity error;

        assert Zero = '0'
            report "Erreur TEST 15 : Zero SUB"
            severity error;


        -- ==========================================
        -- FIN DE LA SIMULATION
        -- ==========================================

        report "Tous les tests de l'UAL sont termines."
            severity note;

        wait;

    end process;

end Behavioral;
