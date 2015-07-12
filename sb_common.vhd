library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

package sb_common is

  --gain block modes
  constant gain_mode_normal : std_logic_vector(3 downto 0) := x"0";
  constant gain_mode_velocity : std_logic_vector(3 downto 0) := x"1";

  --default register values
  constant v_shamt_12 : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_shamt_34 : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_cmat1 : std_logic_vector(15 downto 0) := x"0001";
  constant v_cmat2 : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_oscsel : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_opsel : std_logic_vector(15 downto 0) := (others=>'0');
  constant v_pconf1 : std_logic_vector(15 downto 0) := x"0001";
  constant v_adsr_a : std_logic_vector(15 downto 0) := x"0010";
  constant v_adsr_d : std_logic_vector(15 downto 0) := x"0010";
  constant v_adsr_s : std_logic_vector(15 downto 0) := x"0040";
  constant v_adsr_r : std_logic_vector(15 downto 0) := x"0010";

  --control bus base addresses
  constant voice_0_base : std_logic_vector(15 downto 0) := x"0000";
  constant voice_1_base : std_logic_vector(15 downto 0) := x"0010";
  constant voice_2_base : std_logic_vector(15 downto 0) := x"0020";
  constant voice_3_base : std_logic_vector(15 downto 0) := x"0030";  

  --velocity multiplier table generator
  type vel_mult_table is array(0 to 127) of ufixed(2 downto -5);
  function generate_vel_mult return vel_mult_table;
  
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

end package body;
