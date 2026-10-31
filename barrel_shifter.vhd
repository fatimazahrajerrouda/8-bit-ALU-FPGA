
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity barrel_shifter is
    Port (
        Data_In    : in  STD_LOGIC_VECTOR(7 downto 0);
        Shift_Amt  : in  STD_LOGIC_VECTOR(2 downto 0);
        Shift_Mode : in  STD_LOGIC_VECTOR(1 downto 0);
        Data_Out   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end barrel_shifter;

architecture Behavioral of barrel_shifter is
begin

    process(Data_In, Shift_Amt, Shift_Mode)
    begin
        case Shift_Mode is

            when "00" =>
                -- LSL : Logical Shift Left
                Data_Out <= std_logic_vector(
                    shift_left(
                        unsigned(Data_In),
                        to_integer(unsigned(Shift_Amt))
                    )
                );

            when "01" =>
                -- LSR : Logical Shift Right
                Data_Out <= std_logic_vector(
                    shift_right(
                        unsigned(Data_In),
                        to_integer(unsigned(Shift_Amt))
                    )
                );

            when "10" =>
                -- ASR : Arithmetic Shift Right
                Data_Out <= std_logic_vector(
                    shift_right(
                        signed(Data_In),
                        to_integer(unsigned(Shift_Amt))
                    )
                );

            when others =>
                Data_Out <= (others => '0');

        end case;
    end process;

end Behavioral;
