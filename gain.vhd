library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.sb_common.all;

entity gain is
  generic(data_depth : integer := 24;
          gain_res : integer := 16;
          gain_mode : std_logic_vector(3 downto 0) := gain_mode_normal);
  port(data_in : in std_logic_vector(data_depth-1 downto 0);
       gain_in : in std_logic_vector(gain_res-1 downto 0);

       data_out : out std_logic_vector(data_depth-1 downto 0));
end entity;

architecture modify of gain is

  --signal multiply : real;
  signal multiply: sfixed(data_depth/2 - 1 downto -data_depth/2);
  --constant gain_multiplier : real := 1.0/real(2**15);

  --calculate gains
  --signal calculate_velocity : signed(data_depth-1 downto 0);
  signal calculate_normal : std_logic_vector(data_depth-1 downto 0);

  --velocity mode
  --multiplier table
  constant vm_tab : vel_mult_table := generate_vel_mult;
  signal velocity_multiplier : ufixed(2 downto -5);
  signal data_times_vel : signed(data_depth-1 downto 0); --sfixed(data_depth/2 -1 downto -data_depth/2);
  
  signal data_in_f : sfixed(data_depth-1 downto -5);
  
begin


  data_out <= std_logic_vector(data_times_vel) when gain_mode = gain_mode_velocity else
              calculate_normal;

  --data_in to fixed
  data_in_f <= to_sfixed(signed(data_in), data_in_f); 
  
  --passthrough for now
  calculate_normal <= data_in;

  --scale with velocity

  --velocity multiplier
  velocity_multiplier <= vm_tab(to_integer(unsigned(gain_in)));
  data_times_vel <= to_signed(data_in_f * to_sfixed(velocity_multiplier),
                              data_times_vel);
  
  --multiply
  --multiply <= real(to_integer(signed(gain_in))) * gain_multiplier * real(to_integer(signed(data_in)));

  --saturate
  --data_out <= std_logic_vector(to_signed(multiply, data_depth));


end architecture;
