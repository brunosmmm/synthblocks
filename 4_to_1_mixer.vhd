library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mix_4_to_1 is
  generic(data_depth : integer := 24;
          gain_res : integer := 16);
  port(in_1 : in std_logic_vector(data_depth-1 downto 0);
       in_2 : in std_logic_vector(data_depth-1 downto 0);
       in_3 : in std_logic_vector(data_depth-1 downto 0);
       in_4 : in std_logic_vector(data_depth-1 downto 0);

       mix_out : out std_logic_vector(data_depth-1 downto 0);

       gain_1 : in std_logic_vector(gain_res-1 downto 0);
       gain_2 : in std_logic_vector(gain_res-1 downto 0);
       gain_3 : in std_logic_vector(gain_res-1 downto 0);
       gain_4 : in std_logic_vector(gain_res-1 downto 0)
       );
end entity;

architecture mix of mix_4_to_1 is

  signal in_1_g : std_logic_vector(data_depth-1 downto 0);
  signal in_2_g : std_logic_vector(data_depth-1 downto 0);
  signal in_3_g : std_logic_vector(data_depth-1 downto 0);
  signal in_4_g : std_logic_vector(data_depth-1 downto 0);

  signal all_mixed : signed(data_depth-1 downto 0);
  
begin

  --gain blocks

  g1: entity work.gain(modify)
    generic map(data_depth=>data_depth,
                gain_res=>gain_res)
    port map(data_in=>in_1,
             gain_in=>gain_1,
             data_out=>in_1_g);
  g2: entity work.gain(modify)
    generic map(data_depth=>data_depth,
                gain_res=>gain_res)
    port map(data_in=>in_2,
             gain_in=>gain_2,
             data_out=>in_2_g);
  g3: entity work.gain(modify)
    generic map(data_depth=>data_depth,
                gain_res=>gain_res)
    port map(data_in=>in_3,
             gain_in=>gain_3,
             data_out=>in_3_g);
  g4: entity work.gain(modify)
    generic map(data_depth=>data_depth,
                gain_res=>gain_res)
    port map(data_in=>in_4,
             gain_in=>gain_4,
             data_out=>in_4_g);

  --sum everything
  all_mixed <= signed(in_1_g) + signed(in_2_g) + signed(in_3_g) + signed(in_4_g);
  mix_out <= std_logic_vector(all_mixed);
  
end architecture;
