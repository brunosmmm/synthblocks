library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity gain is
  generic(data_depth : integer := 24);
  port(data_in : in std_logic_vector(data_depth-1 downto 0);
       gain_in : in std_logic_vector(15 downto 0);

       data_out : out std_logic_vector(data_depth-1 downto 0));

end entity;

architecture modify of gain is

  --signal multiply : real;
  signal multiply: sfixed(data_depth/2 - 1 downto -data_depth/2);
  --constant gain_multiplier : real := 1.0/real(2**15);
  
begin

  --passthrough for now
  data_out <= data_in;

  --multiply
  --multiply <= real(to_integer(signed(gain_in))) * gain_multiplier * real(to_integer(signed(data_in)));

  --saturate
  --data_out <= std_logic_vector(to_signed(multiply, data_depth));


end architecture;
