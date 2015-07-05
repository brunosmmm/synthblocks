library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pitch_shifter is
  port (shamt : in std_logic_vector(7 downto 0);
        pitch_in : in std_logic_vector(6 downto 0);
        pitch_out : out std_logic_vector(6 downto 0)
        );
end entity;

architecture shift of pitch_shifter is

  constant min_pitch : std_logic_vector(6 downto 0) := "0000000";
  constant max_pitch : std_logic_vector(6 downto 0) := "1111111";

  signal calculate_pitch : signed(7 downto 0);
  
begin

  --signed sum
  calculate_pitch <= signed('0' & pitch_in) + signed(shamt);

  --saturate
  pitch_out <= min_pitch when calculate_pitch < signed("0" & min_pitch) else
               max_pitch when calculate_pitch > signed("0" & max_pitch) else
               std_logic_vector(calculate_pitch(6 downto 0));

end architecture;
