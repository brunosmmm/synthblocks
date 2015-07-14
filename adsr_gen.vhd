library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sb_common.all;

entity adsr_gen is
  generic(data_depth : integer := 24);
  port(clk : in std_logic;
       rst : in std_logic;

       data_in : in std_logic_vector(data_depth-1 downto 0);
       data_out : out std_logic_vector(data_depth-1 downto 0);

       note_on : in std_logic;
       note_off : in std_logic;

       attack_i : in std_logic_vector(7 downto 0);
       decay_d : in std_logic_vector(7 downto 0);
       release_d : in std_logic_vector(7 downto 0);
       sustain_l : in std_logic_vector(7 downto 0);
       releasing : out std_logic);
end entity;

architecture envelope of adsr_gen is

  signal adsr_gain_s : signed(9 downto 0);
  
  signal adsr_gain : std_logic_vector(7 downto 0);
  constant max_gain : signed(9 downto 0) := "0011111111";
  constant zero_gain : signed(9 downto 0) := (others=>'0');
  --counter to divide clock
  constant env_granularity : unsigned(31 downto 0) := to_unsigned(100000, 32);

  type adsr_state is (adsr_idle, adsr_a, adsr_d, adsr_s, adsr_r);

  --these are signals for now, just placeholders
  --inputs could be providing these signals
  --signal note_velocity : std_logic_vector(6 downto 0);
  --signal attack_increment : std_logic_vector(31 downto 0);
  --signal decay_decrement : std_logic_vector(31 downto 0);
  --signal release_decrement : std_logic_vector(31 downto 0);
  --signal sustain_level : unsigned(6 downto 0);
begin

  gain_block: entity work.gain(modify)
    generic map(data_depth=>data_depth,
                gain_res=>8,
                gain_mode=>gain_mode_envelope)
    port map(data_in=>data_in,
             gain_in=>adsr_gain,
             data_out=>data_out);

  env_gen: process(clk, rst)
    variable env_state : adsr_state;
    variable env_counter : unsigned(31 downto 0);
    variable calculate_gain : signed(9 downto 0);
  begin

    if rst = '1' then
      env_state := adsr_idle;
      adsr_gain_s <= (others=>'0');
      --adsr_gain <= (others=>'0');
      env_counter := (others=>'0');
      calculate_gain := (others=>'0');
      releasing <= '0';
    elsif rising_edge(clk) then

      case env_state is

        when adsr_idle =>
          --whe idle there is no sound produced
          adsr_gain_s <= (others=>'0');
          if note_on = '1' then
            --transition to attack phase
            env_state := adsr_a;
          end if;
        when adsr_a =>
          --start ramping up volume
          if env_counter = env_granularity - 1 then
            --increase gain
            calculate_gain := adsr_gain_s + signed('0' & attack_i);
            if calculate_gain >= max_gain then
              adsr_gain_s <= max_gain;
              env_state := adsr_d;
            else
              adsr_gain_s <= adsr_gain_s + signed('0' & attack_i);
            end if;
            env_counter := (others=>'0');
          else
            env_counter := env_counter + 1;
          end if;
          --if maximum is reached, go to decay phase
          --is this correct? because different velocities
          --will imply in different attack times
        when adsr_d =>
          --decay phase
          if env_counter = env_granularity - 1 then
            --this can underflow, do properly
            calculate_gain := adsr_gain_s - signed('0' & decay_d);
            if calculate_gain <= signed('0' & sustain_l) then
              adsr_gain_s <= signed("00" & sustain_l);
              env_state := adsr_s;
            else
              adsr_gain_s <= adsr_gain_s - signed('0' & decay_d);
            end if;
            env_counter := (others=>'0');
          else
            env_counter := env_counter + 1;
          end if;
        when adsr_s =>
          --sustain
          if note_off = '1' then
            --go to release phase
            env_state := adsr_r;
            releasing <= '1';
          end if;
        when adsr_r =>
          --start ramping down volume
          if env_counter = env_granularity - 1 then
            calculate_gain := adsr_gain_s - signed('0' & release_d);
            if calculate_gain <= zero_gain then
              adsr_gain_s <= zero_gain;
              env_state := adsr_idle;
              releasing <= '0';
            else
              adsr_gain_s <= calculate_gain;
            end if;
            env_counter := (others=>'0');
          else
            env_counter := env_counter + 1;
          end if;
        when others=>
          null;

      end case;
    end if;
  end process;

  adsr_gain <= std_logic_vector(adsr_gain_s(7 downto 0));

end architecture;
