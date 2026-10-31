
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ual_8bits is
    Port (
        SrcA       : in  STD_LOGIC_VECTOR(7 downto 0);
        SrcB       : in  STD_LOGIC_VECTOR(7 downto 0);
        ALU_Ctrl   : in  STD_LOGIC_VECTOR(3 downto 0);

        ALU_Result : out STD_LOGIC_VECTOR(15 downto 0);
        Zero       : out STD_LOGIC;
        Cout       : out STD_LOGIC;
        Overflow   : out STD_LOGIC
    );
end ual_8bits;

architecture Structural of ual_8bits is

    -- Resultats internes
    signal Result_Logic : STD_LOGIC_VECTOR(7 downto 0);
    signal Result_Arith : STD_LOGIC_VECTOR(7 downto 0);
    signal Result_Shift : STD_LOGIC_VECTOR(7 downto 0);
    signal Result_Mult  : STD_LOGIC_VECTOR(15 downto 0);

    -- Commandes internes
    signal Sel_Logic   : STD_LOGIC_VECTOR(1 downto 0);
    signal Sub_Cmd     : STD_LOGIC;
    signal Shift_Mode  : STD_LOGIC_VECTOR(1 downto 0);

    -- Flags du bloc arithmetique
    signal Cout_Arith     : STD_LOGIC;
    signal Overflow_Arith : STD_LOGIC;

    -- Resultat interne sur 16 bits
    signal Result_Final : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- 1. Decodage des commandes

    Sel_Logic <= ALU_Ctrl(1 downto 0);

    Sub_Cmd <= '1' when ALU_Ctrl = "0101"
               else '0';

    with ALU_Ctrl select
        Shift_Mode <= "00" when "1000",
                      "01" when "1001",
                      "10" when "1010",
                      "11" when others;

    -- 2. Instanciation du bloc logique

    U_LOGIC : entity work.bloc_logique
        port map (
            A         => SrcA,
            B         => SrcB,
            Sel_Op    => Sel_Logic,
            Y_Logique => Result_Logic
        );

    -- 3. Instanciation du bloc arithmetique

    U_ARITH : entity work.add_sub_8
        port map (
            A        => SrcA,
            B        => SrcB,
            Sub      => Sub_Cmd,
            R_Arith  => Result_Arith,
            Cout     => Cout_Arith,
            Overflow => Overflow_Arith
        );

    -- 4. Instanciation du Barrel Shifter

    U_SHIFT : entity work.barrel_shifter
        port map (
            Data_In    => SrcA,
            Shift_Amt  => SrcB(2 downto 0),
            Shift_Mode => Shift_Mode,
            Data_Out   => Result_Shift
        );

    -- 5. Instanciation du multiplieur

    U_MULT : entity work.multiplier_8x8
        port map (
            A      => SrcA,
            B      => SrcB,
            Y_Mult => Result_Mult
        );

    -- 6. Multiplexeur de selection

    process(ALU_Ctrl, Result_Logic,
            Result_Arith, Result_Shift, Result_Mult)
    begin
        case ALU_Ctrl is

            -- AND, OR, NOT
            when "0000" | "0001" | "0010" =>
                Result_Final <= x"00" & Result_Logic;

            -- ADD, SUB
            when "0100" | "0101" =>
                Result_Final <= x"00" & Result_Arith;

            -- MULTIPLICATION
            when "0110" =>
                Result_Final <= Result_Mult;

            -- LSL, LSR, ASR
            when "1000" | "1001" | "1010" =>
                Result_Final <= x"00" & Result_Shift;

            -- Operations non definies
            when others =>
                Result_Final <= (others => '0');

        end case;
    end process;

    -- 7. Sortie globale

    ALU_Result <= Result_Final;

    -- 8. Flag Zero

    Zero <= '1' when Result_Final = x"0000"
            else '0';

    -- 9. Flags arithmetiques

    Cout <= Cout_Arith
            when (ALU_Ctrl = "0100" or
                  ALU_Ctrl = "0101")
            else '0';

    Overflow <= Overflow_Arith
                when (ALU_Ctrl = "0100" or
                      ALU_Ctrl = "0101")
                else '0';

end Structural;
