library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

package sb_common is

  --gain block modes
  constant gain_mode_normal : std_logic_vector(3 downto 0) := x"0";
  constant gain_mode_velocity : std_logic_vector(3 downto 0) := x"1";
  constant gain_mode_envelope : std_logic_vector(3 downto 0) := x"2";

  --default register values
  constant v_shamt_12 : std_logic_vector(15 downto 0) := x"0C00";
  constant v_shamt_34 : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_cmat1 : std_logic_vector(15 downto 0) := x"0011";
  constant v_cmat2 : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_oscsel : std_logic_vector(15 downto 0) := x"0009";
  constant v_opsel : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_pconf1 : std_logic_vector(15 downto 0) := x"0001";
  constant v_adsr_a : std_logic_vector(15 downto 0) := x"0008";
  constant v_adsr_d : std_logic_vector(15 downto 0) := x"0008";
  constant v_adsr_s : std_logic_vector(15 downto 0) := x"0080";
  constant v_adsr_r : std_logic_vector(15 downto 0) := x"0001";

  --control bus base addresses
  constant voice_0_base : std_logic_vector(15 downto 0) := x"0000";
  constant voice_1_base : std_logic_vector(15 downto 0) := x"0010";
  constant voice_2_base : std_logic_vector(15 downto 0) := x"0020";
  constant voice_3_base : std_logic_vector(15 downto 0) := x"0030";  

  --velocity or envelope multiplier table generator
  type vel_mult_table is array(0 to 127) of ufixed(2 downto -5);
  type env_mult_table is array(0 to 255) of ufixed(2 downto -5);
  function generate_vel_mult return vel_mult_table;
  function generate_env_mult return env_mult_table;
  
end package;

package body sb_common is
  
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

  function generate_env_mult return env_mult_table is
    variable v_table : env_mult_table;
    variable env_mult : real;
  begin
    v_table(0) := to_ufixed(0, 2, -5);
    for k in 1 to 255 loop
      env_mult := real(k) / 255.0;
      v_table(k) := to_ufixed(env_mult, v_table(k));
    end loop;
    return v_table;
  end function;

end package body;
