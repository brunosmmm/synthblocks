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

  --calculate gains
  signal calculate_normal : signed(data_depth-1 downto 0);

  --velocity mode
  --multiplier table
  constant vm_tab : vel_mult_table := generate_vel_mult;
  constant env_tab : env_mult_table := generate_env_mult;
  
  signal velocity_multiplier : ufixed(2 downto -5);
  signal envelope_multiplier : ufixed(2 downto -5);
  signal data_times_vel : signed(data_depth-1 downto 0);
  signal data_times_env : signed(data_depth-1 downto 0);
  
  signal data_in_f : sfixed(data_depth-1 downto -5);
  --interpret as fixed point directly
  signal gain_in_f : sfixed(gain_res-6 downto -5);
  
begin


  data_out <= std_logic_vector(data_times_vel) when gain_mode = gain_mode_velocity else
              std_logic_vector(data_times_env) when gain_mode = gain_mode_envelope else
              std_logic_vector(calculate_normal);

  --data_in to fixed
  data_in_f <= to_sfixed(signed(data_in), data_in_f);
  gain_in_f <= to_sfixed(gain_in, gain_in_f);
  
  --calculate directly
  calculate_normal <= to_signed(data_in_f * gain_in_f, calculate_normal);

  --scale with velocity

  --velocity multiplier
  velocity_multiplier <= vm_tab(to_integer(unsigned(gain_in))) when gain_mode = gain_mode_velocity else
                         (others=>'0');
  data_times_vel <= to_signed(data_in_f * to_sfixed(velocity_multiplier),
                              data_times_vel);

  envelope_multiplier <= env_tab(to_integer(unsigned(gain_in))) when gain_mode = gain_mode_envelope else
                         (others=>'0');
  data_times_env <= to_signed(data_in_f * to_sfixed(envelope_multiplier),
                              data_times_env);


end architecture;
