
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_barrel_shifter is
end tb_barrel_shifter;

architecture Behavioral of tb_barrel_shifter is

    -- Signaux du testbench
    signal Data_In    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Shift_Amt  : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Shift_Mode : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal Data_Out   : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Instanciation du Barrel Shifter
    DUT : entity work.barrel_shifter
        port map (
            Data_In    => Data_In,
            Shift_Amt  => Shift_Amt,
            Shift_Mode => Shift_Mode,
            Data_Out   => Data_Out
        );

    -- Stimuli
    stimulus : process
    begin

        -- TEST 1 : LSL de 1 position
        -- 00000101 (5) -> 00001010 (10)
        Data_In    <= "00000101";
        Shift_Amt  <= "001";
        Shift_Mode <= "00";
        wait for 10 ns;
        assert Data_Out = "00001010"
            report "Erreur TEST 1 : LSL"
            severity error;

        -- TEST 2 : LSL de 2 positions
        -- 00000101 (5) -> 00010100 (20)
        Data_In    <= "00000101";
        Shift_Amt  <= "010";
        Shift_Mode <= "00";
        wait for 10 ns;
        assert Data_Out = "00010100"
            report "Erreur TEST 2 : LSL"
            severity error;

        -- TEST 3 : LSR de 2 positions
        -- 11111011 (251) -> 00111110 (62)
        Data_In    <= "11111011";
        Shift_Amt  <= "010";
        Shift_Mode <= "01";
        wait for 10 ns;
        assert Data_Out = "00111110"
            report "Erreur TEST 3 : LSR"
            severity error;

        -- TEST 4 : LSR de 3 positions
        -- 11010110 (214) -> 00011010 (26)
        Data_In    <= "11010110";
        Shift_Amt  <= "011";
        Shift_Mode <= "01";
        wait for 10 ns;
        assert Data_Out = "00011010"
            report "Erreur TEST 4 : LSR"
            severity error;

        -- TEST 5 : ASR de 2 positions (nombre negatif)
        -- 11111011 (-5) -> 11111110 (-2)
        Data_In    <= "11111011";
        Shift_Amt  <= "010";
        Shift_Mode <= "10";
        wait for 10 ns;
        assert Data_Out = "11111110"
            report "Erreur TEST 5 : ASR negatif"
            severity error;

        -- TEST 6 : ASR de 2 positions (nombre positif)
        -- 01011000 (88) -> 00010110 (22)
        Data_In    <= "01011000";
        Shift_Amt  <= "010";
        Shift_Mode <= "10";
        wait for 10 ns;
        assert Data_Out = "00010110"
            report "Erreur TEST 6 : ASR positif"
            severity error;

        -- TEST 7 : Aucun decalage
        Data_In    <= "10101010";
        Shift_Amt  <= "000";
        Shift_Mode <= "00";
        wait for 10 ns;
        assert Data_Out = "10101010"
            report "Erreur TEST 7 : Aucun decalage"
            severity error;

        -- TEST 8 : Mode reserve
        Data_In    <= "11111111";
        Shift_Amt  <= "011";
        Shift_Mode <= "11";
        wait for 10 ns;
        assert Data_Out = "00000000"
            report "Erreur TEST 8 : Mode reserve"
            severity error;

        report "Tous les tests du Barrel Shifter sont termines."
            severity note;

        wait;

    end process;

end Behavioral;
