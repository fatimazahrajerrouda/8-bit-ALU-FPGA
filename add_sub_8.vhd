
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_sub_8 is
    Port (
        A        : in  STD_LOGIC_VECTOR(7 downto 0);
        B        : in  STD_LOGIC_VECTOR(7 downto 0);
        Sub      : in  STD_LOGIC;
        R_Arith  : out STD_LOGIC_VECTOR(7 downto 0);
        Cout     : out STD_LOGIC;
        Overflow : out STD_LOGIC
    );
end add_sub_8;

architecture Behavioral of add_sub_8 is

    signal B_mod : STD_LOGIC_VECTOR(7 downto 0);
    signal Sum_9 : UNSIGNED(8 downto 0);

begin

    -- Inversion conditionnelle de B
    B_mod <= B xor (7 downto 0 => Sub);

    -- Addition / Soustraction sur 9 bits
    Sum_9 <= ('0' & unsigned(A))
           + ('0' & unsigned(B_mod))
           + unsigned'("00000000" & Sub);

    -- Resultat sur 8 bits
    R_Arith <= std_logic_vector(Sum_9(7 downto 0));

    -- Carry Out
    Cout <= Sum_9(8);

    -- Overflow signe
    Overflow <= (not (A(7) xor B_mod(7)))
                and (A(7) xor Sum_9(7));

end Behavioral;
