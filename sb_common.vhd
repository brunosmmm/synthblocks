library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

package sb_common is

  --gain block modes
  constant gain_mode_normal : std_logic_vector(3 downto 0) := x"0";
  constant gain_mode_velocity : std_logic_vector(3 downto 0) := x"1";

  --velocity multiplier table generator
  type vel_mult_table is array(0 to 127) of ufixed(2 downto -5);
  function generate_vel_mult return vel_mult_table is
    variable v_table : vel_mult_table;
    variable vel_mult : real;
  begin
    v_table(0) := to_ufixed(0, 2, -5);
    for k in 1 to 127 loop
      vel_mult := real(k) / 127.0;
      v_table(k) := to_ufixed(vel_mult, v_table(k));
    end loop;
    return v_table;
  end function;
  
  
end package;
