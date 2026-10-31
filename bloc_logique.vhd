library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bloc_logique is
    Port (
        A       : in  STD_LOGIC_VECTOR(7 downto 0);
        B       : in  STD_LOGIC_VECTOR(7 downto 0);
        Sel_Op  : in  STD_LOGIC_VECTOR(1 downto 0);
        Y_Logique : out STD_LOGIC_VECTOR(7 downto 0)
    );
end bloc_logique;

architecture Behavioral of bloc_logique is
begin

    process(A, B, Sel_Op)
    begin
        case Sel_Op is
            when "00" =>
                Y_Logique <= A and B;

            when "01" =>
                Y_Logique <= A or B;

            when "10" =>
                Y_Logique <= not A;

            when others =>
                Y_Logique <= (others => '0');
        end case;
    end process;

end Behavioral;
