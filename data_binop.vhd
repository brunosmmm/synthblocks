library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_binop is
  generic(data_depth : integer := 24);
  port(data_1 : in std_logic_vector(data_depth-1 downto 0);
           data_2 : in std_logic_vector(data_depth-1 downto 0);

           op_sel : in std_logic_vector(2 downto 0);
           
           data_out : out std_logic_vector(data_depth-1 downto 0));

end entity;

architecture operate of data_binop is

  signal multiply : signed(data_depth*2 - 1 downto 0);
  
begin

  multiply <= signed(data_1) * signed(data_2);

  data_out <= data_1 when op_sel = "000" else--data1 passthrough
              data_2 when op_sel = "001" else--data2 passthrough
              std_logic_vector(signed(data_1) + signed(data_2)) when op_sel = "010" else
              std_logic_vector(signed(data_1) - signed(data_2)) when op_sel = "011" else
              std_logic_vector(multiply(data_depth-1 downto 0)) when op_sel = "100" else
              (others=>'0');

end architecture;
